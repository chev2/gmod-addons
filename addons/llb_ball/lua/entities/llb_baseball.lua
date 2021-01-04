AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Lethal League Baseball"
ENT.Author = "Lua coding: Chev\nBaseball model: Team Reptile"
ENT.Purpose = "The baseball from LL/LLB. Hit it to make it go faster!"
ENT.Category = "Lethal League"

ENT.AutomaticFrameAdvance = true
ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.BallSize = 18
ENT.ServingPitch = false

ENT.BounceSound = Sound("llb/wall_bounce.ogg")
ENT.HitSound = Sound("llb/medium_hit.ogg")
ENT.StrongHitSound = Sound("llb/strong_hit.ogg")
ENT.KnockoutSound = Sound("llb/knockout.ogg")

ENT.BallOwner = nil

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "LockXAxis", {KeyName = "lockx", Edit = {type="Boolean", order=1}})
	self:NetworkVar("Bool", 1, "LockYAxis", {KeyName = "locky", Edit = {type="Boolean", order=2}})
	self:NetworkVar("Bool", 2, "LockZAxis", {KeyName = "lockz", Edit = {type="Boolean", order=3}})
	self:NetworkVar("Bool", 3, "DamagePlayers", {KeyName = "dmgply", Edit = {type="Boolean", order=4}})
end

function ENT:SpawnFunction(ply, tr, ClassName)
	if (!tr.Hit) then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * self.BallSize * 2)
	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	phys:SetVelocity(Vector(0, 0, 0))
	phys:SetAngles(Angle(0, 0, 0))
	phys:AddAngleVelocity(Vector(256, 0, 0))

	return ent
end

function ENT:Think()
	if CLIENT then return end
	local phys = self:GetPhysicsObject()
	local vel = self:GetVelocity()
	if !IsValid(phys) then return end

	vel.x = self:GetLockXAxis() and 0 or vel.x
	vel.y = self:GetLockYAxis() and 0 or vel.y
	vel.z = self:GetLockZAxis() and 0 or vel.z

	phys:SetVelocity(Vector(vel.x, vel.y, vel.z))
	self:NextThink(CurTime())
	return true
end

function ENT:Initialize()
	if CLIENT then
		//local matname = "LLBBaseball_"..math.Round(SysTime(), 2) * 100
		local matname = "LLBBaseball_"..self:EntIndex()

		self.BallMaterial = CreateMaterial(matname, "VertexLitGeneric", {
			["$basetexture"] = "models/llb/baseball/baseball",
			["$surfaceprop"] = "Rubber",

			["$selfillumtint"] = "[0 1 0]",
			["$selfillum"] = "1",
			["$selfillummask"] = "models/llb/baseball/baseball_i",

			["$phong"] = "1",
			["$phongboost"] = "0.2",
			["$phongexponent"] = "5",
			["$phongfresnelranges"] = "[0.2 0.8 0.1]",
			["$lightwarptexture"] = "models/llb/baseball/lightwarp",
			["$nocull"] = "1",

			["$rimlight"] = "1",
			["$rimlightexponent"] = "5",
			["$rimlightboost"] = "3",

			["$blendtintbybasealpha"] = "0",
			["$blendtintcoloroverbase"] = "0",

			["$model"] = "1"
		})
		self:SetMaterial("!"..matname)

		self.BallMaterial:SetVector("$selfillumtint", Vector(1, 0, 0))
	end

	hook.Add("RenderScreenspaceEffects", "LLBInvertColorsHit", function()
		if self.IsInverted then
			DrawColorModify({
				["$pp_colour_brightness"] = 0,
				["$pp_colour_contrast"] = 1,
				["$pp_colour_colour"] = -1,
				["$pp_colour_addr"] = 0.04
			})
		end
	end)

	if CLIENT then return end
	self:SetModel("models/llb/baseball.mdl")
	self:SetModelScale(0.55)
	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetTrigger(true)
	self.ServingPitch = true
	
	local size = self.BallSize / 2.1
	self:PhysicsInitSphere(size, "metal_bouncy")
	self:SetCollisionBounds(Vector(-size, -size, -size), Vector(size, size, size))

	self.BallTrail = util.SpriteTrail(self, 0, Color(255, 0, 0), false, 17, 17, 0.03, 1/17, "effects/beam_generic01")

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableGravity(false)
	end

	hook.Add("KeyPress", "LLBCheckPlayerHitBall", function(ply, key)
		if !IsValid(ply) or !IsValid(self) or !IsFirstTimePredicted then return end
		if key == IN_ATTACK and ply:GetPos():Distance(self:GetPos()) < 120 then --player will hit the ball if they're within 120 hammer units
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(ply)
			self:OnTakeDamage(dmginfo)
		end
	end)

	util.AddNetworkString("LLBDrawInvertedColors")
	util.AddNetworkString("LLBChangeBallColor")
