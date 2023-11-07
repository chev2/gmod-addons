-- Include shared Lua files
include("spraymesh/sh_init.lua")

-- Include clientside Lua files (usually dependencies before we run the main script here)
include("spraymesh/client/cl_spray_list_db.lua")
include("spraymesh/client/cl_derma_utils.lua")
include("spraymesh/client/cl_sandbox_context_menu.lua")

--
-- Create ConVars
--
local CVAR_ENABLE_SPRAYS = CreateClientConVar("spraymesh_enablesprays", "1", true, false, "Whether or not to show all player sprays.", 0, 1)
local CVAR_ENABLE_ANIMATED_SPRAYS = CreateClientConVar("spraymesh_enableanimated", "1", true, false, "Whether or not to show animated sprays.", 0, 1)
CreateClientConVar("spraymesh_url", spraymesh.SPRAY_URL_DEFAULT, true, true, "The URL to use for your spray.")

--
-- Clientside variables and such
--

-- Used by the client to render sprays in order
-- Done so sprays can be "overwritten", and also for performance
spraymesh.RENDER_ITER_CLIENT = spraymesh.RENDER_ITER_CLIENT or {}

setmetatable(spraymesh.SPRAYDATA, {
    -- Reset render iteration table cache when the main spraymesh table is modified
    __newindex = function(tb, key, value)
        rawset(tb, key, value)

        spraymesh.RENDER_ITER_CLIENT = nil
    end,
})

-- Whether or not we're currently rendering names over player sprays (via spraymesh_shownames)
local SPRAY_SHOWING_NAMES = false

-- Sprays that need to be reloaded will be put in here
local SPRAY_RELOAD_QUEUE = {}

function spraymesh.ReloadSprays()
    spraymesh.RemoveSprays()

    for id64, data in pairs(spraymesh.SPRAYDATA) do
        SPRAY_RELOAD_QUEUE[id64] = data
    end
end

function spraymesh.ReloadSpray(id64)
    if not spraymesh.SPRAYDATA[id64] then return end

    SPRAY_RELOAD_QUEUE[id64] = spraymesh.SPRAYDATA[id64]
end

function spraymesh.RemoveSpray(id64)
    if not spraymesh.SPRAYDATA[id64] then return end

    local meshData = spraymesh.SPRAYDATA[id64].meshdata
    if meshData and meshData.mesh and IsValid(meshData.mesh) then
        meshData.mesh:Destroy()
        meshData.mesh = nil
    end

    spraymesh.SPRAYDATA[id64] = nil
end

function spraymesh.Instructions()
    chat.AddText(
        spraymesh.PRIMARY_CHAT_COLOR, "This server uses ",
        spraymesh.ACCENT_CHAT_COLOR, "SprayMesh Extended! ",
        spraymesh.PRIMARY_CHAT_COLOR, "Use /spraymesh to change your spray."
    )
end

-- URL material solver
local imats = {}

-- Where panels are during loading
local htmlpanels = {}

-- Where panels are for animation, after loading
local htmlpanelsanim = {}

local RT_SPRAY_PENDING = GetRenderTargetEx(
    "spraymesh_pending_spray",
    spraymesh.IMAGE_RESOLUTION,
    spraymesh.IMAGE_RESOLUTION,
    RT_SIZE_DEFAULT,
    MATERIAL_RT_DEPTH_SEPARATE,
    bit.bor(4, 8, 16, 256),
    0,
    IMAGE_FORMAT_BGR888
)

local MAT_SPRAY_PENDING = CreateMaterial("spraymesh/pending_spray_placeholder", "UnlitGeneric", {
    ["$basetexture"] = RT_SPRAY_PENDING:GetName(),

    -- Allows custom coloring
    ["$vertexcolor"] = 1,
    ["$vertexalpha"] = 1,
    ["$model"] = 1,
    ["$nocull"] = 1,
    ["$receiveflashlight"] = 1
})

local RT_SPRAY_DISABLEDVIDEO = GetRenderTargetEx(
    "spraymesh_disabled_video",
    spraymesh.IMAGE_RESOLUTION,
    spraymesh.IMAGE_RESOLUTION,
    RT_SIZE_DEFAULT,
    MATERIAL_RT_DEPTH_SEPARATE,
    bit.bor(4, 8, 16, 256),
    0,
    IMAGE_FORMAT_BGR888
)

