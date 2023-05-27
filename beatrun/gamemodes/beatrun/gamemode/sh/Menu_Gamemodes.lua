hook.Add("PlayerButtonDown", "GMMenuBind", function(ply, button)
	if (game.SinglePlayer() or CLIENT and IsFirstTimePredicted()) and button == KEY_F3 then
		ply:ConCommand("Beatrun_GamemodesMenu")
	end
end)