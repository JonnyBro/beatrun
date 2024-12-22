local qslide_duration = 3
local qslide_speedmult = 1

local slide_sounds = {
	[MAT_DIRT] = {"fol/fol_slide_dirt_01.wav", "fol/fol_slide_dirt_02.wav", "fol/fol_slide_dirt_03.wav", "fol/fol_slide_dirt_04.wav"},
	[MAT_SAND] = {"fol/fol_slide_sand_01.wav", "fol/fol_slide_sand_02.wav", "fol/fol_slide_sand_03.wav", "fol/fol_slide_sand_04.wav"},
	[MAT_METAL] = {"fol/fol_slide_metal_01.wav", "fol/fol_slide_metal_02.wav", "fol/fol_slide_metal_03.wav"},
	[MAT_GLASS] = {"fol/fol_slide_glass_01.wav", "fol/fol_slide_glass_02.wav", "fol/fol_slide_glass_03.wav", "fol/fol_slide_glass_04.wav"},
	[MAT_GRATE] = {"fol/fol_slide_grate_01.wav"},
	[MAT_SLOSH] = {"ambient/water/water_splash1.wav", "ambient/water/water_splash2.wav", "ambient/water/water_splash3.wav"},
	[MAT_WOOD] = {"fol/fol_slide_generic_01.wav", "fol/fol_slide_generic_02.wav", "fol/fol_slide_generic_03.wav"}
}

local slideloop_sounds = {
	[0] = "mirrorsedge/Slide/ME_FootStep_ConcreteSlideLoop.wav",
	[MAT_GLASS] = "mirrorsedge/Slide/ME_FootStep_GlassSlideLoop.wav"
}

slide_sounds[MAT_GRASS] = slide_sounds[MAT_DIRT]
slide_sounds[MAT_SNOW] = slide_sounds[MAT_DIRT]
slide_sounds[MAT_VENT] = slide_sounds[MAT_METAL]
slide_sounds[0] = slide_sounds[MAT_DIRT]

--[[
local animtable = {
	lockang = false,
	allowmove = true,
	followplayer = true,
	ignorez = true,
	BodyAnimSpeed = 1.1,
	deleteonend = false,
	BodyLimitX = 50,
	AnimString = "meslidestart",
	animmodelstring = "new_climbanim",
	camjoint = "camerajoint",
	usefullbody = 2
}
]]

local blocked = false

local function SlidingAnimThink()
	local ba = BodyAnim
	local ply = LocalPlayer()

	if not ply:GetSliding() then
		hook.Remove("Think", "SlidingAnimThink")
	end

	if IsValid(ba) and ba:GetSequence() == 5 and BodyAnimCycle >= 0.55 then
		ba:SetSequence(6)
	end

	if IsValid(ba) and ba:GetSequence() == ba:LookupSequence("meslidestart45") and BodyAnimCycle >= 0.55 then
		ba:SetSequence("meslideloop45")
	end

	if IsValid(ba) then
		ply.OrigEyeAng:Set(ply:GetSlidingAngle())
		ply.OrigEyeAng.x = 0

		local tr = util.QuickTrace(ply:GetPos(), Vector(0, 0, -64), ply)
		local normal = tr.HitNormal
		local oldang = ba:GetAngles()
		local ang = ba:GetAngles()
		local slidey = ply:GetSlidingAngle().y

		oldang[2] = slidey
		ang[2] = slidey
		ang.x = math.max(normal:Angle().x + 90, 360)

		local newang = LerpAngle(20 * FrameTime(), oldang, ang)
		ba:SetAngles(newang)

		BodyLimitX = math.min(20 + ang[1] - 360, 60)
		CamShakeMult = ply:GetVelocity():Length() * 0.0005
	end
end

