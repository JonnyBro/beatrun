local function SwingbarCheck(ply, mv, cmd)
	local mins, maxs = ply:GetCollisionBounds()
	mins.z = maxs.z * 0.85
	maxs.z = maxs.z * 1.75
	maxs.x = maxs.x * 1.5
	mins.x = mins.x * 1.5
	maxs.y = maxs.y * 1.5
	mins.y = mins.y * 1.5

	local tr = ply.Monkey_tr
	local trout = ply.Monkey_trout

	tr.start = mv:GetOrigin()
	tr.endpos = tr.start
	tr.maxs = maxs
	tr.mins = mins
	tr.filter = ply
	tr.collisiongroup = COLLISION_GROUP_WEAPON

	util.TraceHull(tr)

	if IsValid(trout.Entity) and trout.Entity:GetClass() == "br_swingbar" and (ply:GetSwingbarLast() ~= trout.Entity or ply:GetSBDelay() < CurTime()) then
		local swingbar = trout.Entity
		local dot = cmd:GetViewAngles():Forward():Dot(swingbar:GetAngles():Forward())
		local dir = dot > 0 and true or false

		if math.abs(dot) < 0.7 then return end


		if CLIENT then
			swingbar:SetPredictable(true)
		end

		ply:SetSwingbar(swingbar)
		ply:SetWallrunTime(0)
		ply:SetWallrunCount(0)
		ply:SetSBDir(dir)
		ply:SetSBStartLerp(0)
		ply:SetSBOffset(30)
		ply:SetSBPeak(0)
		ply:SetDive(false)
		ply:SetCrouchJump(false)

		ParkourEvent("swingbar", ply)

		mv:SetVelocity(vector_origin)

		if mv:KeyDown(IN_FORWARD) or mv:GetVelocity():Length() > 150 then
			ply:SetSBOffsetSpeed(2)
		else
			ply:SetSBOffsetSpeed(0)
		end

		if CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
			ply:EmitSound("Handsteps.ConcreteHard")
		end
	end
end

local radius = 30
-- local red = Color(255, 0, 0, 200)
local circlepos = Vector()
local axis = Vector(0, 0, 1)
local dummyvec = Vector(1000, 1000, 1000)

local function SwingbarThink(ply, mv, cmd)
	local swingbar = ply:GetSwingbar()

	if not ply:Alive() then
		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetSwingbar(nil)
		ply:SetSBDelay(CurTime() + 1)

		if CLIENT then
			swingbar:SetPredictable(false)
		end

		return
	end

	mv:SetForwardSpeed(0)
	mv:SetSideSpeed(0)

	local pos = swingbar:GetPos()
	local dir = ply:GetSBDir() and 1 or -1
	local ang = swingbar:GetAngles()
	local startlerp = ply:GetSBStartLerp()

	ang:RotateAroundAxis(axis, 90)

	pos.z = pos.z - 60

	ply:SetMoveType(MOVETYPE_NONE)

	local angle = ply:GetSBOffset() * math.pi * 2 / 180

	circlepos:SetUnpacked(0, math.cos(angle) * radius * dir, -math.sin(angle) * radius)
	circlepos:Rotate(ang)

	pos = pos + circlepos

	local origin = startlerp < 1 and LerpVector(startlerp, mv:GetOrigin(), pos) or pos

	ply:SetSBStartLerp(math.min(startlerp + 10 * FrameTime(), 1))
	mv:SetOrigin(origin)

	local offset = ply:GetSBOffset()

	if ply:GetSBOffset() >= 100 then
		ply:SetSBPeak(1)
		ply:SetSBOffsetSpeed(-1)
	end

	if ply:GetSBOffset() <= 0 then
		ply:SetSBPeak(2)
		ply:SetSBOffsetSpeed(1)
	end

	if ply:GetSBPeak() ~= 0 and ply:GetSBOffset() < 6 and ply:GetSBOffset() > 40 then
		ply:SetSBPeak(0)
	end

	if mv:KeyDown(IN_FORWARD) and ply:GetSBPeak() ~= 1 then
		ply:SetSBOffsetSpeed(math.Approach(math.max(ply:GetSBOffsetSpeed(), 0), 1 + ply:GetSBOffset() / 50, math.abs(ply:GetSBOffset() / 100 - 1) * 5 * FrameTime()))
	elseif mv:KeyDown(IN_BACK) and ply:GetSBPeak() ~= 2 then
		ply:SetSBOffsetSpeed(math.Approach(math.min(ply:GetSBOffsetSpeed(), 0), -1, math.abs(ply:GetSBOffset() / 100 - 1) * 5 * FrameTime()))
	else
		local a = (ply:GetSBOffset() - 50) / 50
		ply:SetSBOffsetSpeed(math.Approach(ply:GetSBOffsetSpeed(), 0, a * 5 * FrameTime()))
	end

	if math.abs(ply:GetSBOffsetSpeed()) <= 0.25 and (not mv:KeyDown(IN_FORWARD) and not mv:KeyDown(IN_BACK) or ply:GetSBPeak() ~= 0) then
		ply:SetSBOffset(math.Approach(ply:GetSBOffset(), 45, 2))
	else
		ply:SetSBOffset(math.Clamp(ply:GetSBOffset() + ply:GetSBOffsetSpeed(), 0, 100))
	end

	offset = ply:GetSBOffset()

	if mv:KeyPressed(IN_JUMP) or mv:KeyDown(IN_JUMP) and offset > 90 then
		ParkourEvent("swingjump", ply)

		if mv:KeyPressed(IN_JUMP) and offset > 90 then
			ply:SetSBOffsetSpeed(2.4)
		end

		local ang = cmd:GetViewAngles()
		ang.x = 0

		local vel = ang:Forward() * 125 * ply:GetSBOffsetSpeed()
		vel.z = ply:GetSBOffset() * 2

		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetSwingbarLast(ply:GetSwingbar())
		ply:SetSwingbar(nil)
		ply:SetWallrunDir(dummyvec)

		mv:SetVelocity(vel)

		ply:SetSBDelay(CurTime() + 1)

		if CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
			ply:EmitSound("Cloth.VaultSwish")
		end

		ply:SetMEMoveLimit(GetConVar("Beatrun_SpeedLimit"):GetInt())
		ply:SetMESprintDelay(-1)

		if CLIENT then
			swingbar:SetPredictable(false)
		end

		return
	end
end

local function Swingbar(ply, mv, cmd)
	if not ply.Monkey_tr then
		ply.Monkey_tr = {}
		ply.Monkey_trout = {}
		ply.Monkey_tr.output = ply.Monkey_trout
	end

	if not ply:OnGround() and not ply:GetJumpTurn() and not IsValid(ply:GetSwingbar()) and ply:GetMoveType() == MOVETYPE_WALK then
		SwingbarCheck(ply, mv, cmd)
	end

	if IsValid(ply:GetSwingbar()) then
		SwingbarThink(ply, mv, cmd)
	end
end

hook.Add("SetupMove", "Swingbar", Swingbar)