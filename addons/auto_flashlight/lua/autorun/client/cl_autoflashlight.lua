--
-- Localization stuff
--
language.Add("spawnmenu.options.autoflashlight", "Auto-Flashlight")

language.Add("spawnmenu.options.autoflashlight.cvar.enabled", "Enabled")
language.Add(
    "spawnmenu.options.autoflashlight.cvartooltip.enabled",
    "Whether or not auto-flashlight is enabled."
)

language.Add("spawnmenu.options.autoflashlight.cvar.threshold", "Light Threshold")
language.Add(
    "spawnmenu.options.autoflashlight.cvartooltip.threshold",
    "The threshold for the automatic flashlight to trigger. Higher values mean the flashlight will activate in brighter areas. Default: 0.0055"
)

language.Add("spawnmenu.options.autoflashlight.cvar.frequency", "Checking Frequency")
language.Add(
    "spawnmenu.options.autoflashlight.cvartooltip.frequency",
    "How often Auto-Flashlight should check to see if the player is in darkness. Default: 0.4"
)

--
-- ConVars, variables & functions
--
local CVAR_AUTO_FLASHLIGHT_ENABLED = CreateClientConVar(
    "cl_flashlight_auto",
    1,
    true,
    false,
    language.GetPhrase("#spawnmenu.options.autoflashlight.cvartooltip.enabled")
)

local CVAR_AUTO_FLASHLIGHT_THRESHOLD = CreateClientConVar(
    "cl_flashlight_auto_threshold",
    0.0055,
    true,
    false,
    language.GetPhrase("#spawnmenu.options.autoflashlight.cvartooltip.threshold"),
    0,
    0.5
)

local CVAR_AUTO_FLASHLIGHT_FREQUENCY = CreateClientConVar(
    "cl_flashlight_auto_frequency",
    0.4,
    true,
    false,
    language.GetPhrase("#spawnmenu.options.autoflashlight.cvartooltip.frequency"),
    0.05,
    2
)

local wasInDarkness = false

autoflashlight = autoflashlight or {}

--
-- This function is designed to be overwritten by other developers who
-- might want their custom flashlight implementation to support Auto-Flashlight.
--
-- I'm assuming that not all flashlight implementations make use of "impulse 100",
-- but who knows
--
function autoflashlight.SetFlashlightEnabled(isEnabled)
    -- If isEnabled is not provided, just assume the flashlight is being enabled
    isEnabled = Either(isEnabled ~= nil, isEnabled, true)

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    if (isEnabled and not ply:FlashlightIsOn()) or (not isEnabled and ply:FlashlightIsOn()) then
        RunConsoleCommand("impulse", "100")
    end
end

-- Returns whether or not we were in darkness the last time we checked it
function autoflashlight.GetWasInDarkness()
    return wasInDarkness
end

function autoflashlight.GetEnabled()
    return CVAR_AUTO_FLASHLIGHT_ENABLED:GetBool()
end

function autoflashlight.GetThreshold()
    return CVAR_AUTO_FLASHLIGHT_THRESHOLD:GetFloat()
end

--
-- Main calculation/execution script
--
local function AutoFlashlightDoToggle()
    if not CVAR_AUTO_FLASHLIGHT_ENABLED:GetBool() then return end

    local ply = LocalPlayer()
    -- If player isn't valid for any reason
    if not IsValid(ply) then return end

    local col = render.GetLightColor(ply:EyePos())
    -- Determine luminance from the R, G, B values of the light
    local luminance = (col.x * 0.299) + (col.y * 0.587) + (col.z * 0.114)

    local darknessThreshold = CVAR_AUTO_FLASHLIGHT_THRESHOLD:GetFloat()

    -- Allow controlling the auto-flashlight through hooks
    -- If the hook returns false, the auto-flashlight will be disabled
    if hook.Run("AutoFlashlight.ShouldAllow", luminance, darknessThreshold, wasInDarkness) == false then return end

    local isInDarkness = luminance < darknessThreshold

    -- If we're in a dark area, and weren't previously in a dark area
    if isInDarkness and not wasInDarkness then
        -- Allow developers to control if auto-flashlight can turn on
        -- Returning false will stop it from turning on
        local flashlightAllowedToTurnOn = hook.Run("AutoFlashlight.CanFlashlightTurnOn", luminance, darknessThreshold, wasInDarkness)

        -- ...and the flashlight isn't on yet, and can be turned on
        if not ply:FlashlightIsOn() and flashlightAllowedToTurnOn ~= false then
            -- ...then turn it on
            autoflashlight.SetFlashlightEnabled(true)
        end
    -- If we're not in a dark area, but we were previously
    elseif not isInDarkness and wasInDarkness then
        -- Allow developers to control if auto-flashlight can turn off
        -- Returning false will stop it from turning off
        local flashlightAllowedToTurnOff = hook.Run("AutoFlashlight.CanFlashlightTurnOff", luminance, darknessThreshold, wasInDarkness)

        -- ...and the flashlight is on, and can be turned off
        if ply:FlashlightIsOn() and flashlightAllowedToTurnOff ~= false then
            -- ...then turn it of
            autoflashlight.SetFlashlightEnabled(false)
        end
    end

    wasInDarkness = isInDarkness
end

timer.Create("AutoFlashlight.DoToggle", CVAR_AUTO_FLASHLIGHT_FREQUENCY:GetFloat(), 0, AutoFlashlightDoToggle)

-- Recreate timer whenever flashlight frequency setting is adjusted
cvars.AddChangeCallback("cl_flashlight_auto_frequency", function(convar, oldVal, newVal)
    if not tonumber(newVal) then return end

    timer.Create("AutoFlashlight.DoToggle", tonumber(newVal), 0, AutoFlashlightDoToggle)
    AutoFlashlightDoToggle()
end, "AutoFlashlight.RefreshFrequencyCVar")

--
-- Add Sandbox options menu
--
hook.Add("AddToolMenuCategories", "AutoFlashlight.AddSpawnmenuCategory", function()
    spawnmenu.AddToolCategory("Options", "AutoFlashlight", "#spawnmenu.options.autoflashlight")
end)

hook.Add("PopulateToolMenu", "AutoFlashlight.PopulateSpawnmenuCategory", function()
    spawnmenu.AddToolMenuOption("Options", "AutoFlashlight", "AutoFlashlightSettingsMain", "Settings", "", "", function(pnl)
        pnl:Help("Main Settings")

        pnl:CheckBox("#spawnmenu.options.autoflashlight.cvar.enabled", "cl_flashlight_auto")

        pnl:NumSlider("#spawnmenu.options.autoflashlight.cvar.threshold", "cl_flashlight_auto_threshold", 0, 0.5, 4)
        pnl:ControlHelp("#spawnmenu.options.autoflashlight.cvartooltip.threshold")

        pnl:NumSlider("#spawnmenu.options.autoflashlight.cvar.frequency", "cl_flashlight_auto_frequency", 0.05, 2, 2)
        pnl:ControlHelp("#spawnmenu.options.autoflashlight.cvartooltip.frequency")
    end)
end)
