if not ulx or engine.ActiveGamemode() ~= "beatrun" then return end

local CATEGORY_NAME = "Beatrun"

local function SetPlayerLevel(ply, level)
	if game.IsDedicated() then
		ply:SetLevel(level)
	else
		ply:SendLua(string.format([[LocalPlayer():SetLevel(%d); LocalPlayer():SetXP(CalcXPForNextLevel(%d - 1)); Beatrun_SaveXP()]], level, level))
	end
end

-- !setlevel
function ulx.setlevel(calling_ply, target_plys, level)
	for _, ply in ipairs(target_plys) do
		SetPlayerLevel(ply, level)
	end

	ulx.fancyLogAdmin(calling_ply, "#A changed Beatrun level of #T to #s", target_plys, tostring(level))
end

local setlevel = ulx.command(CATEGORY_NAME, "ulx setlevel", ulx.setlevel, "!setlevel")
setlevel:addParam({
	type = ULib.cmds.PlayersArg
})

setlevel:addParam({
	type = ULib.cmds.NumArg,
	min = 1,
	max = 100000,
	default = 1,
	hint = "Level to set",
	ULib.cmds.round
})

setlevel:defaultAccess(ULib.ACCESS_SUPERADMIN)
setlevel:help("Sets player's Beatrun level\n(calculates proper XP\nand saves)")

-- !addxp
function ulx.addxp(calling_ply, target_plys, amount)
	for _, ply in ipairs(target_plys) do
		if game.IsDedicated() then
			ply:AddXP(amount)
		else
			ply:SendLua(string.format([[LocalPlayer():AddXP(%d); Beatrun_SaveXP()]], amount))
		end
	end

	ulx.fancyLogAdmin(calling_ply, "#A gave #s XP to #T", tostring(amount), target_plys)
end

local addxp = ulx.command(CATEGORY_NAME, "ulx addxp", ulx.addxp, "!addxp")
addxp:addParam({ type = ULib.cmds.PlayersArg })
addxp:addParam({ type = ULib.cmds.NumArg, min = 1, max = 10000000, hint = "XP to add", ULib.cmds.round })
addxp:defaultAccess(ULib.ACCESS_SUPERADMIN)
addxp:help("Adds Beatrun XP to players")

-- !resetlevel
function ulx.resetlevel(calling_ply, target_plys)
	for _, ply in ipairs(target_plys) do
		SetPlayerLevel(ply, 1)
	end

	ulx.fancyLogAdmin(calling_ply, "#A reset Beatrun level of #T", target_plys)
end

local resetlevel = ulx.command(CATEGORY_NAME, "ulx resetlevel", ulx.resetlevel, "!resetlevel")
resetlevel:addParam({ type = ULib.cmds.PlayersArg })
resetlevel:defaultAccess(ULib.ACCESS_SUPERADMIN)
resetlevel:help("Resets Beatrun level and XP of players")

-- !loadcourse
local courseDomain = SERVER and CreateConVar("Beatrun_ServerDomain", "courses.jbro.top", { FCVAR_ARCHIVE }, "Courses database used by ulx loadcourse")

function ulx.loadcourse(calling_ply, code)
	code = string.upper(string.Trim(code))

	local base = "https://" .. courseDomain:GetString()
	local headers = { code = code }

	http.Fetch(base .. "/api/courses/info/" .. code, function(body, _, _, status)
		local res = util.JSONToTable(body or "")
		local info = res and res.data

		if status ~= 200 or not istable(info) then
			return ULib.tsayError(calling_ply, "Course " .. code .. " not found", true)
		end

		if info.mapName ~= game.GetMap() then
			return ULib.tsayError(calling_ply, "Course " .. code .. " is made for " .. tostring(info.mapName), true)
		end

		http.Fetch(base .. "/api/courses/download", function(data, _, _, downloadStatus)
			if downloadStatus ~= 200 or not data or data == "" then
				return ULib.tsayError(calling_ply, "Couldn't download course " .. code, true)
			end

			Beatrun_ReadCourse(util.Base64Decode(data))

			ulx.fancyLogAdmin(calling_ply, "#A loaded course #s (#s)", tostring(info.name), code)
		end, function(err)
			ULib.tsayError(calling_ply, "Couldn't download course " .. code .. ": " .. tostring(err), true)
		end, headers)
	end, function(err)
		ULib.tsayError(calling_ply, "Couldn't reach the courses database: " .. tostring(err), true)
	end)
end

