include("shared.lua")

for _, v in ipairs(file.Find("gamemodes/beatrun/gamemode/cl/*.lua", "GAME")) do
	include("cl/" .. v)
end