local RT_SPRAY_DISABLEDSPRAY = GetRenderTargetEx(
    "spraymesh_disabled_spray",
    spraymesh.IMAGE_RESOLUTION,
    spraymesh.IMAGE_RESOLUTION,
    RT_SIZE_DEFAULT,
    MATERIAL_RT_DEPTH_SEPARATE,
    bit.bor(4, 8, 16, 256),
    0,
    IMAGE_FORMAT_BGR888
)

-- "url" is the URL with ?uniquerequest= stuff added at the end and https:// added to the front
-- "urloriginal" is simply the original URL
local function generateHTMLPanel(url, urloriginal, callback)
    if not string.find(url, "^https?://", 0, false) then
        url = "https://" .. url
    end

    spraymesh.DebugPrint("Generating HTML panel: ", url)

    -- Use spray image resolution from config
    local size = spraymesh.IMAGE_RESOLUTION

    -- Persisting container, for cutting short anims but also drawing an overlay
    local panelContainer = {}

    local panelHTML = vgui.Create("DHTML")
    panelHTML:SetSize(size, size)
    panelHTML:SetAllowLua(false)
    panelHTML:SetAlpha(0)
    panelHTML:SetMouseInputEnabled(false)
    panelHTML:SetScrollbars(false)
    panelHTML.ConsoleMessage = function(panel, msg)
        spraymesh.DebugPrint("HTML ConsoleMessage: " .. tostring(msg))
    end

    panelContainer.panel = panelHTML

    -- Set image/video HTML for the panel
    spraymesh.HTMLHandlers.Get(url, size, panelContainer)
    panelContainer.origurl = urloriginal
    panelContainer.callback = callback

    panelContainer.IsAnimated = (spraymesh.GetURLInfo(urloriginal) == SPRAYTYPE_VIDEO or string.EndsWith(urloriginal, ".gif"))

    panelContainer.RT = GetRenderTargetEx(
        "SprayMesh_URL_" .. util.SHA256(url),
        size,
        size,
        RT_SIZE_DEFAULT,
        MATERIAL_RT_DEPTH_SEPARATE,
        bit.bor(4, 8, 16, 256),
        0,
        IMAGE_FORMAT_BGRA8888
    )

    function panelContainer:PaintSpray()
        if not self.FinalMaterial then return end

        -- If sprays aren't enabled AT ALL
        if not CVAR_ENABLE_SPRAYS:GetBool() then
            self.FinalMaterial:SetTexture("$basetexture", RT_SPRAY_DISABLEDSPRAY)
            return
        end

        -- If animated sprays aren't enabled
        if self.IsAnimated and not CVAR_ENABLE_ANIMATED_SPRAYS:GetBool() then
            self.FinalMaterial:SetTexture("$basetexture", RT_SPRAY_DISABLEDVIDEO)
            return
        end

        -- If spraymesh_shownames was called, show a black background
        if SPRAY_SHOWING_NAMES then
            -- This makes the spray invisible/black for animkilled sprays...
            self.FinalMaterial:SetTexture("$basetexture", self.RT)
        else
            -- FPS saver when not showing names
            self.FinalMaterial:SetTexture("$basetexture", self.htmlmat:GetName())
            return
        end

        render.PushRenderTarget(self.RT)
            cam.Start2D()
                local sW, sH = ScrW(), ScrH()

                local spraytex = surface.GetTextureID(self.htmlmat:GetName())
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetTexture(spraytex)
                surface.DrawTexturedRect(0, 0, sW, sH)

                if SPRAY_SHOWING_NAMES then
                    local count = 1

                    for id64, data in pairs(spraymesh.SPRAYDATA) do
                        -- * This is stupid and inefficient, but it only runs when spraymesh_shownames is called,
                        -- * in which case, good FPS probably isn't important at that very moment
                        if data.url == urloriginal then
                            surface.SetDrawColor(0, 255, 0, 255)
                            surface.DrawOutlinedRect(0, 0, sW, sH, 3)

                            local text = ("%s (%s)"):format(data.PlayerName, id64)
                            draw.WordBox(4, 10, (32 * count) - 22, text, "TargetID", color_black, color_white)

                            count = count + 1
                        end
                    end

                    draw.WordBox(4, 10, sH - 38, urloriginal, "TargetID", color_black, color_white)
                end
            cam.End2D()
        render.PopRenderTarget()
    end

    table.insert(htmlpanels, panelContainer)
end

