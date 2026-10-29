local MAT_EYES = Material("letstakealook/eyes.png", "smooth")
local MAT_SKELETON = Material("letstakealook/running_skeleton")

local COLOR_MODIFY_GRAYSCALE = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 0,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

local IS_LOOKING = false
local IS_SKELETON_HERE = false
local SKELETON_PASSED_TIME = 0

-- List of possible entities to render eyes over
local LOOKING_ENTS = {}

hook.Add("RenderScreenspaceEffects", "LetsTakeALook.Draw", function()
    if IS_SKELETON_HERE then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(MAT_SKELETON)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

        -- Calculate the correct frame to use (36 is the frame count)
        -- We do this because the frame is a one-shot animation; whenever this material shows,
        --  it should start from frame 1. The default material proxy implementation ignores this
        --  and uses CurTime or something
        -- SKELETON_PASSED_TIME = SKELETON_PASSED_TIME + (RealFrameTime() * 36)
        SKELETON_PASSED_TIME = SKELETON_PASSED_TIME + (RealFrameTime() * 36 * 1.2) -- Slightly speed up animation
        MAT_SKELETON:SetInt("$frame", math.min(SKELETON_PASSED_TIME, 36))
    end

    if not IS_LOOKING then return end

    local lply = LocalPlayer()
    local lplyPos = EyePos()

    -- Render eyes on screen
    for _, ent in ipairs(LOOKING_ENTS) do
        -- Technically entities can go invalid while this runs, so we check it here
        if not IsValid(ent) then continue end

        -- Ditto, since an entity can still die during this effect
        if not ent:Alive() then continue end

        -- Render eyes for the local player only when appropriate
        if ent == lply and not lply:ShouldDrawLocalPlayer() then continue end
        local eyePos = nil

        local headBoneId = ent:LookupBone("ValveBiped.Bip01_Head1")
        if headBoneId ~= nil then
            local boneMat = ent:GetBoneMatrix(headBoneId)
            if boneMat ~= nil then
                eyePos = boneMat:GetTranslation()
                eyePos = eyePos + (boneMat:GetForward() * 3.5) + (boneMat:GetRight() * 3.5)
            end
        end

        if eyePos == nil then
            eyePos = ent:EyePos() + Vector(0, 0, 12)
        end

        local toScreenData = eyePos:ToScreen()
        if not toScreenData.visible then continue end

        local dist = eyePos:DistToSqr(lplyPos)
        dist = math.Clamp(120 - (dist / 10000), 20, 500)

        local eyesSize = dist

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(MAT_EYES)
        surface.DrawTexturedRect(toScreenData.x - (eyesSize / 2), toScreenData.y - (eyesSize / 2), eyesSize, eyesSize)
    end

    DrawColorModify(COLOR_MODIFY_GRAYSCALE)
end)

local function LetsTakeALook()
    -- Calculate now which entities should have the eyes overlay on them,
    --  for a little bit of extra performance
    LOOKING_ENTS = {}
    for _, ent in ents.Iterator() do
        if ent:IsDormant() then continue end

        local isNPC = ent:IsNPC()
        local isPlayer = ent:IsPlayer()
        local isNextbot = ent:IsNextBot()

        if not isNPC and not isPlayer and not isNextbot then continue end

        LOOKING_ENTS[#LOOKING_ENTS + 1] = ent
    end
    print(("LOOKING_ENTS: Got %d entities for this table"):format(#LOOKING_ENTS))

    -- Reset skeleton running aniamtion
    MAT_SKELETON:SetInt("$frame", 0)
    IS_SKELETON_HERE = true
    SKELETON_PASSED_TIME = 0

    -- Have to use SysTime() since timer library uses CurTime,
    --  which is affected by host_timescale
    local pauseTime = SysTime()
    local pauseInterval1 = 0.7
    local pauseInterval2 = 4.5 - pauseInterval1
    hook.Add("Think", "CL.LetsTakeALook.CheckPauseState", function()
        if SysTime() - pauseTime >= pauseInterval1 then
            local lply = LocalPlayer()

            lply:EmitSound(
                "letstakealook/carl_the_skeleton.mp3",
                75,
                100,
                0.7,
                CHAN_AUTO
            )

            IS_SKELETON_HERE = false
            IS_LOOKING = true

            pauseTime = SysTime()
            hook.Add("Think", "CL.LetsTakeALook.CheckPauseState", function()
                if SysTime() - pauseTime >= pauseInterval2 then
                    IS_LOOKING = false

                    hook.Remove("Think", "CL.LetsTakeALook.CheckPauseState")
                end
            end)
        end
    end)
end

net.Receive("SV.LetsTakeALook", LetsTakeALook)
