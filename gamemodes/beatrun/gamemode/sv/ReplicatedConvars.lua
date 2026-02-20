util.AddNetworkString("Beatrun_ChangeConvar")

local replicatedConvars = {
	["Beatrun_AllowOverdriveInMultiplayer"] = true,
	["Beatrun_AllowPropSpawn"] = true,
	["Beatrun_AllowWeaponSpawn"] = true,
	["Beatrun_Disarm"] = true,
	["Beatrun_HealthRegen"] = true,
	["Beatrun_InfectionGameTime"] = true,
	["Beatrun_InfectionStartTime"] = true,
	["Beatrun_Kickglitch"] = true,
	["Beatrun_LeRealisticClimbing"] = true,
	["Beatrun_PuristModeForce"] = true,
	["Beatrun_PuristWallrun"] = true,
	["Beatrun_QuakeJump"] = true,
	["Beatrun_RandomLoadouts"] = true,
	["Beatrun_RollSpeedLoss"] = true,
	["Beatrun_SideStep"] = true,
	["Beatrun_SpeedLimit"] = true,
	["Beatrun_Totsugeki"] = true,
	["Beatrun_TotsugekiDir"] = true,
	["Beatrun_TotsugekiHeading"] = true,
	["Beatrun_TotsugekiSpam"] = true,
}

net.Receive("Beatrun_ChangeConvar", function(len, ply)
	if not ply:IsAdmin() then return false end

	local convarName = net.ReadString()
	local convarValue = net.ReadString()

	if not replicatedConvars[convarName] then return false end

	GetConVar(convarName):SetString(convarValue)

	return true
end)