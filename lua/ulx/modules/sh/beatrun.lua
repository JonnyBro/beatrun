local CATEGORY_NAME = "Beatrun"

-- !votemode
function ulx.votemode(calling_ply, mode)
	if GetGlobalBool("GM_EVENTMODE") then return end
	
	if voteStarted then
		ULib.tsayError(calling_ply, "There is already a vote in progress. Please wait for the current one to end.", true)
		return
	end

	if CurTime() < nextVoteTime then
		ULib.tsayError(calling_ply, "Vote is on cooldown. Please wait.", true)
		return
	end

	if not isValidGamemode(mode) then
		ULib.tsayError(calling_ply, "Invalid gamemode \"" .. mode .. "\".\nAvailable modes (alias):\n- Freeplay (fp)\n- Deathmatch (dm)\n- Infection (infect)\n- Data Theft (dt)", true)
		return
	end

	StartVote(mode, calling_ply)
	ulx.fancyLogAdmin(calling_ply, "#A started a votemode for #s", mode)
end

local votemode = ulx.command(CATEGORY_NAME, "ulx votemode", ulx.votemode, "!ulxvotemode")
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