local function generateHTMLTexture(url, meshData, callback)
    --[[
        how to use:
        MyNewImaterial = generateHTMLTexture(url, meshData, function(imat)
            -- custom callback code, for when the image is fully loaded and the meshData has been applied
            -- imat argument is the loaded imaterial
        end)
        meshData is a table pointer, and needs to contain an imaterial key
    ]]
    spraymesh.DebugPrint("Generating HTML material for " .. url)

    -- If the IMaterial doesn't exist yet, initialize it
    if imats[url] == nil then
        -- Pending table
        imats[url] = {}
        table.insert(imats[url], {meshData, callback})

        -- The uniquerequest guff is to stop the game from ever using its internal cache of web resources, because it returns bonkers sizes at random
        local newURL = url .. "?uniquerequest=" .. math.floor(SysTime() * 1000)

        generateHTMLPanel(newURL, url, function(imat)
            -- Should be
            if type(imats[url]) == "table" then
                for k, v in pairs(imats[url]) do
                    local meshDataCurrent = v[1]
                    local optionalCallback = v[2]

                    meshDataCurrent.imaterial = imat

                    if optionalCallback then
                        optionalCallback(imat)
                    end

                    spraymesh.DebugPrint("Finished generating HTML material; replacing dummy texture")
                end

                imats[url] = imat
            end
        end)

        spraymesh.DebugPrint("Generating, giving dummy texture")

        return MAT_SPRAY_PENDING
    elseif type(imats[url]) == "table" then
        -- Pending table; texture is still generating
        spraymesh.DebugPrint("Generated texture is currently pending...")

        table.insert(imats[url], {meshData, callback})

        return MAT_SPRAY_PENDING
    else
        spraymesh.DebugPrint("Generated texture already exists")

        return imats[url]
    end
end

local function copyVert(copy, u, v, norm, bnorm, tang)
    u = u or 0
    v = v or 0
    norm = norm or 1
    bnorm = bnorm or Vector(0, 0, 0)
    tang = tang or 1
    local t = table.Copy(copy)
    t.u, t.v, t.normal, t.bitnormal, t.tangent = u, v, norm, bnorm, tang

    return t
end

-- D C = ix+0,iy+1 ix+1,iy+1
-- A B = ix+0,iy+0 ix+1,iy+0
-- Bottom left corner coord
local function addSquareToPoints(x, y, points, coords)
    --[[local _a = copyVert(coords[x+0][y+0],0,0) -- Repeating texture per square
    local _b = copyVert(coords[x+1][y+0],1,0) -- Probably also needs a y flip
    local _c = copyVert(coords[x+1][y+1],1,1)
    local _d = copyVert(coords[x+0][y+1],0,1)]]
    local rm1 = spraymesh.MESH_RESOLUTION - 1
    local __a = coords[x + 0][y + 0]
    local __b = coords[x + 1][y + 0]
    local __c = coords[x + 1][y + 1]
    local __d = coords[x + 0][y + 1]

    if __a.bad then
        __a = coords[x + 0][math.Clamp(y + 1, 0, spraymesh.MESH_RESOLUTION - 1)]
    end

    if __b.bad then
        __b = coords[x + 1][math.Clamp(y + 1, 0, spraymesh.MESH_RESOLUTION - 1)]
    end

    if __c.bad then
        __c = coords[x + 1][math.Clamp(y + 0, 0, spraymesh.MESH_RESOLUTION - 1)]
    end

    if __d.bad then
        __d = coords[x + 0][math.Clamp(y + 0, 0, spraymesh.MESH_RESOLUTION - 1)]
    end

    -- Probably could simply replace the other but eh
    if __a.bad then
        __a = coords[math.Clamp(x + 1, 0, spraymesh.MESH_RESOLUTION - 1)][math.Clamp(y + 1, 0, spraymesh.MESH_RESOLUTION - 1)]
    end

    if __b.bad then
        __b = coords[math.Clamp(x + 0, 0, spraymesh.MESH_RESOLUTION - 1)][math.Clamp(y + 1, 0, spraymesh.MESH_RESOLUTION - 1)]
    end

    if __c.bad then
        __c = coords[math.Clamp(x + 0, 0, spraymesh.MESH_RESOLUTION - 1)][math.Clamp(y + 0, 0, spraymesh.MESH_RESOLUTION - 1)]
    end

    if __d.bad then
        __d = coords[math.Clamp(x + 1, 0, spraymesh.MESH_RESOLUTION - 1)][math.Clamp(y + 0, 0, spraymesh.MESH_RESOLUTION - 1)]
    end

    local _a = copyVert(__a, (x + 0) / rm1, 1 - ((y + 0) / rm1)) -- Stretch texture over all squares
    local _b = copyVert(__b, (x + 1) / rm1, 1 - ((y + 0) / rm1))
    local _c = copyVert(__c, (x + 1) / rm1, 1 - ((y + 1) / rm1))
    local _d = copyVert(__d, (x + 0) / rm1, 1 - ((y + 1) / rm1))
    table.insert(points, _a) -- Adccba
    table.insert(points, _d)
    table.insert(points, _c)
    table.insert(points, _c)
    table.insert(points, _b)
    table.insert(points, _a)
