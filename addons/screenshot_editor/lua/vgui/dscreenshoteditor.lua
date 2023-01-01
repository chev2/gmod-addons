local PANEL = {}

local BLUR_MATERIAL = Material("pp/blurscreen")

local BUTTON_COLOR_NORMAL = Color(50, 50, 50, 200)
local BUTTON_COLOR_HOVER = Color(70, 70, 70, 200)
local BUTTON_COLOR_DOWN = Color(90, 90, 90, 200)
local BUTTON_COLOR_DISABLED = Color(30, 30, 30, 200)
local BUTTON_PAINT = function(panel, w, h)
    local col = BUTTON_COLOR_NORMAL

    if panel.Depressed then
        col = BUTTON_COLOR_DOWN
    elseif panel:IsHovered() then
        col = BUTTON_COLOR_HOVER
    end

    draw.RoundedBox(8, 0, 0, w, h, col)
end

local BUTTON_COLOR_OUTLINE = Color(0, 0, 0)
local BUTTON_COLOR_OUTLINE_FLASH = Color(0, 0, 0)
local BUTTON_PAINT_OUTLINE = function(panel, w, h)
    local col = BUTTON_COLOR_NORMAL
    local outlineCol = BUTTON_COLOR_OUTLINE

    if panel.Depressed then
        col = BUTTON_COLOR_DOWN
    elseif panel:IsHovered() then
        col = BUTTON_COLOR_HOVER
    end

    if not panel:IsEnabled() then
        col = BUTTON_COLOR_DISABLED

        local curBright = math.Remap(math.sin(SysTime() * 5), -1, 1, 50, 80)

        BUTTON_COLOR_OUTLINE_FLASH.r = curBright
        BUTTON_COLOR_OUTLINE_FLASH.g = curBright
        BUTTON_COLOR_OUTLINE_FLASH.b = curBright

        outlineCol = BUTTON_COLOR_OUTLINE_FLASH
    end

    draw.RoundedBox(8, 0, 0, w, h, outlineCol)
    draw.RoundedBox(6, 2, 2, w - 4, h - 4, col)
end

surface.CreateFont("ScreenshotEditorLabel", {
    font = "Roboto",
    size = 16,
    weight = 500,
    antialias = true,
})

surface.CreateFont("ScreenshotEditorProcessing", {
    font = "Roboto",
    size = 32,
    weight = 500,
    antialias = true,
})

surface.CreateFont("ScreenshotEditorArrow", {
    font = "Consolas",
    size = 24,
    weight = 500,
    antialias = true
})

