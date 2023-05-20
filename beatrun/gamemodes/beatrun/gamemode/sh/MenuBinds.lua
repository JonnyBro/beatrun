hook.Add("PlayerButtonDown", "PlayerButtonDownWikiExample", function(ply, button)
	if (game.SinglePlayer() or CLIENT and IsFirstTimePredicted()) and button == KEY_F4 then
		ply:ConCommand("Beatrun_CourseMenu")
	end
end)