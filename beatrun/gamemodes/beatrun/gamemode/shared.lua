VERSIONGLOBAL = "1.0.9"
VERSIONLATEST = NULL

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