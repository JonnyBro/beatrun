AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

for k, v in ipairs(file.Find("gamemodes/beatrun/gamemode/cl/*.lua", "GAME")) do
	AddCSLuaFile("cl/" .. v)
end

for k, v in ipairs(file.Find("gamemodes/beatrun/gamemode/sh/*.lua", "GAME")) do
	print(v)
	include("sh/" .. v)
	AddCSLuaFile("sh/" .. v)
end

for k, v in ipairs(file.Find("gamemodes/beatrun/gamemode/sv/*.lua", "GAME")) do
	include("sv/" .. v)
end