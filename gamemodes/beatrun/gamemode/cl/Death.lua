local stopsound = CreateClientConVar("Beatrun_Death_StopSound", "0", true, false)

net.Receive("DeathStopSound", function()
	if stopsound:GetBool() then
		return
	else
		RunConsoleCommand("stopsound")
	end
end)
