SWEP.PrintName = "Gamer Girl Bath Water"
SWEP.Purpose = "The Goddess\'s Elixir. Drink it to reach enlightenment!"
SWEP.Instructions = "Primary: Drink\nSecondary: Throw"
SWEP.Author = "\nChev: Coding, partial modelling\nDr. Manndarinchik (GB): Modelling/texturing"

SWEP.Category = "Chev\'s Weapons"
SWEP.Spawnable = true
SWEP.Slot = 1

local bathwatermodel = Model("models/manndarinchik/ggbathwater.mdl")

SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"

SWEP.ViewModel	= bathwatermodel
SWEP.WorldModel	= bathwatermodel
SWEP.HoldType = "pistol"
SWEP.DrawAmmo = false

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack() --drink poison
	self:EmitSound("chev/ggbathwater/bathwater_drink.ogg")

	if SERVER then
		local ply = self.Owner
		local timername = "BathwaterPoison"..ply:SteamID()
		timer.Create(timername, 1.4, 0, function() --ply:SteamID() as SteamID64() provides no value serverside in singleplayer
			if IsValid(ply) and ply:Alive() then
				ply:ViewPunch(Angle(math.random(-1, -2), 0, 0))
				ply:SetHealth(ply:Health() - math.random(2, 4))

				if ply:Health() < 3 then
					ply:Kill()
					ply:ChatPrint("you died after drinking too much bath water")
					timer.Remove(timername)
				else end	
			else
				timer.Remove(timername)
			end
		end)
	end

	self:SetNextPrimaryFire(CurTime() + 20)
end

function SWEP:SecondaryAttack() --throw
	if SERVER then
		local ent = ents.Create("ent_ggbathwater")
		ent:SetPos(self.Owner:EyePos() + self.Owner:GetAimVector() * 16)
		ent:SetAngles(self.Owner:EyeAngles())
		ent:Spawn()

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			local velocity = self.Owner:GetAimVector() * 3000
			phys:ApplyForceCenter(velocity)
			phys:AddAngleVelocity(Vector(0, math.random(500, 2000), 0))
		end
		self.Owner:ViewPunch(Angle(-4, 0, 0))

		self:Remove()
	end

	self:SetNextSecondaryFire(CurTime() + 100)
end

if CLIENT then
	function SWEP:DrawWorldModel()
		local ply = self:GetOwner()

	    if IsValid(ply) then
	        local opos = self:GetPos()
	        local oang = self:GetAngles()
	        local bon = ply:LookupBone("ValveBiped.Bip01_R_Hand")
		    local bp, ba = ply:GetBonePosition(bon or 0)

	        if bp then opos = bp end
	        if ba then oang = ba end

        	opos = opos + oang:Right() * 3.4
      	  	opos = opos + oang:Forward() * 6.9
      		opos = opos + oang:Up() * 0
	        oang:RotateAroundAxis(oang:Right(), 180)
	        self:SetupBones()

	        local mrt = self:GetBoneMatrix(0)
	        if mrt then
		        mrt:SetTranslation(opos)
		        mrt:SetAngles(oang)

		        self:SetBoneMatrix(0, mrt)
	        end
	    end

		self:DrawModel()
	end

	function SWEP:GetViewModelPosition(p, a)
		local bpos = Vector(10, 27, -9)
		local bang = Vector(-20, 180, 0)

		local right = a:Right()
		local up = a:Up()
		local forward = a:Forward()

		a:RotateAroundAxis(right, bang.x)
		a:RotateAroundAxis(up, bang.y)
		a:RotateAroundAxis(forward, bang.z)

		p = p + bpos.x * right
		p = p + bpos.y * forward
		p = p + bpos.z * up

		return p, a
	end
end
