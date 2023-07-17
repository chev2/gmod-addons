if SERVER then AddCSLuaFile() end
DEFINE_BASECLASS("base_gmodentity")
ENT.Type = "anim"
ENT.Model = Model("models/props/de_bikibot/bikibus.mdl")
ENT.EnterPosition = Vector(-145, 1359, 0)
ENT.CenterPosition = Vector(-145, 147, 0)
ENT.LeavePosition = Vector(-145, -1100, 0)

function ENT:Initialize()
    self:SetModel(self.Model)

    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)

    self:DrawShadow(false)
    self:SetNoDraw(true)

    self:SetPos(self.EnterPosition)

    if SERVER then
        self.ActualBus = ents.Create("prop_dynamic") --this is done to support transparency on the model
        self.ActualBus:SetPos(self:GetPos())
        self.ActualBus:SetModel(self.Model)
        self.ActualBus:Spawn()

        self.ActualBus:SetColor(Color(255, 255, 255, 0))
        self.ActualBus:SetRenderMode(RENDERMODE_TRANSCOLOR)

        self.ActualBus:SetParent(self)

        timer.Simple(15, function()
            if IsValid(self) then
                self:LeaveStation()
            end
        end)
    end

    self.TargetPosition = Vector(0, 0, 0)
    self.BusTargetAlpha = 0
    self.BusAlpha = 0

    self:EnterStation()
end

if SERVER then
    function ENT:Think()
        self.BusAlpha = Lerp(FrameTime()*4, self.BusAlpha, self.BusTargetAlpha)
        self:SetPos(LerpVector(FrameTime(), self:GetPos(), self.TargetPosition))
        self.ActualBus:SetColor(Color(255, 255, 255, math.Round(self.BusAlpha)))

        self:NextThink(CurTime())
        return true
    end
end

function ENT:EnterStation()
    self.BusTargetAlpha = 255
    self.TargetPosition = self.CenterPosition
end

function ENT:LeaveStation()
    timer.Simple(4, function() if IsValid(self) then self:Remove() end end)
    
    self.BusTargetAlpha = 0
    self.TargetPosition = self.LeavePosition
end