local function SlidingAnimStart()
	if not IsFirstTimePredicted() and not game.SinglePlayer() then return end

	local ply = LocalPlayer()

	if not ply:Alive() then return end

	deleteonend = false
	BodyLimitY = 80
	BodyLimitX = 40

	if VMLegs and VMLegs:IsActive() then
		VMLegs:Remove()
	end

	if game.SinglePlayer() and not net.ReadBool() or not game.SinglePlayer() and not ply.DiveSliding then
		CamIgnoreAng = false
		camjoint = ply:GetSlidingSlippery() and "eyes" or "CameraJoint"

		if BodyAnimString == "meslideend" then
			BodyAnimCycle = 0.075
		else
			BodyAnimCycle = 0
		end

		BodyAnim:SetSequence(ply:GetSlidingSlippery() and "meslidestart45" or 5)
	else
		ParkourEvent("diveslidestart", ply, true)
	end

	BodyAnim:SetAngles(ply:GetSlidingAngle())
	ply.OrigEyeAng = ply:GetSlidingAngle()

	if ply:Crouching() or CurTime() < ply:GetCrouchJumpTime() then
		BodyAnimCycle = 0.1
		BodyAnim:SetCycle(0.1)
	end

	CamShake = ply:GetSlidingSlippery()
	hook.Add("Think", "SlidingAnimThink", SlidingAnimThink)
end

local function SlidingAnimEnd(slippery, diving)
	if not IsValid(BodyAnim) then return end

	local ply = LocalPlayer()

	if ply:GetJumpTurn() then
		camjoint = "eyes"
		CamIgnoreAng = true

		return
	end

	if not slippery then
		if not ply.DiveSliding and not diving then
			BodyAnimString = "meslideend"
			BodyAnim:ResetSequence("meslideend")
		else
			ply.DiveSliding = false
			ParkourEvent("diveslideend", ply, true)
		end

		BodyAnimCycle = 0
		BodyAnim:SetCycle(0)
		BodyAnimSpeed = 1.3

		timer.Simple(0.2, function()
			if ply:Alive() and BodyAnimString == "meslideend" and BodyAnimArmCopy and not ply:GetSliding() and not ply:OnGround() then
				BodyAnimCycle = 0
				camjoint = "eyes"

				BodyAnim:ResetSequence("jumpair")
			end
		end)
	else
		BodyAnimCycle = 0
		camjoint = "eyes"
	end

	timer.Simple(0.5, function()
		if ply:Alive() and BodyAnimArmCopy and not ply:GetSliding() then
			camjoint = "eyes"

			BodyLimitY = 180
			BodyLimitX = 90

			CamIgnoreAng = true
		end
	end)

	if blocked then
		timer.Simple(0.35, function()
			if IsValid(BodyAnim) then
				BodyAnim:SetSequence("crouchstill")
			end
		end)
	end

	CamShake = false

	hook.Remove("Think", "SlidingAnimThink")
end

if game.SinglePlayer() then
	if SERVER then
		util.AddNetworkString("sliding_spfix")
		util.AddNetworkString("sliding_spend")
	else
		net.Receive("sliding_spfix", function()
			SlidingAnimStart()
		end)

		net.Receive("sliding_spend", function()
			blocked = net.ReadBool()

			local slippery = net.ReadBool()
			local diving = net.ReadBool()

			SlidingAnimEnd(slippery, diving)
		end)
	end
end

local slidepunch = Angle(2.5, 0, -0.5)
-- local slidepunchend = Angle(3, 0, -3.5)
local trace_down = Vector(0, 0, 32)
-- local trace_up = Vector(0, 0, 32)
local trace_tbl = {}

