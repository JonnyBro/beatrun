if not util.IsBinaryModuleInstalled("steamrichpresencer", "GAME") then return end

require("steamrichpresencer")

local richtext = ""
local refresh_time = 60

local function UpdateRichPresence()
	local ply = LocalPlayer()
	if not ply.GetLevel then return end

	local map = game.GetMap()
	local level = LocalPlayer():GetLevel()
	local course = nil
	local customname = hook.Run("BeatrunHUDCourse")
	course = customname and customname or Course_Name ~= "" and Course_Name or "Freeplay"

	if course == nil then
		course = "Freeplay"
	end

	local updatedtext = "Beatrun Lv. " .. level .. " (" .. map .. ") | " .. course

	if richtext ~= updatedtext then
		richtext = updatedtext

		steamworks.SetRichPresence("generic", richtext)
	end
end

hook.Add("OnGamemodeLoaded", "LoadDLL", function()
	UpdateRichPresence()

	timer.Create("UpdateSteamRichPresence", refresh_time, 0, UpdateRichPresence)
end)