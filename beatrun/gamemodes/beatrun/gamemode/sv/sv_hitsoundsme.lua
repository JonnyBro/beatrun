util.AddNetworkString("DeathStopSound")

hook.Add("EntityTakeDamage", "MEHitSounds", function(ply, dmginfo)
	if not ply:IsPlayer() then return end

	if dmginfo:IsBulletDamage() then
		-- Block damage if they're going very fast
		if ply:GetVelocity():Length() > 400 then return true end

		ply:EmitSound("mirrorsedge/Flesh_0" .. tostring(math.random(1, 9)) .. ".wav")
		ply:ViewPunch(Angle(math.Rand(-10, -5), 0, math.Rand(0, 5)))
	elseif dmginfo:IsFallDamage() and not ply:HasGodMode() then
		net.Start("DeathStopSound")
		net.Send(ply)

		timer.Simple(0.01, function()
			if IsValid(ply) then
				ply:EmitSound("mirrorsedge/DeathFall" .. tostring(math.random(1, 4)) .. ".wav")
			end
		end)

		ply:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 255), 0.05, 10)
	end
end)