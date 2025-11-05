local stopsound = CreateClientConVar("Beatrun_Death_StopSounds", "1", true, false)

net.Receive("DeathStopSound", function()
	-- NOTE: blinded is never set??
	if stopsound:GetBool() or not blinded then
		RunConsoleCommand("stopsound")
	end
end)