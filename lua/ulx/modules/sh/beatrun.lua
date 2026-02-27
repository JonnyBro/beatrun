if not ulx or engine.ActiveGamemode() ~= "beatrun" then return end

local CATEGORY_NAME = "Beatrun"

-- !setlevel
function ulx.setlevel(calling_ply, target_plys, level)
	local affected_plys = {}
	for i = 1, #target_plys do
		local ply = target_plys[i]
		local code = string.format([[
			LocalPlayer():SetLevel(%d)
			LocalPlayer():SetXP(XP_nextlevel(%d - 1))
			LocalPlayer():SaveXP()
		]], level, level)

		ply:SendLua(code)
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