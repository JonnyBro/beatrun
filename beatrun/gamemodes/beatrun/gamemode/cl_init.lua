include("shared.lua")

for _, v in ipairs(file.Find("gamemodes/beatrun/gamemode/cl/*.lua", "GAME", "nameasc")) do
	include("cl/" .. v)
end