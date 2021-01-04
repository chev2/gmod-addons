local propyellenabled = true

concommand.Add("propyelling_toggle", function(ply, cmd, args, str)
	propyellenabled = !propyellenabled
	if propyellenabled == true then
		MsgC(Color(200, 200, 200), "Prop yelling is now ", Color(0, 255, 0), "ON\n")
	elseif propyellenabled == false then
		MsgC(Color(200, 200, 200), "Prop yelling is now ", Color(255, 0, 0), "OFF\n")
	else end
end, function() end, "Toggles yelling noises emitted from props when they are spawned.")

local yellsound = {"vo/npc/male01/moan01.wav",
				"vo/npc/male01/moan02.wav",
				"vo/npc/male01/moan03.wav",
				"vo/npc/male01/moan04.wav",
				"vo/npc/male01/moan05.wav",
				"vo/npc/male01/myarm01.wav",
				"vo/npc/male01/myarm02.wav",
				"vo/npc/male01/myarm02.wav",
				"vo/npc/male01/myleg01.wav",
				"vo/npc/male01/myleg02.wav",
				"vo/npc/male01/pain01.wav",
				"vo/npc/male01/pain02.wav",
				"vo/npc/male01/pain03.wav",
				"vo/npc/male01/pain04.wav",
				"vo/npc/male01/pain05.wav",
				"vo/npc/male01/pain06.wav",
				"vo/npc/male01/pain07.wav",
				"vo/npc/male01/pain08.wav",
				"vo/npc/male01/pain09.wav",
				"vo/npc/male01/help01.wav",
				"vo/npc/male01/mygut02.wav",
				"vo/npc/female01/moan01.wav",
				"vo/npc/female01/moan02.wav",
				"vo/npc/female01/moan03.wav",
				"vo/npc/female01/moan04.wav",
				"vo/npc/female01/moan05.wav",
				"vo/npc/female01/myarm01.wav",
				"vo/npc/female01/myarm02.wav",
				"vo/npc/female01/myarm02.wav",
				"vo/npc/female01/myleg01.wav",
				"vo/npc/female01/myleg02.wav",
				"vo/npc/female01/pain01.wav",
				"vo/npc/female01/pain02.wav",
				"vo/npc/female01/pain03.wav",
				"vo/npc/female01/pain04.wav",
				"vo/npc/female01/pain05.wav",
				"vo/npc/female01/pain06.wav",
				"vo/npc/female01/pain07.wav",
				"vo/npc/female01/pain08.wav",
				"vo/npc/female01/pain09.wav",
				"vo/npc/female01/help01.wav",
				"vo/npc/female01/mygut02.wav"}

hook.Add("OnEntityCreated", "PropYelling", function(ent)
	if ent:GetClass() == "prop_physics" and ent:GetMoveType() != MOVETYPE_NONE and propyellenabled then
		EmitSound(yellsound[math.random(#yellsound)], ent:GetPos(), ent:EntIndex())
	end
end)