end

function spraymesh.PlaceSpray(sprayData)
    local id64 = sprayData.SteamID64
    local nick = sprayData.PlayerName
    local hitpos = sprayData.HitPos
    local hitnormal = sprayData.HitNormal
    local url = sprayData.URL
    local playSpraySound = sprayData.PlaySpraySound
    local coordDist = sprayData.CoordDistance
    local sprayTime = sprayData.SprayTime

    local tracenormal = sprayData.TraceNormal
    local anglenormal = tracenormal:Angle()
    anglenormal:Normalize()

    local URLToSpray = url
    local lpid64 = LocalPlayer():SteamID64()

    -- Give other code a chance to block the spray on the client
    local shouldAllowSpray = hook.Run("SprayMesh.ClientShouldAllowSpray", sprayData) ~= false
    if not shouldAllowSpray then return end

    -- If the local player is spraying the default spray, show them help instructions in chat
    local sprayIsDefault = url == spraymesh.SPRAY_URL_DEFAULT
    sprayIsDefault = sprayIsDefault or url == "http://" .. spraymesh.SPRAY_URL_DEFAULT
    sprayIsDefault = sprayIsDefault or url == "https://" .. spraymesh.SPRAY_URL_DEFAULT

    if id64 == lpid64 and sprayIsDefault then
        spraymesh.Instructions()
    end

    -- Play the spray sound
    if playSpraySound then sound.Play("SprayCan.Paint", hitpos, 60, 100, .3) end

    --
    -- Create spray mesh
    --

    -- Benchmark how long it takes to create the spray mesh
    local timestart = SysTime()

    local pos = hitpos + hitnormal -- One unit out
    local points = {}
    local coords = {}

    --
    -- Calculate spray angle
    --
    local tangang = hitnormal:Angle()
    tangang:Normalize()

    -- Note to anyone who reads this:
    -- I pretty much just fiddled with random values and equations until I got it right.
    -- If you're a math person and can understand it, great.
    local angToRotateBy = 0
    if tangang.p < 0 then
        angToRotateBy = 180 + (anglenormal - tangang).y
    elseif tangang.p > 0 then
        angToRotateBy = 180 + (tangang - anglenormal).y
    end

    tangang:RotateAroundAxis(tangang:Forward(), angToRotateBy)

    --
    -- Calculate spray's mesh coordinates
    --
    coordDist = coordDist or spraymesh.COORD_DIST_DEFAULT

    -- Sizing formula to keep the spray the same size (roughly) when mesh resolution changes
    coordDist = coordDist * (1 / spraymesh.MESH_RESOLUTION) * 30

    for ix = 0, spraymesh.MESH_RESOLUTION - 1 do
        coords[ix] = {}

        for iy = 0, spraymesh.MESH_RESOLUTION - 1 do
            coords[ix][iy] = {}

            local coord = coords[ix][iy]

            --local yawMultiplier = math.abs(tangang.p) / 180
            --tangang.y = math.Remap(yawMultiplier, 0, 1, anglenormal.y, tangang.p)

            coord.pos = pos + (-(tangang:Right() * ix) + (tangang:Up() * iy)) * coordDist
            coord.pos = coord.pos + (tangang:Right() * coordDist * spraymesh.MESH_RESOLUTION / 2) - (tangang:Up() * coordDist * spraymesh.MESH_RESOLUTION / 1.8)

            if not (ix == 0 and iy == 0) then
                local testtr = util.TraceLine({
                    start = coord.pos + hitnormal * 16,
                    endpos = coord.pos - hitnormal * 16,
                    filter = function(ent)
                        if ent:IsWorld() then return true end
                    end
                })

                if not testtr.Hit or not testtr.HitWorld then
                    if ix == 0 then
                        coord.pos = coords[ix][iy - 1].pos
                    else
                        coord.pos = coords[ix - 1][iy].pos
                    end

                    coord.bad = true
                else
                    coord.pos = testtr.HitPos + hitnormal
                end
            end

            coord.u, coord.v = 0, 0
            coord.bitnormal = 1
            coord.tangent = 1
            coord.normal = hitnormal

            --
            -- Calculate vertex color
            --
            local lcol = render.ComputeLighting(coord.pos, hitnormal) + render.GetAmbientLightColor()
            lcol = lcol * 255

            local baseBrightness = 60

            local finalCol = Color(255, 255, 255)
            finalCol.r = math.min(lcol.x + baseBrightness, 255)
            finalCol.g = math.min(lcol.y + baseBrightness, 255)
            finalCol.b = math.min(lcol.z + baseBrightness, 255)

            coord.color = finalCol
        end
    end

    for ix = 0, spraymesh.MESH_RESOLUTION - 2 do
        for iy = 0, spraymesh.MESH_RESOLUTION - 2 do
            addSquareToPoints(ix, iy, points, coords)
        end
    end

    -- Create the actual mesh for the spray
    local meshdata = {}
    meshdata.mesh = Mesh()
    meshdata.mesh:BuildFromTriangles(points)
    meshdata.imaterial = generateHTMLTexture(URLToSpray, meshdata)

    -- Remove the existing spray, if any
    spraymesh.RemoveSpray(id64)

    -- Put together new spray info table
    local sprayInfo = spraymesh.SPRAYDATA[id64] or {}
    sprayInfo.meshdata = meshdata
    sprayInfo.meshdata.url = URLToSpray
    sprayInfo.hitpos = hitpos
    sprayInfo.hitnormal = hitnormal
    sprayInfo.TraceNormal = tracenormal
    sprayInfo.url = url
    sprayInfo.PlayerName = nick
    sprayInfo.CoordDistance = coordDist
    sprayInfo.Time = sprayTime or CurTime()

    spraymesh.SPRAYDATA[id64] = sprayInfo

    spraymesh.DebugPrint("Spray mesh created in: " .. SysTime() - timestart .. "s")
