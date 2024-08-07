if SERVER then
	util.AddNetworkString("DBNO")
else
	net.Receive("DBNO", function()
		DoJumpTurn()
	end)
end

local momentumshield = CreateConVar("Beatrun_MomentumShield", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

if SERVER then
	local healthRegen = CreateConVar("Beatrun_HealthRegen", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

	hook.Add("PlayerPostThink", "HealthRegen", function(ply)
		if not healthRegen:GetBool() then return end

		if not ply.LastHP then
			ply.LastHP = ply:Health()
			ply.RegenTime = 0

			return
		end

		if ply:Health() < ply.LastHP then
			ply.RegenTime = CurTime() + 5
		end

		if ply:Alive() and ply.RegenTime < CurTime() and ply:Health() < ply:GetMaxHealth() then
			ply:SetHealth(math.Approach(ply:Health(), ply:GetMaxHealth(), 1))
			ply.RegenTime = CurTime() + 0.05
		end

		ply.LastHP = ply:Health()
	end)

	for _,v in ipairs(player.GetAll()) do
		v:SetNWFloat("MomentumShieldPer", 0)
	end

	hook.Add("Move", "MomentumShieldRegen", function(ply, mv)
		-- I use the move hook because I need momentum data...blame Garry
		--if !momentumshield:GetBool() then return end

		local shieldpercent = ply:GetNWFloat("MomentumShieldPer", 0)

		if !ply.shielddecaytime then
			ply.shielddecaytime = 0

			return
		end

		if ply:GetVelocity():Length2D() > (GetConVar("Beatrun_SpeedLimit"):GetInt() * 0.8181818181818182) then
			ply:SetNWFloat("MomentumShieldPer", math.Approach(shieldpercent, 300, FrameTime() * 30))
			ply.shielddecaytime = CurTime() + 3
		elseif ply.shielddecaytime < CurTime() then
			ply:SetNWFloat("MomentumShieldPer", math.Approach(shieldpercent, 0, FrameTime() * 250))
		end

		--print(shieldpercent)
	end)
end

if CLIENT then
	local lastmomshield = -1
	local shieldlerptime = 0.16
	local start, oldshield, newshield = 0, -1, -1
	local hudscale = ScrH() / 1080
	hook.Add("HUDPaint", "MomentumShieldHUD", function()
		local ply = LocalPlayer()

		if !IsValid(ply) then return end

		local shieldpercent = ply:GetNWFloat("MomentumShieldPer", 0)

		if oldshield == -1 and newshield == -1 then
			oldshield = shieldpercent
			newshield = shieldpercent
		end

		local shieldsmooth = Lerp((CurTime() - start) / shieldlerptime, oldshield, newshield)

		if newshield != shieldpercent then
			if shieldsmooth != shieldpercent then
				newshield = shieldsmooth
			end
			oldshield = newshield
			start = CurTime()
			newshield = shieldpercent
		end

		surface.SetDrawColor(255,255,255)
		surface.DrawRect(ScrW() * 0.5 - 75,ScrH() * 0.6,150 * (math.max(0, shieldsmooth) / 300) * hudscale, 3 * hudscale)
	end)
end

hook.Add("ScalePlayerDamage", "MissedMe", function(ply, hitgroup, dmginfo)
	if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() or momentumshield:GetBool() then return end

	local vel = ply:GetVelocity()
	local vel_len = vel:Length()

	if vel_len > 310 or ply:GetSliding() and vel_len > 100 or ply:GetWallrun() > 0 and vel_len > 200 or ply:GetJumpTurn() and not ply:OnGround() then return true end
end)

hook.Add("EntityTakeDamage", "MissedMe", function(victim, dmginfo)
	if not victim:IsPlayer() or momentumshield:GetBool() then return end

	local dmgtype = dmginfo:GetDamageType()

	if victim:GetSliding() and (dmgtype == DMG_SLASH or dmgtype == DMG_CLUB) then return true end
end)

hook.Add("EntityTakeDamage", "ShieldProtectPlayer", function(ent, dmg)
	if !ent:IsPlayer() or !momentumshield:GetBool() then return end
	shieldper = ent:GetNWFloat("MomentumShieldPer", 0)
	local dmgamount = dmg:GetDamage()

	if shieldper > 0 and (shieldper - dmgamount) > 0 then
		ent:SetNWFloat("MomentumShieldPer", math.Clamp(shieldper - dmgamount, 0, 300))
		dmg:ScaleDamage(0)
	elseif shieldper > 0 then
		ent:SetNWFloat("MomentumShieldPer", math.Clamp(shieldper - dmgamount, 0, 300))
		dmg:SetDamage(shieldper - dmgamount)
	end
end)

hook.Add("PlayerShouldTakeDamage", "DBNO", function(ply, attacker)
	if not IsValid(attacker) then return end

	local class = attacker:GetClass()

	if class == "npc_antlionguard" or class == "npc_antlionguardian" then
		local atteyeang = attacker:EyeAngles()
		atteyeang.x = 0
		atteyeang.z = 0
		atteyeang.y = atteyeang.y - 180

		ply:SetEyeAngles(atteyeang)
		ply:SetJumpTurn(true)
		ply:SetPos(ply:GetPos() + Vector(0, 0, 8))
		ply:SetLocalVelocity(atteyeang:Forward() * 100 + Vector(0, 0, 100))

		if game.SinglePlayer() then
			timer.Simple(0, function()
				net.Start("DBNO")
				net.Send(ply)
			end)
		else
			net.Start("DBNO")
			net.Send(ply)
		end
	end

	if ply:GetJumpTurn() and not ply:OnGround() and attacker:IsNPC() then return false end
end)

if CLIENT then
	local radial = Material("radial.png")
	local dmgalpha = 0

	hook.Add("PreDrawHUD", "NTScreenEffects", function()
		-- Draw the overlay this way or we (sort of) break other HUDs.
		cam.Start2D()
			local ply = LocalPlayer()

			if not ply:Alive() then
				cam.End2D()
				return
			end

			local w = ScrW()
			local h = ScrH()

			curhealth = math.Clamp(ply:Health(), 0, ply:GetMaxHealth())
			dmgalpha = math.min(300 * math.abs(curhealth / ply:GetMaxHealth() - 1), 255)

			surface.SetMaterial(radial)
			surface.SetDrawColor(0, 0, 0, dmgalpha * 0.58)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			surface.DrawTexturedRectRotated(ScrW() * 0.5, ScrH() * 0.5, ScrW(), ScrH(), 180)
			surface.SetDrawColor(255, 25, 25, dmgalpha * math.max(0, math.sin(CurTime() * 6) * 0.09))
			surface.DrawTexturedRect(0, 0, w, h)
		cam.End2D()
	end)
end
