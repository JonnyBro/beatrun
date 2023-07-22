local ClimbingTimes = {5, 1.25, 1, 1, nil, 2}

--[[
local CLIMB_HANG = 1
local CLIMB_HEAVEUP = 2
local CLIMB_STRAFELEFT = 3
local CLIMB_STRAFERIGHT = 4
local CLIMB_FOLDEDSTART = 5
local CLIMB_FOLDEDHEAVEUP = 6


local climb1 = {
	followplayer = false,
	animmodelstring = "climbanim",
	allowmove = true,
	lockang = false,
	ignorez = true,
	smoothend = true,
	AnimString = "climb1"
}

local climbstrings = {"climb1", "climb2"}
]]

if game.SinglePlayer() and SERVER then
	util.AddNetworkString("Climb_SPFix")
elseif game.SinglePlayer() and CLIENT then
	net.Receive("Climb_SPFix", function()
		local lock = net.ReadBool()
		local neweyeang = net.ReadBool()
		local ang = net.ReadAngle()
		local oldlock = net.ReadBool()
		lockang = lock

		if oldlock ~= nil then
			lockang = oldlock
		end

		if neweyeang then
			LocalPlayer().OrigEyeAng = ang
		end
	end)
end

local function ClimbingEnd(ply, mv, cmd)
	mv:SetOrigin(ply:GetClimbingEnd())
	ply:SetClimbing(0)
	ply:SetMoveType(MOVETYPE_WALK)

	local tr = {
		filter = ply
	}

	tr.mins, tr.maxs = ply:GetHull()
	tr.start = mv:GetOrigin()
	tr.endpos = tr.start
	tr.mask = MASK_PLAYERSOLID
	tr.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT

	local trout = util.TraceHull(tr)

	if trout.Hit then
		local trout = {}
		tr.output = trout
		local start = tr.start

		for i = 1, 64 do
			start.z = start.z + 1

			util.TraceHull(tr)

			if not trout.Hit then
				mv:SetOrigin(start)

				break
			end
		end
	end

	local activewep = ply:GetActiveWeapon()

	if IsValid(activewep) then
		activewep:SendWeaponAnim(ACT_VM_DRAW)
	end

	lockang2 = false
	lockang = false

	if game.SinglePlayer() then
		net.Start("Climb_SPFix")
			net.WriteBool(false)
			net.WriteBool(false)
			net.WriteAngle(angle_zero)
			net.WriteBool(false)
		net.Send(ply)
	end
end

