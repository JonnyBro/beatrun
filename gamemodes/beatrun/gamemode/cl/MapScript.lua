if file.Exists("beatrun/gamemode/Maps/" .. game.GetMap() .. "_cl.lua", "LUA") then
	include("beatrun/gamemode/Maps/" .. game.GetMap() .. "_cl.lua")
end