spraymesh = spraymesh or {}

include("spraymesh/sh_config.lua")

-- To ensure that the URLs in the config don't start with HTTP or HTTPS
-- ConVars (such as spraymesh_url) don't allow "//" in the string, so we need to remove it
spraymesh.SPRAY_URL_DEFAULT = string.Replace(spraymesh.SPRAY_URL_DEFAULT, "http://", "https://")
spraymesh.SPRAY_URL_DEFAULT = string.Replace(spraymesh.SPRAY_URL_DEFAULT, "https://", "")

--spraymesh.SPRAY_URL_DISABLED = string.Replace(spraymesh.SPRAY_URL_DISABLED, "http://", "https://")
--spraymesh.SPRAY_URL_DISABLED = string.Replace(spraymesh.SPRAY_URL_DISABLED, "https://", "")

--spraymesh.SPRAY_URL_ANTIGIF = string.Replace(spraymesh.SPRAY_URL_ANTIGIF, "http://", "https://")
--spraymesh.SPRAY_URL_ANTIGIF = string.Replace(spraymesh.SPRAY_URL_ANTIGIF, "https://", "")

-- Stores SteamID64 keys that contain url and delay/immediate vars serverside, and a meshdata var clientside
spraymesh.SPRAYDATA = spraymesh.SPRAYDATA or {}

-- Enums for spray types.
-- SPRAYTYPE_INVALID: The spray is not a valid spray.
-- SPRAYTYPE_IMAGE: The spray is an image.
-- SPRAYTYPE_VIDEO: The spray is a video.
SPRAYTYPE_INVALID = 0
SPRAYTYPE_IMAGE = 1
SPRAYTYPE_VIDEO = 2

-- Checks if the spray URL is valid (image OR video)
function spraymesh.IsValidAnyURL(url)
    return spraymesh.IsValidImageURL(url) or spraymesh.IsValidVideoURL(url)
end

-- Checks if the spray URL is valid (images ONLY)
function spraymesh.IsValidImageURL(url)
    -- Needs to be HTTPS
    if not url:StartWith("https://") then return false end

    -- Needs to be from a whitelisted domain
    if not url:EndsWith("/") then url = url .. "/" end
    urlDomain = string.match(url, "https://(.-)/")
    if not spraymesh.VALID_URL_DOMAINS_IMAGE[urlDomain] then return false end

    -- Must have a valid file extension
    local extension = string.match(url, "%.(%w+)/$")
    if not extension or not spraymesh.VALID_URL_EXTENSIONS_IMAGE[extension] then return false end

    -- Must be 512 characters or fewer
    if #url > 512 then return false end

    return true
end

-- Checks if the spray URL is valid (videos ONLY)
function spraymesh.IsValidVideoURL(url)
    -- Needs to be HTTPS
    if not url:StartWith("https://") then return false end

    -- Needs to be from a whitelisted domain
    if not url:EndsWith("/") then url = url .. "/" end
    urlDomain = string.match(url, "https://(.-)/")
    if not spraymesh.VALID_URL_DOMAINS_VIDEO[urlDomain] then return false end

    -- Must have a valid file extension
    local extension = string.match(url, "%.(%w+)/$")
    if not extension or not spraymesh.VALID_URL_EXTENSIONS_VIDEO[extension] then return false end

    -- Must be 512 characters or fewer
    if #url > 512 then return false end

    return true
end

-- Checks if the URL has an IMAGE extension
function spraymesh.IsImageExtension(url)
    local extension = string.match(url, "%.(%w+)$")
    return spraymesh.VALID_URL_EXTENSIONS_IMAGE[extension] == true
end

-- Checks if the URL has a VIDEO extension
function spraymesh.IsVideoExtension(url)
    local extension = string.match(url, "%.(%w+)$")
    return spraymesh.VALID_URL_EXTENSIONS_VIDEO[extension] == true
end

-- Checks if the URL is valid, and returns the type (image or video)
function spraymesh.GetURLInfo(url)
    -- Ensure URL is set to HTTPS
    url = string.Replace(url, "http://", "https://")
    url = string.Replace(url, "https://", "")
    url = "https://" .. url

    if not spraymesh.IsValidAnyURL(url) then
        spraymesh.DebugPrint("URL does not pass IsValidAnyURL check!")
        return SPRAYTYPE_INVALID
    end

    local sprayType = SPRAYTYPE_INVALID
    if spraymesh.IsImageExtension(url) then
        sprayType = SPRAYTYPE_IMAGE
    elseif spraymesh.IsVideoExtension(url) then
        sprayType = SPRAYTYPE_VIDEO
    end

    return sprayType
end

-- Print debug info to console
function spraymesh.DebugPrint(msg)
    if spraymesh.DEBUG_MODE then print("[SprayMesh Extended Debug]: " .. msg) end
end
