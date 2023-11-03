local chestvec = Vector(0, 0, 32)
local thoraxvec = Vector(0, 0, 48)
local neckvec = Vector(0, 0, 54)
local neckvecduck = Vector(0, 0, 54)
local eyevec = Vector(0, 0, 64)
local eyevecduck = Vector(0, 0, 64)
local hairvec = Vector(0, 0, 80)
local aircheck = Vector(0, 0, 600)
local mantlevec = Vector(0, 0, 16)
local vault1vec = Vector(0, 0, 24)
local vpunch1 = Angle(0, 0, -0.5)
local vpunch2 = Angle(0, 0, -2.5)
local vpunch3 = Angle(1, 0, 0)
local meta = FindMetaTable("Player")

function meta:GetMantle()
	return self:GetDTInt(13)
end

function meta:SetMantle(value)
	return self:SetDTInt(13, value)
end

function meta:GetMantleLerp()
	return self:GetDTFloat(13)
end

function meta:SetMantleLerp(value)
	return self:SetDTFloat(13, value)
end

function meta:GetMantleStartPos()
	return self:GetDTVector(13)
end

function meta:SetMantleStartPos(value)
	return self:SetDTVector(13, value)
end

function meta:GetMantleEndPos()
	return self:GetDTVector(14)
end

function meta:SetMantleEndPos(value)
	return self:SetDTVector(14, value)
end

local function PlayVaultAnim(ply, ang)
	local activewep = ply:GetActiveWeapon()

	if ply:UsingRH() and activewep:GetSequence() == 17 then
		activewep:SendWeaponAnim(ACT_VM_DRAW)
	end

	if game.SinglePlayer() and SERVER then
		local ang = ang or ply:EyeAngles()
		ang.x = 0
		ang.z = 0

		ply:SetNW2Angle("SPOrigEyeAng", ang)
		ply:SendLua("LocalPlayer().OrigEyeAng=LocalPlayer():GetNW2Angle(\"SPOrigEyeAng\")")

		return
	end

	if CLIENT then
		local ang = ang or ply:EyeAngles()
		ang.x = 0
		ang.z = 0
		ply.OrigEyeAng = ang
	end
end

local function Vault1(ply, mv, ang, t, h)
	local mins, maxs = ply:GetHull()

	t.start = mv:GetOrigin() + eyevec + ang:Forward() * 25
	t.endpos = t.start - neckvec
	t.filter = ply

	TraceParkourMask(t)

	t = util.TraceLine(t)

	if t.Entity and t.Entity.NoPlayerCollisions then return false end
	if t.Entity and t.Entity.IsNPC and t.Entity:IsPlayer() then return false end
	if IsValid(t.Entity) and t.Entity:GetClass() == "br_swingbar" then return false end

	if t.Hit and t.Fraction > 0.3 then
		local stepup = t.Fraction > 0.65
		local vaultend = stepup and t.HitPos + mantlevec or t.HitPos + ang:Forward() * 50 + mantlevec
		local tsafety = {}
		local tsafetyout = nil
		local start = t.StartPos - ang:Forward() * 50

		TraceSetData(tsafety, start, t.StartPos, mins, maxs, ply)
		TraceParkourMask(tsafety)

		tsafetyout = util.TraceLine(tsafety)

		if tsafetyout.Hit then return false end

		TraceSetData(tsafety, t.HitPos, t.HitPos, mins, maxs, ply)

		tsafetyout = util.TraceHull(tsafety)
		if tsafetyout.Hit then return false end

		TraceParkourMask(h)
		TraceSetData(h, vaultend, vaultend, mins, maxs, ply)

		local hulltr = util.TraceHull(h)

		if hulltr.Hit then
			vaultend = stepup and t.HitPos + ang:Forward() * 50 + mantlevec or t.HitPos + mantlevec

			TraceSetData(h, vaultend, vaultend, mins, maxs, ply)

			hulltr = util.TraceHull(h)
			stepup = not stepup
		end

		if not hulltr.Hit then
			if t.HitNormal.x ~= 0 then
				t.HitPos.z = t.HitPos.z + 12
			end

			local mat = t.MatType
			local start = mv:GetOrigin() + eyevec
			local vaultendcheck = Vector(vaultend)
			vaultendcheck.z = vaultendcheck.z + 64

			TraceSetData(t, start, vaultendcheck, ply)

			t = util.TraceLine(t)
			if t.Hit then return end

			ply:SetMantleStartPos(mv:GetOrigin())
			ply:SetMantleEndPos(vaultend)
			ply:SetMantleLerp(0)
			ply:SetMantle(1)
			ply:SetWallrunTime(0)

			PlayVaultAnim(ply, ang)

			ply:ViewPunch(vpunch1)
			ply.MantleInitVel = mv:GetVelocity()
			ply.MantleMatType = mat

			if stepup then
				ParkourEvent("stepup", ply)
				ply.VaultStepUp = true
			else
				ParkourEvent("vaultonto", ply)
				ply.VaultStepUp = false
			end

			if game.SinglePlayer() then
				ply:PlayStepSound(1)
			end

			return true
		end
	end

	return false
