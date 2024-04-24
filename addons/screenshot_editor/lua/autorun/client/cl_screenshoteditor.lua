screenshot_editor = screenshot_editor or {}

local SCREENSHOT_FILES = {}
local SCREENSHOT_ITERATE_ACTIVE = false

-- We check filenames that start with these characters in IterateScreenshotFiles()
local charCheckList = {}

for i = 65, 65 + 25 do charCheckList[#charCheckList + 1] = string.char(i) end
for i = 97, 97 + 25 do charCheckList[#charCheckList + 1] = string.char(i) end
for i = 0, 9 do charCheckList[#charCheckList + 1] = tostring(i) end
table.Add(charCheckList, {"_", "-", "(", ")", " "})

-- Not a fantastic method, but it's smoother than file.Find("*.*")
local function IterateScreenshotFiles()
    local fileQueue = {}

    --local ctime = SysTime()

    -- a through z
    -- ! LIMITATION: This will skip over filenames NOT starting with these characters.
    --      ! - this is a small edge case, as maps and screenshots usually shouldn't start with weird characters..
    for i = 1, #charCheckList do
        for j = 1, #charCheckList do
            local char1 = charCheckList[i]
            local char2 = charCheckList[j]

            local fileBeginner = char1 .. char2

            local foundScreenshotFiles = file.Find("screenshots/" .. fileBeginner .. "*.*", "MOD")
            table.Add(fileQueue, foundScreenshotFiles)

            -- if #foundScreenshotFiles > 0 then
            --     print(fileBeginner, #foundScreenshotFiles)
            -- end
        end

        coroutine.yield()
    end

    -- Organize files by modified time, so more recently-created screenshots appear at the top of the UI
    while #fileQueue > 0 do
        for i = 1, 200 do
            if #fileQueue == 0 then continue end

            local fileName = table.remove(fileQueue, 1)
            if string.EndsWith(fileName, ".tga") then continue end

            local fullFileName = "screenshots/" .. fileName
            SCREENSHOT_FILES[fullFileName] = file.Time(fullFileName, "MOD")
        end

        coroutine.yield()
    end

    SCREENSHOT_ITERATE_ACTIVE = false

    hook.Run("ScreenshotEditorProcessingFinished")
end

local fileCo
hook.Add("Think", "GatherScreenshotFiles", function()
    if SCREENSHOT_ITERATE_ACTIVE and (not fileCo or not coroutine.resume(fileCo)) then
        fileCo = coroutine.create(IterateScreenshotFiles)
        coroutine.resume(fileCo)
    end
end)

function screenshot_editor.ProcessScreenshots()
    SCREENSHOT_FILES = {}

    SCREENSHOT_ITERATE_ACTIVE = true
end

function screenshot_editor.IsProcessingScreenshots()
    return SCREENSHOT_ITERATE_ACTIVE
end

function screenshot_editor.GetScreenshots()
    return SCREENSHOT_FILES
end

-- Start this immediately, so we get screenshots processed ASAP
screenshot_editor.ProcessScreenshots()

--[[
    Filter API
]]
local FILTER_DATA = {}

function screenshot_editor.GetFilter(index)
    return FILTER_DATA[index]
end

function screenshot_editor.GetFilters()
    return FILTER_DATA
end

function screenshot_editor.AddFilter(filterData)
    if not filterData.FilterName then
        error("screenshot_editor.AddFrame: Missing \'FilterName\' parameter!")
    end

    if not filterData.FilterCallback then
        error("screenshot_editor.AddFrame: Missing \'FilterCallback\' parameter!")
    end

    FILTER_DATA[#FILTER_DATA + 1] = {
        FilterName = filterData.FilterName,
        FilterCallback = filterData.FilterCallback
    }
end

--[[
    Frame API
]]
local FRAME_DATA = {}

function screenshot_editor.GetFrame(index)
    return FRAME_DATA[index]
end

function screenshot_editor.GetFrames()
    return FRAME_DATA
end

function screenshot_editor.AddFrame(frameData)
    if not frameData.FrameName then
        error("screenshot_editor.AddFrame: Missing \'FrameName\' parameter!")
    end

    if not frameData.MaterialPath then
        error("screenshot_editor.AddFrame: Missing \'MaterialPath\' parameter!")
    end

    FRAME_DATA[#FRAME_DATA + 1] = {
        FrameName = frameData.FrameName,
        MaterialPath = frameData.MaterialPath
    }
end

include("screenshoteditor/cl_filters_basic.lua")
include("screenshoteditor/cl_frames_basic.lua")

-- Sandbox Context Menu
list.Set("DesktopWindows", "ScreenshotEditor", {
    title = "Screenshot Edit",
    icon = "icon64/screenshot_editor.png",

    width = 960,
    height = 700,

    onewindow = true,

    init = function(icon, window)
        -- Remove basic frame and replace with our custom VGUI element
        window:Remove()

        if IsValid(screenshot_editor.PANEL) then screenshot_editor.PANEL:Remove() end
        local mainWindow = vgui.Create("DScreenshotEditor")
        screenshot_editor.PANEL = mainWindow

        icon.Window = mainWindow
    end
})

concommand.Add("screenshot_editor", function(ply, cmd, args, argStr)
    if IsValid(screenshot_editor.PANEL) then screenshot_editor.PANEL:Remove() end
    local mainWindow = vgui.Create("DScreenshotEditor")
    screenshot_editor.PANEL = mainWindow
end)

local function InitializeScreenshotEditorHook()
    table.Empty(FILTER_DATA)
    table.Empty(FRAME_DATA)

    hook.Run("ScreenshotEditorInitialize")
end

hook.Add("Initialize", "RunScreenshotEditorInitialize_OnGamemodeInitialize", InitializeScreenshotEditorHook)
hook.Add("OnReloaded", "RunScreenshotEditorInitialize_OnReloaded", InitializeScreenshotEditorHook)

-- Debug autorefresh
if game.GetWorld() ~= NULL then InitializeScreenshotEditorHook() end
