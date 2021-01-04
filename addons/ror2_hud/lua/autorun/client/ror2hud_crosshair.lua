local surface = surface
local draw = draw
local LocalPlayer = LocalPlayer

local chair1 = Material("ror2hud/crosshair/dot.png")

local chairdash = Material("ror2hud/crosshair/hitline.png")
local chaircorner = Material("ror2hud/crosshair/bracket01.png")
local chaircircle = Material("ror2hud/crosshair/circle.png")
local chaircurve = Material("ror2hud/crosshair/arc.png")

local chairbox = Material("ror2hud/crosshair/squarebox.png")
local chaircursor = Material("ror2hud/crosshair/cursor.png")

local chairsprint = Material("ror2hud/crosshair/arrow.png")
local chairhit = Material("ror2hud/crosshair/hitline.png")

local plyvel = 10

local chairs = {
    { --commando (dynamic)
        name = "Commando",
        draw = function(csize)
            surface.SetMaterial(chair1)
            surface.DrawTexturedRectRotated(ScrW()/2, ScrH()/2, csize, csize, 0)

            surface.SetMaterial(chairdash)
            local dsize = csize * 1.74
            local midw, midh = ScrW()/2, ScrH()/2
            surface.DrawTexturedRectRotated(midw-dsize, midh, dsize+1, dsize+2, 0)
            surface.DrawTexturedRectRotated(midw+dsize, midh, dsize+1, dsize+2, 0)
            surface.DrawTexturedRectRotated(midw, midh-dsize, dsize+1, dsize+2, 90)
            surface.DrawTexturedRectRotated(midw, midh+dsize, dsize+1, dsize+2, 90)
        end,
        size = 15
    },
    { --huntress (static)
        name = "Huntress",
        draw = function(csize)
            surface.SetMaterial(chair1)
            surface.DrawTexturedRect(ScrW()/2-(csize/2), ScrH()/2-(csize/2), csize, csize)
        end,
        size = 15
    },
    { --mul-t (dynamic)
        name = "Mul-T",
        draw = function(csize)
            local midw, midh = ScrW()/2, ScrH()/2

            surface.SetMaterial(chair1)
            surface.DrawTexturedRectRotated(midw, midh, csize, csize, 0)

            surface.SetMaterial(chaircorner)
            surface.DrawTexturedRectRotated(midw+csize, midh-csize, csize, csize, 0)
            surface.DrawTexturedRectRotated(midw-csize, midh-csize, csize, csize, 90)
            surface.DrawTexturedRectRotated(midw-csize, midh+csize, csize, csize, 180)
            surface.DrawTexturedRectRotated(midw+csize, midh+csize, csize, csize, 270)
        end,
        size = 24
    },
    { --mult-t 2 (static)
        name = "Mul-T Rebar",
        draw = function(csize)
            surface.SetMaterial(chairsprint)
            local midw, midh = ScrW()/2, ScrH()/2
            surface.DrawTexturedRectRotated(midw, midh+6, csize, csize, 0)
            surface.DrawTexturedRectRotated(midw+6, midh, csize, csize, 90)
            surface.DrawTexturedRectRotated(midw, midh-6, csize, csize, 180)
            surface.DrawTexturedRectRotated(midw-6, midh, csize, csize, 270)
        end,
        size = 100
    },
    { --artificer (dynamic)
        name = "Artificer",
        draw = function(csize)
            surface.SetMaterial(chaircircle)
            surface.SetDrawColor(255, 255, 255, 50)
            local circsize = csize * 9
            surface.DrawTexturedRect(ScrW()/2-(circsize/2), ScrH()/2-(circsize/2), circsize, circsize)

            surface.SetMaterial(chaircurve)
            surface.SetDrawColor(255, 255, 255, 255)
            local midw, midh = ScrW()/2, ScrH()/2
            surface.DrawTexturedRectRotated(midw, midh-5, csize, csize*1.4, 0)
            surface.DrawTexturedRectRotated(midw-5, midh, csize, csize*1.4, 90)
            surface.DrawTexturedRectRotated(midw, midh+5, csize, csize*1.4, 180)
            surface.DrawTexturedRectRotated(midw+5, midh, csize, csize*1.4, 270)
        end,
        size = 22
    },
    { --rex (static)
        name = "Rex",
        draw = function(csize)
            surface.SetMaterial(chair1)
            surface.DrawTexturedRect(ScrW()/2-(csize/2), ScrH()/2-(csize/2), csize, csize)

            surface.SetMaterial(chairdash)
            local dsize = csize * 1.74
            surface.DrawTexturedRect(ScrW()/2-(dsize/2)-26, ScrH()/2-(dsize/2)-1, dsize+1, dsize+2)
            surface.DrawTexturedRect(ScrW()/2-(dsize/2)+26, ScrH()/2-(dsize/2)-1, dsize+1, dsize+2)
        end,
        size = 15
    },
    { --loader (static)
        name = "Loader",
        draw = function(csize)
            surface.SetMaterial(chair1)
            surface.DrawTexturedRectRotated(ScrW()/2, ScrH()/2, csize, csize, 0)

            surface.SetMaterial(chairbox)
            surface.DrawTexturedRectRotated(ScrW()/2, ScrH()/2, csize*1.6, csize*1.6, 45)

            surface.SetDrawColor(255, 255, 255, 120)
            surface.SetMaterial(chaircurve)
            local dsize = csize * 2.5
            surface.DrawTexturedRectRotated(ScrW()/2-45, ScrH()/2, dsize, dsize*1.2, 90)
            surface.DrawTexturedRectRotated(ScrW()/2+45, ScrH()/2, dsize, dsize*1.2, 270)
        end,
        size = 14
    },
    { --acrid (static)
        name = "Acrid",
        draw = function(csize)
            surface.SetMaterial(chair1)
            surface.DrawTexturedRectRotated(ScrW()/2, ScrH()/2, csize, csize, 0)

            surface.SetDrawColor(255, 255, 255, 220)
            surface.SetMaterial(chaircurve)
            local dsize = csize * 1
            local midw, midh = ScrW()/2, ScrH()/2
            surface.DrawTexturedRectRotated(midw-6, midh, dsize, dsize*1.4, 90)
            surface.DrawTexturedRectRotated(midw+6, midh, dsize, dsize*1.4, 270)
            surface.DrawTexturedRectRotated(midw, midh+6, dsize, dsize*1.4, 180)
        end,
        size = 24
    },
    { --misc. 1 (dynamic)
        name = "Misc. 1",
        draw = function(csize)
            surface.SetMaterial(chair1)
            local midw, midh = ScrW()/2, ScrH()/2
            surface.DrawTexturedRectRotated(midw, midh, csize, csize, 0)

            surface.SetMaterial(chaircurve)
            local dsize = csize * 1.74
            surface.DrawTexturedRectRotated(midw, midh, dsize, dsize, RealTime()*400%360)
            surface.DrawTexturedRectRotated(midw, midh, dsize, dsize, RealTime()*400%360+180)
            surface.DrawTexturedRectRotated(midw, midh, dsize*2, dsize*2, -RealTime()*400%360)
            surface.DrawTexturedRectRotated(midw, midh, dsize*2, dsize*2, -RealTime()*400%360+180)
        end,
        size = 14
    },
    { --misc. 2 (dynamic)
        name = "Misc. 2",
        draw = function(csize)
            surface.SetMaterial(chair1)
            local midw, midh = ScrW()/2, ScrH()/2
            surface.DrawTexturedRectRotated(midw, midh, csize, csize, 0)

            surface.SetMaterial(chairsprint)
            local dsize = csize * 6.74
            plyvel = Lerp(10 * FrameTime(), plyvel, LocalPlayer():GetVelocity():Length()/4 + 10)
            surface.DrawTexturedRectRotated(midw+plyvel, midh, dsize, dsize, 90)
            surface.DrawTexturedRectRotated(midw-plyvel, midh, dsize, dsize, 270)
        end,
        size = 14
    },
    { --misc. 3 (static)
        name = "Misc. 3",
        draw = function(csize)
            local midw, midh = ScrW()/2, ScrH()/2

            surface.SetMaterial(chairsprint)
            
            surface.DrawTexturedRectRotated(midw+10, midh, csize, csize, 90)
            surface.DrawTexturedRectRotated(midw-10, midh, csize, csize, 270)

            local dsize = csize * 1.4

            surface.DrawTexturedRectRotated(midw+50, midh, dsize, dsize, 90)
            surface.DrawTexturedRectRotated(midw-50, midh, dsize, dsize, 270)
        end,
        size = 95
    },
    { --misc. 4 (static)
        name = "Misc. 4",
        draw = function(csize)
            render.PushFilterMag(0)
            render.PushFilterMin(0)
            surface.SetMaterial(chaircursor)
            surface.DrawTexturedRect(ScrW()/2, ScrH()/2, 12, 19, 0)
            render.PopFilterMag()
            render.PopFilterMin()
        end,
        size = 1
    },
    ["sprint"] = {
        draw = function(csize)
            surface.SetMaterial(chairsprint)
            surface.DrawTexturedRect(ScrW()/2-(csize/2), ScrH()/2-(csize/2), csize, csize)
        end,
        size = 100
    },
    ["hit"] = {
        draw = function(csize)
            surface.SetMaterial(chairhit)
            surface.DrawTexturedRect(ScrW()/2-(csize/2), ScrH()/2-(csize/2), csize, csize)
        end,
        size = 152
    }
}

