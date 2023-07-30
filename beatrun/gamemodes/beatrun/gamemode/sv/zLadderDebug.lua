function SpawnDebugLadder()
	local p = Entity(1):GetEyeTrace()
	a = ents.Create("br_ladder")

	a:SetAngles(p.HitNormal:Angle())
	a:SetPos(p.HitPos + p.HitNormal * 10)
	a:Spawn()

	sk = util.QuickTrace(p.HitPos, Vector(0, 0, 100000)).HitPos - p.HitNormal * 10

	a:LadderHeightExact(util.QuickTrace(sk, Vector(0, 0, -100000)).HitPos:Distance(a:GetPos()) - 62)
end