end

net.Receive("LLBDrawInvertedColors", function()
	local ent = net.ReadEntity()
	local time = net.ReadFloat() 
	if !ent:IsDormant() then
		ent.IsInverted = true
		RunConsoleCommand("pp_texturize", "pp/texturize/invert.png")
		timer.Simple(time, function()
			ent.IsInverted = false
			RunConsoleCommand("pp_texturize", "")
		end)
	end
end)

net.Receive("LLBChangeBallColor", function()
	local ent = net.ReadEntity()
	local entowner = net.ReadEntity()
	ent.BallOwner = entowner
	ent.BallMaterial:SetVector("$selfillumtint", ent.BallOwner:GetPlayerColor())
end)

function ENT:OnRemove()
	if SERVER then
		hook.Remove("KeyPress", "LLBCheckPlayerHitBall")
	else
		hook.Remove("RenderScreenspaceEffects", "LLBInvertColorsHit")
	end
end

function ENT:PhysicsCollide(data, physobj)
	-- Play sound on bounce
	if data.DeltaTime > 0.02 then
		sound.Play(self.BounceSound, self:GetPos(), 80, 100, 1)
	end
end

function ENT:StartTouch(ent)
	local speed = self:GetVelocity():Length() ^ 0.8
	if ent:IsPlayer() and self.BallOwner != ent and speed > 16 then --damage a player if they touch the ball
		if !self:GetDamagePlayers() then return end
		local dmginf = DamageInfo()
		dmginf:SetDamage(speed/8)
		dmginf:SetDamageType(DMG_GENERIC)
		dmginf:SetAttacker(self)
		dmginf:SetInflictor(self)
		dmginf:SetDamageForce(Vector(0, 0, 1))
		ent:TakeDamageInfo(dmginf)

		util.ScreenShake(self:GetPos(), 2, 30, 0.5, 300)
		if ent:Health() > 0 then
			sound.Play("llb/takedmg_"..math.random(1, 4)..".ogg", self:GetPos(), 80, 100, 1)
		else
			local phys = self:GetPhysicsObject() --reset ball speed when a player dies
			phys:SetVelocity(Vector(0, 0, 0))
			phys:SetAngles(Angle(90, 0, 0))
			phys:AddAngleVelocity(-phys:GetAngleVelocity() + Vector(256, 0, 0))
			self.ServingPitch = true

			sound.Play(self.KnockoutSound, self:GetPos(), 80, 100, 1)
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	local phys = self:GetPhysicsObject()
	local newvel = self:GetVelocity()*1.5
	local speed = newvel:Length() ^ 0.8

	local att = dmginfo:GetAttacker()
	if att:IsPlayer() and att:Alive() then --set the ball owner and ball color on hit
		self.BallOwner = att
		local plycol = att:GetPlayerColor():ToColor()
		local newplycol = math.Round(plycol.r).." "..math.Round(plycol.g).." "..math.Round(plycol.b)
		self.BallTrail:Fire("Color", newplycol)
		net.Start("LLBChangeBallColor")
			net.WriteEntity(self)
			net.WriteEntity(self.BallOwner)
			net.Broadcast()
	end

	if att:IsPlayer() and !att:Alive() then return end
	local aimvec = att:GetAimVector()

	if self:GetVelocity() == Vector(0, 0, 0) and !self.ServingPitch then return end
	phys:EnableMotion(false)

	if speed > 1000 then --play different sounds based on ball speed
		net.Start("LLBDrawInvertedColors")
			net.WriteEntity(self)
			net.WriteFloat((math.Clamp(0.00205*speed, 0, 1.2)))
			net.Broadcast()
		sound.Play(self.StrongHitSound, self:GetPos(), 80, 100, 1)
		util.ScreenShake(self:GetPos(), 25, 4, 1.3, 300)
	elseif speed > 500 then
		sound.Play(self.StrongHitSound, self:GetPos(), 80, 100, 1)
		util.ScreenShake(self:GetPos(), 20, 4, 1.3, 300)
	else
		sound.Play(self.HitSound, self:GetPos(), 80, (speed*0.0295+100), 1)
		util.ScreenShake(self:GetPos(), 2, 4, 1, 300)
	end

	timer.Simple((math.Clamp(0.00205*speed, 0, 1.2)), function() --temporarily stop the ball after being hit.
		if !IsValid(self) then return end
		phys:EnableMotion(true)
		if self.ServingPitch then
			phys:SetVelocity(aimvec*50*3.4)
			self.ServingPitch = false
		else
			if speed == 0 then return end
			phys:SetVelocity(aimvec*speed*3.8) --may need some more testing
		end
		
		phys:AddAngleVelocity(Vector(-512, 0, 0))
	end)
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end