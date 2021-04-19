ENT.Type = "anim"
ENT.PrintName = "IED"
ENT.Author = ""
ENT.Contact	= ""
ENT.Purpose = ""
ENT.Instructions = ""

ENT.Spawnable = false
ENT.AdminOnly = true 
ENT.DoNotDuplicate = true 
ENT.DisableDuplicator = true

if SERVER then

AddCSLuaFile("shared.lua")

function ENT:Initialize()
	local soundtables = {["song02"] = 23.61, ["song03"] = 37.26, ["song04"] = 13.5, ["song05"] = 14.91, ["song06"] = 19.88}
	local rlength, rsound = table.Random(soundtables)

	self.MUSIC_VOLUME = 0.6

	self.NokiaMusic = CreateSound(self, "chev/arabicnokiaphone/"..rsound..".ogg")
	if self.NokiaMusic then
		self.NokiaMusic:PlayEx(self.MUSIC_VOLUME, 100)
		timer.Create("LoopNokiaSound", rlength, 0, function()
			if self.NokiaMusic then
				self.NokiaMusic:Stop()
				self.NokiaMusic:PlayEx(self.MUSIC_VOLUME, 100)
			end
		end)
	end

	self.CanTool = false

	self.Owner = self.Entity.Owner

	self.Entity:SetModel("models/props_junk/cardboard_box004a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self.Entity.Boom = false
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

 function ENT:Think()
	
	if not IsValid(self) then return end
	if not IsValid(self.Entity) then return end
	
	if self.Entity.Boom then
		self:Explosion()
	end
	
	self.Entity:NextThink(CurTime())
	return true
end

function ENT:Explosion()

	if not IsValid(self) then return end
	if not IsValid(self.Owner) then
		timer.Remove("LoopNokiaSound")
		self.NokiaMusic:Stop()
		self.Entity:Remove()
		return
	end
	
	local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetNormal(Vector(0,0,1))
		effectdata:SetEntity(self.Entity)
		effectdata:SetScale(1)
		effectdata:SetRadius(67)
		effectdata:SetMagnitude(18)
		util.Effect("arabicboom", effectdata)
		util.Effect("HelicopterMegaBomb", effectdata)
		util.Effect("ThumperDust", effectdata)
		
	util.BlastDamage(self.Entity, self.Owner, self.Entity:GetPos(), 500, 170)
	util.ScreenShake(self.Entity:GetPos(), 3000, 255, 2.25, 2000)
	
	self.Entity:EmitSound("ambient/explosions/explode_" .. math.random(1, 4) .. ".wav", 100, 100, 1, CHAN_AUTO)
	local scorchstart = self.Entity:GetPos() + ((Vector(0,0,1)) * 5)
	local scorchend = self.Entity:GetPos() + ((Vector(0,0,-1)) * 5)
	timer.Remove("LoopNokiaSound")
	self.NokiaMusic:Stop()
	self.Entity:Remove()
	util.Decal("Scorch", scorchstart, scorchend)
	
end

function ENT:OnTakeDamage( dmginfo )
		if (dmginfo:GetInflictor() != self.Entity) 
		and (dmginfo:GetInflictor():GetClass() != "chev_ied") then
			local GoodLuck = math.random(1,10)
			if GoodLuck == 1 then
				self:Explosion()
			end
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
end