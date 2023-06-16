GM_DATATHEFT = 1
DATATHEFT_LOADOUTS = {
	{"weapon_357", "weapon_ar2"}
}

if SERVER then
	util.AddNetworkString("DataTheft_Start")
	util.AddNetworkString("DataTheft_Sync")

	function Beatrun_StartDataTheft()
		SetGlobalBool(GM_DATATHEFT, true)

		net.Start("DataTheft_Start")
		net.Broadcast()

		for _, v in ipairs(player.GetAll()) do
			v:DataTheft_Bank()

			v:SetNW2Int("DataCubes", 0)
			v:SetNW2Int("DataBanked", 0)

			if v:GetMoveType() == MOVETYPE_NOCLIP then
				v:SetMoveType(MOVETYPE_WALK)
				v:Spawn()
			else
				for l, b in ipairs(DATATHEFT_LOADOUTS[math.random(#DATATHEFT_LOADOUTS)]) do
					local wep = v:Give(b)
					v:GiveAmmo(300, wep:GetPrimaryAmmoType())
				end
			end
		end
	end

	function Beatrun_StopDataTheft()
		SetGlobalBool(GM_DATATHEFT, false)

		for _, v in ipairs(player.GetAll()) do
			v:StripWeapons()
			v:StripAmmo()
			v:Give("runnerhands")
		end
	end

	local function DataTheftSync(ply)
		if GetGlobalBool(GM_DATATHEFT) and not ply.DataTheftSynced then
			net.Start("DataTheft_Sync")
			net.Send(ply)

			ply.DataTheftSynced = true
		end
	end

	hook.Add("PlayerSpawn", "DataTheftSync", DataTheftSync)

	local function DataTheftDeath(ply, inflictor, attacker)
		if GetGlobalBool(GM_DATATHEFT) then
			local datacount = ply:GetNW2Int("DataCubes", 0)

			if datacount > 0 then
				local pos = ply:GetPos() + Vector(0, 0, 32)

				for i = 1, datacount + 1 do
					local datacube = ents.Create("br_datacube")

					datacube:SetPos(pos)
					datacube:Spawn()
				end

				ply:SetNW2Int("DataCubes", 0)
			elseif IsValid(attacker) and attacker ~= ply then
				local pos = ply:GetPos() + Vector(0, 0, 32)
				local datacube = ents.Create("br_datacube")

				datacube:SetPos(pos)
				datacube:Spawn()
			end
		end
	end

	hook.Add("PlayerDeath", "DataTheftDeath", DataTheftDeath)
end

if CLIENT then
	local function DataTheftHUDName()
		if GetGlobalBool(GM_DATATHEFT) then
			local datacubes = LocalPlayer():GetNW2Int("DataCubes", 0)

			return "Data Theft (" .. datacubes .. ")"
		else
			hook.Remove("BeatrunHUDCourse", "DataTheftHUDName")
		end
	end

	net.Receive("DataTheft_Sync", function()
		hook.Add("BeatrunHUDCourse", "DataTheftHUDName", DataTheftHUDName)
	end)

	local chatcolor = Color(200, 200, 200)

	net.Receive("DataTheft_Start", function()
		hook.Add("BeatrunHUDCourse", "DataTheftHUDName", DataTheftHUDName)
		chat.AddText(chatcolor, "Data Theft! Kill players to collect data, deposit data in banks")
	end)
end