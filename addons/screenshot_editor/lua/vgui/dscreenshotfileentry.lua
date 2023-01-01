local PANEL = {}

local BG_COLOR_NORMAL = Color(0, 0, 0, 230)
local BG_COLOR_HOVERED = Color(20, 20, 20, 230)
local BG_COLOR_SELECTED = Color(40, 40, 40, 230)
local BG_COLOR_TARGETED = Color(30, 106, 156, 230)

surface.CreateFont("DScreenshotFileEntry_FileName", {
    font = system.IsOSX() and "Helvetica" or "Tahoma",
    size = 16,
    weight = 500
})

surface.CreateFont("DScreenshotFileEntry_DateCreated", {
    font = system.IsOSX() and "Helvetica" or "Tahoma",
    size = 16,
    weight = 500
})

function PANEL:Init()
    self.FileName = nil
    self.FileDateCreated = nil

    self:SetSize(ScrW() * 0.2, 48)

    local fnLabel = vgui.Create("DLabel", self)
    fnLabel:SetText("file_name.jpg")
    fnLabel:SetFont("DScreenshotFileEntry_FileName")

    self.FileNameLabel = fnLabel

    local dcLabel = vgui.Create("DLabel", self)
    dcLabel:SetText("Created January 1st, 1970")
    dcLabel:SetFont("DScreenshotFileEntry_DateCreated")

    self.DateCreatedLabel = dcLabel

    self:SetMouseInputEnabled(true)
    self:SetCursor("hand")
    self.Depressed = false

    self.Targeted = false
end

function PANEL:OnMousePressed(keyCode)
    if keyCode == MOUSE_LEFT then
        self.Depressed = true
    end
end

function PANEL:OnMouseReleased(keyCode)
    if keyCode == MOUSE_LEFT then
        if IsValid(self.LayoutPanel) then
            for _, child in ipairs(self.LayoutPanel:GetCanvas():GetChildren()) do
                child.Targeted = false
            end
        end

        self.Targeted = true

        self:DoClick()
    end

    self.Depressed = false
end

function PANEL:OnCursorExited()
    self.Depressed = false
end

function PANEL:DoClick()
    if IsValid(self.LayoutPanel) then
        self.LayoutPanel:OnItemSelected(self)
    end
end

function PANEL:Paint(width, height)
    local col = BG_COLOR_NORMAL

    if self.Depressed then
        col = BG_COLOR_SELECTED
    elseif self:IsHovered() then
        col = BG_COLOR_HOVERED
    end

    if self.Targeted then
        col = BG_COLOR_TARGETED
    end

    draw.RoundedBox(8, 0, 0, width, height, col)
end

function PANEL:PerformLayout(width, height)
    self.FileNameLabel:CenterVertical(0.3)
    self.FileNameLabel:AlignLeft(8)

    self.DateCreatedLabel:CenterVertical(0.7)
    self.DateCreatedLabel:AlignRight(8)
end

function PANEL:SetFileName(fileName)
    self.FileName = fileName

    self.FileNameLabel:SetText(fileName)
    self.FileNameLabel:SizeToContents()
end

function PANEL:SetDateCreated(time)
    self.FileDateCreated = time

    local dayFormat = tonumber(os.date("%d", time))
    local dateFormat = os.date("Created %B %%s, %Y", time)
    dateFormat = Format(
        dateFormat,
        dayFormat .. STNDRD(dayFormat)
    )

    self.DateCreatedLabel:SetText(dateFormat)
    self.DateCreatedLabel:SizeToContents()
end

derma.DefineControl("DScreenshotFileEntry", "Screenshot Editor File Entry", PANEL, "DPanel")