end

-- Removes all fully loaded sprays
function spraymesh.RemoveSprays()
    for k, v in pairs(htmlpanelsanim) do
        imats[v.origurl] = nil
        v.panel:Remove()
    end

    for k, v in pairs(spraymesh.SPRAYDATA) do
        if v.meshdata and v.meshdata.mesh then
            v.meshdata.mesh:Destroy()
            v.meshdata.mesh = nil
        end
    end

    htmlpanelsanim = {}
end

--
-- HTML handlers
--
-- This is the HTML that prepares the spray to be displayed
--

spraymesh.HTMLHandlers = {}

function spraymesh.HTMLHandlers.Get(url, size, panelcontainer)
    -- Remove uniquerequest garbage
    url = string.Explode("?", url, false)[1]

    -- Needs redoing for the extension
    local sprayType = spraymesh.GetURLInfo(url)

    if sprayType == SPRAYTYPE_IMAGE then
        spraymesh.DebugPrint("Using HTMLHandlers.Image for URL: " .. url)
        return spraymesh.HTMLHandlers.Image(url, size, panelcontainer)
    elseif sprayType == SPRAYTYPE_VIDEO then
        spraymesh.DebugPrint("Using HTMLHandlers.Video for URL: " .. url)
        return spraymesh.HTMLHandlers.Video(url, size, panelcontainer)
    end

    spraymesh.DebugPrint("Using (FALLBACK) HTMLHandlers.Image for URL: " .. url)

    return spraymesh.HTMLHandlers.Image(url, size, panelcontainer)
end