local function ClimbingThink(ply, mv, cmd)
	if ply:GetClimbing() == 5 then
		if mv:KeyPressed(IN_FORWARD) and ply:GetClimbingDelay() < CurTime() + 0.65 or mv:KeyDown(IN_FORWARD) and ply:GetClimbingDelay() < CurTime() then
			ParkourEvent("hangfoldedheaveup", ply)

			ply:SetClimbing(6)
			ply:SetClimbingTime(0)
		elseif ply:GetClimbingDelay() < CurTime() then
			ParkourEvent("hangfoldedendhang", ply)

			ply:SetClimbing(1)
			ply:SetClimbingDelay(CurTime() + 1.35)
		end

		mv:SetForwardSpeed(0)
		mv:SetSideSpeed(0)
		mv:SetUpSpeed(0)
		mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_DUCK)))
		mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))

		return
	end

	if (ply:GetClimbing() == 2 or ply:GetClimbing() == 6) and ply:GetClimbingTime() >= 1 then
		mv:SetButtons(0)
		mv:SetForwardSpeed(0)
		mv:SetSideSpeed(0)
		mv:SetUpSpeed(0)

		ClimbingEnd(ply, mv, cmd)

		return
	end

	mv:SetVelocity(vector_origin)

	if ply:GetClimbing() == 1 and ply:GetClimbingDelay() < CurTime() then
		if ply.ClimbLockAng < CurTime() then
			lockang2 = false
			lockang = false

			if game.SinglePlayer() then
				net.Start("Climb_SPFix")
					net.WriteBool(false)
					net.WriteBool(false)
					net.WriteAngle(angle_zero)
					net.WriteBool(false)
				net.Send(ply)
			end
		end

		if mv:KeyDown(IN_DUCK) then
			mv:SetOrigin(ply:GetClimbingStart() - ply:GetClimbingAngle():Forward() * 5)

			ply:SetMoveType(MOVETYPE_WALK)

			mv:SetButtons(0)

			ply:SetClimbing(0)
			ply:SetCrouchJumpBlocked(true)

			ParkourEvent("hangend", ply)

			if CLIENT_IFTP() then
				lockang2 = false
				lockang = false
				BodyLimitX = 90
				BodyLimitY = 180
			elseif game.SinglePlayer() then
				ply:SendLua("lockang2=false lockang=false BodyLimitX=90 BodyLimitY=180")
			end

			return
		end

		local ang = cmd:GetViewAngles()
		ang = math.abs(math.AngleDifference(ang.y, ply.wallang.y))

		if mv:KeyDown(IN_JUMP) and ang > 42 then
			mv:SetOrigin(ply:GetClimbingStart() - ply:GetClimbingAngle():Forward() * 0.6)
			ply:SetMoveType(MOVETYPE_WALK)
			mv:SetButtons(0)
			ply:SetClimbing(0)
			ply:SetSafetyRollKeyTime(CurTime() + 0.1)
			ParkourEvent("hangjump", ply)

			if CLIENT_IFTP() then
				lockang2 = false
				lockang = false
				BodyLimitX = 90
				BodyLimitY = 180

				local ang = ply:EyeAngles()
				ang.x = 0
				ang.z = 0
				BodyAnim:SetAngles(ang)
			elseif game.SinglePlayer() then
				ply:SendLua("lockang2=false lockang=false BodyLimitX=90 BodyLimitY=180 local ang=LocalPlayer():EyeAngles() ang.x=0 ang.z=0 BodyAnim:SetAngles(ang)")
			end

			local ang = cmd:GetViewAngles()
			ang.x = math.min(ang.x, 0)
			ang = ang:Forward()
			ang:Mul(350)
			ang.z = 250

			mv:SetVelocity(ang)

			return
		end

		if mv:KeyPressed(IN_FORWARD) and ang <= 42 then
			local tr = ply.ClimbingTraceSafety
			local trout = ply.ClimbingTraceSafetyOut
			local mins, maxs = ply:GetHull()
			mins.z = maxs.z * 0.25

			tr.start = ply:GetClimbingEnd()
			tr.endpos = tr.start
			tr.maxs = maxs
			tr.mins = mins
			tr.filter = ply
			tr.output = trout

			util.TraceHull(tr)

			if not trout.Hit then
				tr.start = ply:GetClimbingEnd()
				tr.endpos = tr.start - ply:GetClimbingAngle():Forward() * 20

				util.TraceHull(tr)

				if not trout.Hit then
					ply:SetClimbing(2)
					ParkourEvent("climbheave", ply)
				end
			end
		end

		if ply:GetClimbing() == 1 and (mv:KeyDown(IN_MOVELEFT) or mv:KeyDown(IN_MOVERIGHT)) and ply:GetClimbingDelay() < CurTime() then
			local wallang = ply:GetClimbingAngle()
			local dir = wallang:Right()
			local isright = mv:KeyDown(IN_MOVERIGHT)
			local mult = isright and 30 or -30

			dir:Mul(mult)

			local tr = ply.ClimbingTraceEnd
			local trout = ply.ClimbingTraceEndOut
			-- local oldstart = tr.start
			-- local oldend = tr.endpos
			local start = mv:GetOrigin() + wallang:Forward() * 20 + Vector(0, 0, 100) + dir

			tr.start = start
			tr.endpos = start - Vector(0, 0, 80)

			util.TraceLine(tr)

			if trout.Entity and trout.Entity.IsNPC and (trout.Entity:IsNPC() or trout.Entity:IsPlayer()) then return false end

			local fail = trout.Fraction < 0.25 or trout.Fraction > 0.5

			if not fail then
				local ostart = tr.start
				local oendpos = tr.endpos

				tr.start = ply:GetClimbingEnd() + dir
				tr.endpos = tr.start - Vector(0, 0, 100)

				util.TraceLine(tr)

				dir.z = trout.HitPos.z - mv:GetOrigin().z - 77

				tr.endpos = oendpos
				tr.start = ostart
				tr = ply.ClimbingTraceSafety

				trout = ply.ClimbingTraceSafetyOut

				tr.start = mv:GetOrigin() + dir - wallang:Forward() * 0.533
				tr.endpos = tr.start

				util.TraceHull(tr)

				if not trout.Hit then
					ply:SetClimbingEndOld(ply:GetClimbingEnd())
					ply:SetClimbing(isright and 4 or 3)
					ply:SetClimbingStart(mv:GetOrigin())
					ply:SetClimbingEnd(mv:GetOrigin() + dir)
					ply:SetClimbingTime(0)

					tr.start = mv:GetOrigin() + ply:GetClimbingAngle():Forward() * 20 + Vector(0, 0, 100) + dir
					tr.endpos = tr.start - Vector(0, 0, 80)

					if isright then
						ParkourEvent("hangstraferight", ply)
					else
						ParkourEvent("hangstrafeleft", ply)
					end

					ply:SetClimbingDelay(CurTime() + 0.9)
				end
			end
		end
	end

	if ply:GetClimbing() == 3 or ply:GetClimbing() == 4 then
		local isright = mv:KeyDown(IN_MOVERIGHT)
		local dir = ply:GetClimbingAngle():Right()
		local mult = isright and 30 or -30

		dir:Mul(mult)

		local tr = ply.ClimbingTraceEnd
		local trout = ply.ClimbingTraceEndOut

		util.TraceLine(tr)

		if trout.Entity and trout.Entity.IsNPC and (trout.Entity:IsNPC() or trout.Entity:IsPlayer()) then return false end

		local fail = trout.Fraction < 0.25 or trout.Fraction == 1

		if not fail then
			local lerp = ply:GetClimbingTime()
			local lerprate = ClimbingTimes[ply:GetClimbing()]
			local poslerp = LerpVector(lerp, ply:GetClimbingStart(), ply:GetClimbingEnd())

			ply:SetClimbingEndOld(trout.HitPos)

			mv:SetOrigin(poslerp)

			ply:SetClimbingTime(ply:GetClimbingTime() + FrameTime() * lerprate)
		end

		if fail or ply:GetClimbingTime() >= 1 then
			ply:SetClimbing(1)
			ply:SetClimbingStart(mv:GetOrigin())
			ply:SetClimbingEnd(ply:GetClimbingEndOld())
			ply:SetClimbingTime(0)
		end
	end

	if ply:GetClimbing() == 2 or ply:GetClimbing() == 6 then
		if game.SinglePlayer() then
			net.Start("Climb_SPFix")
				net.WriteBool(false)
				net.WriteBool(false)
				net.WriteAngle(angle_zero)
				net.WriteBool(false)
			net.Send(ply)
		end

		local lerp = ply:GetClimbingTime()
		local lerprate = ClimbingTimes[ply:GetClimbing()]

		if lerp > 0.5 then
			lerprate = lerprate * 0.75
		end

		local poslerp = LerpVector(lerp, ply:GetClimbingStart(), ply:GetClimbingEnd())

		mv:SetOrigin(poslerp)

		ply:SetClimbingTime(lerp + FrameTime() * lerprate)
	end

	mv:SetForwardSpeed(0)
	mv:SetSideSpeed(0)
	mv:SetUpSpeed(0)
	mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_DUCK)))
	mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
