spraymesh_derma_utils = spraymesh_derma_utils or {}

-- Enables the maximize button on DFrame panels, used by SprayMesh Extended panels
function spraymesh_derma_utils.EnableMaximizeButton(dframe)
    dframe.btnMaxim.Maximized = false
    dframe.btnMaxim.OriginalSize = {panelWidth, panelHeight}
    dframe.btnMaxim.OriginalPos = {dframe:GetX(), dframe:GetY()}
    dframe.btnMaxim:SetDisabled(false)
    dframe.btnMaxim.DoClick = function(pnl)
        local targetSize = {512, 512}
        local targetPos = {0, 0}

        -- If we're maximized, unmaximize
        if pnl.Maximized then
            targetSize = pnl.OriginalSize
            targetPos = pnl.OriginalPos
        -- If we're unmaximized, maximize
        else
            -- Store current position and size if the user decides to unmaximize later
            pnl.OriginalSize = {dframe:GetSize()}
            pnl.OriginalPos = {dframe:GetPos()}

            targetSize = {ScrW(), ScrH()}
            targetPos = {0, 0}
        end

        pnl.Maximized = not pnl.Maximized

        -- Don't allow the button to be clicked while the transition animation plays
        pnl:SetEnabled(false)
        local animData = dframe:NewAnimation(0.4, 0, 0.3, function(animTable, tgtPanel)
            if IsValid(pnl) then
                pnl:SetEnabled(true)
            end
        end)
        animData.StartSize = {dframe:GetSize()}
        animData.EndSize = targetSize
        animData.StartPos = {dframe:GetPos()}
        animData.EndPos = targetPos

        animData.Think = function(animTable, tgtPanel, fraction)
            local easedFraction = math.ease.OutSine(fraction)

            local easedPosX = Lerp(easedFraction, animTable.StartPos[1], animTable.EndPos[1])
            local easedPosY = Lerp(easedFraction, animTable.StartPos[2], animTable.EndPos[2])
            local easedSizeW = Lerp(easedFraction, animTable.StartSize[1], animTable.EndSize[1])
            local easedSizeH = Lerp(easedFraction, animTable.StartSize[2], animTable.EndSize[2])

            tgtPanel:SetPos(math.Round(easedPosX, 0), math.Round(easedPosY, 0))
            tgtPanel:SetSize(math.Round(easedSizeW, 0), math.Round(easedSizeH, 0))
        end
    end
end

local PREVIEW_HTML_BASE = [=[
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <style>
            body {
                margin: 0;
                background: transparent;
            }

            html {
                overflow: hidden;
            }

            img, video {
                width: 100vw;
                height: 100vh;
                object-fit: contain;
            }
        </style>
    </head>
    <body>
        %s
    </body>
</html>
]=]

local PREVIEW_HTML_IMAGE = [=[<img src="%s">]=]
local PREVIEW_HTML_VIDEO = [=[<video src="%s" muted autoplay loop>]=]

-- Gets preview HTML (HTML code only--no derma panel), to preview sprays using DHTML
function spraymesh_derma_utils.GetPreviewHTML(sprayURL)
    local elementFormatted = ""

    if spraymesh.IsVideoExtension(sprayURL) then
        elementFormatted = Format(PREVIEW_HTML_VIDEO, string.JavascriptSafe(sprayURL))
    elseif spraymesh.IsImageExtension(sprayURL) then
        elementFormatted = Format(PREVIEW_HTML_IMAGE, string.JavascriptSafe(sprayURL))
    -- If we can't figure out the type, assume it's an image
    else
        elementFormatted = Format(PREVIEW_HTML_IMAGE, string.JavascriptSafe(sprayURL))

        spraymesh.DebugPrint("(spraymesh_derma_utils.GetPreviewHTML) Could not figure out image/video type for URL " .. sprayURL)
    end

    return Format(
        PREVIEW_HTML_BASE,
        elementFormatted
    )
end

local PANEL_CACHE = {}

-- Gets preview HTML (panel only), to preview sprays using DHTML
function spraymesh_derma_utils.GetPreviewPanel(sprayURL)
    local urlHash = util.SHA256(sprayURL)

    if IsValid(PANEL_CACHE[urlHash]) then
        return PANEL_CACHE[urlHash]
    else
        local htmlPanel = vgui.Create("DHTML")
        htmlPanel:SetVisible(true)
        htmlPanel:SetAlpha(0)
        htmlPanel:SetAllowLua(false)
        htmlPanel:SetMouseInputEnabled(false)
        htmlPanel:SetKeyboardInputEnabled(false)

        local htmlCode = spraymesh_derma_utils.GetPreviewHTML(sprayURL)
        htmlPanel:SetHTML(htmlCode)

        PANEL_CACHE[urlHash] = htmlPanel

        return htmlPanel
    end
end