local SPRAY_HTML_IMAGE = [=[
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>title</title>
        <style type = "text/css">
            html {
                overflow: hidden;
            }

            body {
                margin: 0;
                background: transparent;
            }

            img {
                width: 100%;
                height: 100%;

                position: absolute;
                top: 0px;
                bottom: 0px;
                left: 0px;
                right: 0px;

                object-fit: contain;
            }
        </style>
    </head>
    <body>
        <div id="sprayimage"></div>
        <script>
            // Thanks to http://www.andygup.net/tag/magic-number/
            var imageContainer = document.getElementById("sprayimage");

            function getImageType(arrayBuffer) {
                var type = "";
                var dv = new DataView(arrayBuffer, 0, 5);
                var nume1 = dv.getUint8(0);
                var nume2 = dv.getUint8(1);
                var hex = nume1.toString(16) + nume2.toString(16);

                switch (hex) {
                    case "8950":
                        type = "image/png";
                        break;
                    case "4749":
                        type = "image/gif";
                        break;
                    case "424d":
                        type = "image/bmp";
                        break;
                    case "ffd8":
                        type = "image/jpeg";
                        break;
                    default:
                        type = "application/octet-stream";
                        break;
                }
                return type;
            }

            function getImageFromServer(path, callback) {
                var xhr = new XMLHttpRequest();

                xhr.open("GET", path, true);
                xhr.responseType = "arraybuffer";
                xhr.onload = function (e) {
                    if (this.status == 200) {
                        var imageType = getImageType(this.response);
                        callback(imageType);
                    }
                    else {
                        //console.log("Problem retrieving image " + JSON.stringify(e))
                        callback("NIL");
                    }
                }

                xhr.send();
            }

            function makeimage() {
                var src = "{SPRAY_URL}";
                getImageFromServer(src, function (imageType) {
                    console.log("Image Type: " + imageType);

                    // Anti-GIF
                    // TODO: Do GIF files still drain FPS on current-day Garry's Mod?
                    // It might not even be necessary to limit them nowadays
                    /*if (imageType == "image/gif") {
                        src = "https://{SPRAY_URL_ANTIGIF}";
                    }*/

                    var sprayImage = document.createElement("img");
                    sprayImage.src = src;

                    console.log(src);

                    // Check to ensure image container is valid before appending our img element
                    if (!!imageContainer) {
                        imageContainer.appendChild(sprayImage);
                    }
                });
            };

            makeimage();
        </script>
    </body>
</html>
]=]

function spraymesh.HTMLHandlers.Image(url, size, panelcontainer)
    local sprayHTML = SPRAY_HTML_IMAGE
    sprayHTML = sprayHTML:Replace("{SPRAY_URL}", string.JavascriptSafe(url))
    sprayHTML = sprayHTML:Replace("{SIZE}", string.JavascriptSafe(size))
    --sprayHTML = sprayHTML:Replace("{SPRAY_URL_ANTIGIF}", string.JavascriptSafe(spraymesh.SPRAY_URL_ANTIGIF))

    panelcontainer.panel:SetHTML(sprayHTML)
end

local SPRAY_HTML_VIDEO = [=[
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <style>
            html {
                overflow: hidden;
            }

            body {
                margin: 0;
                background: transparent;
            }

            video {
                width: 100%;
                height: 100%;

                position: absolute;
                top: 0px;
                bottom: 0px;
                left: 0px;
                right: 0px;

                object-fit: contain;
            }
        </style>
    </head>
    <body>
        <video id="sprayimage" onload="fiximage()" src="{SPRAY_URL}" autoplay loop muted>
        <script>
            function fiximage() {
                var videoElem = document.getElementById("sprayimage");
                if (!!videoElem && videoElem.height > videoElem.width) {
                    videoElem.style.height = "{SIZE}px";
                    videoElem.style.width = "auto";
                }
            };
        </script>
    </body>
</html>
]=]

function spraymesh.HTMLHandlers.Video(url, size, panelcontainer)
    local sprayHTML = SPRAY_HTML_VIDEO
    sprayHTML = sprayHTML:Replace("{SPRAY_URL}", string.JavascriptSafe(url))
    sprayHTML = sprayHTML:Replace("{SIZE}", string.JavascriptSafe(size))

    panelcontainer.panel:SetHTML(sprayHTML)
end

--
-- Network handlers
--

-- Received when the server wants to place a player's spray
net.Receive("SprayMesh.SV_SendSpray", function(length)
    local id64 = net.ReadString()
    local nick = net.ReadString()
    local hitPos = net.ReadVector()
    local hitNormal = net.ReadVector()
    local traceNormal = net.ReadNormal()
    local url = net.ReadString()
    local coordDist = net.ReadFloat()
    local sprayTime = net.ReadFloat()

    spraymesh.DebugPrint("Receiving spray: " .. url)

    local sprayData = {
        SteamID64 = id64,
        PlayerName = nick,
        HitPos = hitPos,
        HitNormal = hitNormal,
        TraceNormal = traceNormal,
        URL = url,
        CoordDistance = coordDist,
        SprayTime = sprayTime,
        PlaySpraySound = true
    }

    spraymesh.PlaceSpray(sprayData)
end)

