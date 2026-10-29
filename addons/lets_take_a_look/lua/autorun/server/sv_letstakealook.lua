util.AddNetworkString("SV.LetsTakeALook")

local function SetTimeFreeze(shouldFreeze)
    local flagsToAdd = bit.bor(FL_FROZEN, FL_GODMODE, FL_NOTARGET)

    if shouldFreeze then
        game.SetTimeScale(0.001)

        for _, ply in player.Iterator() do
            ply:AddFlags(flagsToAdd)
        end
        for _, ent in ents.Iterator() do
            -- Store original move type so we can restore it later
            ent.FrozenByTakeALook = {
                move_type = ent:GetMoveType()
            }
            ent:SetMoveType(MOVETYPE_NONE)

            local physObj = ent:GetPhysicsObject()
            if IsValid(physObj) and physObj:IsMotionEnabled() then
                physObj:EnableMotion(false)
            end

            if ent:IsNPC() then
                ent:SetSchedule(SCHED_NPC_FREEZE)
            end
        end
    else
        game.SetTimeScale(1.0)

        for _, ply in player.Iterator() do
            ply:RemoveFlags(flagsToAdd)
        end
        for _, ent in ents.Iterator() do
            if ent.FrozenByTakeALook then
                ent:SetMoveType(ent.FrozenByTakeALook.move_type)

                local physObj = ent:GetPhysicsObject()
                if IsValid(physObj) then
                    physObj:EnableMotion(true)
                end

                ent.FrozenByTakeALook = nil
            end

            if ent:IsNPC() then
                ent:SetCondition(COND.NPC_UNFREEZE)
            end
        end
    end
end

function LetsTakeALook()
    net.Start("SV.LetsTakeALook")
        net.Broadcast()

    -- Have to use SysTime() since timer library uses CurTime,
    --  which is affected by host_timescale/game.SetTimeScale
    local pauseTime = SysTime()
    local pauseInterval1 = 0.7
    local pauseInterval2 = 4.5 - pauseInterval1
    hook.Add("Think", "SV.LetsTakeALook.CheckPauseState", function()
        if SysTime() - pauseTime >= pauseInterval1 then
            -- Make players & the world stop moving while effect is active, makes the effect more funny
            SetTimeFreeze(true)

            pauseTime = SysTime()
            hook.Add("Think", "SV.LetsTakeALook.CheckPauseState", function()
                if SysTime() - pauseTime >= pauseInterval2 then
                    SetTimeFreeze(false)

                    hook.Remove("Think", "SV.LetsTakeALook.CheckPauseState")
                end
            end)
        end
    end)
end

-- Debug
-- LetsTakeALook()

-- Set random time to next take a look
local nextSpookTime = math.random(2 * 60, 6 * 60)
-- local nextSpookTime = math.random(20, 30)
hook.Add("Think", "SV.LetsTakeALook.CheckActivation", function()
    if CurTime() > nextSpookTime then
        nextSpookTime = CurTime() + math.random(30, 4 * 60)
        -- nextSpookTime = CurTime() + math.random(5, 20)
        LetsTakeALook()
    end
end)

concommand.Add("letstakealook", function(ply, cmd, args, argStr)
    if not ply:IsAdmin() then return end

    nextSpookTime = CurTime() + math.random(30, 4 * 60)
    LetsTakeALook()
end)