local loadcourse = ulx.command(CATEGORY_NAME, "ulx loadcourse", ulx.loadcourse, "!loadcourse")
loadcourse:addParam({ type = ULib.cmds.StringArg, hint = "course code" })
loadcourse:defaultAccess(ULib.ACCESS_SUPERADMIN)
loadcourse:help("Loads a course from the courses database for everyone")

-- !stopcourse
function ulx.stopcourse(calling_ply)
	if Course_Name == "" then return ULib.tsayError(calling_ply, "No course is loaded", true) end

	Course_Stop()

	ulx.fancyLogAdmin(calling_ply, "#A stopped the course")
end

local stopcourse = ulx.command(CATEGORY_NAME, "ulx stopcourse", ulx.stopcourse, "!stopcourse")
stopcourse:defaultAccess(ULib.ACCESS_SUPERADMIN)
stopcourse:help("Stops the current course and returns to freeplay")

-- !restart
function ulx.courserestart(calling_ply, target_plys)
	if Course_Name == "" then return ULib.tsayError(calling_ply, "No course is loaded", true) end

	for _, ply in ipairs(target_plys) do
		if ply:InVehicle() then ply:ExitVehicle() end

		ply.CPSavePos = nil
		ply.CPSaveVehicle = nil
		ply:SetNW2Int("CPNum", 1)
		ply:Spawn()
	end

	ulx.fancyLogAdmin(calling_ply, "#A restarted the course for #T", target_plys)
end

local courserestart = ulx.command(CATEGORY_NAME, "ulx courserestart", ulx.courserestart, "!restart")
courserestart:addParam({ type = ULib.cmds.PlayersArg, ULib.cmds.optional })
courserestart:defaultAccess(ULib.ACCESS_ADMIN)
courserestart:help("Sends players back to the start of the course")

-- !tpcp
function ulx.tpcp(calling_ply, target_ply, num)
	if Course_Name == "" then return ULib.tsayError(calling_ply, "No course is loaded", true) end

	local count = table.Count(Checkpoints)
	local cp = Checkpoints[num]

	if not IsValid(cp) or num >= count then
		return ULib.tsayError(calling_ply, "Pick a checkpoint from 1 to " .. math.max(count - 1, 0) .. ", the last one is the finish", true)
	end

	if target_ply:InVehicle() then target_ply:ExitVehicle() end

	local pos = cp:GetPos() + Vector(0, 0, 8)

	target_ply:SetPos(pos)
	target_ply:SetLocalVelocity(vector_origin)
	target_ply:SetNW2Int("CPNum", num + 1)

	target_ply.CPSavePos = pos
	target_ply.CPSaveAng = target_ply:EyeAngles()
	target_ply.CPSaveVel = vector_origin
	target_ply.CPSaveVehicle = nil

	ulx.fancyLogAdmin(calling_ply, "#A teleported #T to checkpoint #s", target_ply, tostring(num))
end

local tpcp = ulx.command(CATEGORY_NAME, "ulx tpcp", ulx.tpcp, "!tpcp")
tpcp:addParam({ type = ULib.cmds.PlayerArg })
tpcp:addParam({ type = ULib.cmds.NumArg, min = 1, max = 255, hint = "checkpoint", ULib.cmds.round })
tpcp:defaultAccess(ULib.ACCESS_ADMIN)
tpcp:help("Teleports a player to a checkpoint, counting it as passed")

-- !tolastcp
function ulx.tolastcp(calling_ply, target_plys)
	if Course_Name == "" then return ULib.tsayError(calling_ply, "No course is loaded", true) end

	for _, ply in ipairs(target_plys) do
		if ply:InVehicle() then ply:ExitVehicle() end

		if ply.CPSavePos and ply:GetNW2Int("CPNum", 1) > 1 then
			ply:SetPos(ply.CPSavePos)
			ply:SetEyeAngles(ply.CPSaveAng or ply:EyeAngles())
			ply:SetLocalVelocity(vector_origin)
			ply:LoadParkourState()
		else
			ply:Spawn()
		end
	end

	ulx.fancyLogAdmin(calling_ply, "#A returned #T to their last checkpoint", target_plys)
end

local tolastcp = ulx.command(CATEGORY_NAME, "ulx tolastcp", ulx.tolastcp, "!tolastcp")
tolastcp:addParam({ type = ULib.cmds.PlayersArg, ULib.cmds.optional })
tolastcp:defaultAccess(ULib.ACCESS_ADMIN)
tolastcp:help("Returns players to the last checkpoint they passed (or the start)")