-- Received when the server wants to remove a player's spray
net.Receive("SprayMesh.SV_ClearSpray", function()
    local id64 = net.ReadString()
    spraymesh.RemoveSpray(id64)
end)

--
-- Hooks
--

hook.Add("Think", "SprayMesh.Generate", function()
    for k, v in pairs(htmlpanels) do
        local htmlmat = v.panel:GetHTMLMaterial()

        if v and htmlmat then
            spraymesh.DebugPrint("FINISHED")

            local uid = string.Replace(htmlmat:GetName(), "__vgui_texture_", "")

            spraymesh.DebugPrint("Material name: spraymesh_" .. uid)
            local FinalMaterial = CreateMaterial("spraymesh_" .. uid, "UnlitGeneric", {
                ["$basetexture"] = htmlmat:GetName(),
                ["$vertexcolor"] = 1,
                ["$vertexalpha"] = 1,
                ["$model"] = 1,
                ["$nocull"] = 1,
                ["$receiveflashlight"] = 1
            })

            v.callback(FinalMaterial)

            table.remove(htmlpanels, k)
            table.insert(htmlpanelsanim, v)

            v.FinalMaterial = FinalMaterial
            v.htmlmat = htmlmat

            break
        else
            spraymesh.DebugPrint("GENERATING...")
        end
    end
end)

-- Ensures animated sprays are still animating properly (e.g. IMaterial is still valid)
hook.Add("Think", "SprayMesh.HandleAnimatedSprays", function()
    for index, panelData in ipairs(htmlpanelsanim) do
        if panelData then
            if panelData.origurl then
                if imats[panelData.origurl] == nil then
                    panelData.panel:Remove()
                    panelData = nil
                    table.remove(htmlpanelsanim, index)
                    break
                end
            else
                table.remove(htmlpanelsanim, index)
                break
            end
        else
            table.remove(htmlpanelsanim, index)
            break
        end
    end
end)

hook.Add("PostDrawHUD", "SprayMesh.AnimatedSpraysPaint", function()
    for k, panelData in ipairs(htmlpanelsanim) do
        if not panelData then
            table.remove(htmlpanelsanim, k)
            break
        end

        if panelData.PaintSpray then
            panelData:PaintSpray()
        end
    end
end)

