AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- Internal size of the ball--do not touch this
ENT.BallSize = 18

-- If ball is being initially served or not
ENT.ServingPitch = false

util.AddNetworkString("llb_baseball.DrawInvertedColors")
util.AddNetworkString("llb_baseball.ChangeBallColor")
util.AddNetworkString("llb_baseball.ScreenShake")

local NEW_VEL_VECTOR = Vector()

function ENT:Initialize()
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

    local trailTexture = "trails/smoke"
    if IsMounted("tf") then trailTexture = "effects/beam_generic01" end
    self.BallTrail = util.SpriteTrail(self, 0, Color(255, 0, 0), false, 17, 17, 0.03, 1 / 17, trailTexture)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:EnableGravity(false)
    end

    hook.Add("KeyPress", self, function(ent, ply, key)
        if not IsValid(ply) or not IsValid(ent) or not IsFirstTimePredicted() then return end

        local plyPos = ply:GetPos()
        local entPos = ent:GetPos()

        -- The player will hit the ball if they're within 120 hammer units.
        -- They don't need to look directly at the ball
        if key == IN_ATTACK and plyPos:Distance(entPos) < 120 then
            local dmginfo = DamageInfo()
            dmginfo:SetAttacker(ply)
            ent:OnTakeDamage(dmginfo)
        end
    end)
end

function ENT:Think()
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end

    local vel = self:GetVelocity()
    vel.x = self:GetLockXAxis() and 0 or vel.x
    vel.y = self:GetLockYAxis() and 0 or vel.y
    vel.z = self:GetLockZAxis() and 0 or vel.z

    -- Use a preinitialized vector so we don't create a vector every frame
    NEW_VEL_VECTOR:SetUnpacked(vel.x, vel.y, vel.z)
    phys:SetVelocity(NEW_VEL_VECTOR)

    self:NextThink(CurTime())

    return true
end

function ENT:PhysicsCollide(data, physobj)
    -- Play sound and screen shake on bounce
    if data.DeltaTime > 0.02 then
        sound.Play(self.BounceSound, self:GetPos(), 80, 100, 1)

        self:ScreenShake(2, 4, 0.2, 1500)
    end
end

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end

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

function ENT:OnTakeDamage(dmginfo)
    -- Prevents multiple damage events from overlapping and causing issues
    if self.IsPaused then return end

    -- Attacker must be an alive player
    local att = dmginfo:GetAttacker()
    if not att:IsPlayer() or not att:Alive() then return end

    -- Ball needs valid physics, otherwise we can't temporarily freeze it
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end

    local newvel = self:GetVelocity() * 1.5
    local speed = newvel:Length() ^ 0.8

    -- Freeze the ball
    phys:EnableMotion(false)
    self.IsPaused = true

    -- Set new ball owner
    self.BallOwner = att

    -- Set the color of the ball trail
    local plycol = att:GetPlayerColor():ToColor()
    local newplycol = math.Round(plycol.r) .. " " .. math.Round(plycol.g) .. " " .. math.Round(plycol.b)
    self.BallTrail:Fire("Color", newplycol)

    -- Let clients know about the ball's new color
    net.Start("llb_baseball.ChangeBallColor")
        net.WriteEntity(self)
        net.WriteEntity(self.BallOwner)
        net.Broadcast()

    -- Fixes issues where velocity gets nulled out if ball is locked to an axis and player fires perpendicular to it
    local aimAng = att:GetAimVector():Angle()
    aimAng:Normalize()

    if self:GetLockXAxis() then
        aimAng.y = aimAng.y > 0 and 90 or -90
    end

    if self:GetLockYAxis() then
        aimAng.y = math.abs(aimAng.y) > 90 and 180 or 0
    end

    if self:GetLockZAxis() then
        aimAng.p = 0
    end

    local aimVecFixed = aimAng:Forward()

    local ballPauseTime = math.Clamp(0.00205 * speed, 0, 1.2)

    -- Play different sounds based on ball speed
    if speed > 1000 then
        -- Tell clients in PVS to invert their screen colors
        net.Start("llb_baseball.DrawInvertedColors")
            net.WriteEntity(self)
            net.WriteFloat(math.Clamp(0.00205 * speed, 0, 1.2))
            net.SendPVS(self:GetPos())

        sound.Play(self.StrongHitSound, self:GetPos(), 80, 100, 1)
        self:ScreenShake(25, 4, ballPauseTime, 300)
    elseif speed > 500 then
        sound.Play(self.StrongHitSound, self:GetPos(), 80, 100, 1)
        self:ScreenShake(20, 4, ballPauseTime, 300)
    else
        sound.Play(self.HitSound, self:GetPos(), 80, speed * 0.0295 + 100, 1)
        self:ScreenShake(2, 4, ballPauseTime, 300)
    end

    -- Lock the player until ball unfreezes.
    att:Lock()
    timer.Simple(ballPauseTime, function()
        if not IsValid(att) then return end

        att:UnLock()
    end)

    -- Unfreeze the ball after it was temporarily frozen.
    timer.Simple(ballPauseTime, function()
        if not IsValid(self) or not IsValid(phys) then return end
        self.IsPaused = false

        phys:EnableMotion(true)

        if self.ServingPitch then
            phys:SetVelocity(aimVecFixed * 50 * 3.4)

            self.ServingPitch = false
        else
            if speed == 0 then return end

            -- *May need some more testing
            phys:SetVelocity(aimVecFixed * speed * 3.8)
        end

        phys:AddAngleVelocity(Vector(-512, 0, 0))
    end)
end

function ENT:StartTouch(ent)
    local speed = self:GetVelocity():Length() ^ 0.8
    -- Damage a player if they touch the ball
    if ent:IsPlayer() and self.BallOwner != ent and speed > 16 then
        if not self:GetDamagePlayers() then return end
        local dmginf = DamageInfo()
        dmginf:SetDamage(speed / 8)
        dmginf:SetDamageType(DMG_GENERIC)
        dmginf:SetAttacker(self)
        dmginf:SetInflictor(self)
        dmginf:SetDamageForce(Vector(0, 0, 1))
        ent:TakeDamageInfo(dmginf)

        self:ScreenShake(2, 30, 0.5, 300)

        -- If player is still alive after taking damage
        if ent:Health() > 0 then
            sound.Play("llb/takedmg_" .. math.random(1, 4) .. ".ogg", self:GetPos(), 80, 100, 1)
        -- Reset ball speed when a player dies
        else
            local phys = self:GetPhysicsObject()
            phys:SetVelocity(Vector(0, 0, 0))
            phys:SetAngles(Angle(90, 0, 0))
            phys:AddAngleVelocity(-phys:GetAngleVelocity() + Vector(256, 0, 0))

            self.ServingPitch = true

            sound.Play(self.KnockoutSound, self:GetPos(), 80, 100, 1)
        end
    end
end

function ENT:ScreenShake(amplitude, frequency, duration, radius)
    --util.ScreenShake(self:GetPos(), amplitude, frequency, duration, radius, true)

    -- New AirShake parameter only works on clientside at the moment, so we have to network it
    net.Start("llb_baseball.ScreenShake")
        net.WriteVector(self:GetPos())
        net.WriteUInt(amplitude, 8)
        net.WriteUInt(frequency, 8)
        net.WriteFloat(duration)
        net.WriteFloat(radius)
        net.SendPVS(self:GetPos())
end
