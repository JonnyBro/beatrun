if SERVER then
	util.AddNetworkString("DBNO")
else
	net.Receive("DBNO", function()
		DoJumpTurn()
	end)
end

hook.Add("ScalePlayerDamage", "MissedMe", function(ply, hitgroup, dmginfo)
	if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() then return end

	local vel = ply:GetVelocity()
	local vel_len = vel:Length()

	if vel_len > 310 or ply:GetSliding() and vel_len > 100 or ply:GetWallrun() > 0 and vel_len > 200 or ply:GetJumpTurn() and not ply:OnGround() then return true end
end)

hook.Add("EntityTakeDamage", "MissedMe", function(victim, dmginfo)
	if not victim:IsPlayer() then return end

	local dmgtype = dmginfo:GetDamageType()

	if victim:GetSliding() and (dmgtype == DMG_SLASH or dmgtype == DMG_CLUB) then return true end
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

	hook.Add("HUDPaint", "NTScreenEffects", function()
		local ply = LocalPlayer()

		if not ply:Alive() then return end

		local w = ScrW()
		local h = ScrH()

		dmgalpha = math.min(300 * math.abs(ply:Health() / ply:GetMaxHealth() - 1), 255)

		surface.SetMaterial(radial)
		surface.SetDrawColor(0, 0, 0, dmgalpha * 0.85)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		surface.DrawTexturedRectRotated(ScrW() * 0.5, ScrH() * 0.5, ScrW(), ScrH(), 180)
		surface.SetDrawColor(255, 25, 25, dmgalpha * math.max(0, math.sin(CurTime() * 6) * 0.045))
		surface.DrawTexturedRect(0, 0, w, h)
	end)
end

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
end