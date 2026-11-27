local stopsound = CreateClientConVar("Beatrun_StopDeathSound", "1", true, false)

CreateClientConVar("Beatrun_DeathBlackScreen", "1", true, true, "", 0, 1)

net.Receive("DeathStopSound", function()
	if stopsound:GetBool() then
		RunConsoleCommand("stopsound")
	end
end)
