ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Gamer Girl Bath Water Thrown"

if SERVER then AddCSLuaFile() end

ENT.Model = Model("models/manndarinchik/ggbathwater.mdl")

local effectdata = EffectData()

local GlassBreakSounds =
{"physics/glass/glass_impact_bullet1.wav",
"physics/glass/glass_impact_bullet2.wav",
"physics/glass/glass_impact_bullet3.wav",
"physics/glass/glass_impact_bullet4.wav"}

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:PhysicsCollide(coldata, coll)
	effectdata:SetOrigin(coldata.HitPos)

	util.Effect("GlassImpact", effectdata)
	self:EmitSound(GlassBreakSounds[math.random(#GlassBreakSounds)], 60, 100, 1)

	SafeRemoveEntityDelayed(self, 0.01)
end
