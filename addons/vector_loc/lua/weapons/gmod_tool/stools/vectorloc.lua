TOOL.Name = "#tool.vectorloc.name"
TOOL.Category = "Chev\'s tools"
TOOL.AddToMenu = true

TOOL.Information = {
	{name = "left"},
	{name = "right"},
	{name = "reload"},
}

TOOL.ClientConVar["connectvec"] = "0"
TOOL.ClientConVar["connectline"] = "0"
TOOL.ClientConVar["primaryvec"] = "none"
TOOL.ClientConVar["secondaryvec"] = "none"
TOOL.ClientConVar["distance"] = "0"
TOOL.ClientConVar["vecsize"] = "1"
TOOL.ClientConVar["ignorez"] = "1"

local phitpos = Vector(0, 0, 0)
local shitpos = Vector(0, 0, 0)

if CLIENT then
	language.Add("tool.vectorloc.name", "Vector Locator")
	language.Add("tool.vectorloc.desc", "Used to locate or visualize vectors on a map.")
	language.Add("tool.vectorloc.left", "Set a primary vector at the cursor location.")
	language.Add("tool.vectorloc.right", "Set a secondary vector at the cursor location.")
	language.Add("tool.vectorloc.reload", "Reset both vectors.")
else
	util.AddNetworkString("SVtoCLStartHooks")
	util.AddNetworkString("SVtoCLRemoveHooks")
	hook.Add("PostPlayerDeath", "RemoveHooks", function(ply)
		if game.SinglePlayer() then
			net.Start("SVtoCLRemoveHooks")
				net.Send(ply)
		end
	end)
end

net.Receive("SVtoCLStartHooks", function()
	local self = LocalPlayer():GetActiveWeapon()
	self:Deploy()
end)
net.Receive("SVtoCLRemoveHooks", function()
	hook.Remove("PostDrawTranslucentRenderables", "VecToolPrimaryRender")
	hook.Remove("PostDrawTranslucentRenderables", "VecToolSecondaryRender")
	hook.Remove("PostDrawTranslucentRenderables", "VecToolConnectRender")
	hook.Remove("PostDrawTranslucentRenderables", "VecToolConnectLineRender")
end)

local function CalculateDistance()
	RunConsoleCommand("vectorloc_distance", math.Round(phitpos:Distance(shitpos), 1))
end

function TOOL:Deploy()
	if SERVER and game.SinglePlayer() then
		net.Start("SVtoCLStartHooks")
			net.Send(self:GetOwner())
	end
	if CLIENT and self:GetOwner():Alive() then
		hook.Add("PostDrawTranslucentRenderables", "VecToolPrimaryRender", function(depth, skybox)
			local pvec = Vector(self:GetClientInfo("primaryvec"))
			local vsize = self:GetClientNumber("vecsize", 1)
			render.DrawWireframeBox(pvec, Angle(0, 0, 0), Vector(-vsize, -vsize, -vsize), Vector(vsize, vsize, vsize), Color(255, 0, 0), !tobool(self:GetClientInfo("ignorez")))
		end)

		hook.Add("PostDrawTranslucentRenderables", "VecToolSecondaryRender", function(depth, skybox)
			local svec = Vector(self:GetClientInfo("secondaryvec"))
			local vsize = self:GetClientNumber("vecsize", 1)
			render.DrawWireframeBox(svec, Angle(0, 0, 0), Vector(-vsize, -vsize, -vsize), Vector(vsize, vsize, vsize), Color(0, 0, 255), !tobool(self:GetClientInfo("ignorez")))
		end)

		hook.Add("PostDrawTranslucentRenderables", "VecToolConnectRender", function(depth, skybox)
			if self:GetClientNumber("connectvec", 0) == 1 then
				local pvec = Vector(self:GetClientInfo("primaryvec"))
				local svec = Vector(self:GetClientInfo("secondaryvec"))
				local midvec = (pvec + svec)/2
				local piece1 = pvec - midvec
				local piece2 = svec - midvec
				render.DrawWireframeBox(midvec, Angle(0, 0, 0), piece1, piece2, Color(0, 255, 0), !tobool(self:GetClientInfo("ignorez")))
			end
		end)

		hook.Add("PostDrawTranslucentRenderables", "VecToolConnectLineRender", function(depth, skybox)
			if self:GetClientNumber("connectline", 0) == 1 then
				local pvec = Vector(self:GetClientInfo("primaryvec"))
				local svec = Vector(self:GetClientInfo("secondaryvec"))

				render.DrawLine(pvec, svec, Color(255, 255, 0), !tobool(self:GetClientInfo("ignorez")))
			end
		end)
	end

	return true
