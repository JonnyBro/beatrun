function StartDiscordPresence(arguments)
	if not util.IsBinaryModuleInstalled("gdiscord") then return end
	require("gdiscord")

	local image = "default"
	local discord_id = "1109438051496775682"
	local refresh_time = 60
	local discord_start = discord_start or -1

	function DiscordUpdate()
		local ply = LocalPlayer()
		if not ply.GetLevel then return end

		local rpc_data = {}

		if game.SinglePlayer() then
			rpc_data["state"] = "Singleplayer"
		else
			local ip = game.GetIPAddress()

			if ip == "loopback" then
				if GetConVar("p2p_enabled"):GetBool() then
					rpc_data["state"] = "Peer 2 Peer"
				else
					rpc_data["state"] = "Local Server"
				end
			else
				rpc_data["state"] = "Dedicated Server"
			end
		end

		rpc_data["partySize"] = player.GetCount()
		rpc_data["partyMax"] = game.MaxPlayers()

		if game.SinglePlayer() then
			rpc_data["partyMax"] = 0
		end

		local level = ply:GetLevel()
		local customname = hook.Run("BeatrunHUDCourse")
		local course = customname and customname or Course_Name ~= "" and Course_Name or "Freeplay"
		rpc_data["details"] = "Level: " .. level .. " | Map: " .. game.GetMap()
		rpc_data["startTimestamp"] = discord_start
		rpc_data["largeImageKey"] = image
		rpc_data["largeImageText"] = course

		DiscordUpdateRPC(rpc_data)
	end

	timer.Simple(5, function()
		discord_start = os.time()

		DiscordRPCInitialize(discord_id)
		DiscordUpdate()

		if timer.Exists("UpdateDiscordRichPresence") then timer.Remove("UpdateDiscordRichPresence") end

		timer.Create("UpdateDiscordRichPresence", refresh_time, 0, DiscordUpdate)
	end)
end

function StartSteamPresence(arguments)
	if not util.IsBinaryModuleInstalled("steamrichpresencer") then return end
	require("steamrichpresencer")

	local richtext = ""
	local refresh_time = 60

	local function SteamUpdate()
		local ply = LocalPlayer()
		if not ply.GetLevel then return end

		local map = game.GetMap()
		local level = ply:GetLevel()
		local customname = hook.Run("BeatrunHUDCourse")
		local course = customname and customname or Course_Name ~= "" and Course_Name or "Freeplay"
		local updatedtext = "Beatrun Lv. " .. level .. " (" .. map .. ") | " .. course

		if richtext ~= updatedtext then
			richtext = updatedtext
			steamworks.SetRichPresence("generic", richtext)
		end
	end

	timer.Simple(5, function()
		SteamUpdate()

		if timer.Exists("UpdateSteamRichPresence") then timer.Remove("UpdateSteamRichPresence") end

		timer.Create("UpdateSteamRichPresence", refresh_time, 0, SteamUpdate)
	end)
end

hook.Add("OnGamemodeLoaded", "UpdateDiscordStatus", function()
	StartDiscordPresence()
	StartSteamPresence()
end)