local function DrawCrosshair(ctype)
    surface.SetMaterial(ctype.mat)
    surface.DrawTexturedRect(ScrW()/2-(ctype.size/2), ScrH()/2-(ctype.size/2), ctype.size, ctype.size)
end

local enabled_cvar = CreateClientConVar("ror2hud_crosshair_enabled", "1", true, false, "The RoR2 crosshairs are enabled.", 0, 1)
local sprint_enabled_cvar = CreateClientConVar("ror2hud_crosshair_sprint_enabled", "1", true, false, "Shows the sprint crosshair when sprinting.", 0, 1)
local ctype_cvar = CreateClientConVar("ror2hud_crosshair_type", "2", true, false, "Crosshair type.", 0, #chairs)
local filter_cvar = GetConVar("ror2hud_filter")

hook.Add("HUDShouldDraw", "RoR2HUDCrosshairDisableDefault", function(name)
    if name == "CHudCrosshair" then return !enabled_cvar:GetBool() end
end)

hook.Add("HUDPaint", "RoR2HUDCrosshair", function()
    if !enabled_cvar:GetBool() then return end

    render.PushFilterMag(filter_cvar:GetInt())
    render.PushFilterMin(filter_cvar:GetInt())

    surface.SetDrawColor(255, 255, 255, 255)

    local ctype = chairs[ctype_cvar:GetInt()]
    --change to sprint crosshair if the player sprints
    if LocalPlayer():IsSprinting() and LocalPlayer():GetVelocity():Length() > 0 and sprint_enabled_cvar:GetBool() then ctype = chairs["sprint"] end
    if ctype then ctype.draw(ctype.size) end

    render.PopFilterMag()
    render.PopFilterMin()
end)
