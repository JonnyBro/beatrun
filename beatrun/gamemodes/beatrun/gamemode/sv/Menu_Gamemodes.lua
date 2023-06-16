util.AddNetworkString("Beatrun_ToggleGamemode")

net.Receive("Beatrun_ToggleGamemode", function(_, ply)
	local gm = net.ReadString()

	if gm == "datatheft" then
		if not GetGlobalBool(GM_DATATHEFT) then
			Beatrun_StartDataTheft()
		else
			Beatrun_StopDataTheft()
		end
	elseif gm == "infection" then
		if not GetGlobalBool(GM_INFECTION) then
			Beatrun_StartInfection()
		else
			Beatrun_StopInfection()
		end
	end
end)