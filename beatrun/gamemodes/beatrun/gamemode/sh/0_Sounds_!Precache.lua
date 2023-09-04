soundAdd_old = sound.Add

local function soundAdd_detour(tbl)
	if not tbl.name then return end

	soundAdd_old(tbl)

	timer.Simple(2, function()
		util.PrecacheSound(tbl.name)
	end)
end

sound.Add = soundAdd_detour