hook.Add("PostDrawHUD", "SprayMesh.GenerateSprayPlaceholderTextures", function()
    render.PushRenderTarget(RT_SPRAY_PENDING)
        render.Clear(0, 0, 0, 255, true, true)

        cam.Start2D()
            draw.SimpleText("Loading spray...", "DermaLarge", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End2D()
    render.PopRenderTarget()

    render.PushRenderTarget(RT_SPRAY_DISABLEDVIDEO)
        render.Clear(0, 0, 0, 255, true, true)

        cam.Start2D()
            surface.SetDrawColor(255, 0, 0, 255)
            surface.DrawOutlinedRect(0, 0, ScrW(), ScrH(), 3)

            draw.SimpleText("This spray is animated, but you have animated sprays turned off.", "DermaDefaultBold", ScrW() / 2, ScrH() / 2 - 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Use /spraymesh to enable animated sprays.", "DermaDefaultBold", ScrW() / 2, ScrH() / 2 + 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End2D()
    render.PopRenderTarget()

    render.PushRenderTarget(RT_SPRAY_DISABLEDSPRAY)
        render.Clear(0, 0, 0, 255, true, true)

        cam.Start2D()
            surface.SetDrawColor(255, 255, 0, 255)
            surface.DrawOutlinedRect(0, 0, ScrW(), ScrH(), 3)

            draw.SimpleText("[sprays are disabled]", "DermaLarge", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End2D()
    render.PopRenderTarget()

    hook.Remove("PostDrawHUD", "SprayMesh.GenerateSprayPlaceholderTextures")
end)

-- Draw meshes for all player sprays
hook.Add("PostDrawTranslucentRenderables", "SprayMesh.DrawSprays", function(isDrawingDepth, isDrawingSkybox, isDrawing3DSkybox)
    if isDrawingDepth then return end

    -- If render order doesn't exist yet, rebuild it
    if not spraymesh.RENDER_ITER_CLIENT then
        spraymesh.RENDER_ITER_CLIENT = {}

        local i = 1
        for id64, sprayData in SortedPairsByMemberValue(spraymesh.SPRAYDATA, "Time") do
            spraymesh.RENDER_ITER_CLIENT[i] = sprayData.meshdata

            i = i + 1
        end
    end

    -- Render all sprays
    for _, meshData in ipairs(spraymesh.RENDER_ITER_CLIENT) do
        local meshToDraw = meshData.mesh

        if meshData and meshToDraw and IsValid(meshToDraw) then
            render.SetMaterial(meshData.imaterial)
            meshToDraw:Draw()
        end
    end
end)

-- Coroutine function; used to reload sprays with spraymesh_reload
local function cycleReloadSprays()
    local id64, data = next(SPRAY_RELOAD_QUEUE)
    if not id64 then return end

    print(("Reloading spray for %s (%s) at %s"):format(id64, data.PlayerName, data.hitpos))

    local sprayData = {
        SteamID64 = id64,
        PlayerName = data.PlayerName,
        HitPos = data.hitpos,
        HitNormal = data.hitnormal,
        TraceNormal = data.TraceNormal,
        URL = data.url,
        CoordDistance = data.CoordDistance,
        SprayTime = data.Time,
        PlaySpraySound = false
    }

    spraymesh.PlaceSpray(sprayData)

    SPRAY_RELOAD_QUEUE[id64] = nil

    coroutine.yield()
end

local sprayThread = nil
hook.Add("Think", "SprayMesh.ManageSprayReloadCoroutine", function()
    if (not sprayThread or not coroutine.resume(sprayThread)) and next(SPRAY_RELOAD_QUEUE) then
        sprayThread = coroutine.create(cycleReloadSprays)

        coroutine.resume(sprayThread)
    end
end)

--
-- Console commands
--

concommand.Add("spraymesh_reload", function()
    spraymesh.ReloadSprays()
end)

spraymesh.SETTINGS_PANEL = nil
concommand.Add("spraymesh_settings", function()
    if IsValid(spraymesh.SETTINGS_PANEL) then spraymesh.SETTINGS_PANEL:Remove() end
    spraymesh.SETTINGS_PANEL = vgui.Create("DSprayConfiguration")
end)

local VIEWER_PANEL = nil
concommand.Add("spraymesh_viewer", function()
    if IsValid(VIEWER_PANEL) then VIEWER_PANEL:Close() end
    VIEWER_PANEL = vgui.Create("DSprayViewer")
end)

local HELP_PANEL = nil
concommand.Add("spraymesh_help", function()
    if IsValid(HELP_PANEL) then HELP_PANEL:Close() end
    HELP_PANEL = vgui.Create("DSprayHelp")
end)

concommand.Add("spraymesh_shownames", function(ply, cmd, args, argstr)
    local t = CurTime()
    SPRAY_SHOWING_NAMES_TIME = CurTime()

    SPRAY_SHOWING_NAMES = true

    timer.Simple(10, function()
        -- Easy way to allow overlapping commands
        if t == SPRAY_SHOWING_NAMES_TIME then
            SPRAY_SHOWING_NAMES = false
        end
    end)

    -- Print data to console
    for id64, data in pairs(spraymesh.SPRAYDATA) do
        local plyStr = ([[%s (%s)]]):format(data.PlayerName, id64)

        local URLStr = "No URL"

        if data.meshdata and data.meshdata.url then
            URLStr = data.meshdata.url
        end

        print(([[%s %s]]):format(plyStr, URLStr))
    end
end)

if spraymesh.DEBUG_MODE then
    concommand.Add("spraymesh_debug_place", function()
        local tr = LocalPlayer():GetEyeTrace()

        local sprayData = {
            SteamID64 = "DEBUG_" .. util.SHA1(CurTime()),
            PlayerName = "Debug Spray " .. CurTime(),
            HitPos = tr.HitPos,
            HitNormal = tr.HitNormal,
            TraceNormal = tr.Normal,
            URL = spraymesh.SPRAY_URL_DEFAULT,
            CoordDistance = spraymesh.COORD_DIST_DEFAULT,
            SprayTime = CurTime(),
            PlaySpraySound = true
        }

        spraymesh.PlaceSpray(sprayData)
    end)
end
