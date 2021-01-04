local surface = surface
local draw = draw
local render = render
local LocalPlayer = LocalPlayer
local cPushModelMatrix = cam.PushModelMatrix
local cPopModelMatrix = cam.PopModelMatrix

surface.CreateFont("RoR2HUD_Bombardier", {
    font = "Bombardier",
    extended = false,
    size = 25,
    antialias = true
})

local tMat = Matrix()

local enabled_cvar = CreateClientConVar("ror2hud_enabled", "1", true, false, "The RoR2 HUD is enabled.", 0, 1)
local xpadding_cvar = CreateClientConVar("ror2hud_xpadding", "122", true, false, "Changes how far away the HUD touches the sides of the screen.", 0, ScrW())
local ypadding_cvar = CreateClientConVar("ror2hud_ypadding", "100", true, false, "Changes how far away the HUD touches the bottom of the screen.", 0, ScrH())
local armorThickness_cvar = CreateClientConVar("ror2hud_armorthickness", "6", true, false, "How thick the armor bar is compared to the health bar (in pixels).", 0, 32)
local hudAngle_cvar = CreateClientConVar("ror2hud_angle", "3", true, false, "The angle at which the HUD is set at.", -90, 90)
local filter_cvar = CreateClientConVar("ror2hud_filter", "3", true, false, "The texture filter used on the HUD. 0 = None, 1 = Point, 2 = Linear, 3 = Anistropic.", 0, 3)

local function drawElements(offsetx, offsety, angle, drawfunc)
    tMat:SetAngles(Angle(angle, angle, 45))

    tMat:SetTranslation(Vector(offsetx, offsety, 0))

    tMat:SetScale(Vector(1, 1, 0))

    cPushModelMatrix(tMat)
        drawfunc()
    cPopModelMatrix()
end

local function drawUVBar(mat, color, xpos, ypos, width, height, pixels)
    if width < 1 then return end
    surface.SetMaterial(mat)
    surface.SetDrawColor(unpack(color)) -- unpack(color)
    surface.DrawTexturedRectUV(xpos, ypos, 4, height, 0, 0, 0.125, 1)
    surface.DrawTexturedRectUV(xpos+4, ypos, width-(pixels)+1, height, 0.125, 0, 0.875, 1)
    surface.DrawTexturedRectUV(xpos+width-4, ypos, 4, height, 0.875, 0, 1, 1)
end

local hpBarMat = Material("ror2hud/hpbar.png")
local armorBarMat = Material("ror2hud/armorbar.png")
local barBackMat = Material("ror2hud/barback.png")
local lowHp = Material("ror2hud/lowhp_indicator.png")

local curFPS = 0

local hidden_elements = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true
}

hook.Add("HUDShouldDraw", "RoR2HUDDisableDefault", function(name)
    if hidden_elements[name] then return !enabled_cvar:GetBool() end
end)

