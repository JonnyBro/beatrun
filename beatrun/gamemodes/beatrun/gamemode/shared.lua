VERSIONGLOBAL = "v1.0.7"

DeriveGamemode("sandbox")

GM.Name = "Beatrun"
GM.Author = "who cares"
GM.Email = "whocares@noone.com"
GM.Website = "www.mirrorsedge.com xd"

include("player_class/player_beatrun.lua")

for _, v in ipairs(file.Find("gamemodes/beatrun/gamemode/sh/*.lua", "GAME", "nameasc")) do
	AddCSLuaFile("sh/" .. v)
	include("sh/" .. v)
end