end

local function ClimbingRemoveInput(ply, cmd)
end

hook.Add("StartCommand", "ClimbingRemoveInput", ClimbingRemoveInput)

local function ClimbingCheck(ply, mv, cmd)
	local mins, maxs = ply:GetHull()

	if not ply.ClimbingTrace then
		ply.ClimbingTrace = {}
		ply.ClimbingTraceOut = {}
		ply.ClimbingTraceEnd = {}
		ply.ClimbingTraceEndOut = {}
		ply.ClimbingTraceSafety = {}
		ply.ClimbingTraceSafetyOut = {}
		ply.ClimbingTraceSafety.output = ply.ClimbingTraceSafetyOut

		TraceParkourMask(ply.ClimbingTrace)
		TraceParkourMask(ply.ClimbingTraceEnd)
		TraceParkourMask(ply.ClimbingTraceSafety)
	end

	local eyeang = ply:EyeAngles()
	local oldpos = mv:GetOrigin()

	eyeang.x = 0

	local tr = ply.ClimbingTrace
	local trout = ply.ClimbingTraceOut

	mins.z = 45

	tr.start = mv:GetOrigin()

	if ply:GetDive() then
		tr.start:Sub(Vector(0, 0, 48))
	end

	tr.endpos = tr.start + eyeang:Forward() * 50
	tr.maxs = maxs
	tr.mins = mins
	tr.filter = ply
	tr.output = trout

	util.TraceHull(tr)

	mins.z = 0

	if not trout.Hit then return end

	local wallang = trout.HitNormal:Angle()
	wallang.y = wallang.y - 180

	if wallang.x ~= 0 then return end
	if math.abs(math.AngleDifference(wallang.y, eyeang.y)) > 50 then return end
	if IsValid(trout.Entity) and trout.Entity.NoClimbing then return end

	ply:SetClimbingAngle(wallang)

	local tr = ply.ClimbingTraceEnd
	local trout = ply.ClimbingTraceEndOut
	local upvalue = ply:GetWallrun() == 1 and Vector(0, 0, 90) or Vector(0, 0, 65)
	local plymins, plymaxs = ply:GetHull()

	tr.start = mv:GetOrigin() + wallang:Forward() * 45 + upvalue
	tr.endpos = tr.start - Vector(0, 0, 90)
	tr.maxs = plymaxs
	tr.mins = plymins
	tr.filter = ply
	tr.output = trout

	util.TraceLine(tr)

	if trout.Entity and trout.Entity.IsNPC and (trout.Entity:IsNPC() or trout.Entity:IsPlayer()) then return false end

	-- local fraction = trout.Fraction
	local detectionlen = 60

	if trout.Fraction <= 0 or trout.Fraction >= 0.5 then
		tr.start = mv:GetOrigin() + wallang:Forward() * 20 + upvalue
		tr.endpos = tr.start - Vector(0, 0, 90)

		util.TraceLine(tr)

		if trout.Fraction <= 0 or trout.Fraction >= 0.5 then return end

		detectionlen = 25
	end

	local endpos = trout.HitPos
	-- local height = trout.Fraction
	local startpos = ply.ClimbingTraceOut.HitPos
	startpos.z = trout.HitPos.z - 77
	startpos:Add(wallang:Forward() * 0.533)

	if ply:GetDive() then
		local origin = mv:GetOrigin()
		startpos.z = trout.HitPos.z - 30

		mv:SetOrigin(startpos)

		if Vault5(ply, mv, eyeang, ply.mantletr, ply.mantlehull) then
			if CLIENT then
				BodyAnimSetEase(origin)
			elseif game.SinglePlayer() then
				ply:SetNW2Vector("SPBAEase", origin)
				ply:SendLua("BodyAnimSetEase(LocalPlayer():GetNW2Vector('SPBAEase'))")
			end

			startpos.z = trout.HitPos.z - 60

			ply:SetViewOffsetDucked(Vector(0, 0, 64))
			ply:SetMantleStartPos(startpos)

			return
		else
			mv:SetOrigin(origin)
		end

		return
	end

	local tr = ply.ClimbingTraceSafety
	local trout = ply.ClimbingTraceSafetyOut

	tr.filter = ply
	tr.start = endpos
	tr.endpos = tr.start - wallang:Forward() * detectionlen

	util.TraceLine(tr)

	if trout.Hit then return end

	tr.start = startpos + Vector(0, 0, 77)
	tr.endpos = tr.start + wallang:Forward() * detectionlen * 0.5

	util.TraceLine(tr)

	if trout.Hit then return end

	-- local steep = trout.HitNormal:Distance(Vector(0, 0, 1)) > 0.01
	local tr = ply.ClimbingTraceSafety
	local trout = ply.ClimbingTraceSafetyOut

	tr.start = mv:GetOrigin()
	tr.endpos = tr.start + Vector(0, 0, 75)

	util.TraceLine(tr)

	if trout.Hit then return end

	local origin = mv:GetOrigin()
	local tr = ply.ClimbingTraceSafety
	local trout = ply.ClimbingTraceSafetyOut

	tr.start = startpos
	tr.endpos = startpos

	util.TraceLine(tr)

	if trout.Hit then return end

	startpos.z = startpos.z
	ply.ClimbingStartPosCache = startpos
	ply.ClimbingStartSmooth = origin

	mv:SetOrigin(startpos)

	local resetstartpos = false

	if mv:KeyDown(IN_FORWARD) then
		resetstartpos = true

		if ply:GetWallrun() ~= 1 then
			startpos.z = startpos.z + 17
			mv:SetOrigin(startpos)
		end

		if Vault4(ply, mv, eyeang, ply.mantletr, ply.mantlehull) then
			if CLIENT then
				BodyAnimSetEase(origin)
			elseif game.SinglePlayer() then
				ply:SetNW2Vector("SPBAEase", origin)
				ply:SendLua("BodyAnimSetEase(LocalPlayer():GetNW2Vector('SPBAEase'))")
			end

			return
		else
			if ply:GetWallrun() == 1 then
				startpos.z = startpos.z + 17
			end

			mv:SetOrigin(startpos)

			if Vault5(ply, mv, eyeang, ply.mantletr, ply.mantlehull) then
				if CLIENT then
					BodyAnimSetEase(origin)
				elseif game.SinglePlayer() then
					ply:SetNW2Vector("SPBAEase", origin)
					ply:SendLua("BodyAnimSetEase(LocalPlayer():GetNW2Vector('SPBAEase'))")
				end

				return
			end
		end
	end

	if resetstartpos then
		startpos.z = startpos.z - 17
		ply.ClimbingStartPosCache = startpos

		mv:SetOrigin(startpos)
	end

	tr.start = startpos - wallang:Forward() * 0.533
	tr.endpos = tr.start

	util.TraceHull(tr)

	if trout.Hit then
		mv:SetOrigin(oldpos)

		return
	end

	if CLIENT then
		BodyAnimSetEase(origin)
	elseif game.SinglePlayer() then
		ply:SetNW2Vector("SPBAEase", origin)
		ply:SendLua("BodyAnimSetEase(LocalPlayer():GetNW2Vector('SPBAEase'))")
	end

	local wr = ply:GetWallrun()
	-- local wrtime = ply:GetWallrunTime() - CurTime()
	-- local vel = mv:GetVelocity()

	if wr ~= 0 then
		ply:SetWallrun(0)
		ply:EmitSound("Wallrun.Concrete")
	end

	local climbvalue = 1

	ply:SetClimbing(climbvalue)
	ply:SetClimbingStart(startpos)
	ply:SetClimbingEnd(endpos)
	ply:SetClimbingTime(0)
	ply:SetClimbingDelay(CurTime() + 0.75)

	ply.ClimbLockAng = CurTime() + 1.45

	ply:SetCrouchJumpBlocked(false)
	ply:SetQuickturn(false)

	local activewep = ply:GetActiveWeapon()

	if IsValid(activewep) then
		usingrh = activewep:GetClass() == "runnerhands"
	end

	if usingrh and activewep.SendWeaponAnim then
		activewep:SendWeaponAnim(ACT_VM_HITCENTER)
		activewep:SetBlockAnims(false)
	end

	local folded = mv:GetVelocity().z < -400

	if folded then
		local tr = ply.ClimbingTraceSafety
		local trout = ply.ClimbingTraceSafetyOut
		local mins, maxs = ply:GetCollisionBounds()
		mins.z = maxs.z * 0.25

		tr.start = ply:GetClimbingEnd()
		tr.endpos = tr.start
		tr.maxs = maxs
		tr.mins = mins
		tr.filter = ply
		tr.output = trout

		util.TraceHull(tr)

		folded = not trout.Hit
	end

	local lastvel = mv:GetVelocity()

	mv:SetVelocity(vector_origin)
	ply:SetMoveType(MOVETYPE_NOCLIP)
	ply:ViewPunch(Angle(5, 0, 0.5))

	local wallangc = Angle(wallang)

	if folded then
		ply:SetClimbing(5)
		ply:SetClimbingDelay(CurTime() + 0.8)

		ParkourEvent("hangfoldedstart", ply)
	else
		local event = "climbhard"

		if wr == 1 then
			event = "climb"
			wallangc.x = -30
		elseif lastvel.z < -200 then
			event = "climbhard2"
		end

		ParkourEvent(event, ply)
	end

	ply.wallang = wallang

	if IsFirstTimePredicted() then
		if CLIENT or game.SinglePlayer() then
			timer.Simple(0.05, function()
				ply:EmitSound("Bump.Concrete")
			end)
		end

		ply:EmitSound("Handsteps.ConcreteHard")
		ply:EmitSound("Cloth.RollLand")

		if CLIENT_IFTP() then
			ply.OrigEyeAng = wallang
			lockang2 = true

			if folded then
				DoImpactBlur(8)
				lockang2 = false
				lockang = true
			end
		end

		if game.SinglePlayer() then
			net.Start("Climb_SPFix")
				net.WriteBool(false)
				net.WriteBool(true)
				net.WriteAngle(wallang)

			if folded then
				ply:SendLua("DoImpactBlur(8)")
				net.WriteBool(true)
			end

			net.Send(ply)
		end
	end

	if CLIENT and IsFirstTimePredicted() then
		timer.Simple(0, function()
			BodyLimitX = 80
			BodyLimitY = 170
		end)
	elseif game.SinglePlayer() then
		timer.Simple(0, function()
			ply:SendLua("BodyLimitX=80 BodyLimitY=170")
		end)
	end

	if CLIENT or game.SinglePlayer() then
		ply:ConCommand("-jump")
	end

	mv:SetButtons(0)
	mv:SetForwardSpeed(0)
	mv:SetSideSpeed(0)
	mv:SetUpSpeed(0)
end


hook.Add("SetupMove", "Climbing", function(ply, mv, cmd)
	if ply:GetClimbing() == nil or not ply:Alive() then
		ply:SetClimbing(0)
	end

	if IsValid(ply:GetSwingbar()) then return end

	if (not ply:GetCrouchJump() or ply:GetDive()) and not ply:GetJumpTurn() and (mv:KeyDown(IN_FORWARD) or mv:GetVelocity().z < -50 or ply:GetWallrun() == 1) and ply:GetClimbing() == 0 and ply:GetWallrun() ~= 4 and not ply:OnGround() and ply:GetMoveType() ~= MOVETYPE_NOCLIP and ply:GetMoveType() ~= MOVETYPE_LADDER then
		ClimbingCheck(ply, mv, cmd)
	end

	if ply:GetClimbing() ~= 0 then
		ClimbingThink(ply, mv, cmd)
	end
end)