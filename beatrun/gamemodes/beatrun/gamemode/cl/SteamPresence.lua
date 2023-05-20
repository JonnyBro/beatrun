if not system.IsWindows() or not file.Exists("lua/bin/gmcl_steamfriends_win64.dll", "GAME") then
	return
end

local richtext = ""
local nextupdate = 0

local function UpdateRichPresence()
	if CurTime() < nextupdate then
		return
	end

	local rp = steamworks.SetRichPresence

	if not rp then
		return
	end

	local ply = LocalPlayer()

	if not ply.GetLevel then
		return
	end

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

		rp("generic", richtext)
		print("Updating presence")
	end

	nextupdate = CurTime() + 60
end

local function LoadRichPresenceDLL()
	require("steamfriends")
end

hook.Add("OnGamemodeLoaded", "LoadDLL", function ()
	local dllfound = pcall(LoadRichPresenceDLL)
	LoadRichPresenceDLL = nil

	if not dllfound then
		hook.Remove("Tick", "UpdateRichPresence")
	else
		hook.Add("Tick", "UpdateRichPresence", UpdateRichPresence)
	end
end)