function PANEL:Init()
    local FILTER_DATA = screenshot_editor.GetFilters()
    local FRAME_DATA = screenshot_editor.GetFrames()

    local width, height = ScrW(), ScrH()
    self:SetSize(width, height)

    self:DockPadding(16, 16, 16, 16)

    self.CurrentScreenshot = Material("lights/white")
    self.CurrentFilter = 0
    self.CurrentFrame = 0
    self.ShowEditedScreenshots = true
    self.SearchFilter = ""

    local toggleButtonSize = 32

    local controlsBase = vgui.Create("DPanel", self)
    controlsBase:SetSize(width * 0.225, height)
    controlsBase:AlignLeft(0)
    controlsBase:DockPadding(8, 8, 8, 8)
    controlsBase.Paint = function(panel, w, h)
        w = w - (toggleButtonSize + 16)

        -- Blur
        render.SetScissorRect(panel:GetX(), 0, w + panel:GetX(), h, true)
            local x, y = panel:LocalToScreen(0, 0)

            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(BLUR_MATERIAL)

            for i = 0.33, 1, 0.33 do
                BLUR_MATERIAL:SetFloat("$blur", 8 * i)
                BLUR_MATERIAL:Recompute()

                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
            end
        render.SetScissorRect(0, 0, 0, 0, false)

        -- Darken BG
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)
    end

    self.ControlsBase = controlsBase

    local toggleButtonMargin = (height - 16 - 32) / 2
    local toggleControlsButton = vgui.Create("DButton", controlsBase)
    toggleControlsButton:DockMargin(16, toggleButtonMargin, 0, toggleButtonMargin)
    toggleControlsButton:Dock(RIGHT)
    toggleControlsButton:SetFont("ScreenshotEditorArrow")
    toggleControlsButton:SetText("<")
    toggleControlsButton:SetWide(32)
    toggleControlsButton:SetTextColor(color_white)
    toggleControlsButton:SetTooltip("Hide Controls Menu")
    toggleControlsButton.IsHidden = false
    toggleControlsButton.Paint = BUTTON_PAINT
    toggleControlsButton.DoClick = function(panel)
        panel.IsHidden = not panel.IsHidden

        local xPos = panel.IsHidden and -self.ControlsBase:GetWide() + (toggleButtonSize + 16) or 0

        self.ControlsBase:MoveTo(xPos, 0, 0.5, 0, 0.5)

        panel:SetText(panel.IsHidden and ">" or "<")
        panel:SetTooltip(panel.IsHidden and "Show Controls Menu" or "Hide Controls Menu")
    end

    --[[

        Filter control

    ]]
    local filterTall = 48
    local filterPadding = 4

    local filterBase = vgui.Create("DPanel", controlsBase)
    filterBase:Dock(TOP)
    filterBase:DockMargin(0, 0, 0, 8)
    filterBase:SetTall(filterTall)
    filterBase:DockPadding(filterPadding, filterPadding, filterPadding, filterPadding)

    filterBase.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 240))
    end

    local filterButtonLeft = vgui.Create("DButton", filterBase)
    filterButtonLeft:DockMargin(0, 0, 8, 0)
    filterButtonLeft:Dock(LEFT)
    filterButtonLeft:SetWide(filterTall - (filterPadding * 2))
    filterButtonLeft:SetFont("ScreenshotEditorArrow")
    filterButtonLeft:SetText("<")
    filterButtonLeft:SetTextColor(color_white)
    filterButtonLeft.Paint = BUTTON_PAINT
    filterButtonLeft.DoClick = function(panel)
        self.CurrentFilter = (self.CurrentFilter - 1) % #FILTER_DATA

        self.CurrentFilterLabel:SetText("Current Filter: " .. FILTER_DATA[self.CurrentFilter + 1].FilterName)
    end

    local filterButtonRight = vgui.Create("DButton", filterBase)
    filterButtonRight:DockMargin(8, 0, 0, 0)
    filterButtonRight:Dock(RIGHT)
    filterButtonRight:SetWide(filterTall - (filterPadding * 2))
    filterButtonRight:SetFont("ScreenshotEditorArrow")
    filterButtonRight:SetText(">")
    filterButtonRight:SetTextColor(color_white)
    filterButtonRight.Paint = BUTTON_PAINT
    filterButtonRight.DoClick = function(panel)
        self.CurrentFilter = (self.CurrentFilter + 1) % #FILTER_DATA

        self.CurrentFilterLabel:SetText("Current Filter: " .. FILTER_DATA[self.CurrentFilter + 1].FilterName)
    end

    local currentFilterName = vgui.Create("DLabel", filterBase)
    currentFilterName:SetFont("ScreenshotEditorLabel")
    currentFilterName:SetText("Current Filter: None")
    currentFilterName:Dock(FILL)
    currentFilterName:SetContentAlignment(5)

    self.CurrentFilterLabel = currentFilterName

    --[[

        Frame control

    ]]
    local frameBase = vgui.Create("DPanel", controlsBase)
    frameBase:Dock(TOP)
    frameBase:DockMargin(0, 0, 0, 8)
    frameBase:SetTall(filterTall)
    frameBase:DockPadding(filterPadding, filterPadding, filterPadding, filterPadding)

    frameBase.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 240))
    end

    local frameButtonLeft = vgui.Create("DButton", frameBase)
    frameButtonLeft:DockMargin(0, 0, 8, 0)
    frameButtonLeft:Dock(LEFT)
    frameButtonLeft:SetWide(filterTall - (filterPadding * 2))
    frameButtonLeft:SetFont("ScreenshotEditorArrow")
    frameButtonLeft:SetText("<")
    frameButtonLeft:SetTextColor(color_white)
    frameButtonLeft.Paint = BUTTON_PAINT
    frameButtonLeft.DoClick = function(panel)
        self.CurrentFrame = (self.CurrentFrame - 1) % #FRAME_DATA

        self.CurrentFrameLabel:SetText("Current Frame: " .. FRAME_DATA[self.CurrentFrame + 1].FrameName)
    end

    local frameButtonRight = vgui.Create("DButton", frameBase)
    frameButtonRight:DockMargin(8, 0, 0, 0)
    frameButtonRight:Dock(RIGHT)
    frameButtonRight:SetWide(filterTall - (filterPadding * 2))
    frameButtonRight:SetFont("ScreenshotEditorArrow")
    frameButtonRight:SetText(">")
    frameButtonRight:SetTextColor(color_white)
    frameButtonRight.Paint = BUTTON_PAINT
    frameButtonRight.DoClick = function(panel)
        self.CurrentFrame = (self.CurrentFrame + 1) % #FRAME_DATA

        self.CurrentFrameLabel:SetText("Current Frame: " .. FRAME_DATA[self.CurrentFrame + 1].FrameName)
    end

    local currentFrameName = vgui.Create("DLabel", frameBase)
    currentFrameName:SetFont("ScreenshotEditorLabel")
    currentFrameName:SetText("Current Frame: None")
    currentFrameName:Dock(FILL)
    currentFrameName:SetContentAlignment(5)

    self.CurrentFrameLabel = currentFrameName

    --[[
        List filters
    ]]
    local showEditedScreenshots = vgui.Create("DCheckBoxLabel", controlsBase)
    showEditedScreenshots:DockMargin(0, 0, 0, 8)
    showEditedScreenshots:Dock(TOP)
    showEditedScreenshots:SetText("Show Edited Screenshots")
    showEditedScreenshots:SetValue(true)
    showEditedScreenshots.OnChange = function(panel, isChecked)
        self.ShowEditedScreenshots = isChecked

        self:FilterScreenshotsList()
    end

    local searchFilter = vgui.Create("DTextEntry", controlsBase)
    searchFilter:DockMargin(0, 0, 0, 8)
    searchFilter:Dock(TOP)
    searchFilter:SetPlaceholderText("Search...")
    searchFilter:SetUpdateOnType(true)
    searchFilter.OnValueChange = function(panel, text)
        self.SearchFilter = text

        self:FilterScreenshotsList()
    end

    --[[

        Save & close buttons

    ]]
    local closeButton = vgui.Create("DButton", controlsBase)
    closeButton:Dock(BOTTOM)
    closeButton:SetTall(32)
    closeButton:SetText("Close")
    closeButton:SetTextColor(color_white)
    closeButton.Paint = BUTTON_PAINT_OUTLINE
    closeButton.DoClick = function()
        self:Remove()
    end

    local saveButton = vgui.Create("DButton", controlsBase)
    saveButton:Dock(BOTTOM)
    saveButton:DockMargin(0, 0, 0, 8)
    saveButton:SetTall(32)
    saveButton:SetText("Save")
    saveButton:SetTextColor(color_white)
    saveButton.Paint = BUTTON_PAINT_OUTLINE
    saveButton.DoClick = function(panel)
        local fileName = game.GetMap() .. "_" .. os.time() .. "_" .. FrameNumber() .. "_edit"
        RunConsoleCommand("jpeg", fileName, "100")

        timer.Simple(FrameTime(), function()
            if IsValid(panel) then
                panel:SetText("Screenshot saved!")
            end
        end)

        timer.Simple(3, function()
            if IsValid(panel) then
                panel:SetText("Save")
            end
        end)
    end

    --[[

        Refresh screenshots button

    ]]
    local refreshScreenshotsButton = vgui.Create("DButton", controlsBase)
    refreshScreenshotsButton:Dock(BOTTOM)
    refreshScreenshotsButton:DockMargin(0, 0, 0, 8)
    refreshScreenshotsButton:SetTall(32)
    refreshScreenshotsButton:SetText("Refresh Screenshots List")
    refreshScreenshotsButton:SetTextColor(color_white)
    refreshScreenshotsButton.Paint = BUTTON_PAINT_OUTLINE
    refreshScreenshotsButton.DoClick = function(panel)
        local fcScroll = self.FileScroll
        if not IsValid(fcScroll) then return end

        panel:SetText("Refreshing Screenshots...")
        panel:SetEnabled(false)

        fcScroll:Clear()

        local processingLabel = vgui.Create("DLabel", fcScroll)
        processingLabel:Dock(TOP)
        processingLabel:SetText("Processing...")
        processingLabel:SetFont("ScreenshotEditorProcessing")
        processingLabel:SizeToContentsX()
        processingLabel:SetTall(128)
        processingLabel:SetContentAlignment(5)

        if not screenshot_editor.IsProcessingScreenshots() then
            screenshot_editor.ProcessScreenshots()
        end

        hook.Add("ScreenshotEditorProcessingFinished", "ScreenshotEditorRefreshScreenshots", function()
            if IsValid(fcScroll) then
                fcScroll:Clear()
            end

            if IsValid(self) then
                self:AddScreenshotsToList()
            end

            if IsValid(panel) then
                panel:SetText("Refresh Screenshots List")
                panel:SetEnabled(true)
            end
        end)
    end

    --[[

        File chooser control

    ]]
    local fcScroll = vgui.Create("DScrollPanel", controlsBase)
    fcScroll:DockMargin(0, 0, 0, 8)
    fcScroll:Dock(FILL)
    --fcScroll:SetTall(height * 0.5)
    fcScroll.OnItemSelected = function(panel, item)
        panel.VBar:Stop()
        panel.VBar:AnimateTo(item:GetY(), 0.3, 0, 0.4)

        self.CurrentScreenshot = Material("../screenshots/" .. item.FileName, "smooth")
    end

    self.FileScroll = fcScroll

    controlsBase:SetRenderInScreenshots(false)

    self:SetKeyboardInputEnabled(true)

    self:Center()
    self:MakePopup()

    -- In case screenshots are still being processed
    if screenshot_editor.IsProcessingScreenshots() then
        refreshScreenshotsButton:DoClick()
    else
        self:AddScreenshotsToList()
    end
