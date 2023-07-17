DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Lethal League Baseball"
ENT.Author = "Lua coding & model port: Chev\nBaseball model: Team Reptile"
ENT.Purpose = "The baseball from LL/LLB. Hit it to make it go faster!"
ENT.Category = "Lethal League"

ENT.AutomaticFrameAdvance = true
ENT.Editable = true
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.BounceSound = Sound("llb/wall_bounce.ogg")
ENT.HitSound = Sound("llb/medium_hit.ogg")
ENT.StrongHitSound = Sound("llb/strong_hit.ogg")
ENT.KnockoutSound = Sound("llb/knockout.ogg")

ENT.BallOwner = nil

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "LockXAxis", {KeyName = "lockx", Edit = {type = "Boolean", order = 1}})
    self:NetworkVar("Bool", 1, "LockYAxis", {KeyName = "locky", Edit = {type = "Boolean", order = 2}})
    self:NetworkVar("Bool", 2, "LockZAxis", {KeyName = "lockz", Edit = {type = "Boolean", order = 3}})
    self:NetworkVar("Bool", 3, "DamagePlayers", {KeyName = "dmgply", Edit = {type = "Boolean", order = 4}})
end
