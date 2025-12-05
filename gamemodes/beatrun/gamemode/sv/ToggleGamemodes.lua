util.AddNetworkString("Beatrun_ToggleGamemode")

net.Receive("Beatrun_ToggleGamemode", function(_, ply)
	if not ply:IsAdmin() then return end

	local gm = string.lower(net.ReadString())

	if gm == "datatheft" then
		if not GetGlobalBool("GM_DATATHEFT") then
			Beatrun_StartDataTheft()
		else
			Beatrun_StopDataTheft()
		end
	elseif gm == "infection" then
		if not GetGlobalBool("GM_INFECTION") then
			Beatrun_StartInfection()
		else
			Beatrun_StopInfection()
		end
	elseif gm == "deathmatch" then
		if not GetGlobalBool("GM_DEATHMATCH") then
			Beatrun_StartDeathmatch()
		else
			Beatrun_StopDeathmatch()
		end
	elseif gm == "eventmode" then
		if not GetGlobalBool("GM_EVENTMODE") then
			Beatrun_StartEventmode()
		else
			Beatrun_StopEventmode()
		end
	end
end)