/*--------------------------------------------------------------
	Editing system to allow server owners to add their own zones
--------------------------------------------------------------*/

if SERVER then AddCSLuaFile() return end

local IsEditingVectors = false
local EditorVector1 = Vector(0, 0, 0)
local EditorVector2 = Vector(0, 0, 0)

local function vecStr(vec)
	return "Vector("..table.concat(vec:ToTable(), ", ")..")"
end

concommand.Add("bhop_startvec", function()
	if !LocalPlayer():IsAdmin() then return end
	IsEditingVectors = true
	EditorVector1 = LocalPlayer():GetPos()
end)

concommand.Add("bhop_endvec", function() --
	if !LocalPlayer():IsAdmin() then return end
	IsEditingVectors = false
	EditorVector2 = LocalPlayer():GetPos()

	EditorVector1 = Vector(math.Round(EditorVector1.x), math.Round(EditorVector1.y), math.Round(EditorVector1.z)) --Round values
	EditorVector2 = Vector(math.Round(EditorVector2.x), math.Round(EditorVector2.y), math.Round(EditorVector2.z)) --Round values

	local generatedCode = table.concat({
		"bhopmaps.Add(\""..game.GetMap().."\", {\n",
		"\tStartLocation = {", vecStr(EditorVector1), ", ", vecStr(EditorVector2), "}, \n",
		"\tEndLocation = {", vecStr(EditorVector1), ", ", vecStr(EditorVector2), "}, \n",
		"})\n"
	}, "")

	SetClipboardText(generatedCode)

	MsgC(bhopColor2, "Generated code:\n", bhopColor1, generatedCode, bhopColor2,
		"This code has been copied to your clipboard.\n",
		"You will have to adjust the start and end location values manually.\n",
		"Put these values into ", bhopColor1, "gamemodes/chevbhop/gamemode/maps/<mapname>.lua!\n", bhopColor2,
		"You must put start zone AND end zone values into this file if you want timers to work!\n")
end)

hook.Add("PostDrawTranslucentRenderables", "DrawBunnyhopStartFinishZones", function() --draw zones
	if !IsEditingVectors then return end
	render.SetColorMaterial()
	render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), EditorVector1, LocalPlayer():GetPos(), PrimaryColor, true)
end)
