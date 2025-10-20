local Deathstopsound = CreateClientConVar("Beatrun_Death_StopSounds", "1", true, false)

net.Receive("DeathStopSound", function()
if Deathstopsound:GetBool() then
	if not blinded then
		RunConsoleCommand("stopsound")
	end
end
end)