end

local function Vault2(ply, mv, ang, t, h)
	if ply:GetWallrun() == 1 then
		local highvault = Vault4(ply, mv, ang, t, h)

		if highvault then
			if CLIENT then
				BodyAnimSetEase(mv:GetOrigin())
			elseif game.SinglePlayer() then
				ply:SetNW2Vector("SPBAEase", mv:GetOrigin())
				ply:SendLua("BodyAnimSetEase(LocalPlayer():GetNW2Vector('SPBAEase'))")
			end
		end

		return highvault
	end

	local mins, maxs = ply:GetHull()
	maxs.z = maxs.z * 0.5

	local start = mv:GetOrigin() + chestvec + ang:Forward() * 35

	TraceSetData(t, start, start, mins, maxs, ply)
	TraceParkourMask(t)

	local vaultpos = t.endpos + ang:Forward() * 35

	t = util.TraceHull(t)

	if t.Entity and t.Entity.NoPlayerCollisions then return false end
	if t.Entity and t.Entity.IsNPC and t.Entity:IsPlayer() then return false end
	if IsValid(t.Entity) and t.Entity:GetClass() == "br_swingbar" then return false end

	if t.Hit then
		local tsafety = {}
		local tsafetyout = {}
		local start = nil

		TraceParkourMask(tsafety)
		tsafety.output = tsafetyout
		start = mv:GetOrigin() + eyevec
		TraceSetData(tsafety, start, start + ang:Forward() * 100, mins, maxs, ply)

		util.TraceLine(tsafety)

		if tsafetyout.Hit then return false end
		start = start + ang:Forward() * 100
		TraceSetData(tsafety, start, start - thoraxvec)

		util.TraceLine(tsafety)

		if tsafetyout.Hit then return false end

		start = t.StartPos + chestvec
		TraceSetData(h, start, start, mins, maxs, ply)

		TraceParkourMask(h)

		local hulltr = util.TraceHull(h)

		mins, maxs = ply:GetHull()

		TraceSetData(h, vaultpos, vaultpos, mins, maxs, ply)

		local hulltr2 = util.TraceHull(h)

		if not hulltr.Hit and not hulltr2.Hit then
			if t.MatType == MAT_GRATE and (CLIENT and IsFirstTimePredicted() or game.SinglePlayer()) then
				ply:EmitSound("FenceClimb")
			end

			ply:SetMantleData(mv:GetOrigin(), vaultpos, 0, 2)
			ply:SetWallrunTime(0)

			PlayVaultAnim(ply, ang)

			ply:ViewPunch(vpunch2)
			ply.MantleInitVel = mv:GetVelocity()
			ply.MantleInitVel.z = 0
			ply.MantleMatType = t.MatType

			ParkourEvent("vault", ply)

			if game.SinglePlayer() or CLIENT and IsFirstTimePredicted() then
				timer.Simple(0.1, function()
					ply:EmitSound("Cloth.VaultSwish")
					ply:FaithVO("Faith.StrainSoft")
				end)

				ply:EmitSound("Handsteps.ConcreteHard")
			end

			return true
		end
	end

	return false
end