-- !invalidaterun
function ulx.invalidaterun(calling_ply, target_plys)
	if Course_Name == "" then return ULib.tsayError(calling_ply, "No course is loaded", true) end

	local affected = {}

	for _, ply in ipairs(target_plys) do
		if ply:GetNW2Int("CPNum", 1) ~= -1 then
			ply:SetNW2Int("CPNum", -1)
			ply:SendLua([[notification.AddLegacy("#beatrun.misc.runinvalidated", NOTIFY_ERROR, 5)]])

			table.insert(affected, ply)
		end
	end

	if #affected == 0 then return ULib.tsayError(calling_ply, "Nobody is in a run", true) end

	ulx.fancyLogAdmin(calling_ply, "#A invalidated the run of #T", affected)
end

local invalidaterun = ulx.command(CATEGORY_NAME, "ulx invalidaterun", ulx.invalidaterun, "!invalidaterun")
invalidaterun:addParam({ type = ULib.cmds.PlayersArg })
invalidaterun:defaultAccess(ULib.ACCESS_ADMIN)
invalidaterun:help("Stops the current run of players, their time won't count until they respawn")

-- !buildperm / !unbuildperm
function ulx.buildperm(calling_ply, target_plys, should_revoke)
	for _, ply in ipairs(target_plys) do
		ply.BuildModePerm = not should_revoke

		if should_revoke and ply.BuildMode and not ply:IsSuperAdmin() then BuildMode_Toggle(ply) end
	end

	if should_revoke then
		ulx.fancyLogAdmin(calling_ply, "#A took build mode access from #T", target_plys)
	else
		ulx.fancyLogAdmin(calling_ply, "#A gave build mode access to #T", target_plys)
	end
end

local buildperm = ulx.command(CATEGORY_NAME, "ulx buildperm", ulx.buildperm, "!buildperm")
buildperm:addParam({ type = ULib.cmds.PlayersArg })
buildperm:addParam({ type = ULib.cmds.BoolArg, invisible = true })
buildperm:defaultAccess(ULib.ACCESS_SUPERADMIN)
buildperm:help("Lets players use build mode until they leave the server")
buildperm:setOpposite("ulx unbuildperm", { _, _, true }, "!unbuildperm")

-- !gamemode
local GAMEMODES = {
	datatheft = { global = "GM_DATATHEFT", start = "Beatrun_StartDataTheft", stop = "Beatrun_StopDataTheft" },
	deathmatch = { global = "GM_DEATHMATCH", start = "Beatrun_StartDeathmatch", stop = "Beatrun_StopDeathmatch" },
	infection = { global = "GM_INFECTION", start = "Beatrun_StartInfection", stop = "Beatrun_StopInfection" },
	eventmode = { global = "GM_EVENTMODE", start = "Beatrun_StartEventmode", stop = "Beatrun_StopEventmode" }
}

function ulx.brgamemode(calling_ply, mode)
	local gm = GAMEMODES[mode]

	if GetGlobalBool(gm.global) then
		_G[gm.stop]()

		return ulx.fancyLogAdmin(calling_ply, "#A stopped #s", mode)
	end

	for name, other in pairs(GAMEMODES) do
		if GetGlobalBool(other.global) then return ULib.tsayError(calling_ply, name .. " is already running", true) end
	end

	if mode == "eventmode" then
		if not IsValid(calling_ply) then return ULib.tsayError(calling_ply, "Event mode needs a player to be its manager", true) end
		if Course_Name ~= "" then return ULib.tsayError(calling_ply, "Stop the course before starting event mode", true) end

		_G[gm.start](calling_ply)
	else
		_G[gm.start]()
	end

	ulx.fancyLogAdmin(calling_ply, "#A started #s", mode)
end

local brgamemode = ulx.command(CATEGORY_NAME, "ulx brgamemode", ulx.brgamemode, "!gamemode")
brgamemode:addParam({ type = ULib.cmds.StringArg, completes = table.GetKeys(GAMEMODES), restrictToCompletes = true, hint = "gamemode" })
brgamemode:defaultAccess(ULib.ACCESS_ADMIN)
brgamemode:help("Starts or stops a Beatrun gamemode")

-- !manager / !suspend / !unsuspend
local function RequireEventmode(calling_ply)
	if GetGlobalBool("GM_EVENTMODE") then return true end

	ULib.tsayError(calling_ply, "Event mode isn't running", true)
