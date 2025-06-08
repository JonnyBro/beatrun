BEATRUN_SHARED = BEATRUN_SHARED or {}

installedVersion = "1.0.54"
latestVersion = ""
local isVersionCheched

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

if not isVersionCheched then
	http.Fetch("https://raw.githubusercontent.com/JonnyBro/beatrun/main/version.txt", function(body, _, _, code)
		if code == 200 then
			latestVersion = body:gsub("[\n\r]", "")

			print("Latest version: " .. latestVersion)

			if latestVersion == installedVersion then
				print("You're up to date, nice!")
			else
				print("You're not using the latest GitHub version.")
			end

			isVersionCheched = true

			return
		else
			print("Error while checking version (not code 200):\n", body)
			isVersionCheched = true

			return
		end
	end)
end