local function Vault3(ply, mv, ang, t, h)
	local mins, maxs = ply:GetHull()
	maxs.z = maxs.z * 0.5

	t.start = mv:GetOrigin() + chestvec + ang:Forward() * 35
	t.endpos = t.start
	t.filter = ply

	TraceParkourMask(t)
	t.maxs = maxs
	t.mins = mins

	local vaultpos = t.endpos + ang:Forward() * 60

	t = util.TraceHull(t)

	if t.Entity and t.Entity.NoPlayerCollisions then return false end
	if t.Entity and t.Entity.IsNPC and (t.Entity:IsNPC() or t.Entity:IsPlayer()) then return false end
	if IsValid(t.Entity) and t.Entity:GetClass() == "br_swingbar" then return false end

	if t.Hit then
		local tsafety = {}
		local tsafetyout = {}
		local start = nil

		TraceParkourMask(tsafety)
		tsafety.output = tsafetyout
		start = mv:GetOrigin() + eyevec
		TraceSetData(tsafety, start, start + ang:Forward() * 150, ply)

		util.TraceLine(tsafety)

		if tsafetyout.Hit then return false end

		start = mv:GetOrigin() + eyevec + ang:Forward() * 150
		TraceSetData(tsafety, start, start - thoraxvec)

		util.TraceLine(tsafety)

		if tsafetyout.Hit then return false end

		start = mv:GetOrigin() + eyevec + ang:Forward() * 150
		TraceSetData(tsafety, start, start - aircheck)

		util.TraceLine(tsafety)

		if not tsafetyout.Hit then return false end

		mins.z = mins.z * 1
		h.start = t.StartPos + chestvec
		h.endpos = h.start
		h.filter = ply
		h.maxs = maxs
		h.mins = mins

		TraceParkourMask(h)
		local hulltr = util.TraceHull(h)
		local mins, maxs = ply:GetHull()

		h.start = vaultpos
		h.endpos = h.start
		h.filter = ply
		h.maxs = maxs
		h.mins = mins

		local hulltr2 = util.TraceHull(h)

		if not hulltr.Hit and not hulltr2.Hit then
			if t.MatType == MAT_GRATE and (CLIENT and IsFirstTimePredicted() or game.SinglePlayer()) then
				ply:EmitSound("FenceClimb")
			end

			ply:SetMantleData(mv:GetOrigin(), vaultpos, 0, 3)
			ply:SetWallrunTime(0)

			PlayVaultAnim(ply, ang)

			ply:ViewPunch(vpunch3)
			ply.MantleInitVel = mv:GetVelocity()
			ply.MantleInitVel.z = 0
			ply.MantleMatType = t.MatType

			ParkourEvent("vaultkong", ply)

			if game.SinglePlayer() or CLIENT and IsFirstTimePredicted() then
				timer.Simple(0.1, function()
					ply:EmitSound("Cloth.VaultSwish")
					ply:FaithVO("Faith.StrainSoft")
				end)

				ply:EmitSound("Handsteps.ConcreteHard")
			end

			return true
		end
	end

	return false
end

function Vault4(ply, mv, ang, t, h)
	local mins, maxs = ply:GetHull()

	t.StartPos = mv:GetOrigin() + eyevec + ang:Forward() * 50

	local vaultpos = mv:GetOrigin() + ang:Forward() * 65 + vault1vec

	local tsafety = {
		start = mv:GetOrigin() + hairvec
	}

	tsafety.endpos = tsafety.start + ang:Forward() * 75
	tsafety.filter = ply
	tsafety.mask = MASK_PLAYERSOLID
	tsafety.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT

	local tsafetyout = util.TraceLine(tsafety)

	if tsafetyout.Hit then return false end

	tsafety.start = mv:GetOrigin() + aircheck + ang:Forward() * 40
	tsafety.endpos = tsafety.start - hairvec

	local tsafetyout = util.TraceLine(tsafety)

	if tsafetyout.Hit then return false end

	tsafety.start = mv:GetOrigin() + chestvec
	tsafety.endpos = tsafety.start + ang:Forward() * 150

	local tsafetyout = util.TraceLine(tsafety)

	if not tsafetyout.Hit then return false end

	mins.z = mins.z * 1
	h.start = vaultpos
	h.endpos = vaultpos
	h.filter = ply
	h.mask = MASK_PLAYERSOLID
	h.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
	h.maxs = maxs
	h.mins = mins

	local hsafetyout = util.TraceHull(h)

	if hsafetyout.Hit then return false end

	local startpos = ply:GetWallrun() ~= 1 and mv:GetOrigin() or mv:GetOrigin() + Vector(0, 0, 20) - ang:Forward() * 5

	ply:SetMantleData(startpos, vaultpos, 0, 4)
	ply:SetWallrunTime(0)

	PlayVaultAnim(ply, ang)

	ply:ViewPunch(Angle(2.5, 0, 0))
	ply.MantleInitVel = mv:GetVelocity()
	ply.MantleInitVel.z = 0
	ply.MantleMatType = t.MatType

	ParkourEvent("vaulthigh", ply)

	if CLIENT then
		CamIgnoreAng = false
	elseif game.SinglePlayer() then
		ply:SendLua("CamIgnoreAng=false")
	end

	if game.SinglePlayer() or CLIENT and IsFirstTimePredicted() then
		timer.Simple(0.1, function()
			ply:EmitSound("Cloth.VaultSwish")
			ply:FaithVO("Faith.StrainSoft")
		end)

		ply:EmitSound("Handsteps.ConcreteHard")
	end

	if CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
		tsafety.start = ply:EyePos()
		tsafety.endpos = tsafety.start + ang:Forward() * 100

		local tsafetyout = util.TraceLine(tsafety)

		if tsafetyout.MatType == MAT_GRATE then
			ply:EmitSound("FenceClimb")

			timer.Simple(0.45, function()
				ply:EmitSound("FenceClimbEnd")
			end)
		end
	end

	return true
