local function initialize_map_error_commands()
	local matable = {} --material table
	local matablelen = 0 --length of the material table
	local sndtable = {} --sound table
	local sndtablelen = 0 --length of the sound table
	local imat = Material --shortcut for Material
	local stext = FindMetaTable("IMaterial")["SetTexture"] --shortcut for IMaterial.SetTexture

	local surface_infos = game.GetWorld():GetBrushSurfaces() --array of SurfaceInfos
	local ref = {} --reference hash table
	local map_materials = {} --result table - array of IMaterial objects
	
	for k, v in ipairs(surface_infos) do --remove duplicate materials
		if v:IsWater() then continue end
		path = v:GetMaterial():GetString("$basetexture")
		if path and !ref[path] then
			map_materials[#map_materials + 1] = v:GetMaterial()
			ref[path] = true
		end
	end
	for k, v in ipairs(game.GetWorld():GetMaterials()) do --do worldspawn.GetMaterials to try to get displacement materials
		if v and !ref[v] then
			map_materials[#map_materials + 1] = imat(v)
			ref[v] = true
		end
	end

	MsgC(Color(0, 157, 255), "Found " .. #map_materials .. " map textures\n")

	local function get_fps() return GetConVar("fps_max"):GetInt() end

	local function init_random_locations()
		local tbr = table.remove
		local tbi = table.insert
		local ff = file.Find

		local rfile, rdir = ff("materials/*", "GAME")
		for k, v in pairs(rdir) do
			if v == "vgui" or v == "skybox" then
				tbr(rdir, k)
			end
		end

		for i=1, math.Round(#rdir/2, 0), 1 do --remove some folders, since looking through hundreds of folders is VERY performance-heavy
			tbr(rdir, math.random(1, #rdir))
		end

		for k, v in pairs(rdir) do --this function is expensive
			local rnfile = ff("materials/"..v.."/*.vtf", "GAME") --find vtf files
			for k, vn in pairs(rnfile) do
				rnfile[k] = v.."/"..rnfile[k]
				tbi(matable, rnfile[k])
			end
			coroutine.yield()
		end
		matablelen = #matable

		local rfile, rdir = ff("sound/*", "GAME")
		for i=1, math.Round(#rdir/1.5, 0), 1 do
			tbr(rdir, math.random(1, #rdir))
		end

		for k, v in pairs(rdir) do --this function is expensive too
			local rnfile = ff("sound/"..v.."/*.mp3", "GAME")
			for k, vn in pairs(rnfile) do
				rnfile[k] = v.."/"..rnfile[k]
				tbi(sndtable, rnfile[k])
			end

			coroutine.yield()

			local rnfilewav = ff("sound/"..v.."/*.wav", "GAME")
			for k, vn in pairs(rnfilewav) do
				rnfilewav[k] = v.."/"..rnfilewav[k]
				tbi(sndtable, rnfilewav[k])
			end

			coroutine.yield()
		end
		sndtablelen = #sndtable
	end

	local random_loc_co = coroutine.create(init_random_locations)
	coroutine.resume(random_loc_co)

	hook.Add("Think", "map_intitialize_random_locations_co", function()
		if coroutine.status(random_loc_co) == "dead" then
			hook.Remove("Think", "map_intitialize_random_locations_co")
			MsgC(Color(0, 157, 255), "Game textures have been successfully initialized\n")
			return
		end
		coroutine.resume(random_loc_co)
	end)

	concommand.Add("map_randomizetextures", function()
		MsgC(Color(0, 157, 255), "Randomizing map textures. You may experience some lag for a bit!\n")

		local co = coroutine.create(function() --create a coroutine to hopefully reduce the game freezing
			for k, v in pairs(map_materials) do
				stext(v, "$basetexture", matable[math.random(matablelen)]) --setting random textures is very laggy
				stext(v, "$basetexture2", matable[math.random(matablelen)]) --set basetexture2 for displacements
				coroutine.yield()
			end
	
			for k, ent in pairs(ents.GetAll()) do
				if ent == game.GetWorld() then continue end --don't affect the world materials, they already changed
				for k, v in pairs(ent:GetMaterials()) do
					stext(imat(v), "$basetexture", matable[math.random(matablelen)])
					coroutine.yield()
				end
			end
		end)

		timer.Create("map_randomizetextures_co", 2 / get_fps(), 0, function() --2 / max fps - try to run every 2 frames or so
			if coroutine.status(co) == "dead" then
				timer.Remove("map_randomizetextures_co")
				MsgC(Color(0, 157, 255), "Map textures have been successfully randomized\n")
				return
			end
			coroutine.resume(co)
		end)
	end)

	concommand.Add("map_erroreverything", function()
		for k, v in pairs(map_materials) do
			stext(v, "$basetexture", "")
			stext(v, "$basetexture2", "")
		end

		for k, ent in pairs(ents.GetAll()) do
			if ent == game.GetWorld() then continue end
			for k, v in pairs(ent:GetMaterials()) do
				stext(imat(v), "$basetexture", "")
			end
		end

		for k, ent in pairs(ents.FindByClass("prop_*")) do
			ent:SetModel("models/error.mdl")
			for k, v in pairs(ent:GetMaterials()) do
				stext(imat(v), "$basetexture", "models/weapons/v_slam/new light1")
			end
		end

		timer.Create("ErrorModels", 0.05, 0, function()
			for k, ent in pairs(ents.FindByClass("prop_*")) do
				ent:SetModel("models/error.mdl")
			end
		end)

		MsgC(Color(255, 0, 255), "Map textures are now missing.\n")
	end)

	concommand.Add("map_randomizesounds", function()
		hook.Add("EntityEmitSound", "ChevMapSoundRandomizer", function(t)
			t.SoundName = sndtable[math.random(sndtablelen)]
			t.Channel = CHAN_AUTO
			return true
		end)
		if game.SinglePlayer() then
			net.Start("EnableRandomSounds")
					net.SendToServer()
			net.Receive("SendRandomSound", function()
				local t = net.ReadTable()
				EmitSound(sndtable[math.random(sndtablelen)], (t.Pos or LocalPlayer():GetPos()), t.Entity:EntIndex(), t.Channel, t.Volume, t.SoundLevel, t.Flags, t.Pitch)
			end)
			MsgC(Color(0, 255, 255), "Map sounds are now randomized\n")
		else
			MsgC(Color(20, 255, 255), "Map sounds are now randomized, but only client-side sounds will be randomized, since you aren't in singleplayer\n")
		end
	end)
end

if CLIENT then hook.Add("InitPostEntity", "initialize_map_error_commands", initialize_map_error_commands) end

if SERVER and game.SinglePlayer() then
	util.AddNetworkString("EnableRandomSounds")
	util.AddNetworkString("SendRandomSound")
	net.Receive("EnableRandomSounds", function()
		hook.Add("EntityEmitSound", "RandomizeEntSoundsServer", function(t)
			if math.random(0, 10) > 3 then --lower random sound chance to prevent lag a little
				net.Start("SendRandomSound")
					net.WriteTable(t)
					net.Broadcast()
				return false
			end
		end)
	end)
end
