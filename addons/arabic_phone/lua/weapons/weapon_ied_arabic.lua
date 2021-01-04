SWEP.PrintName = "Arabic Nokia Phone"
SWEP.Category = "Chev's Weapons"
SWEP.Author = "Chev / M9K"
SWEP.Purpose = "An improvised remote explosive/detonator that plays funny ringtones."
SWEP.Instructions = "Primary: Drop IED.".."\n" .."Secondary: Detonate"

SWEP.Slot = 4
SWEP.SlotPos = 26

SWEP.DrawAmmo = true
SWEP.DrawWeaponInfoBox = true
SWEP.BounceWeaponIcon = false
SWEP.DrawCrosshair = false
SWEP.Weight = 2
SWEP.HoldType = "fist"
SWEP.ViewModelFOV = 75

SWEP.ViewModel = "models/weapons/weapon_ied_arabic.mdl"
SWEP.WorldModel = "models/weapons/weapon_ied_arabic.mdl"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.FiresUnderwater = true

game.AddAmmoType({
	name = "arabicfunnyammo",
	dmgtype = DMG_BULLET
})

SWEP.Primary.Sound = Sound("Weapon_SLAM.SatchelThrow")
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "arabicfunnyammo"				

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1	
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:PrimaryAttack()
	if self:CanPrimaryAttack() then
		self:TakePrimaryAmmo(1)
		self:SetNextPrimaryFire(CurTime() + 1)	
		self.Weapon:EmitSound(self.Primary.Sound)

		local aim = self.Owner:GetAimVector()
		local side = aim:Cross(Vector(0,0,1))
		local up = side:Cross(aim)
		local pos = self.Owner:GetShootPos() + side * -5 + up * -10
		if SERVER then
			local ied = ents.Create("chev_ied")
			if !ied:IsValid() then return false end
			ied:SetNWEntity("Owner", self.Owner)
			ied:SetAngles(aim:Angle()+Angle(90,0,0))
			ied:SetPos(pos)
			ied:SetOwner(self.Owner)
			/*ied.Owner = self.Owner	-- redundancy department of redundancy checking in
			ied:SetNWEntity("Owner", self.Owner)*/
			ied:Spawn()
			local phys = ied:GetPhysicsObject()
			phys:ApplyForceCenter(self.Owner:GetAimVector() * 1500)
		end
		timer.Simple(0.25, function() if not IsValid(self) then return end
		if IsValid(self.Owner) and IsValid(self.Weapon) then
			if self.Owner:Alive() and self.Owner:GetActiveWeapon():GetClass() == "weapon_ied_arabic" then
				self:Reload()
			end
		end end)
	else return 
	end
	
end

function SWEP:SecondaryAttack()
	for k, v in pairs (ents.FindByClass("chev_ied")) do	
		if v:GetNWEntity("Owner") == self.Owner then
			v.Boom=true 
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		end
	end	
end	

function SWEP:GetViewModelPosition( pos, ang )
	pos = pos + ang:Right()*6
	pos = pos + ang:Up()*-3.5
	pos = pos + ang:Forward()*7
	ang:RotateAroundAxis(ang:Up(),0)
	ang:RotateAroundAxis(ang:Forward(), -10)
	ang:RotateAroundAxis(ang:Right(),00)
	return pos, ang 
end
