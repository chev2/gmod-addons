--
-- Displays helpful info on how to use SprayMesh Extended.
--
local PANEL = {}

local HELP_HTML = [=[
<html>
    <head>
        <style>
            body {
                margin: 16px;
                background: rgba(0, 0, 0, 80%);
                color: white;
                font-family: 'Arial', 'Helvetica', sans-serif;
            }

            li {
                line-height: 1.5;
            }

            a {
                color: lightblue;
            }

            p {
                line-height: 1.2;
            }

            code {
                background: hsl(0, 0%, 20%);
                color: rgb(81, 161, 106);

                border-radius: 4px;
                padding: 4px;
                line-height: 2;
            }

            #wrapper {
                width: 768px;
                margin: auto;
            }
        </style>
    </head>
    <body>
        <div id="wrapper">
            <h1>SprayMesh Extended</h1>
            <p>SprayMesh Extended is an improvement to the original addon, SprayMesh.</p>
            <p>It comes with various new features and improvements, included but not limited to:</p>
            <ul>
                <li>A built-in menu for SprayMesh Extended:</li>
                <ul>
                    <li>Comes with a settings panel to adjust some SprayMesh Extended settings.</li>
                    <li>Comes with a spray manager to save, name & search sprays.</li>
                    <li>Has a pop-up menu to view all active sprays on the server.</li>
                    <li>Has a pop-up menu which contains a guide to using SprayMesh Extended, as well as viewing what spray types (like image & video extensions) are whitelisted.</li>
                </ul>
                <li>Sprays can be rotated on floors and ceilings.</li>
                <li>Sprays are now easier to see in dark areas.</li>
                <li>Sprays render in the order they're sprayed (so that players can spray over each others' sprays).</li>
                <li>Sprays will be kept when a player re-joins the server (however, sprays will still reset upon a server shutdown/restart).</li>
                <li>A cleaner codebase, and optimized code a bit.</li>
                <li>Config (and Lua hooks) for developers and server owners to customize SprayMesh Extended to their liking.</li>
                <li>Ability to block sprays from muted players.</li>
                <li>Support for CatBox & LitterBox natively included.</li>
            </ul>
            <p>Keep in mind that SprayMesh Extended is designed to be a <strong>replacement</strong> for SprayMesh, not an addition.</p>
            <p><strong>You will run into various issues if you try to use both addons at the same time!</strong></p>

            <h2>Credits</h2>
            <p>SprayMesh Extended is made by Chev <code>(STEAM_0:0:71541002)</code>. Thanks for supporting my work!</p>
            <p>SprayMesh (the original) is made by <strong>Bletotum</strong>: <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=394091909" target="_blank">Steam Workshop Link</a></p>
            <p>Also, thanks to <strong>Sony</strong> for making Spray Manager V2, which inspired SprayMesh Extended's own manager: <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=1805554541" target="_blank">Steam Workshop Link</a></p>

            <h2>Using SprayMesh Extended</h2>
            <p>First, find an image you like. The whitelisted websites on <strong>this server</strong> are as follows:</p>

            <p>Image URLs:</p> 
            <ul>
                {{WHITELISTED_IMAGE_DOMAINS}}
            </ul>

            <p>Video/Animated URLs:</p> 
            <ul>
                {{WHITELISTED_VIDEO_DOMAINS}}
            </ul>

            <br>
            <p>Next, open the configurator. It can be opened in the following ways:</p>
            <ul>
                <li>Typing <code>/spraymesh</code> into chat (if the server supports it)</li>
                <li>Typing <code>spraymesh_settings</code> into the developer console</li>
                <li>Opening the context (C) menu in gamemodes like Sandbox and clicking on <code>SprayMesh</code></li>
            </ul>
            <p>Then, paste the image's URL into the red bar in the configurator. If the bar turns green, the URL is valid.</p>
            <p>Click the <code>Add Spray</code> button or press enter and your spray will be added to your spray list.</p>
            <br>

            <p>If the bar is still red, then the URL you entered isn't valid.</p>
            <p>It either contains invalid characters (such as <code>&lt;, &gt;, [, ]</code> etc.) or it's from a website that isn't whitelisted for use on this server.</p>
            <br>

            <p>All sprays get resized to a resolution of <code>{{SPRAY_RESOLUTION}}</code> on this server. You can use images larger than this--they will simply be downsized.</p>
            <p>Images do not need to be perfectly square. Wide and tall images work just fine.</p>
            <br>

            <p>Right-clicking on a spray in the spray manager will present additional options, such as copying the URL or removing the spray.</p>
            <br>

            <p>Whitelisted image extensions on this server:</p>
            <ul>
                {{WHITELISTED_IMAGE_EXTENSIONS}}
            </ul>

            <p>Whitelisted video extensions on this server:</p>
            <ul>
                {{WHITELISTED_VIDEO_EXTENSIONS}}
            </ul>
        </div>
    </body>
