local vwrtime = 1.5
local hwrtime = 1.5
tiltdir = 1
local tilt = 0
local wrmins = Vector(-16, -16, 0)
local wrmaxs = Vector(16, 16, 16)

function PuristWallrunningCheck(ply, mv, cmd, vel, eyeang, timemult, speedmult)
	local downvel = mv:GetVelocity().z

	if downvel > -75 then
		downvel = math.max(downvel, 10)
	end

	timemult = math.Clamp(math.max(downvel * 0.1, -10), 0.5, 1.1)

	if not ply:OnGround() and mv:KeyDown(IN_JUMP) and mv:GetVelocity().z > -200 then
		local tr = ply.WallrunTrace
		local trout = ply.WallrunTraceOut
		tr.start = ply:EyePos() - Vector(0, 0, 15)
		tr.endpos = tr.start + eyeang:Forward() * 25
		tr.filter = ply
		tr.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
		tr.output = trout

		util.TraceLine(tr)

		if trout.HitNormal:IsEqualTol(ply:GetWallrunDir(), 0.25) then
			return
		end

		if trout.Entity and trout.Entity.IsNPC and (trout.Entity.NoWallrun or trout.Entity:IsNPC() or trout.Entity:IsPlayer()) then
			return false
		end

		if trout.Hit and timemult > 0.5 then
			tr.start = tr.start + Vector(0, 0, 10)
			tr.endpos = tr.start + eyeang:Forward() * 30

			util.TraceLine(tr)

			if trout.Hit then
				local angdir = trout.HitNormal:Angle()
				angdir.y = angdir.y - 180
				local wallnormal = trout.HitNormal
				local eyeang = Angle(angdir)
				eyeang.x = 0
				tr.start = ply:EyePos() - Vector(0, 0, 5)
				tr.endpos = tr.start + eyeang:Forward() * 40
				tr.filter = ply
				tr.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
				tr.output = trout

				util.TraceLine(tr)

				if not trout.Hit then
					return
				end

				if SERVER then
					ply:EmitSound("Bump.Concrete")
				end

				if ply:GetWallrunTime() - CurTime() > -2 then
					timemult = math.max(1 - math.max(ply:GetWallrunCount() - 1, 0) * 0.4, 0.25)
				else
					ply:SetWallrunCount(0)
				end

				ply.WallrunOrigAng = angdir

				ply:SetWallrunData(1, CurTime() + vwrtime * timemult * speedmult, wallnormal)
				ply:ViewPunch(Angle(-5, 0, 0))
				ParkourEvent("wallrunv", ply)

				if CLIENT_IFTP() then
					BodyLimitX = 30
					BodyLimitY = 70
					BodyAnimCycle = 0

					BodyAnim:SetSequence("wallrunverticalstart")

					ply.OrigEyeAng = angdir
				elseif game.SinglePlayer() then
					net.Start("BodyAnimWallrun")
					net.WriteBool(true)
					net.WriteAngle(angdir)
					net.Send(ply)
				end

				return
			end
		end
	end

	if not ply:OnGround() or mv:KeyPressed(IN_JUMP) then
		local tr = ply.WallrunTrace
		local trout = ply.WallrunTraceOut
		tr.start = ply:EyePos()
		tr.endpos = tr.start + eyeang:Right() * 25
		tr.filter = ply
		tr.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
		tr.output = trout

		util.TraceLine(tr)

		if trout.HitNormal:IsEqualTol(ply:GetWallrunDir(), 0.25) then
			return
		end

		if trout.Hit and trout.HitNormal:IsEqualTol(ply:GetEyeTrace().HitNormal, 0.1) then
			local ovel = mv:GetVelocity() * 0.85
			ovel.z = 0

			ply:SetWallrunOrigVel(ovel)
			ply:SetWallrunElevated(false)
			mv:SetVelocity(vector_origin)
			ply:SetWallrunData(2, CurTime() + hwrtime * timemult, trout.HitNormal)
			ParkourEvent("wallrunh", ply)
			ply:ViewPunch(Angle(0, 1, 0))

			if CLIENT and IsFirstTimePredicted() then
				tiltdir = -1

				hook.Add("CalcViewBA", "WallrunningTilt", WallrunningTilt)
			elseif SERVER and game.SinglePlayer() then
				net.Start("WallrunTilt")
				net.WriteBool(true)
				net.Send(ply)
			end

			return
		end
	end

	if not ply:OnGround() or mv:KeyPressed(IN_JUMP) then
		local tr = ply.WallrunTrace
		local trout = ply.WallrunTraceOut
		tr.start = ply:EyePos()
		tr.endpos = tr.start + eyeang:Right() * -25
		tr.filter = ply
		tr.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
		tr.output = trout

		util.TraceLine(tr)

		if trout.HitNormal:IsEqualTol(ply:GetWallrunDir(), 0.25) then
			return
		end

		if trout.Hit and trout.HitNormal:IsEqualTol(ply:GetEyeTrace().HitNormal, 0.1) then
			local ovel = mv:GetVelocity() * 0.85
			ovel.z = 0

			ply:SetWallrunOrigVel(ovel)
			ply:SetWallrunDir(trout.HitNormal)
			mv:SetVelocity(vector_origin)
			ply:SetWallrunElevated(false)
			ply:SetWallrunData(3, CurTime() + hwrtime * timemult, trout.HitNormal)
			ParkourEvent("wallrunh", ply)
			ply:ViewPunch(Angle(0, -1, 0))

			if CLIENT and IsFirstTimePredicted() then
				tiltdir = 1

				hook.Add("CalcViewBA", "WallrunningTilt", WallrunningTilt)
			elseif game.SinglePlayer() then
				net.Start("WallrunTilt")
				net.WriteBool(false)
				net.Send(ply)
			end

			return
		end
	end
