local meta = FindMetaTable("Player")
local metavec = FindMetaTable("Vector")
local PUNCH_DAMPING = 9
local PUNCH_SPRING_CONSTANT = 120

local viewbob_intensity = CreateClientConVar("Beatrun_ViewbobIntensity", "20", true, true, language.GetPhrase("beatrun.convars.viewbob"), -100, 100)
local viewbob_stabilized = CreateClientConVar("Beatrun_ViewbobStabilized", "0", true, true, language.GetPhrase("beatrun.convars.viewbobstabilization"), 0, 1)

local function lensqr(ang)
	return ang[1] ^ 2 + ang[2] ^ 2 + ang[3] ^ 2
end

function metavec:Approach(x, y, z, speed)
	if not isnumber(x) then
		local vec = x
		speed = y
		x, y, z = vec:Unpack()
	end

	self[1] = math.Approach(self[1], x, speed)
	self[2] = math.Approach(self[2], y, speed)
	self[3] = math.Approach(self[3], z, speed)
end

local function CLViewPunchThink()
	local plr = LocalPlayer()

	if not plr.ViewPunchVelocity then
		plr.ViewPunchVelocity = Angle()
		plr.ViewPunchAngle = Angle()
	end

	local vpa = plr.ViewPunchAngle
	local vpv = plr.ViewPunchVelocity

	if not plr.ViewPunchDone and lensqr(vpa) + lensqr(vpv) > 1e-06 then
		local FT = FrameTime()
		vpa = vpa + vpv * FT
		local damping = 1 - PUNCH_DAMPING * FT

		if damping < 0 then
			damping = 0
		end

		vpv = vpv * damping
		local springforcemagnitude = PUNCH_SPRING_CONSTANT * FT
		springforcemagnitude = math.Clamp(springforcemagnitude, 0, 2)
		vpv = vpv - vpa * springforcemagnitude
		vpa[1] = math.Clamp(vpa[1], -89.9, 89.9)
		vpa[2] = math.Clamp(vpa[2], -179.9, 179.9)
		vpa[3] = math.Clamp(vpa[3], -89.9, 89.9)
		plr.ViewPunchAngle = vpa
		plr.ViewPunchVelocity = vpv
	else
		plr.ViewPunchDone = true
	end
end

hook.Add("Think", "CLViewPunch", CLViewPunchThink)

local PunchPos = Vector()
local runfwd = 0
local runangmul = 1
local crouchmul = 1
local capmul = 0

local function CLViewPunchCalc(ply, pos, ang)
	local ply = LocalPlayer()

	if ply.ViewPunchAngle then
		ang:Add(ply.ViewPunchAngle)
	end

	local stabilize = viewbob_stabilized:GetBool() and 1 or -1
	local vel = ply:GetVelocity():Length()
	local punchang = ply:GetViewPunchAngles() + (ply.ViewPunchAngle or angle_zero)

	if ply:OnGround() and not ArmInterrupting(ply.BAC) and not ply:Crouching() and not ply:GetRolling() and ply:KeyDown(IN_FORWARD) and vel > 155 then
		local offset = Vector(0, -1, 0)

		if runfwd < 0.8 then
			capmul = math.Approach(capmul, 1, FrameTime() * 2)
		else
			capmul = math.Approach(capmul, 0, FrameTime() * 8)
		end

		vel = Lerp(capmul, vel, 290)

		offset:Mul(punchang.z * math.min(math.max((vel / 300 - 1) * stabilize, 0), 1) * 165)
		PunchPos:Approach(offset, FrameTime() * vel / 100 * 150 * math.abs(runfwd - 1.35) * 0.65)

		runfwd = math.Approach(runfwd, 0.1, FrameTime() * 0.25)
	else
		PunchPos:Approach(0, 0, 0, FrameTime() * 5)

		runfwd = math.Approach(runfwd, 1.25, FrameTime() * 5)
	end

	local grounded = ply:OnGround() and ply:GetMantle() == 0 and ply:GetClimbing() == 0 and not ply:GetSliding() and not ply:Crouching()

	if not grounded then
		crouchmul = math.Approach(crouchmul, 0, FrameTime() * 10)
	else
		crouchmul = math.Approach(crouchmul, 1, FrameTime() * 1.5)
	end

	local punchlocal = LocalToWorld(PunchPos, angle_zero, pos, ang)

	punchlocal:Sub(pos)
	punchlocal:Mul(math.abs(runfwd - 1.25))

	punchlocal.z = math.max(math.abs(PunchPos.y) * math.abs(runfwd - 1) * 2, -0.5) * crouchmul

	punchlocal:Mul(0.66)

	pos:Add(punchlocal)

	punchlocal:Mul(1.5151515151515151)

	runangmul = math.Approach(runangmul, grounded and 0.5 or 0, FrameTime() * (grounded and 5 or 15))

	ang:Sub(ply:GetViewPunchAngles() * math.abs(runfwd - 0.75) * runangmul)

	ang.z = ang.z - PunchPos.y * 0.15 * math.Clamp(-(runfwd - 1) * 1.25, 0, 1.25)
	ang.x = ang.x + punchlocal.z * 0.1 * math.Clamp(runfwd * 1.25 - 0.125, 0, 1.25)
end

hook.Add("CalcViewBA", "CLViewPunch", CLViewPunchCalc)

function meta:CLViewPunch(angle)
	self.ViewPunchVelocity:Add(angle * viewbob_intensity:GetFloat())

	local ang = self.ViewPunchVelocity
	ang[1] = math.Clamp(ang[1], -180, 180)
	ang[2] = math.Clamp(ang[2], -180, 180)
	ang[3] = math.Clamp(ang[3], -180, 180)

	self.ViewPunchDone = false
end

function meta:GetCLViewPunchAngles()
	return self.ViewPunchAngle
end