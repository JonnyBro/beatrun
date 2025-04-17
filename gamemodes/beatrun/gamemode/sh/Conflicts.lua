local problematichooks = {
	SetupMove = {"vmanip_vault"}
}

local function RemoveConflicting()
	for k, v in pairs(problematichooks) do
		for _, b in ipairs(v) do
			hook.Remove(k, b)
		end
	end

	hook.Remove("InitPostEntity", "RemoveConflicting")
end

hook.Add("InitPostEntity", "RemoveConflicting", RemoveConflicting)