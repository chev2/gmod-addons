include("shared.lua")

hook.Add("HUDShouldDraw", "HideHL2HUD", function(name)
	for _, v in pairs{"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"} do
		if name == v then return false end
	end
end)

local TOGGLEHUD = true
local TOGGLECROSSHAIR = false
local TOGGLEDBHOP = true

hook.Add("HUDShouldDraw", "BhopToggleHUD", function(name)
	if name == "CHudGMod" then return TOGGLEHUD end
end)
hook.Add("HUDShouldDraw", "BhopToggleCrosshair", function(name)
	if name == "CHudCrosshair" then return TOGGLECROSSHAIR end
end)

hook.Add("OnPlayerChat", "BhopToggleCMDs", function(ply, text, team, isdead) //Toggle HUD, Crosshair & Autohop commands
	if ply != LocalPlayer() then return end
	if string.StartWith(text, "!hud") then
		TOGGLEHUD = !TOGGLEHUD
		return true
	end
	if string.StartWith(text, "!c") then
		TOGGLECROSSHAIR = !TOGGLECROSSHAIR
		return true
	end
	if string.StartWith(text, "!togglebhop") or string.StartWith(text, "!toggleautohop") then
		TOGGLEDBHOP = !TOGGLEDBHOP
		if TOGGLEDBHOP == true then
			chat.AddText(Color(137, 137, 137), "Autohop has been toggled ", Color(0, 255, 0), "ON", Color(137, 137, 137), ".")
		else
			chat.AddText(Color(137, 137, 137), "Autohop has been toggled ", Color(255, 0, 0), "OFF", Color(137, 137, 137), ".")
		end
		return true
	end
end)

function GM:StartCommand(ply, cmd)
	if bit.band(cmd:GetButtons(), IN_JUMP) ~= 0 and TOGGLEDBHOP == true then //Actual bunnyhop movement, credit to Jordan for making this script
		if !ply:IsOnGround() then
			cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
		end
	end
end
