local stopsound = CreateClientConVar("Beatrun_StopDeathSound", "1", true, false)

net.Receive("DeathStopSound", function()
	if stopsound:GetBool() then
		RunConsoleCommand("stopsound")
	end
end)
