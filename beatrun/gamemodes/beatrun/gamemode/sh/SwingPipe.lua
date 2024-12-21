local function SwingpipeCheck(ply, mv, cmd)
	local mins, maxs = ply:GetCollisionBounds()
	maxs.x = maxs.x * 2
	mins.x = mins.x * 2
	maxs.y = maxs.y * 2
	mins.y = mins.y * 2

	local tr = ply.Monkey_tr
	local trout = ply.Monkey_trout

	tr.start = mv:GetOrigin()
	tr.endpos = tr.start
	tr.maxs = maxs
	tr.mins = mins
	tr.filter = ply
	tr.ignoreworld = true

	util.TraceHull(tr)

	tr.ignoreworld = false

	if IsValid(trout.Entity) and trout.Entity:GetClass() == "br_swingpipe" and (ply:GetSwingbarLast() ~= trout.Entity or ply:GetSBDelay() < CurTime()) then
		local swingpipe = trout.Entity
		-- local dot = cmd:GetViewAngles():Forward():Dot(swingpipe:GetAngles():Forward())

		if CLIENT then
			swingpipe:SetPredictable(true)
		end

		local pos = swingpipe:GetPos()
		pos.z = mv:GetOrigin().z

		local entvector = pos - ply:GetShootPos()
		entvector.z = pos.z

		local entdot = entvector:Dot(mv:GetAngles():Right())
		local dir = entdot < 0
		local trwall = util.QuickTrace(mv:GetOrigin(), mv:GetAngles():Right() * 100 * (dir and -1 or 1), ply)

		if trwall.Hit then
			ply.swingbarang = (trwall.HitNormal:Angle():Right():Angle() + Angle(0, 90 * (dir and -1 or 1))).y
		else
			ply.swingbarang = (ply:EyeAngles() + Angle(0, 90)).y
		end

		ply.SwingHullCheck = false
		ply:SetSwingpipe(swingpipe)
		ply:SetWallrunTime(0)
		ply:SetSBDir(dir)
		ply:SetSBStartLerp(0)
		ply:SetSBOffset(0)
		ply:SetSBPeak(0)
		ply:SetClimbingStart(pos)

		if mv:KeyDown(IN_FORWARD) or mv:GetVelocity():Length() > 150 then
			ply:SetSBOffsetSpeed(2)
		else
			ply:SetSBOffsetSpeed(0)
		end
	end
end

-- local red = Color(255, 0, 0, 200)
local radius = 40
local circlepos = Vector()
local axis = Vector(0, 1, 0)

local function SwingpipeThink(ply, mv, cmd)
	local swingpipe = ply:GetSwingpipe()

	if not ply:Alive() then
		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetSwingbar(nil)
		ply:SetSBDelay(CurTime() + 1)

		if CLIENT then
			swingpipe:SetPredictable(false)
		end

		return
	end

	mv:SetForwardSpeed(0)
	mv:SetSideSpeed(0)

	local pos = ply:GetClimbingStart()
	local dir = ply:GetSBDir() and 1 or -1
	local ang = Angle()
	local startlerp = ply:GetSBStartLerp()

	ang:RotateAroundAxis(axis, 90)

	local angle = math.NormalizeAngle(ply:GetSBOffset() - ply.swingbarang) * math.pi * 2 / 360
	circlepos:SetUnpacked(0, math.cos(angle) * radius * -1, -math.sin(angle) * radius)
	circlepos:Rotate(ang)

	if not ply.SwingHullCheck then
		local angleend = math.NormalizeAngle(60 * -dir - ply.swingbarang) * math.pi * 2 / 360
		local spendpos = Vector(0, math.cos(angleend) * radius * -1, -math.sin(angleend) * radius)

		spendpos:Rotate(ang)
		spendpos:Add(pos)

		if ply:GetSBDir() then
			spendpos:Add(mv:GetAngles():Right() * 17)
		else
			spendpos:Sub(mv:GetAngles():Right() * 17)
		end

		local minhull, maxhull = ply:GetHull()

		if util.TraceHull({
			start = spendpos,
			endpos = spendpos,
			filter = {ply:GetSwingpipe(), ply},
			mins = minhull,
			maxs = maxhull
		}).Hit then
			ply:SetMoveType(MOVETYPE_WALK)
			ply:SetSwingbarLast(ply:GetSwingpipe())
			ply:SetSwingpipe(nil)
			ply:SetSBDelay(CurTime() + 0.05)

			return
		end

		if CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
			ply:EmitSound("Handsteps.ConcreteHard")
		end

		ply:ViewPunch(Angle(1, 0, 0))
		ply:SetCrouchJump(false)
		ply:SetDive(false)

		if ply:GetSBDir() then
			ParkourEvent("swingpipeleft", ply)
		else
			ParkourEvent("swingpiperight", ply)
		end

		ply.SwingHullCheck = true
	end

	pos = pos + circlepos
	local origin = startlerp < 1 and LerpVector(startlerp, mv:GetOrigin(), pos) or pos

	ply:SetSBStartLerp(math.min(startlerp + 5 * FrameTime(), 1))

	if ply:GetSBDir() then
		ply:SetSBOffset(math.max(ply:GetSBOffset() - 250 * FrameTime() * math.min(startlerp + 0.5 - math.min(math.max(math.abs(ply:GetSBOffset()) - 65, 0) / 30, 0.6), 1.15), -90))

		origin:Add(mv:GetAngles():Right() * 17 * startlerp)
	else
		ply:SetSBOffset(math.min(ply:GetSBOffset() + 250 * FrameTime() * math.min(startlerp + 0.5 - math.min(math.max(math.abs(ply:GetSBOffset()) - 65, 0) / 30, 0.6), 1.15), 90))

		origin:Sub(mv:GetAngles():Right() * 17 * startlerp)
	end

	mv:SetOrigin(origin)
	mv:SetVelocity(vector_origin)

	if CLIENT or game.SinglePlayer() then
		ply:SetEyeAngles(LerpAngle(startlerp, ply:EyeAngles(), circlepos:Angle()))

		if CLIENT and IsFirstTimePredicted() then
			viewtiltlerp.z = startlerp * -10 * dir

			ply:CLViewPunch(Angle(0, 0.1 * dir))
		elseif SERVER then
			ply:SendLua("viewtiltlerp.z = " .. startlerp .. "*-10*" .. dir)
			ply:ViewPunch(Angle(0, 0.1 * dir))
		end
	end

	if math.abs(ply:GetSBOffset()) >= 90 then
		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetSwingbarLast(ply:GetSwingpipe())
		ply:SetSwingpipe(nil)
		ply:SetSBDelay(CurTime() + 0.5)

		mv:SetVelocity(cmd:GetViewAngles():Forward() * 260 + Vector(0, 0, 150))

		ParkourEvent("jumpfar", ply)
	end
end

local function Swingpipe(ply, mv, cmd)
	if not ply.Monkey_tr then
		ply.Monkey_tr = {}
		ply.Monkey_trout = {}
		ply.Monkey_tr.output = ply.Monkey_trout
	end

	if not ply:OnGround() and not IsValid(ply:GetSwingpipe()) and ply:GetMoveType() == MOVETYPE_WALK and mv:GetVelocity().z < 800 then
		SwingpipeCheck(ply, mv, cmd)
	end

	if IsValid(ply:GetSwingpipe()) then
		SwingpipeThink(ply, mv, cmd)
	end
end

hook.Add("SetupMove", "Swingpipe", Swingpipe)