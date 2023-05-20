hook.Add("OnEntityCreated", "lol", function(ent)
	if ent:IsNPC() then
		SafeRemoveEntityDelayed(ent, 0.1)
	end

	if ent:GetClass() == "trigger_weapon_strip" then
		ent:Remove()
	end

	if ent:GetClass() == "trigger_once" then
		ent:Remove()
	end
end)