local function SlideSurfaceSound(ply, pos)
	trace_tbl.start = pos
	trace_tbl.endpos = pos - trace_down
	trace_tbl.filter = ply

	local tr = util.TraceLine(trace_tbl)
	local sndtable = slide_sounds[tr.MatType] or slide_sounds[0]

	ply:EmitSound(sndtable[math.random(#sndtable)], 75, 100 + math.random(-20, -15), 0.5)

	if ply:WaterLevel() > 0 then
		sndtable = slide_sounds[MAT_SLOSH]

		ply:EmitSound(sndtable[math.random(#sndtable)])
	end

	return tr.MatType
end

local function SlideLoopSound(ply, pos, mat)
	local sndtable = slideloop_sounds[mat] or slideloop_sounds[0]

	ply.SlideLoopSound = CreateSound(ply, sndtable)
	ply.SlideLoopSound:PlayEx(0.05, 100)
end

-- local COORD_FRACTIONAL_BITS = 5
-- local COORD_DENOMINATOR = bit.lshift(1, COORD_FRACTIONAL_BITS)
-- local COORD_RESOLUTION = 1 / COORD_FRACTIONAL_BITS

local metaent = FindMetaTable("Entity")
metaent.oldOnGround = metaent.oldOnGround or metaent.OnGround

function metaent:OnGround()
	return self:IsPlayer() and self:GetSlidingSlippery() or self:oldOnGround()
end

hook.Add("SetupMove", "qslide", function(ply, mv, cmd)
	if not ply:Alive() then return end
	if ply:GetSafetyRollTime() > CurTime() then return end

	if not ply.OldDuckSpeed then
		ply.OldDuckSpeed = ply:GetDuckSpeed()
		ply.OldUnDuckSpeed = ply:GetUnDuckSpeed()
	end

	local sliding = ply:GetSliding()
	local speed = mv:GetVelocity()
	speed.z = 0
	speed = speed:Length()

	local runspeed = ply:GetRunSpeed()
	local slidetime = math.max(0.1, qslide_duration)
	local ducking = mv:KeyDown(IN_DUCK)
	local crouching = ply:Crouching()
	local sprinting = mv:KeyDown(IN_SPEED)
	local onground = ply:OnGround()
	local CT = CurTime()

	if not ply.SlideSlipperyTrace then
		local mins, maxs = ply:GetHull()
		ply.SlideSlipperyTraceOut = {}

		ply.SlideSlipperyTrace = {
			mask = MASK_SHOT_HULL,
			collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
			maxs = maxs,
			mins = mins,
			output = ply.SlideSlipperyTraceOut
		}
	end

	local slipperytrace = ply.SlideSlipperyTrace
	local slipperytraceout = ply.SlideSlipperyTraceOut
	local slipfail = true

	if ply:GetMoveType() == MOVETYPE_WALK then
		slipperytrace.start = mv:GetOrigin()
		slipperytrace.endpos = slipperytrace.start

		util.TraceHull(slipperytrace)

		local safestart = slipperytraceout.HitPos
		slipperytrace.start = safestart
		slipperytrace.endpos = Vector(safestart)
		slipperytrace.endpos.z = safestart.z - ply:GetStepSize() * 0.5

		util.TraceHull(slipperytrace)

		if slipperytraceout.Fraction > 0 and slipperytraceout.Fraction < 1 and not slipperytraceout.StartSolid then
			local slipnormal = slipperytraceout.HitNormal
			local hitpos = slipperytraceout.HitPos
			local ent = slipperytraceout.Entity
			-- local delta = math.abs(mv:GetOrigin().z - hitpos.z)

			slipperytrace.start = safestart
			slipperytrace.endpos = safestart - Vector(0, 0, 120)

			util.TraceLine(slipperytrace)

			if slipperytraceout.Hit and slipperytraceout.HitNormal:DistToSqr(slipnormal) < 0.3 then
				local normal = slipnormal
				local sang = normal:Angle()

				if sang.x > 315 and sang.x < 330 then
					mv:SetOrigin(hitpos)

					ply:SetGroundEntity(ent)
					ply:SetCrouchJumpBlocked(false)

					onground = true
					slipfail = false

					ply:SetCrouchJump(false)

					if SERVER and mv:GetVelocity().z <= -1250 and not ply:InOverdrive() then
						local dmg = DamageInfo()
							dmg:SetDamageType(DMG_FALL)
							dmg:SetDamage(1000)
						ply:TakeDamageInfo(dmg)
					end
				end
			end
		end
	end

	if (not onground or slipfail or ply:GetSlidingSlipperyUpdate() < CT or not slipperytraceout.HitNormal) and slipfail then
		slipperytrace.filter = ply
		slipperytrace.start = mv:GetOrigin()
		slipperytrace.endpos = slipperytrace.start - Vector(0, 0, 32)

		util.TraceHull(slipperytrace)

		ply:SetSlidingSlipperyUpdate(CT + 0.25)
	end

	local normal = slipperytraceout.HitNormal
	local sang = normal:Angle()
	local slippery = sang.x > 315 and sang.x < 330 and ply:GetMoveType() ~= MOVETYPE_NOCLIP and not ply:GetCrouchJump() and onground and not slipfail and ply:WaterLevel() < 1

	ply:SetSlidingSlippery(slippery)

	if slippery then
		sang.x = 0
		sang.y = math.floor(sang.y)

		ply:SetSlidingAngle(sang)

		local vel = mv:GetVelocity()
		vel.z = 0

		if vel:Length() == 0 then
			local ang = cmd:GetViewAngles()
			ang.x = 0

			mv:SetVelocity(ang:Forward() * 10)
		end
	end

	if onground and not ply:GetSliding() and not ply:GetJumpTurn() and ply:Alive() and 
	   (ply:GetSlidingDelay() < CT) and ducking and
	   ((ducking and sprinting and speed > runspeed * 0.5) or slippery or ply:GetDive()) then
		vel = math.min(speed, 541.44) * ply:GetOverdriveMult()

		ParkourEvent(slippery and "slide45" or "slide", ply)

		if slippery then
			vel = 230

			ply:SetDive(false)
			ply.DiveSliding = false
		end

		if ply:GetDive() then
			ply.DiveSliding = true
		end

		ply:SetViewOffset(Vector(0, 0, 64))
		ply:SetSliding(true)

		local slidecalctime = slidetime * math.min(vel / 300, 1)
		ply:SetSlidingTime(CT + slidecalctime)

		if not ply:Crouching() then
			ply:ViewPunch(slidepunch)
		end

		ply:SetDuckSpeed(0.1)
		ply:SetUnDuckSpeed(0.05)

		if not slippery then
			if not ply.DiveSliding then
				ply:SetSlidingAngle(mv:GetVelocity():Angle())
			else
				local ang = cmd:GetViewAngles()
				ang.x = 0
				ply:SetSlidingAngle(ang)
			end
		end

		ply:SetSlidingVel(vel)
		ply:SetSlidingStrafe(0)
		ply.SlidingInitTime = CT

		if game.SinglePlayer() then
			ply:SendLua("LocalPlayer().SlidingInitTime = CurTime()")
		end

		ply:SetJumpTurn(false)
		ply:SetJumpTurnRecovery(0)

		if SERVER then
			local pos = mv:GetOrigin()
			local mat = SlideSurfaceSound(ply, pos)

			SlideLoopSound(ply, pos, mat)
		end

		if game.SinglePlayer() then
			net.Start("sliding_spfix")
				net.WriteBool(ply:GetDive())
			net.Send(ply)
		end

		if CLIENT and IsFirstTimePredicted() then
			SlidingAnimStart()

			hook.Add("Think", "SlidingAnimThink", SlidingAnimThink)
		end
	elseif (not ducking and ply:GetMelee() == 0 and not slippery or not onground) and sliding then
		blocked = false

		if not ducking then
			ply.SlideHull = ply.SlideHull or {}
			ply.SlideHullOut = ply.SlideHullOut or {}

			local hulltr = ply.SlideHull
			local hulltrout = ply.SlideHullOut
			local mins, maxs = ply:GetHull()
			local origin = mv:GetOrigin()

			hulltr.start = origin
			hulltr.endpos = origin
			hulltr.maxs = maxs
			hulltr.mins = mins
			hulltr.filter = ply
			hulltr.mask = MASK_PLAYERSOLID
			hulltr.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
			hulltr.output = hulltrout

			util.TraceHull(hulltr)

			if hulltrout.Hit then
				blocked = true
			end
		end

		ply:SetCrouchJumpBlocked(false)
		ply:SetSliding(false)
		ply:SetSlidingTime(0)
		ply:ViewPunch(Angle(0.85, 0.35, 0))

		if ply:GetSlidingVel() > 400 then
			ply:SetMEMoveLimit(600)
		end

		if game.SinglePlayer() then
			net.Start("sliding_spend")
				net.WriteBool(blocked)
				net.WriteBool(false)
				net.WriteBool(ply.DiveSliding)
			net.Send(ply)

			ply.DiveSliding = false
		elseif CLIENT and IsFirstTimePredicted() then
			SlidingAnimEnd(false, ply.DiveSliding)

			ply.DiveSliding = false
		end

		ply:SetSlidingDelay(CT + 0.1)

		if SERVER and ply.SlideLoopSound then
			ply.SlideLoopSound:Stop()
		end

		ply:ConCommand("-duck")

		ply:SetViewOffsetDucked(Vector(0, 0, 32))
	end

	sliding = ply:GetSliding()

	if sliding then
		local eyeang = cmd:GetViewAngles()
		eyeang.x = 0
		eyeang.z = 0
		eyeang = eyeang:Forward()

		ply:SetViewOffsetDucked(Vector(0, 0, 28) + eyeang * -25)
		local slidedelta = (ply:GetSlidingTime() - CT) / slidetime
		local speed = ply:GetSlidingVel() * math.min(1.75, (ply:GetSlidingTime() - CT + 0.5) / slidetime) * qslide_speedmult

		mv:SetVelocity(ply:GetSlidingAngle():Forward() * speed)

		local pos = mv:GetOrigin()

		if not ply:GetSlidingLastPos() then
			ply:SetSlidingLastPos(pos)
		end

		if not slippery and pos.z > ply:GetSlidingLastPos().z + 1 then
			ply:SetSlidingTime(ply:GetSlidingTime() - 0.025)
		elseif slippery or slidedelta < 1 and pos.z < ply:GetSlidingLastPos().z - 0.25 then
			ply:SetSlidingTime(CT + slidetime)                       --[[ GetConVar("Beatrun_SpeedLimit"):GetInt() ]]
			ply:SetSlidingVel(math.min(mv:GetVelocity():Length() * 0.865, 450 * ply:GetOverdriveMult()))
		end

		ply:SetSlidingLastPos(pos)

		if slippery then
			if mv:KeyDown(IN_MOVERIGHT) then
				ply:SetSlidingStrafe(math.Clamp(ply:GetSlidingStrafe() - FrameTime() * 125, -300, 300))
			elseif mv:KeyDown(IN_MOVELEFT) then
				ply:SetSlidingStrafe(math.Clamp(ply:GetSlidingStrafe() + FrameTime() * 125, -300, 300))
			else
				ply:SetSlidingStrafe(math.Approach(ply:GetSlidingStrafe(), 0, FrameTime() * 5))
			end

			mv:SetVelocity(mv:GetVelocity() - ply:GetSlidingAngle():Right() * ply:GetSlidingStrafe())

			if mv:KeyPressed(IN_JUMP) then
				local vel = mv:GetVelocity()
				vel:Mul(math.min(math.max(speed, 300) / 300, 1))
				vel.z = 175

				ply:SetSliding(false)
				ply:SetSlidingTime(0)

				if CLIENT then
					BodyAnimSetEase(mv:GetOrigin())
				elseif game.SinglePlayer() then
					ply:SetNW2Vector("SPBAEase", mv:GetOrigin())
					ply:SendLua("BodyAnimSetEase(LocalPlayer():GetNW2Vector('SPBAEase'))")
				end

				mv:SetOrigin(mv:GetOrigin() + Vector(0, 0, 33))

				ply:SetGroundEntity(nil)
				ply:SetSlidingSlippery(false)

				mv:SetVelocity(vel)

				ParkourEvent("jumpslide", ply)
			end
		end

		if not slippery then -- TODO: Find a way to make proper slide jump. It works on slippery because you are not holding Crouch for slippery objects
			if mv:KeyDown(IN_MOVELEFT) then
				local ang = ply:GetSlidingAngle()
				ang.y = ang.y + 0.5

				ply:SetSlidingAngle(ang)
			elseif mv:KeyDown(IN_MOVERIGHT) then
				local ang = ply:GetSlidingAngle()
				ang.y = ang.y - 0.5

				ply:SetSlidingAngle(ang)
			end
		end

		if mv:KeyPressed(IN_BACK) and ply:GetMelee() == 0 and ply:GetSlidingTime() < CT + slidetime * 0.95 then
			if CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
				cmd:SetViewAngles(ply:GetSlidingAngle())
			end

			ply.DiveSliding = false
			ply:SetSlidingTime(0)
			ply:SetSliding(false)
			ply:SetQuickturn(true)
			ply:SetQuickturnTime(CT)
			ply:SetQuickturnAng(cmd:GetViewAngles())

			if CLIENT and IsFirstTimePredicted() then
				DoJumpTurn(false)
			elseif game.SinglePlayer() then
				ply:SendLua("DoJumpTurn(false)")
			end

			ply:SetJumpTurn(true)

			ply:ViewPunch(Angle(2.5, 0, 5))

			ply:SetViewOffsetDucked(Vector(0, 0, 17))
			ply:SetViewOffset(Vector(0, 0, 64))

			mv:SetOrigin(mv:GetOrigin() + Vector(0, 0, 48))
			mv:SetVelocity(mv:GetVelocity() * 0.75 + Vector(0, 0, 251))
		end

		if ply:GetVelocity():Length() <= 75 then
			ply:SetSlidingTime(0)
		end

		if ply:GetMelee() ~= 0 then
			ply:SetSlidingTime(math.max(ply:GetSlidingTime(), CurTime() + 0.1))
		end

		if ply:GetSlidingTime() < CT and ply:GetMelee() == 0 then
			ply:SetSliding(false)
			ply:SetSlidingTime(0)
			ply:ViewPunch(Angle(0.85, 0, 0.15))

			if SERVER and game.SinglePlayer() then
				net.Start("sliding_spend")
					net.WriteBool(false)
					net.WriteBool(slippery)
					net.WriteBool(ply.DiveSliding)
				net.Send(ply)
			elseif CLIENT and IsFirstTimePredicted() then
				SlidingAnimEnd(slippery, ply.DiveSliding)
			end

			ply:SetSlidingDelay(CT + 0.1)

			if SERVER then
				ply.SlideLoopSound:Stop()
			end

			ply.DiveSliding = false

			if not mv:KeyDown(IN_ATTACK2) or mv:KeyDown(IN_FORWARD) then
				ply:ConCommand("-duck")
				ply:SetViewOffsetDucked(Vector(0, 0, 32))
			else
				ply:SetViewOffsetDucked(Vector(0, 0, 17))
				ply:SetViewOffset(Vector(0, 0, 64))
				ply:SetJumpTurn(true)

				if CLIENT then
					DoJumpTurn(false)

					BodyAnim:SetSequence("meslideendprone")
				elseif game.SinglePlayer() then
					ply:SendLua("DoJumpTurn(false) BodyAnim:SetSequence('meslideendprone')")
				end
			end
		end
	end

	sliding = ply:GetSliding()

	if not crouching and not sliding then
		ply:SetDuckSpeed(ply.OldDuckSpeed)
		ply:SetUnDuckSpeed(ply.OldUnDuckSpeed)
	end
end)

hook.Add("PlayerFootstep", "qslidestep", function(ply)
	if ply:GetSliding() then return true end
end)

hook.Add("StartCommand", "qslidespeed", function(ply, cmd)
	if ply:GetSliding() then
		cmd:RemoveKey(IN_SPEED)

		if not ply:GetSlidingSlippery() then
			cmd:RemoveKey(IN_JUMP)
		end

		cmd:ClearMovement()

		local slidetime = math.max(0.1, qslide_duration)

		if (ply:GetSlidingTime() - CurTime()) / slidetime > 0.8 and (ply.SlidingInitTime > CurTime() - 0.25 or ply:GetSlidingSlippery()) then
			cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_DUCK))
		end
	end
end)