end

function Vault5(ply, mv, ang, t, h)
	if ply:GetWallrun() == 1 and ply:GetWallrunTime() - CurTime() < 0.75 then return false end
	if mv:GetVelocity().z < (not ply:GetDive() and -100 or -1000) then return false end

	local eyevec = not ply:Crouching() and eyevec or eyevecduck
	local neckvec = not ply:Crouching() and neckvec or neckvecduck

	t.start = mv:GetOrigin() + eyevec + ang:Forward() * 70
	t.endpos = t.start - neckvec
	t.filter = ply
	t.mask = MASK_PLAYERSOLID
	t.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
	t = util.TraceLine(t)

	if not t.Hit then return false end

	if t.Entity and t.Entity.NoPlayerCollisions then return false end

	local vaultend = t.HitPos + mantlevec

	local tsafety = {
		start = t.StartPos - ang:Forward() * 70,
		endpos = t.StartPos,
		filter = ply,
		mask = MASK_PLAYERSOLID,
		collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
	}

	tsafety = util.TraceLine(tsafety)

	if tsafety.Hit then return false end

	tsafety.start = mv:GetOrigin() + hairvec
	tsafety.endpos = tsafety.start + ang:Forward() * 60

	local tsafetyout = util.TraceLine(tsafety)

	if tsafetyout.Hit then return false end

	h.start = vaultend
	h.endpos = h.start
	h.filter = ply
	h.mask = MASK_PLAYERSOLID
	h.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
	h.mins, h.maxs = ply:GetHull()

	local hulltr = util.TraceHull(h)

	if not hulltr.Hit then
		if t.HitNormal.x ~= 0 then
			t.HitPos.z = t.HitPos.z + 12
		end

		ply:SetMantleStartPos(mv:GetOrigin())
		ply:SetMantleEndPos(vaultend)
		ply:SetMantleLerp(0)
		ply:SetMantle(5)
		ply:SetWallrunTime(0)

		PlayVaultAnim(ply, ang)

		ply:ViewPunch(vpunch1)
		ply.MantleInitVel = mv:GetVelocity()
		ply.MantleMatType = t.MatType

		ParkourEvent("vaultontohigh", ply)

		if game.SinglePlayer() then
			ply:PlayStepSound(1)
		end

		return true
	end

	return false
end

