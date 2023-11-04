include("spraymesh/sh_init.lua")

util.AddNetworkString("SprayMesh.SV_SendSpray")
util.AddNetworkString("SprayMesh.SV_ClearSpray")

-- Remove various HTML/JS characters from the URL
local function SanitizeURL(url)
    local ban = [=[{}[]:'",<>()]=]
    local bad = string.Explode("", ban, false)

    for k, v in pairs(bad) do
        url = string.Replace(url, v, "") -- Gsub uses patterns that conflict with the special characters
    end

    return url
end

-- Called when the player sprays something--their set URL will be sanitized and checked to ensure it's valid.
local function FixURL(url, ply)
    -- If the URL is nil, invalid data type or an empty string
    if url == nil or type(url) ~= "string" or url == "" then
        spraymesh.DebugPrint("URL is wrong type or is empty data!")

        url = spraymesh.SPRAY_URL_DEFAULT
    end

    -- If the URL contains bad/exploitable characters
    if url ~= SanitizeURL(url) then
        spraymesh.DebugPrint("URL is not equal to its sanitized counterpart!")

        url = spraymesh.SPRAY_URL_DEFAULT
    end

    -- Check to see if the spray is a valid image or video spray
    -- This is where the whitelisted domains/extensions for the spray is checked
    local allowed = false
    local sprayType = spraymesh.GetURLInfo(url)
    spraymesh.DebugPrint("FixURL spray type: " .. sprayType)
    if sprayType ~= SPRAYTYPE_INVALID then allowed = true end

    spraymesh.DebugPrint("FixURL allowed?: " .. tostring(allowed))

    if not allowed then
        spraymesh.DebugPrint("INVALID URL: " .. url)

        url = spraymesh.SPRAY_URL_DEFAULT
    end

    return url
end

function spraymesh.RemoveSpray(id64)
    if not spraymesh.SPRAYDATA[id64] then return end

    net.Start("SprayMesh.SV_ClearSpray")
        net.WriteString(id64)
        net.Broadcast()

    spraymesh.SPRAYDATA[id64] = nil
end

function spraymesh.SendSpray(hitpos, hitnormal, tracenormal, ply)
    if IsValid(ply) and ply.SteamID64 then
        local id64 = ply:SteamID64()
        local url = FixURL(ply:GetInfo("spraymesh_url"), ply)
        local sprayInfo = spraymesh.SPRAYDATA[id64] or {}

        sprayInfo.url = url
        sprayInfo.pos = hitpos
        sprayInfo.normal = hitnormal
        sprayInfo.TraceNormal = -tracenormal
        sprayInfo.PlayerName = ply:Nick()
        sprayInfo.Time = ply.LastSprayTime or CurTime()

        local coordDist = spraymesh.COORD_DIST_DEFAULT

        sprayInfo.CoordDistance = coordDist

        hook.Run("SprayMesh.OnSpraySent", ply, url, hitpos)

        spraymesh.DebugPrint("sending spray: " .. sprayInfo.url)

        net.Start("SprayMesh.SV_SendSpray")
            net.WriteString(id64)
            net.WriteString(sprayInfo.PlayerName)
            net.WriteVector(hitpos)
            net.WriteVector(hitnormal)
            net.WriteNormal(tracenormal)
            net.WriteString(url)
            net.WriteFloat(sprayInfo.CoordDistance)
            net.WriteFloat(sprayInfo.Time)
            net.Broadcast()

        spraymesh.SPRAYDATA[id64] = sprayInfo
    end
end

local PLAYER = FindMetaTable("Player")
local OldAllowImmediateDecalPainting = PLAYER.AllowImmediateDecalPainting

-- We need to adjust this metamethod to interface with SprayMesh.
function PLAYER:AllowImmediateDecalPainting(allow)
    local id64 = self:SteamID64()
    spraymesh.SPRAYDATA[id64] = spraymesh.SPRAYDATA[id64] or {}
    spraymesh.SPRAYDATA[id64].immediate = allow

    return OldAllowImmediateDecalPainting(self, allow)
end

-- The default, built-in spray gets overriden here
hook.Add("PlayerSpray", "SprayMesh.OverrideNativeSpray", function(ply)
    spraymesh.DebugPrint("playerspray")

    local id64 = ply:SteamID64()
    local sprayInfo = spraymesh.SPRAYDATA[id64] or {}

    -- The player must be alive, and the spray must not be on cooldown
    if (not sprayInfo.delay or sprayInfo.immediate) and ply:Alive() then
        -- Apply spray cooldown
        if not sprayInfo.immediate then
            sprayInfo.delay = true

            timer.Simple(spraymesh.SPRAY_COOLDOWN, function()
                if sprayInfo then
                    sprayInfo.delay = false
                end
            end)
        end

        -- Perform trace
        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + (ply:GetAimVector() * (4096 * 8)),
            filter = function(ent)
                if ent:IsWorld() then return true end
            end
        })

        -- No spraying on invisible walls
        if tr.HitTexture:lower() == "tools/toolsinvisible" then return true end

        ply.LastSprayTime = CurTime()

        -- The spray must hit the world
        local sprayHitValidSpot = tr.Hit and tr.Entity:IsWorld()

        -- Give other code a chance to block the spray
        local shouldAllowSpray = hook.Run("SprayMesh.ShouldAllowSpray", ply, tr) ~= false

        if sprayHitValidSpot and shouldAllowSpray then
            spraymesh.SendSpray(tr.HitPos, tr.HitNormal, tr.Normal, ply)
        end
    end

    spraymesh.SPRAYDATA[id64] = sprayInfo

    -- Disables regular sprays
    return true
end)

-- See https://wiki.facepunch.com/gmod/GM:PlayerInitialSpawn
-- for why this is needed.
local LOAD_QUEUE = {}

local function SendSpraysToClient(ply)
    for id64, data in pairs(spraymesh.SPRAYDATA) do
        if data.pos and data.normal then
            spraymesh.DebugPrint("- Sending spray: " .. data.url)

            net.Start("SprayMesh.SV_SendSpray")
                net.WriteString(id64)
                net.WriteString(data.PlayerName)
                net.WriteVector(data.pos)
                net.WriteVector(data.normal)
                net.WriteVector(data.TraceNormal)
                net.WriteString(data.url)
                net.WriteFloat(data.CoordDistance)
                net.WriteFloat(data.Time)
                net.Send(ply)
        else
            spraymesh.DebugPrint(("Invalid SprayMesh data found for %s, skipping..."):format(id64))
        end
    end
end

-- Send existing spraymesh sprays to joining players.
hook.Add("PlayerInitialSpawn", "SprayMesh.SendExistingSpraysToConnectedPlayer", function(ply)
    LOAD_QUEUE[ply] = true
end)

hook.Add("SetupMove", "SprayMesh.NetworkSpraysOnceReady", function(ply, mv, cmd)
    if LOAD_QUEUE[ply] and not cmd:IsForced() then
        LOAD_QUEUE[ply] = nil

        spraymesh.DebugPrint("Player " .. ply:Nick() .. " is ready to receive networking")
        SendSpraysToClient(ply)
    end
end)

-- Spraymesh chat command, using the provided prefixes
hook.Add("PlayerSay", "SprayMesh.OpenSprayMeshConfigurationMenu", function(ply, text, isTeam)
    for _, prefix in ipairs(spraymesh.CHAT_COMMAND_PREFIXES) do
        if string.StartsWith(text:lower(), prefix .. "spraymesh") then
            ply:ConCommand("spraymesh_settings")
            return ""
        end
    end
end)
