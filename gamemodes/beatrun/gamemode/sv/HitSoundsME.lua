util.AddNetworkString("DeathStopSound")

hook.Add("EntityTakeDamage", "MEHitSounds", function(ply, dmginfo)
	if not ply:IsPlayer() then return end
	if not dmginfo:IsFallDamage() and not (ply:HasGodMode() or cvars.Bool("sbox_godmode", false)) then ply:FaithVO("Faith.ImpactHard") end

	if dmginfo:IsBulletDamage() then
		-- No damage if they're going above 400 hu/h. Get dodged idiot
		if ply:GetVelocity():Length() > 400 then return true end

		ply:EmitSound("FleshHit")
	elseif not (ply:HasGodMode() or cvars.Bool("sbox_godmode", false)) and dmginfo:IsFallDamage() and ply:Health() - dmginfo:GetDamage() <= 0 then
		net.Start("DeathStopSound")
		net.Send(ply)

		timer.Simple(0.01, function() if IsValid(ply) then ply:EmitSound("DeathFall") end end)

		ply:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 255), 0.05, 5)
	end
end)
