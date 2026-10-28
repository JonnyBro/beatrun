hook.Add("PlayerButtonDown", "CourseMenuBind", function(ply, button)
	if (game.SinglePlayer() or CLIENT and IsFirstTimePredicted()) and button == KEY_F4 then
		ply:ConCommand("beatrun_coursesmenu")
	end
end)