hook.Add("SetupMove", "BeatrunVaulting", function(ply, mv, cmd)
	if ply.MantleDisabled or IsValid(ply:GetSwingbar()) or ply:GetClimbing() ~= 0 or ply:GetMelee() ~= 0 then return end

	if not ply:Alive() then
		if ply:GetMantle() ~= 0 then
			ply:SetMantle(0)
		end

		return
	end

	if ply:GetMantle() == 0 then
		local mvtype = ply:GetMoveType()

		if ply:OnGround() or mv:GetVelocity().z < -350 or mvtype == MOVETYPE_NOCLIP or mvtype == MOVETYPE_LADDER then return end
	end

	ply.mantletr = ply.mantletr or {}
	ply.mantlehull = ply.mantlehull or {}

	local t = ply.mantletr
	local h = ply.mantlehull

	if not h.filter then
		h.filter = ply
		h.mins, h.maxs = ply:GetHull()
	end

	if ply:GetMantle() == 0 and not ply:OnGround() and mv:KeyDown(IN_FORWARD) and not mv:KeyDown(IN_DUCK) and not ply:Crouching() then
		local ang = mv:GetAngles()
		ang.x = 0
		ang.z = 0

		if not Vault2(ply, mv, ang, t, h) and not Vault3(ply, mv, ang, t, h) then
			Vault1(ply, mv, ang, t, h)
		end
	end

	if ply:GetMantle() ~= 0 then
		mv:SetMaxClientSpeed(0)
		mv:SetSideSpeed(0)
		mv:SetUpSpeed(0)
		mv:SetForwardSpeed(0)

		cmd:ClearMovement()

		mv:SetVelocity(vector_origin)

		ply:SetMoveType(MOVETYPE_NOCLIP)

		local mantletype = ply:GetMantle()
		local mlerp = ply:GetMantleLerp()
		local FT = FrameTime()
		local TargetTick = 1 / FT / 66.66
		local mlerpend = mantletype == 1 and 0.8 or 1
		local mlerprate = (mantletype == 1 and 0.075 or 0.06) / TargetTick
		local mvec = LerpVector(ply:GetMantleLerp(), ply:GetMantleStartPos(), ply:GetMantleEndPos())

		mv:SetOrigin(mvec)

		if mantletype == 1 then
			if not ply.VaultStepUp and mlerp > 0.01 and mlerp < 0.65 then
				mlerprate = mlerprate * mlerp / 0.5

				if CLIENT and IsFirstTimePredicted() then
					ply:CLViewPunch(Angle(0.1 / (mlerp / 0.25), 0, 0.05))
				elseif game.SinglePlayer() then
					ply:ViewPunch(Angle(0.33 / (mlerp / 0.25), 0, 0.05))
				end
			end

			ply:SetMantleLerp(Lerp(mlerprate, mlerp, 1))
		elseif mantletype == 2 then
			ply:SetMEMoveLimit(500)
			ply:SetMESprintDelay(-1)

			mlerprate = mlerprate * 0.75

			if mlerp < 0.25 then
				if mlerp > 0.1 then
					local mult = math.max(0.5, 0.5 + ply.MantleInitVel:Length() / 375 * 0.3 - 0.2)

					mlerprate = mlerprate * mult
				end

				if CLIENT and IsFirstTimePredicted() then
					ply:CLViewPunch(Angle(0.25 * mlerp / 0.2, -0.05, -0.15))
				elseif game.SinglePlayer() then
					ply:ViewPunch(Angle(0.75 * mlerp / 0.2, -0.25, -0.5))
				end
			elseif mlerp > 0.45 and mlerp < 0.7 then
				if CLIENT and IsFirstTimePredicted() then
					ply:CLViewPunch(Angle(-0.15, 0.1, 0.15))
				elseif game.SinglePlayer() then
					ply:ViewPunch(Angle(-0.75, 0.25, 0.5))
				end
			end

			ply:SetMantleLerp(math.Approach(mlerp, 1, mlerprate))
		elseif mantletype == 3 then
			if mlerp < 0.45 then
				if CLIENT and IsFirstTimePredicted() then
					ply:CLViewPunch(Angle(0.15, 0, 0))
				elseif game.SinglePlayer() then
					ply:ViewPunch(Angle(0.3, 0, 0))
				end
			elseif mlerp > 0.45 and mlerp < 0.8 then
				if CLIENT and IsFirstTimePredicted() then
					ply:CLViewPunch(Angle(-0.05, 0, 0))
				elseif game.SinglePlayer() then
					ply:ViewPunch(Angle(-0.25, 0, 0))
				end
			end

			local mult = math.max(0.75, 0.75 + ply.MantleInitVel:Length() / 350 * 0.3 - 0.2)

			mlerprate = mlerprate * mult

			ply:SetMantleLerp(math.Approach(mlerp, 1, mlerprate))
		elseif mantletype == 4 then
			mlerprate = 0.03 / TargetTick

			if mlerp < 0.0575 then
				if CLIENT and IsFirstTimePredicted() then
					ply:CLViewPunch(Angle(0.25 * mlerp / 0.2, 0, -0.25))
				elseif game.SinglePlayer() then
					ply:ViewPunch(Angle(0.75 * mlerp / 0.1, 0, -0.5))
				end

				mlerprate = mlerprate * 0.1
			elseif CLIENT and IsFirstTimePredicted() then
				ply:CLViewPunch(Angle(-0.05, 0, 0.25 / (mlerp / 0.3)))
			elseif game.SinglePlayer() then
				ply:ViewPunch(Angle(-0.15, 0, 0.5 / (mlerp / 0.3)))
			end

			if mlerp > 0.3 then
				mlerprate = mlerprate * 1.5
			end

			ply:SetMantleLerp(math.Approach(mlerp, 1, mlerprate))
		elseif mantletype == 5 then
			mlerprate = 0.03 / TargetTick

			if mlerp < 0.0575 then
				if CLIENT and IsFirstTimePredicted() then
					ply:CLViewPunch(Angle(-0.15 * mlerp / 0.1, 0, -0.25))
				elseif game.SinglePlayer() then
					ply:ViewPunch(Angle(0.15 * mlerp / 0.1, 0, -0.5))
				end

				mlerprate = mlerprate * 0.1
			else
				if CLIENT and IsFirstTimePredicted() then
					ply:CLViewPunch(Angle(0.01, 0, 0.5 / (mlerp / 0.15)))
				elseif game.SinglePlayer() then
					ply:ViewPunch(Angle(-0.05, 0, 0.5 / (mlerp / 0.3)))
				end

				if mlerp < 0.7 then
					mlerprate = mlerprate * 0.8
				else
					mlerprate = mlerprate * 0.6
				end
			end

			ply:SetMantleLerp(math.Approach(mlerp, 1, mlerprate))
		end

		mlerp = ply:GetMantleLerp()

		h.start = mvec
		h.endpos = h.start
		h.filter = ply
		h.mask = MASK_PLAYERSOLID
		h.mins, h.maxs = ply:GetHull()

		local hulltr = util.TraceHull(h)

		if mlerpend <= mlerp or not hulltr.Hit and (mantletype == 1 and mlerp > 0.4 or mantletype == 2 and mlerp > 0.5 or mantletype == 5 and mlerp > 0.75) then
			local ang = mv:GetAngles()
			ang.x = 0
			ang.z = 0

			if mantletype >= 2 and mantletype ~= 4 and mantletype ~= 5 then
				mv:SetVelocity(ang:Forward() * math.Clamp(ply.MantleInitVel:Length(), 200, 600))
			end

			ply:SetViewOffsetDucked(Vector(0, 0, 32))
			ply:SetMantle(0)
			ply:SetMoveType(MOVETYPE_WALK)

			if hulltr.Hit then
				mv:SetOrigin(ply:GetMantleEndPos())
			end

			if mantletype == 4 then
				mv:SetVelocity(ang:Forward() * 150)
				ply:SetMEMoveLimit(150)
			end

			if mv:KeyDown(IN_JUMP) and mantletype < 4 then
				if CLIENT and IsFirstTimePredicted() then
					BodyLimitX = 90
					BodyLimitY = 180
				elseif game.SinglePlayer() then
					ply:SendLua("BodyLimitX=90 BodyLimitY=180")
				end

				ply:ViewPunch(Angle(-2.5, 0, 0))
				ParkourEvent("springboard", ply)

				if IsFirstTimePredicted() then
					if game.SinglePlayer() or CLIENT then
						ply:EmitSound("Cloth.VaultSwish")
					end

					if ply.MantleMatType == 77 or ply.MantleMatType == 86 then
						ply:EmitSound("Metal.Ringout")
					end

					hook.Run("PlayerFootstep", ply, mv:GetOrigin(), 1, "Footsteps.Concrete", 1)
				end

				local springboardvel = ang:Forward() * math.Clamp((ply.MantleInitVel or vector_origin):Length() * 0.75, 200, 300) + Vector(0, 0, 350)
				springboardvel:Mul(ply:GetOverdriveMult())
				springboardvel[3] = springboardvel[3] / ply:GetOverdriveMult()

				mv:SetVelocity(springboardvel)

				local activewep = ply:GetActiveWeapon()

				if ply:UsingRH() and mantletype == 1 then
					activewep:SendWeaponAnim(ACT_VM_RECOIL1)
				end
			end
		else
			mv:SetButtons(0)
		end
	end
end)