end

-- Add screenshots to the DListView
function PANEL:AddScreenshotsToList()
    local fileScroll = self.FileScroll
    if not IsValid(fileScroll) then return end

    fileScroll:Clear()

    for fileName, fileTime in pairs(screenshot_editor.GetScreenshots()) do
        fileName = fileName:Replace("screenshots/", "")

        local fileEntry = self.FileScroll:Add("DScreenshotFileEntry")
        fileEntry:DockMargin(0, 0, 4, 4)
        fileEntry:Dock(TOP)

        fileEntry:SetWide(self.ControlsBase:GetWide() - 16)
        fileEntry:SetFileName(fileName)
        fileEntry:SetDateCreated(fileTime)

        fileEntry.LayoutPanel = self.FileScroll
    end

    local fileEntries = self.FileScroll:GetCanvas():GetChildren()

    table.sort(fileEntries, function(a, b)
        return (a.FileDateCreated or 0) > (b.FileDateCreated or 0)
    end)

    for index, fileEntry in ipairs(fileEntries) do
        if fileEntry:GetName() ~= "DScreenshotFileEntry" then continue end

        if index == 1 then
            fileEntry:OnMouseReleased(MOUSE_LEFT)
        end

        fileEntry:SetZPos(index)
    end

    self:FilterScreenshotsList()
