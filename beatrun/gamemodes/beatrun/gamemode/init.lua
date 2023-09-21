AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

for _, v in ipairs(file.Find("gamemodes/beatrun/gamemode/cl/*.lua", "GAME")) do
	print(v)

	AddCSLuaFile("cl/" .. v)
end

for _, v in ipairs(file.Find("gamemodes/beatrun/gamemode/sh/*.lua", "GAME")) do
	print(v)

	AddCSLuaFile("sh/" .. v)
	include("sh/" .. v)
end

for _, v in ipairs(file.Find("gamemodes/beatrun/gamemode/sv/*.lua", "GAME")) do
	print(v)

	include("sv/" .. v)
end