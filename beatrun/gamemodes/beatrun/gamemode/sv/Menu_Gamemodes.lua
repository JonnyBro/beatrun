util.AddNetworkString("Beatrun_ToggleGamemode")
util.AddNetworkString("Beatrun_UpdateDataTheftLoadout")

local datatheft, infection = false

net.Receive("Beatrun_ToggleGamemode", function(_, ply)
	local gm = net.ReadString()

	if gm == "datatheft" then
		datatheft = not datatheft

		if datatheft then
			Beatrun_StartDataTheft()
		else
			Beatrun_StopDataTheft()
		end
	elseif gm == "infection" then
		infection = not infection

		if infection then
			Beatrun_StartInfection()
		else
			Beatrun_StopInfection()
		end
	end
end)

net.Receive("Beatrun_UpdateDataTheftLoadout", function(_, ply)

end)