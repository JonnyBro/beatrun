STAR = "★"
REC = "⚫"
VERSIONGLOBAL = "v1.Zero"
DeriveGamemode("sandbox")
GM.Name = "Beatrun"
GM.Author = "datae"
GM.Email = "datae@dontemailme.com"
GM.Website = "www.mirrorsedge.com"
include("player_class/player_beatrun.lua")

for _, v in ipairs(file.Find("gamemodes/beatrun/gamemode/sh/*.lua", "GAME", "nameasc")) do
	AddCSLuaFile("sh/" .. v)
	include("sh/" .. v)
end