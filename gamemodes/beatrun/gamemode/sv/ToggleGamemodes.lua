util.AddNetworkString("Beatrun_ToggleGamemode")

net.Receive("Beatrun_ToggleGamemode", function(_, ply)
	if not ply:IsAdmin() then return end

	local mode = string.lower(net.ReadString())

	if mode == "datatheft" then
		if not GetGlobalBool("GM_DATATHEFT") then
			Beatrun_StartDataTheft()
		else
			Beatrun_StopDataTheft()
		end
	elseif mode == "infection" then
		if not GetGlobalBool("GM_INFECTION") then
			Beatrun_StartInfection()
		else
			Beatrun_StopInfection()
		end
	elseif mode == "deathmatch" then
		if not GetGlobalBool("GM_DEATHMATCH") then
			Beatrun_StartDeathmatch()
		else
			Beatrun_StopDeathmatch()
		end
	elseif mode == "eventmode" then
		if not GetGlobalBool("GM_EVENTMODE") then
			Beatrun_StartEventmode(ply)
		else
			Beatrun_StopEventmode()
		end
	end
end)