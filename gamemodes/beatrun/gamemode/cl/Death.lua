net.Receive("DeathStopSound", function()
	if not blinded then
		RunConsoleCommand("stopsound")
	end
end)