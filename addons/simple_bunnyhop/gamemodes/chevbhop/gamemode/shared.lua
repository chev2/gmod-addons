GM.Name = "Simple Bunnyhop"
GM.Author = "Chev [STEAM_1:0:71541002]"
GM.Email = "N/A"
GM.Website = "N/A"

local modulefiles = file.Find("gamemodes/chevbhop/gamemode/modules/*.lua", "GAME")
for k, v in pairs(modulefiles) do AddCSLuaFile("modules/"..v) include("modules/"..v) end

local mapfiles = file.Find("gamemodes/chevbhop/gamemode/maps/*.lua", "GAME") -- read all map files from maps/
for k, v in pairs(mapfiles) do AddCSLuaFile("maps/"..v) include("maps/"..v) end

include("timersystem/timerzones.lua")
include("timersystem/timercreator.lua")

bhopColor1 = Color(255, 255, 255)
bhopColor2 = Color(120, 120, 120)

function AccurateTime(seconds) --nicer time format
	if isstring(seconds) then seconds = tonumber(seconds) end -- string to number
	if !seconds then seconds = 0 end
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor(seconds / 60)
	local millisecs = (seconds - math.floor(seconds)) * 1000
	seconds = math.floor(seconds % 60)

	return string.format("%i:%02i:%03i", minutes, seconds, millisecs)
end

function GM:Initialize()
	if SERVER then
		hook.Add("PlayerSay", "BhopResetPosition", function(ply, text, team) -- Respawn chat command
			if string.StartWith(text, "!r") then
				ply:Spawn()
			end
		end)

		hook.Add("PlayerSay", "BhopGetScore", function(ply, text, team) -- Score chat command
			if string.StartWith(text, "!score") then
				local score = ply:GetPData("SimpleBunnyhopScore_"..game.GetMap())
				if score != nil then
					local dat = util.Compress(util.TableToJSON({bhopColor1, ply:Nick(), bhopColor2, "\'s record for ", bhopColor1, game.GetMap(),
						bhopColor2, ": ", bhopColor1, AccurateTime(score), bhopColor2, "."}))

					net.Start("bhop_addtext")
						net.WriteData(dat, #dat)
						net.Broadcast()
				else
					local dat = util.Compress(util.TableToJSON({bhopColor1, ply:Nick(), bhopColor2, " does not have a record set for ", bhopColor1, 
						game.GetMap(), bhopColor2, "."}))

					net.Start("bhop_addtext")
						net.WriteData(dat, #dat)
						net.Send(ply)
				end
			end
		end)
	end
end

function GM:PlayerNoClip(ply)
	if GetConVar("sv_cheats"):GetInt() > 0 or game.SinglePlayer() or ply:IsAdmin() then return true end
	return false
end

function GM:PlayerInitialSpawn(ply)
	ply:SetJumpPower(240)
	ply:SetNoCollideWithTeammates(true)
end

hook.Add("PreGamemodeLoaded", "DisableWidgets", function() -- disable widgets to save on performance
	function widgets.PlayerTick() end
	hook.Remove("PlayerTick", "TickWidgets")
end)

if SERVER then
	util.AddNetworkString("bhop_setscore")
	util.AddNetworkString("bhop_addtext")
else
	net.Receive("bhop_addtext", function(len)
		local dat = net.ReadData(len)
		local dat_d = util.Decompress(dat)
		local tab = util.JSONToTable(dat_d)

		chat.AddText(unpack(tab))
	end)
end