end

function ulx.eventmanager(calling_ply, target_ply, should_demote)
	if not RequireEventmode(calling_ply) then return end

	if should_demote then
		if target_ply:GetNW2String("EPlayerStatus") ~= "Manager" then return ULib.tsayError(calling_ply, target_ply:Nick() .. " isn't a manager", true) end

		SetPlayerEventStatus(target_ply, "Member")

		return ulx.fancyLogAdmin(calling_ply, "#A made #T an event member", target_ply)
	end

	if not target_ply:IsAdmin() then return ULib.tsayError(calling_ply, "Only admins can be event managers", true) end

	SetPlayerEventStatus(target_ply, "Manager")

	ulx.fancyLogAdmin(calling_ply, "#A made #T an event manager", target_ply)
end

local eventmanager = ulx.command(CATEGORY_NAME, "ulx eventmanager", ulx.eventmanager, "!manager")
eventmanager:addParam({ type = ULib.cmds.PlayerArg })
eventmanager:addParam({ type = ULib.cmds.BoolArg, invisible = true })
eventmanager:defaultAccess(ULib.ACCESS_ADMIN)
eventmanager:help("Makes an admin an event manager")
eventmanager:setOpposite("ulx uneventmanager", { _, _, true }, "!unmanager")

function ulx.eventsuspend(calling_ply, target_plys, should_unsuspend)
	if not RequireEventmode(calling_ply) then return end

	local affected = {}

	for _, ply in ipairs(target_plys) do
		if ply:GetNW2String("EPlayerStatus") ~= "Manager" then
			SetPlayerEventStatus(ply, should_unsuspend and "Member" or "Suspended")

			table.insert(affected, ply)
		end
	end

	if #affected == 0 then return ULib.tsayError(calling_ply, "Managers can't be suspended", true) end

	ulx.fancyLogAdmin(calling_ply, should_unsuspend and "#A unsuspended #T" or "#A suspended #T", affected)
end

local eventsuspend = ulx.command(CATEGORY_NAME, "ulx eventsuspend", ulx.eventsuspend, "!suspend")
eventsuspend:addParam({ type = ULib.cmds.PlayersArg })
eventsuspend:addParam({ type = ULib.cmds.BoolArg, invisible = true })
eventsuspend:defaultAccess(ULib.ACCESS_ADMIN)
eventsuspend:help("Suspends players in event mode")
eventsuspend:setOpposite("ulx eventunsuspend", { _, _, true }, "!unsuspend")

-- !br
local SERVER_SETTINGS = {
	"Beatrun_AllowEntitiesSpawn", "Beatrun_AllowPropSpawn", "Beatrun_AllowWeaponSpawn", "Beatrun_DisableOverdrive",
	"Beatrun_Disarm", "Beatrun_Dropkick", "Beatrun_HealthRegen", "Beatrun_InfectionGameTime", "Beatrun_InfectionStartTime",
	"Beatrun_Kickglitch", "Beatrun_LedgeGrabDamage", "Beatrun_LeRealisticClimbing", "Beatrun_PuristModeForce",
	"Beatrun_PuristWallrun", "Beatrun_QuakeJump", "Beatrun_RandomLoadouts", "Beatrun_RollSpeedLoss", "Beatrun_SideStep",
	"Beatrun_SpeedLimit", "Beatrun_Totsugeki", "Beatrun_TotsugekiDir", "Beatrun_TotsugekiHeading", "Beatrun_TotsugekiSpam"
}

function ulx.brsetting(calling_ply, setting, value)
	local cvar = GetConVar(setting)
	if not cvar then return ULib.tsayError(calling_ply, "Unknown setting " .. setting, true) end

	if not value or value == "" then return ULib.tsay(calling_ply, setting .. " = " .. cvar:GetString()) end

	cvar:SetString(value)

	ulx.fancyLogAdmin(calling_ply, "#A set #s to #s", setting, value)
end

local brsetting = ulx.command(CATEGORY_NAME, "ulx br", ulx.brsetting, "!br")
brsetting:addParam({ type = ULib.cmds.StringArg, completes = SERVER_SETTINGS, restrictToCompletes = true, hint = "setting" })
brsetting:addParam({ type = ULib.cmds.StringArg, hint = "value, empty to show", ULib.cmds.optional })
brsetting:defaultAccess(ULib.ACCESS_SUPERADMIN)
brsetting:help("Shows or changes a Beatrun server setting")