end

function PuristWallrunningThink(ply, mv, cmd, wr, wrtimeremains)
	if wr == 4 then
		local ang = cmd:GetViewAngles()
		ang.x = 0
		local vel = ang:Forward() * 30
		vel.z = 25

		mv:SetVelocity(vel)
		mv:SetSideSpeed(0)
		mv:SetForwardSpeed(0)

		if ply:GetWallrunTime() < CurTime() or mv:GetVelocity():Length() < 10 then
			ply:SetWallrun(0)
			ply:SetQuickturn(false)
			mv:SetVelocity(vel * 4)

			local activewep = ply:GetActiveWeapon()

			if IsValid(activewep) then
				usingrh = activewep:GetClass() == "runnerhands"
			end

			if usingrh then
				activewep:SendWeaponAnim(ACT_VM_HITCENTER)
				activewep:SetBlockAnims(false)
			end

			return
		end

		if mv:KeyPressed(IN_JUMP) then
			ParkourEvent("jumpwallrun", ply)
			ply:SetSafetyRollKeyTime(CurTime() + 0.001)

			vel.z = 30

			vel:Mul(ply:GetOverdriveMult())
			mv:SetVelocity(vel * 8)
			ply:SetWallrun(0)
			ply:SetQuickturn(false)

			local activewep = ply:GetActiveWeapon()

			if IsValid(activewep) then
				usingrh = activewep:GetClass() == "runnerhands"
			end

			if usingrh then
				activewep:SendWeaponAnim(ACT_VM_HITCENTER)
				activewep:SetBlockAnims(false)
			end
		end

		return
	end

	if wr == 1 and wrtimeremains then
		local velz = math.Clamp((ply:GetWallrunTime() - CurTime()) / vwrtime, 0.1, 1)
		local vecvel = Vector()
		vecvel.z = 200 * velz

		vecvel:Add(ply:GetWallrunDir():Angle():Forward() * -50)
		vecvel:Mul(ply:GetOverdriveMult())
		mv:SetVelocity(vecvel)
		mv:SetForwardSpeed(0)
		mv:SetSideSpeed(0)

		local tr = ply.WallrunTrace
		local trout = ply.WallrunTraceOut
		local eyeang = ply.WallrunOrigAng or Angle()
		eyeang.x = 0
		tr.start = ply:EyePos() - Vector(0, 0, 5)
		tr.endpos = tr.start + eyeang:Forward() * 40
		tr.filter = ply
		tr.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
		tr.output = trout

		util.TraceLine(tr)

		if not trout.Hit then
			ply:SetWallrunTime(0)
		end

		if mv:KeyPressed(IN_JUMP) and (mv:KeyDown(IN_MOVELEFT) or mv:KeyDown(IN_MOVERIGHT)) then
			local dir = mv:KeyDown(IN_MOVERIGHT) and 1 or -1
			local vel = mv:GetVelocity()
			vel.z = 250

			mv:SetVelocity(vel + eyeang:Right() * 150 * dir)

			local event = ply:GetWallrun() == 3 and "jumpwallrunright" or "jumpwallrunleft"

			ParkourEvent(event, ply)

			if IsFirstTimePredicted() then
				ply:EmitSound("Wallrun.Concrete")
			end
		end
	end

	if wr >= 2 and wrtimeremains then
		local dir = wr == 2 and 1 or -1

		mv:SetForwardSpeed(0)
		mv:SetSideSpeed(0)

		local ovel = ply:GetWallrunOrigVel()
		local vecvel = ply:GetWallrunDir():Angle():Right() * dir * math.max(ovel:Length() + 50, 75)

		if ovel:Length() > 400 then
			ovel:Mul(0.975)
			ply:SetWallrunOrigVel(ovel)
		end

		local tr = ply.WallrunTrace
		local trout = ply.WallrunTraceOut
		local mins, maxs = ply:GetCollisionBounds()
		mins.z = -32

		if not ply:GetWallrunElevated() then
			tr.start = mv:GetOrigin()
			tr.endpos = tr.start
			tr.maxs = maxs
			tr.mins = mins
			tr.filter = ply
			tr.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
			tr.output = trout

			util.TraceHull(tr)
		end

		if not ply:GetWallrunElevated() and trout.Hit then
			vecvel.z = 100
		elseif not ply:GetWallrunElevated() and not trout.Hit then
			ply:SetWallrunElevated(true)
		end

		if ply:GetWallrunElevated() then
			vecvel.z = 0 + math.Clamp(-(CurTime() - ply:GetWallrunTime() + 1.025) * 250, -400, 25)
		end

		if vecvel:Length() > 300 then
			vecvel:Mul(ply:GetOverdriveMult())
		end

		mv:SetVelocity(vecvel)

		local eyeang = ply:EyeAngles()
		eyeang.x = 0

		if ply:GetVelocity():Length() <= 75 then
			ply:SetWallrunTime(0)
		end

		tr.start = ply:EyePos()
		tr.endpos = tr.start + eyeang:Right() * 45 * dir
		tr.maxs = wrmaxs
		tr.mins = wrmins
		tr.filter = ply
		tr.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
		tr.output = trout

		util.TraceHull(tr)

		if not trout.Hit and ply:GetWallrunTime() - CurTime() < hwrtime * 0.7 then
			tr.start = ply:EyePos()
			tr.endpos = tr.start + eyeang:Forward() * -60
			tr.filter = ply
			tr.output = trout

			util.TraceLine(tr)

			if not trout.Hit then
				ply:SetWallrunTime(0)
			else
				if not ply:GetWallrunDir():IsEqualTol(trout.HitNormal, 0.75) then
					ply:SetWallrunTime(0)
				end

				ply:SetWallrunDir(trout.HitNormal)
			end
		elseif ply:GetWallrunTime() - CurTime() < hwrtime * 0.7 then
			tr.start = ply:EyePos()
			tr.endpos = tr.start + eyeang:Right() * 45 * dir
			tr.filter = ply
			tr.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
			tr.output = trout

			util.TraceLine(tr)

			if trout.Hit and ply:GetWallrunDir():IsEqualTol(trout.HitNormal, 0.75) then
				ply:SetWallrunDir(trout.HitNormal)
			end
		end

		if mv:KeyPressed(IN_JUMP) and ply:GetWallrunTime() - CurTime() ~= hwrtime then
			ply:SetQuickturn(false)
			ply:SetWallrunTime(0)
			ply:SetSafetyRollKeyTime(CurTime() + 0.001)
			mv:SetVelocity(eyeang:Forward() * math.max(150, vecvel:Length() - 25) + Vector(0, 0, 250))

			local event = ply:GetWallrun() == 3 and "jumpwallrunright" or "jumpwallrunleft"

			ParkourEvent(event, ply)

			if IsFirstTimePredicted() then
				ply:EmitSound("Wallrun.Concrete")
			end
		end
	end

	if ply:GetWallrunSoundTime() < CurTime() then
		local delay = nil
		local wr = ply:GetWallrun()

		if wr == 1 then
			delay = math.Clamp(math.abs(ply:GetWallrunTime() - CurTime() - 2.75) / vwrtime * 0.165, 0.175, 0.3)
		else
			delay = math.Clamp(math.abs(ply:GetWallrunTime() - CurTime()) / hwrtime * 0.165, 0.15, 1.75)
		end

		if SERVER then
			ply:EmitSound("Wallrun.Concrete")
			timer.Simple(0.025, function ()
				ply:EmitSound("WallrunRelease.Concrete")
			end)
		end

		ply:SetWallrunSoundTime(CurTime() + delay)
		ply:ViewPunch(Angle(0.25, 0, 0))
	end

	if ply:GetWallrunTime() < CurTime() or mv:GetVelocity():Length() < 10 then
		if ply.vwrturn == 0 then
			ply:SetQuickturn(false)
		end

		if CLIENT and IsFirstTimePredicted() and wr == 1 then
			BodyLimitX = 90
			BodyLimitY = 180
			BodyAnimCycle = 0

			BodyAnim:SetSequence("jumpair")
		elseif game.SinglePlayer() and wr == 1 then
			net.Start("BodyAnimWallrun")
			net.WriteBool(false)
			net.Send(ply)
		end

		ply:SetWallrun(0)

		return
	end
end
