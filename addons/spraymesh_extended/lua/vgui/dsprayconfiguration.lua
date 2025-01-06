--
-- Allows the user to configure their saved sprays & SprayMesh Extended settings.
--
surface.CreateFont("DSprayConfiguration.SprayText", {
    font = "Roboto-Regular",
    size = 16
})

local PANEL = {}

local SPRAY_NAME_BG_COLOR = Color(0, 0, 0, 240)

function PANEL:Init()
    self.Sprays = {}

    self.SprayPreviewSize = 256

    self.URL_CVar = GetConVar("spraymesh_url")

    local sprayLayoutSpace = 4
    local settingsWidth = 330

    self:SetTitle("Spray Configuration")
    self:SetIcon("icon16/world_edit.png")

    local minPanelWidth = (self.SprayPreviewSize * 3) + (sprayLayoutSpace * 5) + settingsWidth + 28 + 16
    local panelWidth = math.max(ScrW() * 0.6, minPanelWidth)
    local panelHeight = math.max(ScrH() * 0.8, 700)
    self:SetSize(panelWidth, panelHeight)
    self:SetMinWidth(minPanelWidth)
    self:SetMinHeight(700)

    self:SetSizable(true)
    self:SetDraggable(true)
    self:SetScreenLock(true)

    self:Center()
    self:MakePopup()

    spraymesh_derma_utils.EnableMaximizeButton(self)

    local BG_COLOR_EMBEDDED = Color(0, 0, 0, 120)

    --
    -- Settings base panel
    --
    self.SettingsPanel = self:Add("DPanel")
    self.SettingsPanel:SetWide(settingsWidth)
    self.SettingsPanel:DockMargin(4, 0, 0, 0)
    self.SettingsPanel:DockPadding(12, 8, 12, 8)
    self.SettingsPanel:Dock(RIGHT)
    self.SettingsPanel:SetBackgroundColor(BG_COLOR_EMBEDDED)

    --
    -- Input bar label & base
    --
    self.AddSprayPanel = self:Add("DPanel")
    self.AddSprayPanel:Dock(TOP)
    self.AddSprayPanel:DockMargin(0, 0, 0, 4)
    self.AddSprayPanel:DockPadding(12, 8, 12, 8)
    self.AddSprayPanel:SetTall(256)
    self.AddSprayPanel:SetBackgroundColor(BG_COLOR_EMBEDDED)

    self.AddSprayLabel = self.AddSprayPanel:Add("DLabel")
    self.AddSprayLabel:SetContentAlignment(5)
    self.AddSprayLabel:SetFont("DermaLarge")
    self.AddSprayLabel:SetText("Add Spray")
    self.AddSprayLabel:SetTextColor(color_white)
    self.AddSprayLabel:SizeToContents()
    self.AddSprayLabel:DockMargin(0, 0, 0, 4)
    self.AddSprayLabel:Dock(TOP)

    self.TopInputBar = self.AddSprayPanel:Add("DPanel")
    self.TopInputBar:SetTall(28)
    self.TopInputBar:Dock(TOP)
    self.TopInputBar:SetBackgroundColor(BG_COLOR_EMBEDDED)
    self.TopInputBar:DockMargin(0, 0, 0, 4)
    self.TopInputBar:DockPadding(4, 4, 4, 4)

    self.AddSprayPanel:InvalidateChildren()
    self.AddSprayPanel:SizeToChildren(false, true)

    --
    -- Spray preview grid
    --
    self.SavedSpraysPanel = self:Add("DPanel")
    self.SavedSpraysPanel:Dock(FILL)
    self.SavedSpraysPanel:DockMargin(0, 0, 0, 0)
    self.SavedSpraysPanel:DockPadding(12, 8, 12, 8)
    self.SavedSpraysPanel:SetBackgroundColor(BG_COLOR_EMBEDDED)

    self.SavedSpraysLabel = self.SavedSpraysPanel:Add("DLabel")
    self.SavedSpraysLabel:SetContentAlignment(5)
    self.SavedSpraysLabel:SetFont("DermaLarge")
    self.SavedSpraysLabel:SetText("Saved Sprays")
    self.SavedSpraysLabel:SetTextColor(color_white)
    self.SavedSpraysLabel:SizeToContents()
    self.SavedSpraysLabel:DockMargin(0, 0, 0, 4)
    self.SavedSpraysLabel:Dock(TOP)

    self.SavedSpraySearch = self.SavedSpraysPanel:Add("DTextEntry")
    self.SavedSpraySearch:DockMargin(0, 0, 0, 8)
    self.SavedSpraySearch:Dock(TOP)
    self.SavedSpraySearch:SetPlaceholderText("Search for a spray...")
    self.SavedSpraySearch:SetUpdateOnType(true)
    self.SavedSpraySearch:SetMaximumCharCount(256)
    self.SavedSpraySearch:SetTextColor(color_white)

    self.SavedSpraySearch.CursorColor = color_white
    self.SavedSpraySearch.BGColor = Color(0, 0, 0, 220)
    self.SavedSpraySearch.BGColorDisabled = Color(50, 50, 50, 220)
    self.SavedSpraySearch.BaseIndicatorColor = Color(130, 130, 130)
    self.SavedSpraySearch.IndicatorColor = self.SavedSpraySearch.BaseIndicatorColor

    self.SavedSpraySearch.Paint = function(panel, w, h)
        draw.RoundedBox(6, 0, 0, w, h, panel.IndicatorColor)
        draw.RoundedBox(4, 2, 2, w - 4, h - 4, panel.BGColor)

        local text = panel:GetText()
        if (not text or text == "") and panel:IsEnabled() then
            panel:SetText("Search for a spray...")
            panel:DrawTextEntryText(panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel.CursorColor)
            panel:SetText(text)
        else
            panel:DrawTextEntryText(panel:GetTextColor(), panel:GetHighlightColor(), panel.CursorColor)
        end
    end

    self.SavedSpraySearch.OnValueChange = function(panel, text)
        self:FilterSearch(text)
    end

    self.Scroll = self.SavedSpraysPanel:Add("DScrollPanel")
    self.Scroll:Dock(FILL)

    self.IconLayout = self.Scroll:Add("DIconLayout")
    self.IconLayout:Dock(FILL)
    self.IconLayout:SetSpaceX(sprayLayoutSpace)
    self.IconLayout:SetSpaceY(sprayLayoutSpace)

    -- Load saved sprays
    local savedSprays = spraylist.GetSprays()
    if savedSprays and #savedSprays > 0 then
        for _, savedSprayData in ipairs(savedSprays) do
            local url = savedSprayData.url
            local name = savedSprayData.name

            self:AddSpray(url, name)
        end
    end

    --
    -- Settings
    --
    self.SettingsLabel = self.SettingsPanel:Add("DLabel")
    self.SettingsLabel:SetContentAlignment(5)
    self.SettingsLabel:SetFont("DermaLarge")
    self.SettingsLabel:SetText("Settings")
    self.SettingsLabel:SetTextColor(color_white)
    self.SettingsLabel:SizeToContents()
    self.SettingsLabel:DockMargin(0, 0, 0, 4)
    self.SettingsLabel:Dock(TOP)

    self.EnableSprays = self.SettingsPanel:Add("DCheckBoxLabel")
    self.EnableSprays:SetText("Enable sprays")
    self.EnableSprays:SetTextColor(color_white)
    self.EnableSprays:SetConVar("spraymesh_enablesprays")
    self.EnableSprays:DockMargin(0, 0, 0, 4)
    self.EnableSprays:Dock(TOP)

    self.EnableAnimatedSprays = self.SettingsPanel:Add("DCheckBoxLabel")
    self.EnableAnimatedSprays:SetText("Enable animated sprays")
    self.EnableAnimatedSprays:SetTextColor(color_white)
    self.EnableAnimatedSprays:SetConVar("spraymesh_enableanimated")
    self.EnableAnimatedSprays:DockMargin(0, 0, 0, 4)
    self.EnableAnimatedSprays:Dock(TOP)

    self.ShowActiveSpraysButton = self.SettingsPanel:Add("DButton")
    self.ShowActiveSpraysButton:SetText("Show all active player sprays")
    self.ShowActiveSpraysButton:Dock(BOTTOM)
    self.ShowActiveSpraysButton:DockMargin(16, 4, 16, 0)
    self.ShowActiveSpraysButton.DoClick = function()
        vgui.Create("DSprayViewer")
    end

    self.ReloadSpraysButton = self.SettingsPanel:Add("DButton")
    self.ReloadSpraysButton:SetText("Reload all sprays")
    self.ReloadSpraysButton:Dock(BOTTOM)
    self.ReloadSpraysButton:DockMargin(16, 4, 16, 0)
    self.ReloadSpraysButton.DoClick = function()
        RunConsoleCommand("spraymesh_reload")

        notification.AddLegacy("Reloaded sprays.", NOTIFY_GENERIC, 5)
    end

    self.HelpButton = self.SettingsPanel:Add("DButton")
    self.HelpButton:SetText("Help & Info")
    self.HelpButton:Dock(BOTTOM)
    self.HelpButton:DockMargin(16, 4, 16, 0)
    self.HelpButton.DoClick = function()
        RunConsoleCommand("spraymesh_help")
    end

    --
    -- Input bar (URL input, name input, 'add spray' button)
    --
    self.AddButton = self.TopInputBar:Add("DButton")
    self.AddButton:SetText("Add spray")
    self.AddButton:SizeToContents()
    self.AddButton:Dock(RIGHT)
    self.AddButton.DoClick = function()
        if IsValid(self.InputURL) then
            local urlToAdd = self.InputURL:GetText()
            local name = self.InputSprayName:GetText()
            name = Either(name == "", nil, name)

            if self:IsValidURL(urlToAdd) and name then
                -- Let player know that the spray was successfully added
                surface.PlaySound("ui/buttonclick.wav")

                self:AddSpray(urlToAdd, name)
                spraylist.AddSpray(urlToAdd, name)

                -- Stop the flashing animations for the input boxes if they're still playing
                self.InputURL:Stop()
                self.InputSprayName:Stop()

                -- Set the input box text, color & enabled status to defaults
                self.InputURL:SetText("")
                self.InputURL.IndicatorColor = self.InputURL.BaseIndicatorColor

                self.InputSprayName:SetText("")
                self.InputSprayName.IndicatorColor = self.InputSprayName.BaseIndicatorColor
                self.InputSprayName:SetEnabled(false)
            else
                surface.PlaySound("resource/warning.wav")

                self.InputURL:Stop()
                self.InputSprayName:Stop()

                local panelToFlash = self.InputURL
                if self:IsValidURL(urlToAdd) and not name then
                    panelToFlash = self.InputSprayName
                end

                local baseColor = panelToFlash.BaseIndicatorColor

                -- Play flash animation on the incomplete text entry, so the player knows what is failing
                local anim = panelToFlash:NewAnimation(0.4, 0, 0.5, function(animTable, panel)
                    panel.IndicatorColor = baseColor
                end)
                anim.StartColor = Color(255, 0, 0)
                anim.EndColor = Color(baseColor.r, baseColor.g, baseColor.b)
                anim.Think = function(animData, panel, fraction)
                    local lerpR = Lerp(fraction, animData.StartColor.r, animData.EndColor.r)
                    local lerpG = Lerp(fraction, animData.StartColor.g, animData.EndColor.g)
                    local lerpB = Lerp(fraction, animData.StartColor.b, animData.EndColor.b)

                    panel.IndicatorColor.r = lerpR
                    panel.IndicatorColor.g = lerpG
                    panel.IndicatorColor.b = lerpB
                end
            end
        end

        if IsValid(self.InputURL) then
            self.InputURL:RequestFocus()
        end
    end

    self.InputSprayName = self.TopInputBar:Add("DTextEntry")
    self.InputSprayName:DockMargin(0, 0, 4, 0)
    self.InputSprayName:Dock(RIGHT)
    self.InputSprayName:SetWide(panelWidth * 0.25)
    self.InputSprayName:SetPlaceholderText("Enter a name for your spray...")
    self.InputSprayName:SetUpdateOnType(true)
    self.InputSprayName:SetEnabled(false)
    self.InputSprayName:SetMaximumCharCount(64)
    self.InputSprayName:SetTextColor(color_white)

    self.InputSprayName.CursorColor = color_white
    self.InputSprayName.BGColor = Color(0, 0, 0, 220)
    self.InputSprayName.BGColorDisabled = Color(50, 50, 50, 220)
    self.InputSprayName.BaseIndicatorColor = Color(170, 170, 170)
    self.InputSprayName.IndicatorColor = self.InputSprayName.BaseIndicatorColor

    self.InputSprayName.Paint = function(panel, w, h)
        if not panel:IsEnabled() then
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, panel.BGColorDisabled)
        else
            draw.RoundedBox(6, 0, 0, w, h, panel.IndicatorColor)
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, panel.BGColor)
        end

        local text = panel:GetText()
        if (not text or text == "") and panel:IsEnabled() then
            panel:SetText("Enter a name for your spray...")
            panel:DrawTextEntryText(panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel.CursorColor)
            panel:SetText(text)
        else
            panel:DrawTextEntryText(panel:GetTextColor(), panel:GetHighlightColor(), panel.CursorColor)
        end
    end
    self.InputSprayName.OnEnter = function(pnl)
        if IsValid(self.AddButton) then
            self.AddButton:DoClick()
        end
    end

    self.InputURL = self.TopInputBar:Add("DTextEntry")
    self.InputURL:DockMargin(0, 0, 4, 0)
    self.InputURL:Dock(FILL)
    self.InputURL:SetPlaceholderText("Enter a URL...")
    self.InputURL:SetUpdateOnType(true)
    self.InputURL:SetTextColor(color_white)

    self.InputURL.CursorColor = color_white
    self.InputURL.BGColor = Color(0, 0, 0, 220)
    self.InputURL.BaseIndicatorColor = Color(179, 0, 0)
    self.InputURL.IndicatorColor = self.InputURL.BaseIndicatorColor

    self.InputURL.Paint = function(panel, w, h)
        draw.RoundedBox(6, 0, 0, w, h, panel.IndicatorColor)
        draw.RoundedBox(4, 2, 2, w - 4, h - 4, panel.BGColor)

        local text = panel:GetText()
        if not text or text == "" then
            panel:SetText("Enter a URL...")
            panel:DrawTextEntryText(panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel.CursorColor)
            panel:SetText(text)
        else
            panel:DrawTextEntryText(panel:GetTextColor(), panel:GetHighlightColor(), panel.CursorColor)
        end
    end
    self.InputURL.OnValueChange = function(panel, text)
        self.InputURL:Stop()
        self.InputSprayName:Stop()

        if self:IsValidURL(text) then
            panel.IndicatorColor = Color(0, 179, 0)

            self.InputSprayName:SetEnabled(true)
        else
            panel.IndicatorColor = Color(179, 0, 0)

            self.InputSprayName:SetEnabled(false)
        end
    end
    self.InputURL.OnEnter = function(pnl)
        if IsValid(self.AddButton) then
            self.AddButton:DoClick()
        end
    end