end

function PANEL:FilterScreenshotsList()
    local showEdited = self.ShowEditedScreenshots

    local fileScrollCanvas = self.FileScroll:GetCanvas()

    for _, child in ipairs(fileScrollCanvas:GetChildren()) do
        if child:GetName() ~= "DScreenshotFileEntry" then continue end

        local fileName = string.StripExtension(child.FileName)

        local shouldShow = true

        if fileName:EndsWith("_edit") then
            shouldShow = shouldShow and showEdited
        end

        local searchMatched = string.find(fileName:lower(), self.SearchFilter:lower(), nil, true)
        shouldShow = shouldShow and searchMatched

        child:SetVisible(shouldShow)
    end

    fileScrollCanvas:InvalidateLayout()
end

function PANEL:PaintScreenshot(width, height)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(self.CurrentScreenshot)
    surface.DrawTexturedRect(0, 0, width, height)

    local currentFilterData = screenshot_editor.GetFilter(self.CurrentFilter + 1)
    if currentFilterData and currentFilterData.FilterCallback then
        currentFilterData.FilterCallback(width, height, self.CurrentScreenshot)
    end

    local currentFrameData = screenshot_editor.GetFrame(self.CurrentFrame + 1)
    if currentFrameData then
        if not currentFrameData.Material then
            currentFrameData.Material = Material(currentFrameData.MaterialPath, "smooth mips")
        end

        render.PushFilterMin(TEXFILTER.ANISOTROPIC)
        render.PushFilterMag(TEXFILTER.ANISOTROPIC)

        local frameMat = currentFrameData.Material
        surface.SetMaterial(frameMat)
        surface.DrawTexturedRect(0, 0, width, height)

        render.PopFilterMin()
        render.PopFilterMag()
    end
end

function PANEL:Paint(width, height)
    surface.SetDrawColor(20, 20, 20, 255)
    surface.DrawRect(0, 0, width, height)

    self:PaintScreenshot(width, height)
end

function PANEL:OnKeyCodePressed(keyCode)
    local pressedUpKey = (keyCode == KEY_W) or (keyCode == KEY_UP)
    local pressedDownKey = (keyCode == KEY_S) or (keyCode == KEY_DOWN)

    if pressedUpKey or pressedDownKey then
        local selectedLine = 1

        local fileEntries = self.FileScroll:GetCanvas():GetChildren()
        for index, line in ipairs(fileEntries) do
            if line.Targeted then
                selectedLine = index
                break
            end
        end

        local lineIdToSelect = selectedLine
        -- Bit of a weird workaround to deal with entries that aren't visible
        for i = selectedLine + (pressedUpKey and -1 or 1), (pressedUpKey and 0 or #fileEntries), (pressedUpKey and -1 or 1) do
            local iLine = fileEntries[i]

            if IsValid(iLine) and iLine:IsVisible() then
                lineIdToSelect = i
                break
            end
        end

        if selectedLine ~= lineIdToSelect then
            local lineToSelect = fileEntries[lineIdToSelect]
            if IsValid(lineToSelect) then
                lineToSelect:OnMouseReleased(MOUSE_LEFT)
            end
        end
    end
end

derma.DefineControl("DScreenshotEditor", "Screenshot Editor", PANEL, "EditablePanel")
