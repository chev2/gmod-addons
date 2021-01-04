AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("SendBhopZonesToClient")

function GM:PlayerCanPickupWeapon()
	return true
end

function GM:PlayerCanPickupItem()
	return true
end

function GM:PlayerSetModel(ply) //Sets a playermodel
	ply:SetModel("models/player/kleiner.mdl")
end

function GM:CanPlayerSuicide() //disable suicide
	return false
end

function GM:PlayerShouldTakeDamage() //Disables most forms of damage
	return false
end

function GM:GetFallDamage() //Disables fall damage
	return 0
end

function GM:InitPostEntity() //Commands to make bunnyhopping smoother, feel free to change them
	RunConsoleCommand("sv_airaccelerate", "400") //10 is the default, used to allow for sharper turns to gain speed
	RunConsoleCommand("sv_gravity", "600") //600 is the default, alows for gravity adjustment
	RunConsoleCommand("sv_maxvelocity", "10000") //3500 is the default, allows to change max player velocity
	RunConsoleCommand("sv_sticktoground", "0") //1 is the default, allows the bhop mechanic to go up slopes
end
