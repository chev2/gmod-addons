SWEP.PrintName = "Flying Nimbus"
SWEP.Purpose = "A flying nimbus. Use it to move around!"
SWEP.Base = "weapon_base"
SWEP.Slot = 0
SWEP.SlotPos = 3
SWEP.Category = "Dragon Ball"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.WorldModel = ""
SWEP.ViewModel = ""

SWEP.DrawAmmo = false
SWEP.HoldType = "normal"

game.AddParticles("particles/nimbus/flyingparticles.pcf")
PrecacheParticleSystem("nimbus_smoke") --Precache particles

local NimbusPlayerOnGround = true

function SWEP:Deploy()
	timer.Create("NimbusParticleEffect",0.5,0,function() 
		if SERVER then
			if NimbusPlayerOnGround == true then
				self.Owner:StopParticles()
			else
				ParticleEffectAttach("nimbus_smoke",4,self.Owner,self.Owner:LookupAttachment("hips"))
			end
		end	
	end)

	timer.Create("NimbusParticleResetTimer",24,0,function() self.Owner:StopParticles() end) --Destroy cloud particles after 24 seconds to prevent frame drops1
end

function SWEP:Think()
	if self.Owner:IsOnGround() == true then
		NimbusPlayerOnGround = true
		self:SetHoldType("normal")
	else
		NimbusPlayerOnGround = false
		self:SetHoldType("knife")
	end
	if self.Owner:KeyDown(IN_JUMP) then
		self.Owner:SetVelocity(Vector(0,0,20))
	end
end

function SWEP:PrimaryAttack() end

function SWEP:SecondaryAttack() end

function SWEP:Holster()
	hook.Remove("OnPlayerHitGround", "NimbusCloudDisableFlight")
	timer.Remove("NimbusParticleResetTimer")
	timer.Remove("NimbusParticleEffect")
	self.Owner:StopParticles()
	return true
end

function SWEP:OnRemove()

end