</html>
]=]

function PANEL:Init()
    self:SetTitle("SprayMesh Extended Help")
    self:SetIcon("icon16/help.png")

    local fWidth = math.max(ScrW() * 0.72, 1056)
    local fHeight = math.max(ScrH() * 0.8, 594)
    self:SetSize(fWidth, fHeight)
    self:SetMinWidth(1056)
    self:SetMinHeight(594)

    self:SetSizable(true)
    self:SetDraggable(true)
    self:SetScreenLock(true)

    self:Center()
    self:MakePopup()

    spraymesh_derma_utils.EnableMaximizeButton(self)

    local html = vgui.Create("DHTML", self)
    html:Dock(FILL)
    html:SetAllowLua(false)
    html.OnChildViewCreated = function(panel, sourceURL, targetURL, isPopup)
        gui.OpenURL(targetURL)
    end

    local finalHTML = HELP_HTML

    --
    -- Image domains
    --
    local imageDomains = {}
    for domain, val in SortedPairs(spraymesh.VALID_URL_DOMAINS_IMAGE) do
        if val ~= true then continue end

        imageDomains[#imageDomains + 1] = "<li><code>" .. string.JavascriptSafe(domain) .. "</code></li>"
    end

    if #imageDomains == 0 then
        imageDomains = {"<li>No image domains whitelisted</li>"}
    end

    finalHTML = string.Replace(finalHTML, "{{WHITELISTED_IMAGE_DOMAINS}}", table.concat(imageDomains, "\n"))

    --
    -- Video domains
    --
    local videoDomains = {}
    for domain, val in SortedPairs(spraymesh.VALID_URL_DOMAINS_VIDEO) do
        if val ~= true then continue end

        videoDomains[#videoDomains + 1] = "<li><code>" .. string.JavascriptSafe(domain) .. "</code></li>"
    end

    if #videoDomains == 0 then
        videoDomains = {"<li>No video domains whitelisted</li>"}
    end

    finalHTML = string.Replace(finalHTML, "{{WHITELISTED_VIDEO_DOMAINS}}", table.concat(videoDomains, "\n"))

    --
    -- Image extensions
    --
    local imageExts = {}
    for domain, val in SortedPairs(spraymesh.VALID_URL_EXTENSIONS_IMAGE) do
        if val ~= true then continue end

        imageExts[#imageExts + 1] = "<li><code>." .. string.JavascriptSafe(domain) .. "</code></li>"
    end

    if #imageExts == 0 then
        imageExts = {"<li>No image extensions whitelisted</li>"}
    end

    finalHTML = string.Replace(finalHTML, "{{WHITELISTED_IMAGE_EXTENSIONS}}", table.concat(imageExts, "\n"))

    --
    -- Video extensions
    --
    local videoExts = {}
    for domain, val in SortedPairs(spraymesh.VALID_URL_EXTENSIONS_VIDEO) do
        if val ~= true then continue end

        videoExts[#videoExts + 1] = "<li><code>." .. string.JavascriptSafe(domain) .. "</code></li>"
    end

    if #videoExts == 0 then
        videoExts = {"<li>No video extensions whitelisted</li>"}
    end

    finalHTML = string.Replace(finalHTML, "{{WHITELISTED_VIDEO_EXTENSIONS}}", table.concat(videoExts, "\n"))

    --
    -- Image resolution
    --
    local sprayRes = string.JavascriptSafe(spraymesh.IMAGE_RESOLUTION)
    finalHTML = string.Replace(finalHTML, "{{SPRAY_RESOLUTION}}", sprayRes .. "x" .. sprayRes)

    html:SetHTML(finalHTML)
end

-- Register control
derma.DefineControl("DSprayHelp", "SprayMesh Extended - Help", PANEL, "DFrame")
