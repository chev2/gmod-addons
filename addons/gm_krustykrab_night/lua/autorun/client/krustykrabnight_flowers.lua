if not string.StartWith(game.GetMap(), "gm_krustykrab_night") then return end

local skyFlowerMat = Material("spongebob/meltyflower.png", "mips smooth")
skyFlowerMat:SetString("$alpha", "0.5")

local skyFlowerColor = Color(28, 101, 47)

local skyFlowerPosData = {
	{
		Pos = Vector(16, -12, 5),
		Dir = Vector(-1, 1, 0),
		Width = 4,
		Height = 4,
		Rot = 170
	},
	{
		Pos = Vector(0, -12, 5),
		Dir = Vector(0, 1, 0),
		Width = 5,
		Height = 5,
		Rot = 180
	},
	{
		Pos = Vector(-14, -13.5, 4.3),
		Dir = Vector(0.7, 0.67, -0.22),
		Width = 6,
		Height = 6,
		Rot = 185
	},
	{
		Pos = Vector(-12.2, 15.4, 3.5),
		Dir = Vector(0.61, -0.77, -0.18),
		Width = 4,
		Height = 3.5,
		Rot = 180
	},
	{
		Pos = Vector(7.7, 17.8, 4.8),
		Dir = Vector(-0.39, -0.89, -0.24),
		Width = 8,
		Height = 8,
		Rot = 185
	},
	{
		Pos = Vector(17.89, 6.52, 6.09),
		Dir = Vector(-0.89, -0.33, -0.3),
		Width = 3,
		Height = 3,
		Rot = 200
	},
	{
		Pos = Vector(17.93, 3.88, 7.96),
		Dir = Vector(-0.89, -0.19, -0.39),
		Width = 3,
		Height = 3,
		Rot = 180
	},
}

hook.Add("PostDrawSkyBox", "KrustyKrabNight_RenderSkyFlowers", function()
	render.OverrideDepthEnable(true, false)

	cam.Start3D(vector_origin)
		render.SetMaterial(skyFlowerMat)

		for _, tabData in ipairs(skyFlowerPosData) do
			render.DrawQuadEasy(tabData.Pos, tabData.Dir, tabData.Width, tabData.Height, skyFlowerColor, tabData.Rot)
		end

		--render.DrawQuadEasy(LocalPlayer():GetAimVector()*20, -LocalPlayer():GetAimVector(), 3, 3, skyFlowerColor, 170)
	cam.End3D()
	
	render.OverrideDepthEnable(false, false)
end)
