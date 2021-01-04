local vm_velocity_enabled = CreateClientConVar("vm_velocity_enabled", "1", true, false, "Whether or not viewmodel velocity is enabled."):GetBool()
cvars.AddChangeCallback("vm_velocity_enabled", function(_, _, newval) vm_velocity_enabled = tobool(newval) end)

local vm_velocity_max = CreateClientConVar("vm_velocity_max", "700", true, false, "Maximum velocity to be applied."):GetFloat()
cvars.AddChangeCallback("vm_velocity_max", function(_, _, newval) vm_velocity_max = newval end)

local old_vel = Vector(0, 0, 0) --placeholder value

hook.Add("CalcViewModelView", "vm_velocity", function(_, _, _, _, newPos, newAng)
    if vm_velocity_enabled then
        vel = LocalPlayer():GetVelocity()
        vel_capped = Vector(0, 0, math.Clamp(vel.z, -vm_velocity_max, vm_velocity_max)) --limit max value so viewmodels don't go too far off-screen
        lerped_vel = LerpVector(FrameTime() * 40, old_vel, vel_capped) --lerp
        old_vel = lerped_vel
        return newPos - (lerped_vel * 0.006), newAng
    end
end)
