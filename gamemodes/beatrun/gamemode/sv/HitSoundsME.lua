util.AddNetworkString("DeathStopSound")

hook.Add("EntityTakeDamage", "MEHitSounds", function(ply, dmginfo)
	if not ply:IsPlayer() then return end

	if dmginfo:IsBulletDamage() then
		if ply:GetVelocity():Length() > 400 then return true end -- Block damage if they're going very fast

		ply:EmitSound("mirrorsedge/Flesh_0" .. tostring(math.random(1, 9)) .. ".wav")
		-- ply:ViewPunch(Angle(math.Rand(-10, -5), 0, math.Rand(0, 5))) -- People cried so hard about this
	elseif not ply:HasGodMode() and (dmginfo:IsFallDamage() and ply:Health() - dmginfo:GetDamage() <= 0) then
		net.Start("DeathStopSound")
		net.Send(ply)

		timer.Simple(0.01, function()
			if IsValid(ply) then
				ply:EmitSound("mirrorsedge/DeathFall" .. tostring(math.random(1, 4)) .. ".wav")
			end
		end)

		ply:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 255), 0.05, 5)
	end
end)
