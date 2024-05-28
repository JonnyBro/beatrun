if SERVER then
	util.AddNetworkString("Deathmatch_Start")
	util.AddNetworkString("Deathmatch_Sync")

	CreateConVar("Beatrun_RandomMWLoadouts", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "#beatrun.randomloadouts.helptext")

	function getRandomMGBaseWeapon()
		local allWep = weapons.GetList()
		local wepIndex = math.random(#allWep)
		local wep = allWep[wepIndex]

		if wep.Base == "mg_base" then
			return wep
		else
			return getRandomMGBaseWeapon()
		end
	end

	function Beatrun_StartDeathmatch()
		SetGlobalBool("GM_DEATHMATCH", true)

		net.Start("Deathmatch_Start")
		net.Broadcast()

		for _, v in ipairs(player.GetAll()) do
			if v:GetMoveType() == MOVETYPE_NOCLIP then
				v:SetMoveType(MOVETYPE_WALK)
				v:Spawn()
			end

			if GetConVar("Beatrun_RandomMWLoadouts"):GetBool() then
				for i = 0, 1 do
					local randomSWEP = getRandomMGBaseWeapon()
					local w = v:Give(randomSWEP.ClassName)

					timer.Simple(1, function()
						if w:GetPrimaryAmmoType() ~= -1 then v:GiveAmmo(10000, w:GetPrimaryAmmoType(), true) end
						if w:GetSecondaryAmmoType() ~= -1 then v:GiveAmmo(5, w:GetSecondaryAmmoType(), true) end
					end)
				end
			else
				for _, b in ipairs(BEATRUN_GAMEMODES_LOADOUTS[math.random(#BEATRUN_GAMEMODES_LOADOUTS)]) do
					local w = v:Give(b)

					timer.Simple(1, function()
						if w:GetPrimaryAmmoType() ~= -1 then v:GiveAmmo(10000, w:GetPrimaryAmmoType(), true) end
						if w:GetSecondaryAmmoType() ~= -1 then v:GiveAmmo(5, w:GetSecondaryAmmoType(), true) end
					end)
				end
			end
		end
	end

	function Beatrun_StopDeathmatch()
		SetGlobalBool("GM_DEATHMATCH", false)

		for _, v in ipairs(player.GetAll()) do
			v:SetNW2Int("DeathmatchKills", 0)

			v:StripWeapons()
			v:StripAmmo()
			v:Give("runnerhands")
		end
	end

	local function DeathmatchSync(ply)
		if GetGlobalBool("GM_DEATHMATCH") and not ply.DeathmatchSynced then
			net.Start("Deathmatch_Sync")
			net.Send(ply)

			ply.DeathmatchSynced = true
		end
	end

	hook.Add("PlayerSpawn", "DeathmatchSync", DeathmatchSync)

	local function DeathmatchDeath(ply, inflictor, attacker)
		if GetGlobalBool("GM_DEATHMATCH") then
			local plyKills = ply:GetNW2Int("DeathmatchKills", 0)

			if ply == attacker and plyKills ~= 0 then
				ply:SetNW2Int("DeathmatchKills", plyKills - 1)
			elseif IsValid(attacker) and attacker ~= ply then
				local kills = attacker:GetNW2Int("DeathmatchKills", 0)

				attacker:SetNW2Int("DeathmatchKills", kills + 1)
			end
		end
	end

	hook.Add("PlayerDeath", "DeathmatchDeath", DeathmatchDeath)
end

if CLIENT then
	local function DeathmatchHUDName()
		if GetGlobalBool("GM_DEATHMATCH") then
			return "#beatrun.deathmatch.name"
		else
			hook.Remove("BeatrunHUDCourse", "DeathmatchHUDName")
		end
	end

	net.Receive("Deathmatch_Sync", function()
		hook.Add("BeatrunHUDCourse", "DeathmatchHUDName", DeathmatchHUDName)
	end)

	net.Receive("Deathmatch_Start", function()
		hook.Add("BeatrunHUDCourse", "DeathmatchHUDName", DeathmatchHUDName)
		chat.AddText(Color(200, 200, 200), language.GetPhrase("beatrun.deathmatch.start"))
	end)
end