hook.Add("HUDPaint", "RoR2HUD", function()
    if !enabled_cvar:GetBool() then return end -- if the cvar is set to disable the HUD

    render.PushFilterMag(filter_cvar:GetInt()) --smooth filter
    render.PushFilterMin(filter_cvar:GetInt())

    local xpadding = xpadding_cvar:GetInt()
    local ypadding = ypadding_cvar:GetInt()
    local armorThickness = armorThickness_cvar:GetInt()
    local hudAngle = hudAngle_cvar:GetInt()

    --[[------------------------
               Health
    --]]------------------------

    local hp = LocalPlayer():Health()
    local maxhp = LocalPlayer():GetMaxHealth()
    local hpratio = math.Clamp(hp, 0, maxhp) / maxhp

    drawElements(xpadding, ScrH()-ypadding, -hudAngle, function()
        surface.SetDrawColor(210, 210, 210, 180)
        surface.SetMaterial(barBackMat)
        surface.DrawTexturedRect(0, 0, 430, 30)
        drawUVBar(hpBarMat, {94, 173, 48, 255}, 0, 0, 430*hpratio, 30, 8)
    end) --health bar

    local armor = LocalPlayer():Armor()
    local maxarmor = LocalPlayer():GetMaxArmor()
    local armorratio = math.Clamp(armor, 0, maxarmor) / maxarmor

    drawElements(xpadding-armorThickness, ScrH()-ypadding-armorThickness, -hudAngle, function()
        drawUVBar(armorBarMat, {255, 255, 255, 255}, 0, 0, 438*armorratio, 30+armorThickness*2, 8)
    end) --armor bar

    drawElements(xpadding, ScrH()-ypadding, -hudAngle, function()
        surface.SetMaterial(lowHp)
        surface.DrawTexturedRect(3, 3, 50, 24)

        draw.TextShadow({
            text = math.max(hp, 0) .. " / " .. maxhp,
            font = "RoR2HUD_Bombardier",
            pos = {215, 15},
            color = color_white,
            xalign = TEXT_ALIGN_CENTER,
            yalign = TEXT_ALIGN_CENTER
        }, 1, 150)
    end) -- health text

    curFPS = Lerp(4 * RealFrameTime(), curFPS, 1/RealFrameTime())

    drawElements(xpadding+6, ScrH()-ypadding-34, -hudAngle, function()
        draw.TextShadow({
            text = LocalPlayer():Nick(),
            font = "RoR2HUD_Bombardier",
            pos = {0, 12},
            color = color_white,
            xalign = TEXT_ALIGN_LEFT,
            yalign = TEXT_ALIGN_CENTER
        }, 1, 150)
        draw.TextShadow({
            text = "FPS: " .. math.Round(curFPS) .. "  Ping: " .. LocalPlayer():Ping(),
            font = "RoR2HUD_Bombardier",
            pos = {415, 12},
            color = color_white,
            xalign = TEXT_ALIGN_RIGHT,
            yalign = TEXT_ALIGN_CENTER
        }, 1, 150)
    end) -- name, fps/ping text

    --[[------------------------
              Ammunition
    --]]------------------------

    local wep = LocalPlayer():GetActiveWeapon()

    drawElements(ScrW()-xpadding-430, ScrH()-ypadding-(7*hudAngle), hudAngle, function()
        surface.SetDrawColor(210, 210, 210, 180)
        surface.SetMaterial(barBackMat)
        surface.DrawTexturedRectRotated(215, 15, 430, 30, 180)
    end)

    if IsValid(wep) then
        if wep:GetPrimaryAmmoType() > -1 then
            local clip1max = wep:GetMaxClip1()
            local clip1cur = wep:Clip1()
            local clip1ammo = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())
            local clip1ratio = clip1cur > -1 and math.min(clip1cur / clip1max, 1) or math.Clamp(clip1ammo, 0, 1)
            local showntext = clip1cur > -1 and clip1cur .. " / " .. clip1ammo or clip1ammo

            drawElements(ScrW()-xpadding-430, ScrH()-ypadding-(7*hudAngle), hudAngle, function()
                drawUVBar(hpBarMat, {211, 195, 112, 255}, 430*(1-clip1ratio), 0, 430*clip1ratio, 30, 8)
                draw.TextShadow({
                    text = showntext,
                    font = "RoR2HUD_Bombardier",
                    pos = {215, 15},
                    color = color_white,
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER
                }, 1, 150)
            end) --ammo bar with text
        end

        if wep:GetSecondaryAmmoType() > -1 then
            local clip2ammo = LocalPlayer():GetAmmoCount(wep:GetSecondaryAmmoType())
            surface.SetFont("RoR2HUD_Bombardier")
            local w = surface.GetTextSize(clip2ammo) + 15
            
            drawElements(ScrW()-xpadding-430, ScrH()-ypadding-(7*hudAngle)-34, hudAngle, function()
                drawUVBar(hpBarMat, {200, 200, 200, 100}, 424-w, 4, w, 22, 8)
                draw.TextShadow({
                    text = clip2ammo,
                    font = "RoR2HUD_Bombardier",
                    pos = {415, 15},
                    color = color_white,
                    xalign = TEXT_ALIGN_RIGHT,
                    yalign = TEXT_ALIGN_CENTER
                }, 1, 150)
            end) --secondary text ammo
        end
    end

    render.PopFilterMag()
    render.PopFilterMin()
end)
