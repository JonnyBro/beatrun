util.AddNetworkString("Beatrun_ToggleDataTheft")
util.AddNetworkString("Beatrun_ToggleInfection")

local datatheft, infection = false

net.Receive("Beatrun_ToggleDataTheft", function(_, ply)
	datatheft = not datatheft
	if datatheft then
		Beatrun_StartDataTheft()
	else
		Beatrun_StopDataTheft()
	end
end)

net.Receive("Beatrun_ToggleInfection", function(_, ply)
	infection = not infection
	if infection then
		Beatrun_StartInfection()
	else
		Beatrun_StopInfection()
	end
end)