if SERVER then
	net.Receive("bhop_setscore", function(len, ply)
		local newScore = net.ReadFloat()
		local entryName = "SimpleBunnyhopScore_"..game.GetMap()
		local curScore = ply:GetPData(entryName)

		if (curScore != nil and tonumber(curScore) > newScore) or curScore == nil then -- if the new score has a lower clear time than the current one
			ply:SetPData(entryName, newScore)

			local tab_str = ""

			if curScore != nil then
				tab_str = util.TableToJSON({bhopColor1, "New record! ", bhopColor2, "Old time: ", bhopColor1, AccurateTime(curScore), 
					bhopColor2, ". New time: ", bhopColor1, AccurateTime(newScore), bhopColor2, ". Difference: ",
					bhopColor1, AccurateTime(curScore - newScore), bhopColor2, "."})
			else
				tab_str = util.TableToJSON({bhopColor1, "New record! ", bhopColor2, "New time: ", bhopColor1, AccurateTime(newScore),
					bhopColor2, "."})
			end

			local tab_str_c = util.Compress(tab_str)

			net.Start("bhop_addtext")
				net.WriteData(tab_str_c, #tab_str_c)
				net.Send(ply)
		end
	end)

	AddCSLuaFile()
	return
end

if !bhopmaps.MapIsValid(game.GetMap()) then
	hook.Add("InitPostEntity", "NotifyMissingTimerConfig", function()
		chat.AddText(Color(255, 100, 0), "[Simple Bunny Hop] No timer configuration has been found for this map. Timers and scores cannot be used.")
	end)
	return
end

local mapLocations = bhopmaps.GetLocations(game.GetMap())

local StartVector1 = mapLocations.StartLocation[1] or Vector(0, 0, 0)
local StartVector2 = mapLocations.StartLocation[2] or Vector(0, 0, 0)

local EndVector1 = mapLocations.EndLocation[1] or Vector(0, 0, 0)
local EndVector2 = mapLocations.EndLocation[2] or Vector(0, 0, 0)

local timerCurTime = 0
local timerIsFinished = true
local playerSpeed = 0

local HUDPadding = 8
local fontSize = 28
local BackBoxHeight = fontSize * 2 + HUDPadding + 6
local BackBoxWidth = ScrW() * 0.11 + HUDPadding

local blurMaterial = Material("pp/blurscreen")
local v1Blur = 1 - (BackBoxHeight / ScrH())
local u1Blur = BackBoxWidth / ScrW()

hook.Add("PostDrawOpaqueRenderables", "DrawBunnyhopStartFinishZones", function() --draw zones
	render.SetColorMaterial()
	render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), StartVector1, StartVector2, Color(0, 255, 0), true)
	render.DrawWireframeBox(Vector(0, 0, 0), Angle(0, 0, 0), EndVector1, EndVector2, Color(255, 0, 0), true)
end)

hook.Add("Think", "BunnyhopTimerLogic", function() --timer logic
	if !timerIsFinished then --if the timer is not finished (the player hasn't reached the end)
		timerCurTime = timerCurTime + FrameTime()
	end

	if LocalPlayer():InStartZone() then
		timerIsFinished = false
		timerCurTime = 0
	elseif LocalPlayer():InEndZone() and !timerIsFinished then
		timerIsFinished = true
		chat.AddText(bhopColor2, "Run finished - time: ", bhopColor1, tostring(AccurateTime(timerCurTime)), 
			bhopColor2, ". Finish speed: ", bhopColor1, tostring(playerSpeed), bhopColor2,
			" u/sec. (Type ", bhopColor1, "!r", bhopColor2, " to reset)")

		net.Start("bhop_setscore")
			net.WriteFloat(timerCurTime)
			net.SendToServer()
	end
end)

local plyMeta = FindMetaTable("Player")

function plyMeta:InStartZone()
	return self:GetPos():WithinAABox(StartVector1, StartVector2)
end

function plyMeta:InEndZone()
	return self:GetPos():WithinAABox(EndVector1, EndVector2)
end

surface.CreateFont("BhopFontDefault", {
	font = "Bahnschrift",
	extended = false,
	size = fontSize,
	antialias = true,
})

function GM:HUDPaint()
	playerSpeed = math.floor(LocalPlayer():GetVelocity():Length2D())

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(blurMaterial)

	for i = 1, 3 do
		blurMaterial:SetFloat("$blur", (i / 20) * 30)
		blurMaterial:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRectUV(0, ScrH()-BackBoxHeight, BackBoxWidth, BackBoxHeight, 0, v1Blur, u1Blur, 1) --blur effect
	end

	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(0, ScrH()-BackBoxHeight, BackBoxWidth, BackBoxHeight)
	
	draw.TextShadow({ --time text
		text = "Time: "..AccurateTime(timerCurTime),
		font = "BhopFontDefault",
		pos = {HUDPadding,  ScrH()-28-HUDPadding}, --28 is the font height
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_BOTTOM,
		color = Color(200, 200, 200, 255)
	}, 2, 200)
	draw.TextShadow({ --speed text
		text = "Speed: "..playerSpeed.." u/sec",
		font = "BhopFontDefault",
		pos = {HUDPadding, ScrH()-HUDPadding},
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_BOTTOM,
		color = Color(200, 200, 200, 255)
	}, 2, 200) --speed text w/ shadow
end