end

function TOOL:Holster()
	hook.Remove("PostDrawTranslucentRenderables", "VecToolPrimaryRender")
	hook.Remove("PostDrawTranslucentRenderables", "VecToolSecondaryRender")
	hook.Remove("PostDrawTranslucentRenderables", "VecToolConnectRender")
	hook.Remove("PostDrawTranslucentRenderables", "VecToolConnectLineRender")

	return true
end

function TOOL:LeftClick(primarytrace)
	if SERVER then
		if game.SinglePlayer() then
			self:Deploy()
		else
			return true
		end
	end

	phitpos = primarytrace.HitPos

	CalculateDistance()

	RunConsoleCommand("vectorloc_primaryvec", math.Round(phitpos.x).." "..math.Round(phitpos.y).." "..math.Round(phitpos.z))

	return true
end

function TOOL:RightClick(secondarytrace)
	if SERVER then
		if game.SinglePlayer() then
			self:Deploy()
		else
			return true
		end
	end

	shitpos = secondarytrace.HitPos

	CalculateDistance()

	RunConsoleCommand("vectorloc_secondaryvec", math.Round(shitpos.x).." "..math.Round(shitpos.y).." "..math.Round(shitpos.z))

	return true
end

function TOOL:Reload()
	if SERVER then
		if game.SinglePlayer() then
			self:Deploy()
		else
			return true
		end
	end
	RunConsoleCommand("vectorloc_primaryvec", "0 0 0")
	RunConsoleCommand("vectorloc_secondaryvec", "0 0 0")

	return true
end

function TOOL:DrawToolScreen(width, height)
	surface.SetDrawColor(Color(20, 20, 20))
	surface.DrawRect(0, 0, width, height)

	local onetable = string.Explode(" ", self:GetClientInfo("primaryvec"))
	local primaryvalue = table.concat(onetable, ", ")

	local twotable = string.Explode(" ", self:GetClientInfo("secondaryvec"))
	local secondaryvalue = table.concat(twotable, ", ")

	local curpos = tostring(LocalPlayer():GetEyeTrace().HitPos):gsub("%.[%d]+", ""):gsub("%s", ", ")

	draw.SimpleText("1st Vector:", "DermaLarge", 10, 25, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(primaryvalue, "DermaLarge", 10, 55, Color(150, 100, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("2nd Vector:", "DermaLarge", 10, 100, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(secondaryvalue, "DermaLarge", 10, 130, Color(100, 100, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("Looking at:", "DermaLarge", 10, 175, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(curpos, "DermaLarge", 10, 205, Color(100, 100, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("Distance: "..self:GetClientInfo("distance"), "DermaLarge", 10, 235, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function TOOL.BuildCPanel(CPanel)
	CPanel:Help("#tool.vectorloc.desc")
	CPanel:TextEntry("Primary Vector:", "vectorloc_primaryvec")
	CPanel:TextEntry("Secondary Vector:", "vectorloc_secondaryvec")
	CPanel:CheckBox("Vectors form a box?", "vectorloc_connectvec")
	CPanel:CheckBox("Vectors form a line?", "vectorloc_connectline")
	CPanel:CheckBox("Do the vectors ignore Z? (Render through walls)", "vectorloc_ignorez")
	CPanel:NumSlider("Vector point size:", "vectorloc_vecsize", 0, 24, 2)
end