util.AddNetworkString("Beatrun_ChangeConvar")

local replicatedConvars = {
	["Beatrun_AllowPropSpawn"] = true,
	["Beatrun_AllowWeaponSpawn"] = true,
	["Beatrun_AllowOverdriveInMultiplayer"] = true,
	["Beatrun_HealthRegen"] = true,
	["Beatrun_LeRealisticClimbing"] = true,
	["Beatrun_SpeedLimit"] = true,
	["Beatrun_PuristModeForce"] = true,
	["Beatrun_PuristWallrun"] = true,
	["Beatrun_Kickglitch"] = true,
	["Beatrun_QuakeJump"] = true,
	["Beatrun_SideStep"] = true,
	["Beatrun_Disarm"] = true,
	["Beatrun_Totsugeki"] = true,
	["Beatrun_TotsugekiSpam"] = true,
	["Beatrun_TotsugekiHeading"] = true,
	["Beatrun_TotsugekiDir"] = true,
	["Beatrun_InfectionStartTime"] = true,
	["Beatrun_InfectionGameTime"] = true,
	["Beatrun_RandomLoadouts"] = true,
}

net.Receive("Beatrun_ChangeConvar", function(len, ply)
	if not ply:IsAdmin() then return end

	local convarName = net.ReadString()
	local convarValue = net.ReadString()

	if not replicatedConvars[convarName] then return end

	GetConVar(convarName):SetString(convarValue)
end)