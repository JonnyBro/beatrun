local vwrtime = 1.5
local hwrtime = 1.5
tiltdir = 1
local tilt = 0

local PuristWallrun = CreateConVar("Beatrun_PuristWallrun", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "\"Realistic\" wallrunning", 0, 1)

function WallrunningTilt(ply, pos, ang, fov)
	local wr = ply:GetWallrun()

	if wr < 2 and tilt == 0 then
		hook.Remove("CalcViewBA", "WallrunningTilt")

		return
	end

	ang.z = ang.z + tilt

	local tiltspeed = wr >= 2 and math.max(math.abs(tilt / 15 * tiltdir - 1) * 1.75, 0.1) or 1

	tilt = math.Approach(tilt, wr >= 2 and 15 * tiltdir or 0, RealFrameTime() * (wr >= 2 and 30 or 70) * tiltspeed)
end

if SERVER then
	util.AddNetworkString("BodyAnimWallrun")
	util.AddNetworkString("WallrunTilt")
end

if CLIENT and game.SinglePlayer() then
	net.Receive("BodyAnimWallrun", function()
		local a = net.ReadBool()

		if a then
			local ply = LocalPlayer()
			local eyeang = ply:EyeAngles()

			eyeang.x = 0

			ply.WallrunOrigAng = net.ReadAngle()

			BodyLimitX = 25
			BodyLimitY = 70
			BodyAnimCycle = 0
			BodyAnim:SetSequence("wallrunverticalstart")
		else
			BodyLimitX = 90
			BodyLimitY = 180
			BodyAnimCycle = 0
			BodyAnim:SetSequence("jumpair")
		end
	end)

	net.Receive("WallrunTilt", function()
		if net.ReadBool() then
			tiltdir = -1
		else
			tiltdir = 1
		end

		hook.Add("CalcViewBA", "WallrunningTilt", WallrunningTilt)
	end)
end

local wrmins = Vector(-16, -16, 0)
local wrmaxs = Vector(16, 16, 16)

local function WallrunningThink(ply, mv, cmd)
	local wr = ply:GetWallrun()

	if wr ~= 0 and ply:OnGround() then
		ply:SetWallrunTime(0)
	end

	if mv:KeyPressed(IN_DUCK) then
		ply:SetCrouchJumpBlocked(true)
		ply:SetWallrunTime(0)

		mv:SetButtons(mv:GetButtons() - IN_DUCK)
	end

	local wrtimeremains = CurTime() < ply:GetWallrunTime()

	if PuristWallrun:GetBool() then
		PuristWallrunningThink(ply, mv, cmd, wr, wrtimeremains)

		return
	end

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

			if ply:UsingRH() then
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

			if ply:UsingRH() then
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
			vecvel.z = 5 + math.Clamp(-(CurTime() - ply:GetWallrunTime() + 0.8) * 250, -400, 25)
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

			mv:SetVelocity(eyeang:Forward() * math.max(150, vecvel:Length() - 50) + Vector(0, 0, 250))

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
			delay = math.Clamp(math.abs(ply:GetWallrunTime() - CurTime() - 2.75) / hwrtime * 0.165, 0.15, 1.75)
		end

		if SERVER then
			ply:EmitSound("Wallrun.Concrete")

			timer.Simple(0.025, function()
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

-- local upcheck = Vector(0, 0, 75)

local realistic = GetConVar("Beatrun_LeRealisticClimbing")

local function WallrunningCheck(ply, mv, cmd)
	if realistic:GetBool() and not ply:UsingRH() then return end

	if not ply.WallrunTrace then
		ply.WallrunTrace = {}
		ply.WallrunTraceOut = {}
	end

	local eyeang = ply:EyeAngles()
	eyeang.x = 0

	local vel = mv:GetVelocity()
	vel.z = 0

	local timemult = math.max(1 - math.max(ply:GetWallrunCount() - 1, 0) * 0.2, 0.5)
	local speedmult = math.max(0.9, math.min(vel:Length(), 260) / 250)

	if ply:GetGrappling() then return end
	if ply:GetJumpTurn() then return end

	if PuristWallrun:GetBool() then
		PuristWallrunningCheck(ply, mv, cmd, vel, eyeang, timemult, speedmult)

		return
	end

	if not ply:OnGround() and mv:KeyDown(IN_JUMP) and mv:GetVelocity().z > -200 then
		local tr = ply.WallrunTrace
		local trout = ply.WallrunTraceOut

		tr.start = ply:EyePos() - Vector(0, 0, 15)
		tr.endpos = tr.start + eyeang:Forward() * 25
		tr.filter = ply
		tr.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
		tr.output = trout

		util.TraceLine(tr)

		if trout.HitNormal:IsEqualTol(ply:GetWallrunDir(), 0.25) then return end
		if trout.Entity and trout.Entity.IsNPC and (trout.Entity.NoWallrun or trout.Entity:IsNPC() or trout.Entity:IsPlayer()) then return false end

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

				if not trout.Hit then return end

				if SERVER then
					ply:EmitSound("Bump.Concrete")
				end

				ply.WallrunOrigAng = angdir
				ply:SetWallrunData(1, CurTime() + vwrtime * timemult * speedmult, wallnormal)
				ply:ViewPunch(Angle(-5, 0, 0))

				ParkourEvent("wallrunv", ply)

				if CLIENT and IsFirstTimePredicted() then
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

		if trout.HitNormal:IsEqualTol(ply:GetWallrunDir(), 0.25) then return end

		if trout.Hit and trout.HitNormal:IsEqualTol(ply:GetEyeTrace().HitNormal, 0.1) then
			local ovel = mv:GetVelocity()
			ovel.z = 0

			ply:SetWallrunOrigVel(ovel)
			ply:SetWallrunElevated(false)

			mv:SetVelocity(vector_origin)

			ply:SetWallrunData(2, CurTime() + hwrtime * timemult, trout.HitNormal)

			ParkourEvent("wallrunh", ply)

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

		if trout.HitNormal:IsEqualTol(ply:GetWallrunDir(), 0.25) then return end

		if trout.Hit and trout.HitNormal:IsEqualTol(ply:GetEyeTrace().HitNormal, 0.1) then
			local ovel = mv:GetVelocity()
			ovel.z = 0

			ply:SetWallrunOrigVel(ovel)
			ply:SetWallrunDir(trout.HitNormal)

			mv:SetVelocity(vector_origin)

			ply:SetWallrunElevated(false)
			ply:SetWallrunData(3, CurTime() + hwrtime * timemult, trout.HitNormal)

			ParkourEvent("wallrunh", ply)

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

local vecdir = Vector(1000, 1000, 1000)

hook.Add("SetupMove", "Wallrunning", function(ply, mv, cmd)
	if ply:GetWallrun() == nil or not ply:Alive() then
		ply:SetWallrun(0)
	end

	if ply:GetWallrun() == 0 and mv:GetVelocity().z > -450 and not ply:OnGround() and mv:KeyDown(IN_FORWARD) and not ply:Crouching() and not mv:KeyDown(IN_DUCK) and ply:GetMoveType() ~= MOVETYPE_NOCLIP and ply:WaterLevel() < 1 then
		WallrunningCheck(ply, mv, cmd)
	end

	if ply:GetWallrun() ~= 0 then
		WallrunningThink(ply, mv, cmd)
	end

	if ply:GetWallrun() == 0 and (ply:OnGround() or ply:GetGrappling() or ply:GetClimbing() ~= 0) then
		ply:SetWallrunDir(vecdir)
		ply:SetWallrunCount(0)
	end
end)