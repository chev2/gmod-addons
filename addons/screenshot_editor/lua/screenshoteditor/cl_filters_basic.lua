--[[

    Comic Book

]]
local CB_COLOR_1 = color_white:ToVector()
local CB_COLOR_2_TOP = Vector(1, 0.96, 0.28)
local CB_COLOR_2_BOTTOM = Vector(0.24, 0.622, 0.88)
local CB_COLOR_3_TOP = Color(142, 45, 226):ToVector()
local CB_COLOR_3_BOTTOM = Color(74, 0, 224):ToVector()

local ComicBookBuffer = GetRenderTarget("ComicBookBuffer", ScrW(), ScrH())
local MaterialComicBookBuffer = MaterialComicBookBuffer or CreateMaterial("ComicBookScreen", "UnlitGeneric", {
    ["$basetexture"] = ComicBookBuffer:GetName(),
})

local MaterialComicBookTop = CreateMaterial("ComicBookTopGradient", "UnlitGeneric", {
    ["$basetexture"] = "vgui/white",
    ["$translucent"] = "1",
    ["$color"] = "{255 0 0}"
})

local MaterialComicBookBottom = CreateMaterial("ComicBookBottomGradient", "UnlitGeneric", {
    ["$basetexture"] = "vgui/gradient_up",
    ["$translucent"] = "1",
    ["$color"] = "{0 255 0}"
})

local function DrawComicBookNoBuffer(threshold, colortop, colorbottom, material)
    render.PushRenderTarget(ComicBookBuffer)
    render.Clear(0, 0, 0, 255)
    render.ClearDepth()

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(material)
    surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

    DrawSobel(threshold)

    -- Contrast to black and white only
    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 45,
        ["$pp_colour_colour"] = 0,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    })

    render.PopRenderTarget()

    -- Draw gradient
    render.SetMaterial(MaterialComicBookTop)
    MaterialComicBookTop:SetVector("$color", colortop)
    render.DrawScreenQuad()

    render.SetMaterial(MaterialComicBookBottom)
    MaterialComicBookBottom:SetVector("$color", colorbottom)
    render.DrawScreenQuad()

    render.OverrideBlend(true, BLEND_DST_COLOR, BLEND_ZERO, BLENDFUNC_ADD, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD)

    -- Draw sobel effect
    render.SetMaterial(MaterialComicBookBuffer)
    render.DrawScreenQuad()

    render.OverrideBlend(false)
end

--[[

    Texturize

]]
-- Native to Garry's Mod
local MAT_TEXTURIZE_PATTERN1 = Material("pp/texturize/pattern1.png")
local MAT_TEXTURIZE_LINES = Material("pp/texturize/lines.png")
local MAT_TEXTURIZE_RAINBOW = Material("pp/texturize/rainbow.png")
local MAT_TEXTURIZE_SQUAREDO = Material("pp/texturize/squaredo.png")
local MAT_TEXTURIZE_PINKO = Material("pp/texturize/pinko.png")
local MAT_TEXTURIZE_PLAIN = Material("pp/texturize/plain.png")

-- Custom
local MAT_TEXTURIZE_80S = Material("pp/texturize/80s.png")
local MAT_TEXTURIZE_ACIDIC = Material("pp/texturize/acidic.png")
local MAT_TEXTURIZE_CHECKER = Material("pp/texturize/checker.png")
local MAT_TEXTURIZE_INVERT = Material("pp/texturize/invert.png")
local MAT_TEXTURIZE_OCEANIC = Material("pp/texturize/oceanic.png")

--[[

    Chromatic Aberration

]]
local MAT_CA_RED = CreateMaterial("pp/ca/red", "UnlitGeneric", {
    ["$basetexture"] = "_rt_FullFrameFB",
    ["$color2"] = "[1 0 0]",
    ["$ignorez"] = "1",
    ["$additive"] = "1"
})

local MAT_CA_GREEN = CreateMaterial("pp/ca/green", "UnlitGeneric", {
    ["$basetexture"] = "_rt_FullFrameFB",
    ["$color2"] = "[0 1 0]",
    ["$ignorez"] = "1",
    ["$additive"] = "1"
})

