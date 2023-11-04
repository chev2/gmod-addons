-- Add SprayMesh Extended to the Sandbox context menu
list.Set("DesktopWindows", "SprayMeshExtended", {
    title = "SprayMesh",
    icon = "icon64/spraymesh.png",

    width = 960,
    height = 700,

    onewindow = true,

    init = function(icon, window)
        -- Remove basic frame and replace with our custom VGUI element
        window:Remove()

        if IsValid(spraymesh.SETTINGS_PANEL) then spraymesh.SETTINGS_PANEL:Remove() end
        local mainWindow = vgui.Create("DSprayConfiguration")
        spraymesh.SETTINGS_PANEL = mainWindow

        icon.Window = mainWindow
    end
})
