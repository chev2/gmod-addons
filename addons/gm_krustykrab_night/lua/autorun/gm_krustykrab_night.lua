if !string.StartWith(game.GetMap(), "gm_krustykrab_night") then return end

if SERVER then
	local lightswitchsnd = Sound("buttons/lightswitch2.wav")
	local phoneringsnd = Sound("gm_krustykrab_night/telephone.ogg")

	local timers = {}

	function InitializeKrustyKrabEvent()
		if KKrabEventBlocked then return end
		KKrabEventBlocked = true

		for i=1, math.random(20, 30), 1 do --flickering lights
			table.insert(timers, i*math.Rand(0.9, 1.1))
			table.sort(timers, function(a, b) --we do this to make the modulo state work
				return a < b
			end)
		end

		for k, v in pairs(timers) do
			timer.Simple(v, function()
				local state_sprite = (k % 2 == 0) and "Show" or "Hide" --flip the switch between on and off state
				local state_light = (k % 2 == 0) and "On" or "Off"

				for ek, ev in pairs(ents.FindByName("kkrab_upperlights")) do --get all light ents
					if k == #timers then --if we're on the final timer, turn the lights on
						ev:Fire(ev:GetClass() == "env_sprite" and "ShowSprite" or "TurnOn")
					else
						ev:Fire(ev:GetClass() == "env_sprite" and state_sprite.."Sprite" or "Turn"..state_light)	
					end
				end

				sound.Play(lightswitchsnd, Vector(1964, 173, 0), 60, 100, 1)
			end)
		end

		timer.Simple(timers[#timers] + 5, function() --5 seconds after flickering lights, ring the phone
			sound.Play(phoneringsnd, Vector(2000, 172, 55), 70, 100, 1)

			timer.Simple(30, function() --30 seconds after phone rang, show bus
				local e = ents.Create("slasherbus")
				e:Spawn()

				timer.Simple(15, function()
					KKrabEventBlocked = false --the player can start the event again
				end)
			end)
		end)
	end
end

if CLIENT then
	local skyflower = Material("spongebob/meltyflower.png", "mips smooth")
	skyflower:SetString("$alpha", "0.5")

	local skyflowercol = Color(28, 101, 47)

	hook.Add("PostDrawSkyBox", "KrustyKrabNight_RenderSkyFlowers", function()
		if !IsValid(LocalPlayer()) then return end

		render.OverrideDepthEnable(true, false)
		cam.Start3D(Vector(0, 0, 0))
			render.SetMaterial(skyflower)
			render.DrawQuadEasy(Vector(16, -12, 5), Vector(-1, 1, 0), 4, 4, skyflowercol, 170)
			render.DrawQuadEasy(Vector(0, -12, 5), Vector(0, 1, 0), 5, 5, skyflowercol, 180)
			render.DrawQuadEasy(Vector(-14, -13.5, 4.3), Vector(0.7, 0.67, -0.22), 6, 6, skyflowercol, 185)
			render.DrawQuadEasy(Vector(-12.2, 15.4, 3.5), Vector(0.61, -0.77, -0.18), 4, 3.5, skyflowercol, 180)
			render.DrawQuadEasy(Vector(7.7, 17.8, 4.8), Vector(-0.39, -0.89, -0.24), 8, 8, skyflowercol, 185)
			render.DrawQuadEasy(Vector(17.89, 6.52, 6.09), Vector(-0.89, -0.33, -0.3), 3, 3, skyflowercol, 200)
			render.DrawQuadEasy(Vector(17.93, 3.88, 7.96), Vector(-0.89, -0.19, -0.39), 3, 3, skyflowercol, 170)
			//render.DrawQuadEasy(LocalPlayer():GetAimVector()*20, -LocalPlayer():GetAimVector(), 3, 3, skyflowercol, 170)
		cam.End3D()
		render.OverrideDepthEnable(false, false)
	end)
end