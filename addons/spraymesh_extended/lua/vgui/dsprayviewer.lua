--
-- Displays all active sprays in a viewable panel.
-- Useful for moderation, or if you just want to get the URL for other peoples' sprays.
--
surface.CreateFont("DSprayViewer.NameDisplay", {
    font = "Roboto-Regular",
    size = 17
})

local PANEL = {}

function PANEL:Init()
    self:SetTitle("Player Spray Viewer")
    self:SetIcon("icon16/user.png")

    local fWidth = math.max(ScrW() * 0.72, 1056)
    local fHeight = math.max(ScrH() * 0.7, 594)
    self:SetSize(fWidth, fHeight)
    self:SetMinWidth(1056)
    self:SetMinHeight(594)

    self:SetSizable(true)
    self:SetDraggable(true)
    self:SetScreenLock(true)

    self:Center()
    self:MakePopup()

    spraymesh_derma_utils.EnableMaximizeButton(self)

    local scroll = vgui.Create("DScrollPanel", self)
    scroll:Dock(FILL)

    local iconlayout = vgui.Create("DIconLayout", scroll)
    iconlayout:DockMargin(4, 4, 4, 4)
    iconlayout:Dock(FILL)
    iconlayout:SetSpaceX(12)
    iconlayout:SetSpaceY(12)

    self.Layout = iconlayout

    for id64, sprayData in pairs(spraymesh.SPRAYDATA) do
        local display = vgui.Create("DSprayDisplay", self.Layout)
        display:SetURL(sprayData.url)
        display:SetPlayer(sprayData.PlayerName, id64)
    end
end

-- Register control
derma.DefineControl("DSprayViewer", "SprayMesh Spray Layout", PANEL, "DFrame")

local DISPLAY = {}
DISPLAY.SprayPreviewSize = 256

local MAT_FAKE_TRANSPARENT = Material("spraymesh/fake_transparent.png", "noclamp")

function DISPLAY:Init()
    self:DockPadding(4, 4, 4, 4)
    self:SetMouseInputEnabled(true)
    self:SetCursor("hand")
    self:SetTooltip("Right-click to show options")

    self.NameDisplay = vgui.Create("DLabel", self)
    self.NameDisplay:SetFont("DSprayViewer.NameDisplay")
    self.NameDisplay:SetText("Unknown - Unknown")
    self.NameDisplay:SetTextColor(color_white)
    self.NameDisplay:SetContentAlignment(5)
    self.NameDisplay:DockMargin(0, 0, 0, 4)
    self.NameDisplay:Dock(BOTTOM)

    -- Placeholder image
    self.ImageDisplay = vgui.Create("DPanel", self)
    self.ImageDisplay:SetMouseInputEnabled(false)
    self.ImageDisplay:Dock(FILL)
    self.ImageDisplay.Paint = nil

    self:SetSize(self.SprayPreviewSize + 8, self.SprayPreviewSize + 32 + 8)
end

function DISPLAY:OnMousePressed(keyCode)
    if keyCode == MOUSE_LEFT then
        gui.OpenURL(self.URL)
    elseif keyCode == MOUSE_RIGHT then
        local dMenu = DermaMenu()

        local copyURL = dMenu:AddOption("Copy URL", function()
            SetClipboardText(self.URL)
            notification.AddLegacy("Copied Spray URL to clipboard.", NOTIFY_GENERIC, 5)
        end)
        copyURL:SetIcon("icon16/page_white_copy.png")

        local copySteamID = dMenu:AddOption("Copy Steam ID", function()
            SetClipboardText(util.SteamIDFrom64(self.PlayerID64))
            notification.AddLegacy("Copied " .. self.PlayerName .. "'s Steam ID to clipboard.", NOTIFY_GENERIC, 5)
        end)
        copySteamID:SetIcon("icon16/page_white_copy.png")

        local copySteamID64 = dMenu:AddOption("Copy Steam ID 64", function()
            SetClipboardText(self.PlayerID64)
            notification.AddLegacy("Copied " .. self.PlayerName .. "'s Steam ID 64 to clipboard.", NOTIFY_GENERIC, 5)
        end)
        copySteamID64:SetIcon("icon16/page_white_copy.png")

        dMenu:Open()
    end
end

function DISPLAY:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)
end

function DISPLAY:SetURL(url)
    if not url:StartWith("http") then
        url = "https://" .. url
    end

    self.URL = url

    local sprayPanel = spraymesh_derma_utils.GetPreviewPanel(url)

    self.ImageDisplay.Material = sprayPanel:GetHTMLMaterial()
    self.ImageDisplay.Paint = function(panel, width, height)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(MAT_FAKE_TRANSPARENT)
        surface.DrawTexturedRect(0, 0, width, height)

        -- If the material isn't valid, continuously try to re-fetch the HTML IMaterial
        if not panel.Material then
            if IsValid(sprayPanel) then
                panel.Material = sprayPanel:GetHTMLMaterial()
            end

            return
        end

        surface.SetMaterial(panel.Material)
        surface.DrawTexturedRect(0, 0, width, height)
    end
end

-- Builds the caption (e.g. Player - 12345678)
function DISPLAY:BuildText()
    local msgFormatted = Format(
        "%s - %s",
        self.PlayerName or "Unknown",
        self.PlayerID64 or "Unknown"
    )

    self.NameDisplay:SetText(msgFormatted)
    self.NameDisplay:SizeToContents()
end

function DISPLAY:SetPlayer(name, id64)
    self.PlayerName = name
    self.PlayerID64 = id64

    self:BuildText()
end

derma.DefineControl("DSprayDisplay", "SprayMesh Extended - Spray Display", DISPLAY, "DPanel")
