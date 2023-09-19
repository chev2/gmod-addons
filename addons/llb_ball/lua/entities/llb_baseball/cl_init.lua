include("shared.lua")

function ENT:Initialize()
    -- Create an individual material for every ball instance
    -- This allows each ball to be colored individually
    local matname = "LLBBaseball_" .. self:EntIndex()

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
    self:SetMaterial("!" .. matname)

    self.BallMaterial:SetVector("$selfillumtint", Vector(1, 0, 0))

    hook.Add("RenderScreenspaceEffects", self, function(ent)
        if ent.IsInverted then
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_colour"] = 1,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0,
                ["$pp_colour_inv"] = 1,
            })
        end
    end)
end

function ENT:Draw()
    self:DrawModel()
end

net.Receive("llb_baseball.ChangeBallColor", function()
    local ent = net.ReadEntity()
    local entowner = net.ReadEntity()
    ent.BallOwner = entowner
    ent.BallMaterial:SetVector("$selfillumtint", ent.BallOwner:GetPlayerColor())
end)

net.Receive("llb_baseball.DrawInvertedColors", function()
    local ent = net.ReadEntity()
    local time = net.ReadFloat()

    if not ent:IsDormant() then
        ent.IsInverted = true

        --RunConsoleCommand("pp_texturize", "pp/texturize/invert.png")

        timer.Simple(time, function()
            --RunConsoleCommand("pp_texturize", "")

            if IsValid(ent) then
                ent.IsInverted = false
            end
        end)
    end
end)

net.Receive("llb_baseball.ScreenShake", function()
    local pos = net.ReadVector()
    local amplitude = net.ReadUInt(8)
    local frequency = net.ReadUInt(8)
    local duration = net.ReadFloat()
    local radius = net.ReadFloat()

    util.ScreenShake(pos, amplitude, frequency, duration, radius, true)
end)