local MAT_CA_BLUE = CreateMaterial("pp/ca/blue", "UnlitGeneric", {
    ["$basetexture"] = "_rt_FullFrameFB",
    ["$color2"] = "[0 0 1]",
    ["$ignorez"] = "1",
    ["$additive"] = "1"
})

local MAT_CA_BASE = Material("vgui/black")

local function DrawChromaticAberration(rx, ry, gx, gy, bx, by)
    render.UpdateScreenEffectTexture()

    MAT_CA_RED:SetTexture("$basetexture", render.GetScreenEffectTexture())
    MAT_CA_GREEN:SetTexture("$basetexture", render.GetScreenEffectTexture())
    MAT_CA_BLUE:SetTexture("$basetexture", render.GetScreenEffectTexture())

    render.SetMaterial(MAT_CA_BASE)
    render.DrawScreenQuad()

    render.SetMaterial(MAT_CA_RED)
    render.DrawScreenQuadEx(-rx / 2, -ry / 2, ScrW() + rx, ScrH() + ry)

    render.SetMaterial(MAT_CA_GREEN)
    render.DrawScreenQuadEx(-gx / 2, -gy / 2, ScrW() + gx, ScrH() + gy)

    render.SetMaterial(MAT_CA_BLUE)
    render.DrawScreenQuadEx(-bx / 2, -by / 2, ScrW() + bx, ScrH() + by)
end

--[[

    Negate

]]
local MAT_NEGATIVE = CreateMaterial("MaterialNegativeBuffer" .. math.floor(CurTime() * 1000), "UnlitGeneric", {
    ["$basetexture"] = "vgui/white",
    ["$translucent"] = "0",
    ["$color"] = "[1 1 1]"
})

local function DrawNegative()
    render.UpdateScreenEffectTexture()

    MAT_NEGATIVE:SetTexture("$basetexture", render.GetScreenEffectTexture(0))
    render.SetMaterial(MAT_NEGATIVE)
    render.DrawScreenQuad()

    render.OverrideBlend(true, BLEND_ONE_MINUS_DST_COLOR, BLEND_ZERO, BLENDFUNC_ADD)

    render.SetColorMaterial()
    render.DrawScreenQuad()

    render.OverrideBlend(false)
end

