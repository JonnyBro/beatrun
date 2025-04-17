Infection_StartTime = 0
Infection_EndTime = 0

local startTime = CreateConVar("Beatrun_InfectionStartTime", 10, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "", 5, 20)
local gameTime = CreateConVar("Beatrun_InfectionGameTime", 190, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "", 30, 600)

function table.Shuffle(t)
	local n = #t

	while n > 1 do
		local k = math.random(n)
		t[k] = t[n]
		t[n] = t[k]
		n = n - 1
	end

	return t
end

local function HumanCount()
	local count = 0

	for _, v in ipairs(player.GetAll()) do
		if IsValid(v) and not v:GetNW2Bool("Infected") then
			count = count + 1
		end
	end

	return count
end

if SERVER then
	util.AddNetworkString("Infection_Start")
	util.AddNetworkString("Infection_End")
	util.AddNetworkString("Infection_Touch")
	util.AddNetworkString("Infection_Announce")
	util.AddNetworkString("Infection_XPReward")
	util.AddNetworkString("Infection_LastMan")
	util.AddNetworkString("Infection_Sync")

	local revealed = false
	local ended = false
	local didmusic = false
	-- local didgun = false
	local cachedhumancount = -1

	-- local function GiveLastManGun()
	-- 	if cachedhumancount == 1 then
	-- 		for k, v in pairs(player.GetAll()) do
	-- 			if not didgun and not ended and v:Alive() and not v:GetNW2Bool("Infected") then
	-- 				hook.Run("Infection_LastManGun", v)
	-- 				didgun = true
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- end

	net.Receive("Infection_Touch", function(len, ply)
		local victim = net.ReadEntity()

		if ended or not ply:Alive() or not ply:GetNW2Bool("Infected") or victim:GetNW2Bool("Infected") then return end

		if IsValid(victim) and victim:IsPlayer() and ply:GetPos():Distance(victim:GetPos()) < 300 then
			victim:SetNW2Bool("Infected", true)

			net.Start("Infection_Announce")
				net.WriteEntity(ply)
				net.WriteEntity(victim)
			net.Broadcast()

			victim:SetNW2Float("PBTime", CurTime() - Infection_StartTime)

			local humancount = HumanCount()
			cachedhumancount = humancount

			-- timer.Simple(0.01, GiveLastManGun)

			if humancount < 1 then
				victim:EmitSound("blackout_hit_0" .. math.random(1, 3) .. ".wav")

				net.Start("Infection_End")
					net.WriteFloat(CurTime())
				net.Broadcast()

				ended = true

				timer.Simple(15, function()
					if ended and GetGlobalBool("GM_INFECTION") then
						Beatrun_StartInfection()
					end
				end)
			else
				victim:EmitSound("player_damage_tonal_hit_0" .. math.random(1, 6) .. ".wav")
			end
		end
	end)

	local function InfectionSync(ply)
		if GetGlobalBool("GM_INFECTION") and not ply.InfectionSynced then
			net.Start("Infection_Sync")
				net.WriteFloat(Infection_StartTime)
				net.WriteFloat(Infection_EndTime)
			net.Send(ply)

			ply.InfectionSynced = true
		end
	end

	hook.Add("PlayerSpawn", "InfectionSync", InfectionSync)

	function Beatrun_StopInfection()
		SetGlobalBool("GM_INFECTION", false)

		local players = player.GetAll()

		for k, v in ipairs(players) do
			v:SetNW2Float("PBTime", 0)
			v:SetNW2Bool("Infected", false)
		end

		Infection_StartTime = 0
		Infection_EndTime = 0

		hook.Remove("Think", "InfectionTimer")
	end

	local function Beatrun_FirstInfection()
		local players = player.GetAll()
		local numinfected = math.max(math.floor(#players / 4), 1)

		for k, v in pairs(players) do
			if not v:Alive() then
				v:Spawn()
			end
		end

		if numinfected == 1 then
			local infected = players[math.random(#players)]
			infected:SetNW2Bool("Infected", true)

			net.Start("Infection_XPReward")
				net.WriteBool(false)
			net.Send(infected)
		else
			table.Shuffle(players)

			for i = 1, numinfected do
				players[i]:SetNW2Bool("Infected", true)

				net.Start("Infection_XPReward")
					net.WriteBool(false)
				net.Send(players[i])
			end
		end
	end

	local function InfectionTimer()
		if not GetGlobalBool("GM_INFECTION") then return end

		if player.GetCount() <= 1 then
			Beatrun_StopInfection()

			return
		end

		if not revealed and Infection_StartTime <= CurTime() then
			revealed = true

			Beatrun_FirstInfection()
		end

		local timeremaining = Infection_EndTime - CurTime()

		if not didmusic and revealed and timeremaining <= 60 and timeremaining >= 50 and player.GetCount() >= 5 and cachedhumancount == 1 then
			timer.Simple(0.1, function()
				for k, v in ipairs(player.GetAll()) do
					if v:Alive() and not v:GetNW2Bool("Infected") then
						net.Start("Infection_LastMan")
						net.Send(v)

						break
					end
				end
			end)

			didmusic = true
		end

		if Infection_EndTime <= CurTime() and not ended then
			for k, v in ipairs(player.GetAll()) do
				if v:GetNW2Float("PBTime") == 0 and not v:GetNW2Bool("Infected") then
					v:SetNW2Float("PBTime", Infection_EndTime - Infection_StartTime)
				end
			end

			net.Start("Infection_End")
				net.WriteFloat(CurTime())
			net.Broadcast()

			ended = true

			timer.Simple(15, function()
				if ended and GetGlobalBool("GM_INFECTION") then
					Beatrun_StartInfection()
				end
			end)
		end
	end

	function Beatrun_StartInfection()
		if GetGlobalBool("GM_INFECTION") and not ended then return end
		if Course_Name ~= "" then return end
		if player.GetCount() < 2 then return end

		net.Start("Infection_Start")
			net.WriteFloat(CurTime())
		net.Broadcast()

		SetGlobalBool("GM_INFECTION", true)

		revealed = false
		ended = false
		didmusic = false
		-- didgun = false
		cachedhumancount = 0

		local players = player.GetAll()

		for k, v in ipairs(players) do
			v:SetNW2Float("PBTime", 0)
			v:SetNW2Bool("Infected", false)
			v:SelectWeapon("runnerhands")
			v:StripAmmo()

			v.InfectionSynced = true
			v.InfectionWuzHere = true

			if v:GetMoveType() == MOVETYPE_NOCLIP then
				v:SetMoveType(MOVETYPE_WALK)
				v:Spawn()
			end
		end

		Infection_StartTime = CurTime() + startTime:GetInt()
		Infection_EndTime = CurTime() + gameTime:GetInt()

		hook.Add("Think", "InfectionTimer", InfectionTimer)
	end

	function InfectionDeath(ply)
		if not GetGlobalBool("GM_INFECTION") then return end

		if revealed and Infection_StartTime < CurTime() and not ply:GetNW2Bool("Infected") then
			if ply.InfectionWuzHere then
				ply:SetNW2Float("PBTime", CurTime() - Infection_StartTime)
			end

			ply:SetNW2Bool("Infected", true)

			net.Start("Infection_Announce")
				net.WriteEntity(ply)
				net.WriteEntity(ply)
			net.Broadcast()

			local humancount = HumanCount()
			cachedhumancount = humancount

			-- timer.Simple(0.01, GiveLastManGun)

			if humancount < 1 then
				net.Start("Infection_End")
					net.WriteFloat(CurTime())
				net.Broadcast()

				ended = true

				timer.Simple(15, function()
					if ended and GetGlobalBool("GM_INFECTION") then
						Beatrun_StartInfection()
					end
				end)
			end

			local timeremaining = Infection_EndTime - CurTime()

			if timeremaining <= 70 and timeremaining >= 50 and player.GetCount() > 6 and humancount == 1 then
				timer.Simple(0.1, function()
					for _, v in ipairs(player.GetAll()) do
						if v:Alive() and not v:GetNW2Bool("Infected") then
							net.Start("Infection_LastMan")
							net.Send(v)

							break
						end
					end
				end)
			end
		end
	end

	hook.Add("PlayerDeath", "InfectionDeath", InfectionDeath)
	hook.Add("PlayerSpawn", "InfectionDeath", InfectionDeath)
end

if CLIENT then
	local endtime = 0
	local noclipkey = 0

	local function InfectionHUDName()
		if GetGlobalBool("GM_INFECTION") then
			local team = LocalPlayer():GetNW2Bool("Infected") and language.GetPhrase("beatrun.infection.infectedtext") or language.GetPhrase("beatrun.infection.humantext")

			return "Infection " .. team
		else
			hook.Remove("BeatrunHUDCourse", "InfectionHUDName")
		end
	end

	local view = {}
	local lookingbehind = true

	local function blankfunc()
	end

	local function InfectionCalcView(ply, pos, ang)
		if GetGlobalBool("GM_INFECTION") then
			local keydown = input.IsKeyDown(noclipkey)

			if keydown then
				ang.x = 0
				ang.z = 0
				ang.y = ang.y + 180

				view.origin = pos
				view.angles = ang

				lookingbehind = true

				LocalPlayer():DrawViewModel(false)

				BodyAnimMDL.RenderOverride = blankfunc
				BodyAnimMDLarm.RenderOverride = blankfunc
			end

			if lookingbehind and not keydown then
				lookingbehind = false

				LocalPlayer():DrawViewModel(true)

				BodyAnimMDL.RenderOverride = nil
				BodyAnimMDLarm.RenderOverride = nil
			end
		elseif CurTime() > Infection_StartTime + 1 then
			if IsValid(BodyAnimMDL) then
				BodyAnimMDL:SetNoDraw(false)
			end

			if IsValid(BodyAnimMDLarm) then
				BodyAnimMDLarm:SetNoDraw(false)
			end

			LocalPlayer():DrawViewModel(true)
			hook.Remove("CalcView", "InfectionCalcView")
		end
	end

	local chatcolor = Color(200, 200, 200)

	net.Receive("Infection_Start", function()
		local start = net.ReadFloat()
		local noclipbind = input.LookupBinding("noclip") or "n"
		noclipkey = input.GetKeyCode(noclipbind)
		endtime = 0

		Infection_StartTime = start + startTime:GetInt()
		Infection_EndTime = start + gameTime:GetInt()

		hook.Add("BeatrunHUDCourse", "InfectionHUDName", InfectionHUDName)
		hook.Add("CalcView", "InfectionCalcView", InfectionCalcView)

		chat.AddText(chatcolor, language.GetPhrase("beatrun.infection.start"):format(math.max(math.floor(player.GetCount() / 4), 1), startTime:GetInt()))
	end)

	local music = nil

	net.Receive("Infection_End", function()
		local survivors = ""
		endtime = net.ReadFloat()

		timer.Simple(0.5, function()
			for k, v in ipairs(player.GetAll()) do
				if not v:GetNW2Bool("Infected") then
					survivors = survivors .. v:Nick() .. ", "

					if v == LocalPlayer() then
						LocalPlayer():AddXP(200)
					end
				end
			end

			survivors = survivors:sub(1, -3)

			if survivors == "" then
				survivors = language.GetPhrase("beatrun.infection.nosurvivors")

				LocalPlayer():EmitSound("death.wav")
			end

			chat.AddText(chatcolor, language.GetPhrase("beatrun.infection.end"):format(survivors, _time))
		end)

		if music and music.Stop then
			music:Stop()
		end
	end)

	net.Receive("Infection_LastMan", function()
		sound.PlayFile("sound/music/infection_countdown.mp3", "", function(station, errCode, errStr)
			if IsValid(station) then
				station:SetVolume(0.5)
				station:Play()

				music = station
			end
		end)
	end)

	local red = Color(255, 25, 25)
	local yellow = Color(255, 255, 100)

	net.Receive("Infection_Announce", function()
		local attacker = net.ReadEntity()
		local victim = net.ReadEntity()

		if IsValid(attacker) and IsValid(victim) then
			if attacker == victim then
				chat.AddText(attacker, red, " " .. language.GetPhrase("beatrun.infection.infected"))
			else
				chat.AddText(attacker, red, " " .. language.GetPhrase("beatrun.infection.infectedby") .. " ", yellow, victim, "!")
			end

			attacker.InfectionTouchDelay = CurTime() + 3

			if attacker == LocalPlayer() then
				LocalPlayer():AddXP(25)
			end
		end
	end)

	local function InfectionHUD()
		if not GetGlobalBool("GM_INFECTION") then return end

		surface.SetTextColor(color_white)
		surface.SetFont("BeatrunHUD")

		local remainingtime = Infection_EndTime - (endtime == 0 and CurTime() or endtime)

		if CurTime() < Infection_StartTime then
			remainingtime = Infection_StartTime - CurTime()
		end

		remainingtime = math.max(remainingtime, 0)

		local timer = string.FormattedTime(remainingtime, "%02i:%02i:%02i")
		local tw, _ = surface.GetTextSize(timer)

		surface.SetTextPos(ScrW() * 0.5 - tw * 0.5, ScrH() * 0.25)
		surface.DrawText(timer)
	end

	local tab = {
		["$pp_colour_contrast"] = 1.05,
		["$pp_colour_addg"] = 0.023529411764705882,
		["$pp_colour_addb"] = 0.023529411764705882,
		["$pp_colour_addr"] = 0.12549019607843137,
		["$pp_colour_colour"] = 0.91,
		["$pp_colour_brightness"] = -0.1,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0,
		["$pp_colour_mulr"] = 0
	}

	hook.Add("BeatrunSpawn", "InfectionSpawnDelay", function()
		LocalPlayer().InfectionTouchDelay = CurTime() + 6
	end)

	local function BeatrunInfectedVision()
		if GetGlobalBool("GM_INFECTION") and LocalPlayer():GetNW2Bool("Infected") then
			tab["$pp_colour_colour"] = CurTime() > (LocalPlayer().InfectionTouchDelay or 0) and 0.91 or 0.1
			DrawColorModify(tab)
		end
	end

	hook.Add("HUDPaint", "InfectionHUD", InfectionHUD)
	hook.Add("RenderScreenspaceEffects", "BeatrunInfectedVision", BeatrunInfectedVision)

	net.Receive("Infection_XPReward", function()
		local humanwin = net.ReadBool()

		if humanwin then
			LocalPlayer():AddXP(200)
			chat.AddText(chatcolor, language.GetPhrase("beatrun.infection.award"))
		else
			LocalPlayer():AddXP(100)
			chat.AddText(chatcolor, language.GetPhrase("beatrun.infection.awardinfected"))
		end
	end)

	net.Receive("Infection_Sync", function()
		endtime = 0
		Infection_StartTime = net.ReadFloat()
		Infection_EndTime = net.ReadFloat()
		hook.Add("BeatrunHUDCourse", "InfectionHUDName", InfectionHUDName)
	end)
end