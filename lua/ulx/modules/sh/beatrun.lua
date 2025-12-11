local CATEGORY_NAME = "Beatrun"
-- format: multiline
local beatrunGamemodesCompletes = {
	"Freeplay",
	"fp",

	"Infection",
	"infect",

	"Deathmatch",
	"dm",

	"Data Theft",
	"dt",
}

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

	if mode == "Freeplay" then
		if GetGlobalBool("GM_DATATHEFT") then
			Beatrun_StopDataTheft()
		elseif GetGlobalBool("GM_INFECTION") then
			Beatrun_StopInfection()
		elseif GetGlobalBool("GM_DEATHMATCH") then
			Beatrun_StopDeathmatch()
		end
	elseif mode == "Infection" then
		if not GetGlobalBool("GM_INFECTION") then
			Beatrun_StartInfection()
		else
			Beatrun_StopInfection()
		end
	elseif mode == "Deathmatch" then
		if not GetGlobalBool("GM_DEATHMATCH") then
			Beatrun_StartDeathmatch()
		else
			Beatrun_StopDeathmatch()
		end
	elseif mode == "Data Theft" then
		if not GetGlobalBool("GM_EVENTMODE") then
			Beatrun_StartEventmode(ply)
		else
			Beatrun_StopEventmode()
		end
	end

	ULib.tsay(_, str)
	ulx.logString(str)
end

function ulx.votemode(calling_ply, mode)
	if ulx.voteInProgress then
		ULib.tsayError(calling_ply, "There is already a vote in progress. Please wait for the current one to end.", true)
		return
	end

	if mode == "fp" then mode = "Freeplay" end
	if mode == "infect" then mode = "Infection" end
	if mode == "dm" then mode = "Deathmatch" end
	if mode == "dt" then mode = "Data Theft" end

	ulx.doVote("Change gamemode to " .. mode .. "?", {"Yes", "No"}, voteDone, _, _, _, mode, calling_ply)
	ulx.fancyLogAdmin(calling_ply, "#A started a votemode for #s", mode)
end

local votemode = ulx.command(CATEGORY_NAME, "ulx votemode", ulx.votemode, "!votemode")
votemode:addParam{
	type = ULib.cmds.StringArg,
	completes = beatrunGamemodesCompletes,
	hint = "gamemode",
	error = "invalid gamemode \"%s\" specified",
	ULib.cmds.restrictToCompletes,
	ULib.cmds.takeRestOfLine
}

votemode:defaultAccess(ULib.ACCESS_ALL)
votemode:help("Starts a Beatrun gamemode vote.")

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