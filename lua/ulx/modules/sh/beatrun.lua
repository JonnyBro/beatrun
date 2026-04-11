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

		table.insert(affected_plys, ply)
	end

	if #affected_plys > 0 then
		ulx.fancyLogAdmin(calling_ply, "#A set level of #T to #s", affected_plys, tostring(level))
	end
end

local setlevel = ulx.command(CATEGORY_NAME, "ulx setlevel", ulx.setlevel, "!setlevel")
setlevel:addParam({
	type = ULib.cmds.PlayersArg
})

setlevel:addParam({
	type = ULib.cmds.NumArg,
	min = -100000,
	max = 100000,
	default = 1,
	hint = "Level to set",
	ULib.cmds.round
})

setlevel:defaultAccess(ULib.ACCESS_SUPERADMIN)
setlevel:help("Sets player's local level (calculates proper XP, saves).")
