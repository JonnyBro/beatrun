util.AddNetworkString("Beatrun_UpdateLoadouts")

local function IsAvailableForPlayer(ply)
	return ply:IsAdmin()
end

net.Receive("Beatrun_UpdateLoadouts", function(len, ply)
	local data = net.ReadData(len)
	data = util.Decompress(data)

	if not data or data == "" then return end

	local loadout = util.JSONToTable(data)

	if not loadout then return print("Failed to parse %s\"s loadout!", ply:Nick()) end

	local canUse, reason = IsAvailableForPlayer(ply)

	if not canUse then return ply:ChatPrint("[Loadout] " .. reason) end
end)