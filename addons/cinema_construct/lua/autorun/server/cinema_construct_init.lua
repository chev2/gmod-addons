--[[----------------------------------------------------------------------------
 lua script to spawn door models in gamemodes that doesn't support theater_door
----------------------------------------------------------------------------]]--
if game.GetMap() ~= "cinema_construct" then return end

hook.Add("InitPostEntity", "cinema_construct.InitDoorsForNonCinemaGamemodes", function()
	-- If gamemode folder contains 'cinema', assume the server is running a Cinema-derived gamemode, and abort
	-- We'll assume the gamemode handles theater_door already
	local gmFolder = GAMEMODE.FolderName
	if string.find(string.lower(gmFolder), "cinema") then
		print("[cinema_construct] Gamemode '" .. gmFolder .. "' is assumed to be a Cinema-based gamemode; We won't apply theater_door entity patch.")
		return
	end

	print("[cinema_construct] Spawning theater_door entities for non-Cinema-based gamemode...")

	local DOOR_MODEL = Model("models/sunabouzu/theater_door02.mdl")

	local DOOR_POSITIONS = {
		Vector(1680, -1600, -144), 
		Vector(1736, -1600, 1136), --backrooms
		Vector(-2816, -2448, 256),
		Vector(-2816, -2448, 768),
		Vector(-2816, -2448, 1280),
		Vector(-2816, -2448, 1792), --building elevator up
		Vector(-1792, -2448, 768),
		Vector(-1792, -2448, 1280),
		Vector(-1792, -2448, 1792),
		Vector(-1792, -2448, 2304) --building elevator down
	}

	local DOOR_ANGLES = {
		Angle(0, 180, 0),
		Angle(0, 180, 0), --backrooms
		Angle(0, 0, 0),
		Angle(0, 0, 0),
		Angle(0, 0, 0),
		Angle(0, 0, 0), --building elevator up
		Angle(0, 180, 0),
		Angle(0, 180, 0),
		Angle(0, 180, 0),
		Angle(0, 180, 0) --building elevator down
	}

	local function CreateCinemaConstructDoors()
		for i = 1, #DOOR_POSITIONS, 1 do
			local doorent = ents.Create("prop_dynamic")
			if not IsValid(doorent) then return end

			doorent:SetModel(DOOR_MODEL)
			doorent:SetPos(DOOR_POSITIONS[i])
			doorent:SetAngles(DOOR_ANGLES[i])
			doorent:PhysicsInit(SOLID_VPHYSICS)
			doorent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
			doorent:DrawShadow(false)
			doorent:Spawn()
			
			local phys = doorent:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
		end
	end

	CreateCinemaConstructDoors()

	hook.Add("PostCleanupMap", "CreateCinemaConstructDoorsCleanup", function()
		CreateCinemaConstructDoors()
	end)
end)
