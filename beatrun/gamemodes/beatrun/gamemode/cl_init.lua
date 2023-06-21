include("shared.lua")

for k, v in ipairs(file.Find("gamemodes/beatrun/gamemode/cl/*.lua", "GAME")) do
	print(v)
	include("cl/" .. v)
end


