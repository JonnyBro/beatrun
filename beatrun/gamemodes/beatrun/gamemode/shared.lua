VERSIONGLOBAL = "1.0.10"
VERSIONLATEST = ""

DeriveGamemode("sandbox")

GM.Name = "Beatrun"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "github.com/JonnyBro/beatrun"

include("player_class/player_beatrun.lua")

for _, v in ipairs(file.Find("gamemodes/beatrun/gamemode/sh/*.lua", "GAME", "nameasc")) do
	AddCSLuaFile("sh/" .. v)
	include("sh/" .. v)
end

http.Fetch("https://raw.githubusercontent.com/JonnyBro/beatrun/main/version.txt", function(body, size, headers, code)
	if code == 200 then
		VERSIONLATEST = body:gsub("[\n\r]", "")
	else
		print("Error while checking version (not 200 code):\n" .. body)
	end
end, function(e)
	print("Error while checking version (error on fetch):\n" .. e)
end)