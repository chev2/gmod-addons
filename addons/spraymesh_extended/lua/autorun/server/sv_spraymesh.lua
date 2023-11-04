-- Initialize SprayMesh Extended on the server
include("spraymesh/server/sv_init.lua")

-- Send Lua files to the client
AddCSLuaFile("spraymesh/sh_init.lua")
AddCSLuaFile("spraymesh/sh_config.lua")

AddCSLuaFile("spraymesh/client/cl_init.lua")
AddCSLuaFile("spraymesh/client/cl_spray_list_db.lua")
AddCSLuaFile("spraymesh/client/cl_derma_utils.lua")
AddCSLuaFile("spraymesh/client/cl_sandbox_context_menu.lua")
