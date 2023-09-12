DEFINE_BASECLASS("gamemode_base")

-- successfully yonked from DarkRP, thanks <3
function fp(tbl)
	local func = tbl[1]

	return function(...)
		local fnArgs = {}
		local arg = {...}
		local tblN = table.maxn(tbl)

		for i = 2, tblN do fnArgs[i - 1] = tbl[i] end
		for i = 1, table.maxn(arg) do fnArgs[tblN + i - 1] = arg[i] end

		return func(unpack(fnArgs, 1, table.maxn(fnArgs)))
	end
end

local function disableBabyGod(ply)
	if not IsValid(ply) or not ply.Babygod then return end

	ply.Babygod = nil
	ply:GodDisable()
end

local function enableBabyGod(ply)
	timer.Remove(ply:EntIndex() .. "babygod")

	ply.Babygod = true
	ply:GodEnable()

	timer.Create(ply:EntIndex() .. "babygod", 5, 1, fp({disableBabyGod, ply}))
end

function GM:PlayerSpawn(ply, transition)
	player_manager.SetPlayerClass(ply, "player_beatrun")

	ply:StripAmmo()

	BaseClass.PlayerSpawn(self, ply, transition)

	if GetGlobalBool("GM_DEATHMATCH") or GetGlobalBool("GM_DATATHEFT") then
		enableBabyGod(ply)
	end
end