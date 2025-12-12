local CATEGORY_NAME = "Beatrun"
-- format: multiline
local beatrunGamemodes = {
	"Freeplay",
	"fp",

	"Infection",
	"infect",

	"Deathmatch",
	"dm",

	"Data Theft",
	"dt"
}

local function isValidGamemode(mode)
	mode = string.lower(mode)

	for _, v in ipairs(beatrunGamemodes) do
		if string.lower(v) == mode then return true end
	end

	return false
end

local function ChangeGamemode(mode)
	mode = string.lower(mode)

	if GetGlobalBool("GM_DATATHEFT") then
		Beatrun_StopDataTheft()
	elseif GetGlobalBool("GM_INFECTION") then
		Beatrun_StopInfection()
	elseif GetGlobalBool("GM_DEATHMATCH") then
		Beatrun_StopDeathmatch()
	end

	if mode == "infection" or mode == "infect" then
		if not GetGlobalBool("GM_INFECTION") then
			Beatrun_StartInfection()
		else
			Beatrun_StopInfection()
		end
	elseif mode == "deathmatch" or mode == "dm" then
		if not GetGlobalBool("GM_DEATHMATCH") then
			Beatrun_StartDeathmatch()
		else
			Beatrun_StopDeathmatch()
		end
	elseif mode == "data theft" or mode == "dt" then
		if not GetGlobalBool("GM_DATATHEFT") then
			Beatrun_StartEventmode(ply)
		else
			Beatrun_StopEventmode()
		end
	end
end

-- !votemode
local function voteDone(t, mode, ply)
	local results = t.results
	local winner
	local winnernum = 0

	for id, numvotes in pairs(results) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	local str
	if not winner then
		str = "Vote ended! No one voted or not enough votes."
	else
		str = "Vote successful! (" .. winnernum .. "/" .. t.voters .. ")\nStarting \"" .. mode .. "\"..."
	end

	ChangeGamemode(mode)

	ULib.tsay(_, str)
	ulx.logString(str)
end

function ulx.votemode(calling_ply, mode)
	if ulx.voteInProgress then
		ULib.tsayError(calling_ply, "There is already a vote in progress. Please wait for the current one to end.", true)
		return
	end

	if not isValidGamemode(mode) then
		ULib.tsayError(calling_ply, "Invalid gamemode \"" .. mode .. "\".\nAvailable modes (alias):\n- Freeplay (fp)\n- Deathmatch (dm)\n- Infection (infect)\n- Data Theft (dt)", true)
		return
	end

	ulx.doVote("Change gamemode to " .. mode .. "?", {"Yes", "No"}, voteDone, _, _, _, mode, calling_ply)
	ulx.fancyLogAdmin(calling_ply, "#A started a votemode for #s", mode)
end

local votemode = ulx.command(CATEGORY_NAME, "ulx votemode", ulx.votemode, "!votemode")
votemode:addParam{
	type = ULib.cmds.StringArg,
	completes = beatrunGamemodes,
	hint = "gamemode",
	error = "Invalid gamemode \"%s\" specified\nAvailable modes (alias):\n- Freeplay (fp): Stops all gamemodes\n- Deathmatch (dm)\n- Infection (infect)\n- Data Theft (dt)",
	ULib.cmds.takeRestOfLine
}

votemode:defaultAccess(ULib.ACCESS_ALL)
votemode:help("Starts a Beatrun gamemode vote.\nAvailable modes (alias, case-insensitive):\n- Freeplay (fp): Stops all gamemodes\n- Deathmatch (dm)\n- Infection (infect)\n- Data Theft (dt)")

-- !setlevel
function ulx.setlevel(calling_ply, target_plys, level)
	local affected_plys = {}
	for i = 1, #target_plys do
		local ply = target_plys[i]

		ply:SendLua(string.format("LocalPlayer():SetLevel(%d)", level))
		ply:SendLua(string.format("local xp = XP_nextlevel(%d - 1); LocalPlayer():SetXP(xp)", level))
	end

	ulx.fancyLogAdmin(calling_ply, "#A changed #T level to #i", affected_plys, level)
end

local setlevel = ulx.command(CATEGORY_NAME, "ulx setlevel", ulx.setlevel, "!setlevel")
setlevel:addParam({
	type = ULib.cmds.PlayersArg
})

setlevel:addParam({
	type = ULib.cmds.NumArg,
	min = -1000,
	max = 1000,
	default = 1,
	hint = "Level to set",
	ULib.cmds.round
})

setlevel:defaultAccess(ULib.ACCESS_SUPERADMIN)
setlevel:help("Sets player's local level (calculates proper XP, saves).")