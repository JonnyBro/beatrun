VERSION_GLOBAL = "1.0.14"
VERSION_LATEST = ""
VERSION_CHECKED = false

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

if not VERSION_CHECKED then
	http.Fetch("https://raw.githubusercontent.com/JonnyBro/beatrun/main/version.txt", function(body, size, headers, code)
		if code == 200 then
			VERSION_LATEST = body:gsub("[\n\r]", "")
			print("Latest version: " .. VERSION_LATEST)

			if VERSION_LATEST > VERSION_GLOBAL then
				print("Your version is behind latest, please update.")
			elseif VERSION_LATEST == VERSION_GLOBAL then
				print("You're up to date, nice!")
			else
				print("Your version is ahead of latest. Huh?")
			end

			VERSION_CHECKED = true

			return
		else
			print("Error while checking version (not 200 code):\n" .. body)
			VERSION_CHECKED = true

			return
		end
	end)
end