-- Add basic screenshot editor filters
hook.Add("ScreenshotEditorInitialize", "ScreenshotEditor_AddBasicFilters", function()
    screenshot_editor.AddFilter({
        FilterName = "None",
        FilterCallback = function(width, height)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Black & White",
        FilterCallback = function(width, height)
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 0,

    screenshot_editor.AddFilter({
        FilterName = "Sepia",
        FilterCallback = function(width, height)
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 0,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })

            DrawColorModify({
                ["$pp_colour_addr"] = 175 / 255,
                ["$pp_colour_addg"] = 155 / 255,
                ["$pp_colour_addb"] = 137 / 255,
                ["$pp_colour_brightness"] = -0.6,
                ["$pp_colour_contrast"] = 0.95,
                ["$pp_colour_colour"] = 1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Vibrant",
        FilterCallback = function(width, height)
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 1.6,
            })
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Deep Fried",
        FilterCallback = function(width, height)
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 3,
            })

            DrawSharpen(3, 1)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Super Deep Fried",
        FilterCallback = function(width, height)
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 5,
            })

            DrawSharpen(6, 1)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Sharpen",
        FilterCallback = function(width, height)
            DrawSharpen(1.3, 1)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Toy Town",
        FilterCallback = function(width, height)
            DrawToyTown(2, ScrH() / 2)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Bloom",
        FilterCallback = function(width, height)
            DrawBloom(0.65, 1, 2, 2, 3, 1, 1, 1, 1)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Rising Heat",
        FilterCallback = function(width, height)
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 0,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })

            DrawColorModify({
                ["$pp_colour_addr"] = 155 / 255,
                ["$pp_colour_addg"] = 39 / 255,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Lovely",
        FilterCallback = function(width, height)
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 0,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })

            DrawColorModify({
                ["$pp_colour_addr"] = 255 / 800,
                ["$pp_colour_addg"] = 140 / 800,
                ["$pp_colour_addb"] = 243 / 500,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Cold",
        FilterCallback = function(width, height)
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 0,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })

            DrawColorModify({
                ["$pp_colour_addr"] = 107 / 800,
                ["$pp_colour_addg"] = 193 / 800,
                ["$pp_colour_addb"] = 255 / 800,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Radioactive",
        FilterCallback = function(width, height)
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 0,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })

            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 255 / 800,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Texturize (Pattern #1)",
        FilterCallback = function(width, height, mat)
            DrawTexturize(1, MAT_TEXTURIZE_PATTERN1)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Texturize (Lines)",
        FilterCallback = function(width, height, mat)
            DrawTexturize(1, MAT_TEXTURIZE_LINES)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Texturize (Rainbow)",
        FilterCallback = function(width, height, mat)
            DrawTexturize(1, MAT_TEXTURIZE_RAINBOW)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Texturize (Squaredo)",
        FilterCallback = function(width, height, mat)
            DrawTexturize(1, MAT_TEXTURIZE_SQUAREDO)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Texturize (Pinko)",
        FilterCallback = function(width, height, mat)
            DrawTexturize(1, MAT_TEXTURIZE_PINKO)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Texturize (Plain)",
        FilterCallback = function(width, height, mat)
            DrawTexturize(1, MAT_TEXTURIZE_PLAIN)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Texturize (80s)",
        FilterCallback = function(width, height, mat)
            DrawTexturize(1, MAT_TEXTURIZE_80S)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Texturize (Acidic)",
        FilterCallback = function(width, height, mat)
            DrawTexturize(1, MAT_TEXTURIZE_ACIDIC)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Texturize (Checker)",
        FilterCallback = function(width, height, mat)
            DrawTexturize(1, MAT_TEXTURIZE_CHECKER)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Texturize (Invert)",
        FilterCallback = function(width, height, mat)
            DrawTexturize(1, MAT_TEXTURIZE_INVERT)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Texturize (Oceanic)",
        FilterCallback = function(width, height, mat)
            DrawTexturize(1, MAT_TEXTURIZE_OCEANIC)
        end
    })
        FilterCallback = function(width, height, mat)
            DrawComicBookNoBuffer(0.1, CB_COLOR_1, CB_COLOR_1, mat)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Comic Book #2",
        FilterCallback = function(width, height, mat)
            DrawComicBookNoBuffer(0.1, CB_COLOR_2_TOP, CB_COLOR_2_BOTTOM, mat)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Comic Book #3",
        FilterCallback = function(width, height, mat)
            DrawComicBookNoBuffer(0.1, CB_COLOR_3_TOP, CB_COLOR_3_BOTTOM, mat)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "High Contrast",
        FilterCallback = function(width, height, mat)
            DrawComicBookNoBuffer(0.1, CB_COLOR_1, CB_COLOR_1, mat)

            DrawNegative()

            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 10,
                ["$pp_colour_colour"] = 1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "FAITH",
        FilterCallback = function(width, height, mat)
            DrawComicBookNoBuffer(0.1, CB_COLOR_1, CB_COLOR_1, mat)

            DrawNegative()

            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 10,
                ["$pp_colour_colour"] = 1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })

            DrawColorModify({
                ["$pp_colour_addr"] = -(18 / 255),
                ["$pp_colour_addg"] = -(177 / 255),
                ["$pp_colour_addb"] = -(227 / 255),
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })

            DrawChromaticAberration(6, 6, 0, 0, 0, 0)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Chromatic Aberration (Red / Cyan)",
        FilterCallback = function(width, height, mat)
            DrawChromaticAberration(6, 6, 0, 0, 0, 0)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Chromatic Aberration (Green / Purple)",
        FilterCallback = function(width, height, mat)
            DrawChromaticAberration(0, 0, 6, 6, 0, 0)
        end
    })

    screenshot_editor.AddFilter({
        FilterName = "Chromatic Aberration (Blue / Yellow)",
        FilterCallback = function(width, height, mat)
            DrawChromaticAberration(0, 0, 0, 0, 6, 6)
        end
    })
end)
