if !string.StartWith(game.GetMap(), "gm_krustykrab_night") then return end

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