end

function PANEL:IsValidURL(urlToCheck)
    return spraymesh.IsValidAnyURL(urlToCheck)
end

local MAT_FAKE_TRANSPARENT = Material("spraymesh/fake_transparent.png", "noclamp")

function PANEL:AddSpray(url, name)
    -- If the spray already exists
    local existingSpray = self.Sprays[url]
    if existingSpray and IsValid(existingSpray) and IsValid(existingSpray:GetParent()) then
        existingSpray:GetParent():Remove()
        self.Sprays[url] = nil
    end

    local newSpray = self.IconLayout:Add("DPanel")
    newSpray:SetSize(self.SprayPreviewSize, self.SprayPreviewSize)
    newSpray:SetMouseInputEnabled(true)
    newSpray:SetCursor("hand")
    newSpray:SetTooltip("Right-click for options")

    newSpray.URL = string.gsub(url, "https?://", "")
    newSpray.Name = name

    local sprayPanel = spraymesh_derma_utils.GetPreviewPanel(url)

    newSpray.Material = sprayPanel:GetHTMLMaterial()
    newSpray.Paint = function(panel, width, height)
        -- Draw transparency grid, so the user has a better idea of which parts
        --  of the image are transparent
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

    newSpray.PaintOver = function(panel, width, height)
        if panel.URL == self.URL_CVar:GetString() then
            --surface.SetDrawColor(255, 255, 255, 30)
            --surface.DrawRect(0, 0, width, height)

            local blink = Lerp((math.sin(RealTime() * 5) + 1) / 2, 200, 255)

            surface.SetDrawColor(255, blink, 0, 255)
            surface.DrawOutlinedRect(0, 0, width, height, 6)
        end

        draw.WordBox(8, width / 2, height - 8, panel.Name, "DSprayConfiguration.SprayText", SPRAY_NAME_BG_COLOR, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end

    newSpray.OnMousePressed = function(panel, keyCode)
        if keyCode == MOUSE_LEFT then
            surface.PlaySound("ui/buttonclick.wav")

            notification.AddLegacy("Selected spray '" .. name .. "'.", NOTIFY_GENERIC, 3)

            RunConsoleCommand("spraymesh_url", panel.URL)
        elseif keyCode == MOUSE_RIGHT then
            local dmenu = DermaMenu()

            local copyURL = dmenu:AddOption("Copy URL", function()
                local copiedURL = "https://" .. panel.URL
                SetClipboardText(copiedURL)

                notification.AddLegacy("Copied spray URL clipboard.", NOTIFY_GENERIC, 5)
            end)
            copyURL:SetIcon("icon16/page_white_copy.png")

            local sayInChat = dmenu:AddOption("Send URL to chat", function()
                local urlToSend = panel.URL
                RunConsoleCommand("say", "https://" .. urlToSend)

                self:Close()
            end)
            sayInChat:SetIcon("icon16/comment_add.png")

            local sayInTeamChat = dmenu:AddOption("Send URL to team chat", function()
                local urlToSend = panel.URL
                RunConsoleCommand("say_team", "https://" .. urlToSend)

                self:Close()
            end)
            sayInTeamChat:SetIcon("icon16/comments_add.png")

            local remove = dmenu:AddOption("Remove", function()
                Derma_Query(
                    "Are you sure you want to delete the spray \"" .. panel.Name .. "\"?",
                    "Confirmation:",
                    "Delete",
                    function()
                        self.Sprays["https://" .. panel.URL] = nil

                        spraylist.RemoveSpray("https://" .. panel.URL)

                        panel:Remove()

                        notification.AddLegacy("Spray deleted.", NOTIFY_GENERIC, 5)
                    end,
                    "Cancel",
                    function() end
                )
            end)
            remove:SetIcon("icon16/cross.png")

            dmenu:Open()
        end
    end

    self.Sprays[url] = newSpray

    -- Sort sprays
    local sortedChildrenTb = self.IconLayout:GetChildren()

    table.sort(sortedChildrenTb, function(a, b)
        return (a.Name or ""):lower() < (b.Name or ""):lower()
    end)

    for index, panel in ipairs(sortedChildrenTb) do
        panel:SetZPos(index)
    end

    self.IconLayout:Layout()

    -- Gotta give time to let the newly-added entry and the IconLayout adjust their sizes, then
    -- we adjust the DScrollPanel canvas size. From my tests, this is only necessary
    -- when the player adds their FIRST spray to the list
    timer.Simple(0, function()
        if IsValid(self.Scroll) then
            self.Scroll:InvalidateLayout()
        end
    end)
end

function PANEL:FilterSearch(text)
    for url, sprayPanel in pairs(self.Sprays) do
        if not IsValid(sprayPanel) then continue end

        -- Since spray panels are wrapped inside a parent, we want to target visibility for the parent instead
        local panelParent = sprayPanel:GetParent()

        local queryIsEmpty = string.Trim(text, " ") == ""
        local textInURL = string.find(url:lower(), text:lower(), 0, true) ~= nil
        local textInName = string.find(sprayPanel.Name:lower(), text:lower(), 0, true) ~= nil

        if queryIsEmpty or textInURL or textInName then
            panelParent:SetVisible(true)
        else
            panelParent:SetVisible(false)
        end
    end

    self.IconLayout:Layout()
end

-- Register control
derma.DefineControl("DSprayConfiguration", "Spraymesh Extended - Configurator", PANEL, "DFrame")
