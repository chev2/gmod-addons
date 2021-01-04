local no_viewmodel_sway_enabled = CreateClientConVar("no_viewmodel_sway_enabled", "1", true, false, "Whether or not viewmodel velocity is enabled."):GetBool()
cvars.AddChangeCallback("no_viewmodel_sway_enabled", function(_, _, newval) no_viewmodel_sway_enabled = tobool(newval) end)
hook.Add("CalcViewModelView", "no_viewmodel_sway", function(_, _, oldPos, oldAng, _, _) if no_viewmodel_sway_enabled then return oldPos, oldAng end end)
