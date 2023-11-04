--
-- * SPRAYMESH EXTENDED CONFIGURATION FILE
-- * If you are a server owner, feel free to edit the settings in here to your liking.
--
-- Ideally, this should be the only Lua file you have to modify--if you want to add or remove other features,
-- leave a suggestion and I might make it something configurable. :)
--
-- You can leave suggestions on either:
-- - The Steam Workshop page, or
-- - The GitHub repository: https://github.com/chev2/gmod-addons/issues
--

-- Default spray, often used when player's current spray is invalid or they otherwise haven't set a spray yet
spraymesh.SPRAY_URL_DEFAULT = "files.catbox.moe/xsdikl.png"

-- Units between points (default: 2); resXcoorddist = the dimensions (size) of all player sprays
-- Bigger values means spray sizes will increase
spraymesh.COORD_DIST_DEFAULT = 1.75

-- Mesh resolution (default: 30); this controls how many points make up the mesh grid, such as 30x30,
-- which affects how smooth or jagged the mesh cuts off or wraps around the map diagonally
-- * Tip: try to keep res as 10x the coord dist, and remember that the maximum res is 105 before this breaks
spraymesh.MESH_RESOLUTION = 30

-- The image resolution used for sprays
-- e.g. 512 means the image is resized to be 512x512 pixels
-- Default: 512
-- * The resolution MUST be a power of 2 (256, 512, 1024, etc.), otherwise sprays will be sized weirdly
spraymesh.IMAGE_RESOLUTION = 512

-- How often players can spray (in seconds).
spraymesh.SPRAY_COOLDOWN = 3

-- Command prefixes for the spraymesh command, e.g. "!", "/" will allow both !spraymesh and /spraymesh.
-- * If you want to disable chat commands, just remove all the entries in this list.
spraymesh.CHAT_COMMAND_PREFIXES = {
    "!",
    "/",
    "."
}

-- A list of valid IMAGE domains that sprays can use.
spraymesh.VALID_URL_DOMAINS_IMAGE = {
    ["i.imgur.com"] = true,
    ["files.catbox.moe"] = true,
    ["litter.catbox.moe"] = true,
    ["cdn.discordapp.com"] = true,
}

-- A list of valid VIDEO domains that sprays can use.
spraymesh.VALID_URL_DOMAINS_VIDEO = {
    ["i.imgur.com"] = true,
}

-- A list of valid IMAGE extensions that sprays can use.
-- * NOTE: SprayMesh (the original addon) disabled GIF sprays due to heavy performance impact.
-- * I'm not sure if modern Garry's Mod still has the same issue, but if it does (at least, in your tests),
-- * simply remove gif from this list to disable GIFs.
spraymesh.VALID_URL_EXTENSIONS_IMAGE = {
    ["jpeg"] = true,
    ["jpg"] = true,
    ["png"] = true,
    ["webp"] = true,
    ["gif"] = true,
    ["avif"] = true,
}

-- A list of valid VIDEO extensions that sprays can use.
spraymesh.VALID_URL_EXTENSIONS_VIDEO = {
    ["webm"] = true,
    ["gifv"] = true,
    ["mp4"] = true,
}

-- The primary color to use when SprayMesh prints messages to chat. (R, G, B)
spraymesh.PRIMARY_CHAT_COLOR = Color(114, 192, 255)

-- The secondary/accent color to use when SprayMesh prints messages to chat. (R, G, B)
spraymesh.ACCENT_CHAT_COLOR = Color(255, 255, 255)

-- Set to true to enable boring debugging stuff like filling the console with various print statements.
spraymesh.DEBUG_MODE = false

