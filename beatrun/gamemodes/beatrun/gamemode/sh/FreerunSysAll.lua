local quakejump = CreateConVar("Beatrun_QuakeJump", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
local sidestep = CreateConVar("Beatrun_SideStep", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
local speed_limit = CreateConVar("Beatrun_SpeedLimit", 325, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

local function Hardland(jt)
	local ply = LocalPlayer()
	ply.hardlandtime = CurTime() + 1

	util.ScreenShake(Vector(0, 0, 0), 2, 2, 0.25, 0)

	BodyAnimCycle = 0

	if not ply:GetDive() then
		if jt then
			if ply:GetMelee() == MELEE_DROPKICK then
				jt = false
			end

			DoJumpTurn(jt)

			BodyAnim:SetSequence("jumpturnflyidle")
		else
			BodyAnim:SetSequence("jumpcoilend")
		end
	end
end

if game.SinglePlayer() and SERVER then
	util.AddNetworkString("Beatrun_HardLand")
end

if game.SinglePlayer() and CLIENT then
	net.Receive("Beatrun_HardLand", function()
		Hardland(net.ReadBool())
	end)
end

hook.Add("PlayerStepSoundTime", "MEStepTime", function(ply, step, walking)
	local activewep = ply:GetActiveWeapon()
	local sprint = ply:GetMEMoveLimit() < speed_limit:GetInt() - 25
	local stepmod = ply:GetStepRight() and 1 or -1
	local stepvel = 1.25
	local stepvel2 = 1

	if BodyAnimArmCopy then
		stepvel2 = 0
	end

	stepvel = stepvel - math.abs(ply:GetMEMoveLimit() / 100 - 1) * 0.33

	local stepmod2 = 1
	local stepmod3 = 1

	if IsValid(activewep) and activewep:GetClass() ~= "runnerhands" then
		stepmod2 = 0.25

		if not ply:IsSprinting() then
			stepmod3 = 0.25
		end
	end

	if not ply:Crouching() and not ply:KeyDown(IN_WALK) then
		if game.SinglePlayer() then
			local intensity = ply:GetInfoNum("Beatrun_ViewbobIntensity", 20) / 20

			intensity = sprint and intensity * 0.5 or intensity * 0.25

			ply:ViewPunch(Angle(0.45 * stepmod2 * stepvel2, 0, 0.5 * stepmod * stepvel * stepmod3) * intensity)
		elseif CLIENT and IsFirstTimePredicted() then
			local intensity = ply:GetInfoNum("Beatrun_ViewbobIntensity", 20) / 20

			intensity = sprint and intensity * 0.25 or intensity * 0.1

			ply:CLViewPunch(Angle(0.45 * stepmod2 * stepvel2, 0, 0.5 * stepmod * stepvel * stepmod3) * intensity)
		end
	end

	local steptime = math.Clamp(750 / (ply:GetVelocity() * Vector(1, 1, 0)):Length() * 100, 200, 400)

	if ply:Crouching() then
		steptime = steptime * 2
	end

	if ply:InOverdrive() then
		steptime = steptime * 0.8
	end

	ply:SetStepRelease(CurTime() + steptime * 0.25 * 0.001)

	return steptime
end)

hook.Add("PlayerFootstep", "MEStepSound", function(ply, pos, foot, sound, volume, filter, skipcheck)
	ply:SetStepRight(not ply:GetStepRight())

	if (ply:GetSliding() or CurTime() < ply:GetSafetyRollTime() - 0.5) and not skipcheck then return true end
	if ply:GetMEMoveLimit() < 100 and ply:KeyDown(IN_FORWARD) and not ply.FootstepLand and not IsValid(ply:GetBalanceEntity()) then return true end

	local mat = sound:sub(0, -6)
	local newsound = FOOTSTEPS_LUT[mat]

	if mat == "player/footsteps/ladder" then return end

	newsound = newsound or "Concrete"

	ply.LastStepMat = newsound

	if game.SinglePlayer() then
		ply:SetNW2String("LastStepMat", newsound)
	end

	ply.FootstepReleaseLand = true

	if CLIENT or game.SinglePlayer() then
		ply:EmitSound("Footsteps." .. newsound)
		ply:EmitSound("Cloth.MovementRun")

		if math.random() > 0.9 then
			ParkourEvent("step")
		end
	end

	ply.LastFootstepSound = mat

	if ply:WaterLevel() > 0 then
		ply:EmitSound("Footsteps.Water")
	end

	if ply:InOverdrive() and ply:GetVelocity():Length() > 400 then
		ply:EmitSound("Footsteps.Spark")
	end

	if (CLIENT and IsFirstTimePredicted() or game.SinglePlayer()) and ply.FootstepLand then
		local landsound = FOOTSTEPS_LAND_LUT[mat] or "Concrete"

		ply:EmitSound("Land." .. landsound)

		ply.FootstepLand = false
	end

	hook.Run("PlayerFootstepME", ply, pos, foot, sound, volume, filter)

	return true
end)

hook.Add("OnPlayerHitGround", "MELandSound", function(ply, water, floater, speed)
	local vel = ply:GetVelocity()
	vel.z = 0

	ply.FootstepLand = true
	ply.LastLandTime = CurTime()

	ply:ViewPunch(Angle(3, 0, 1.5) * speed * 0.0025)

	if SERVER and vel:Length() < 100 then
		ply:PlayStepSound(1)
	end

	ParkourEvent("land", ply)

	if ply:GetMelee() == MELEE_DROPKICK and ply:GetMeleeTime() < CurTime() and vel:Length() < 300 then
		if CLIENT and IsFirstTimePredicted() then
			Hardland(false)
		elseif SERVER and game.SinglePlayer() then
			net.Start("Beatrun_HardLand")
				net.WriteBool(false)
			net.Send(ply)
		end
	end

	if not ply:InOverdrive() and speed > 500 and speed < 750 and not ply:GetJumpTurn() and (ply:GetSafetyRollKeyTime() <= CurTime() or ply:GetCrouchJump()) then
		ply:ViewPunch(Angle(10, -2, 5))
		ply:SetMESprintDelay(CurTime() + 0.5)
		ply:SetMEMoveLimit(50)

		local jt = false
		local eyedir = ply:EyeAngles()
		eyedir.x = 0
		eyedir = eyedir:Forward()

		local vel = ply:GetVelocity()
		vel.z = 0

		if ply:GetCrouchJumpTime() < CurTime() and vel:GetNormalized():Dot(eyedir) < -0.75 then
			jt = true

			ply:SetJumpTurn(true)
		end

		if CLIENT and IsFirstTimePredicted() then
			Hardland(jt)
		elseif SERVER and game.SinglePlayer() then
			net.Start("Beatrun_HardLand")
				net.WriteBool(jt)
			net.Send(ply)
		end
	end

	if SERVER and speed >= 500 and ply:GetJumpTurn() then
		local info = DamageInfo()
		local dmg = ply:Health() * 0.1

		if ply:Health() - dmg > 0 then
			info:SetDamage(dmg)
			info:SetDamageType(DMG_FALL)
			info:SetAttacker(game.GetWorld())
			info:SetInflictor(game.GetWorld())

			ply:TakeDamageInfo(info)
		end
	end
end)

hook.Add("SetupMove", "MESetupMove", function(ply, mv, cmd)
	local activewep = ply:GetActiveWeapon()
	local usingrh = IsValid(activewep) and activewep:GetClass() == "runnerhands"
	local ismoving = (mv:KeyDown(IN_FORWARD) or not ply:OnGround() or ply:Crouching()) and not mv:KeyDown(IN_BACK) and ply:Alive() and (mv:GetVelocity():Length() > 50 or ply:GetMantle() ~= 0 or ply:Crouching())

	if (CLIENT or game.SinglePlayer()) and CurTime() > (ply:GetStepRelease() or 0) and ply.FootstepReleaseLand then
		local newsound = FOOTSTEPS_RELEASE_LUT[ply.LastFootstepSound] or "Concrete"

		if ply:WaterLevel() > 0 then
			ply:EmitSound("Release.Water")
		end

		ply:EmitSound("Release." .. newsound)
		ply.FootstepReleaseLand = false
	end

	if not ply:OnGround() and ply:GetClimbing() == 0 and mv:GetVelocity():Length() > 50 then
		ply.FootstepLand = true
	end

	if ply:GetRunSpeed() ~= speed_limit:GetInt() * ply:GetOverdriveMult() then
		ply:SetRunSpeed(speed_limit:GetInt() * ply:GetOverdriveMult())
	end

	if not ply:GetMEMoveLimit() then
		ply:SetMEMoveLimit(speed_limit:GetInt())
		ply:SetMESprintDelay(0)
		ply:SetMEAng(0)
	end

	if ply:KeyDown(IN_WALK) then
		mv:SetForwardSpeed(mv:GetForwardSpeed() * 0.0065)
		mv:SetSideSpeed(mv:GetSideSpeed() * 0.0065)

		ply:SetMEMoveLimit(150)
		ply:SetMESprintDelay(0)
		ply:SetMEAng(0)

		-- mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
	end

	local ang = mv:GetAngles()
	ang[1] = 0
	ang[3] = 0

	local MEAng = math.Truncate(ang:Forward().x, 2)
	local MEAngDiff = math.abs((MEAng - ply:GetMEAng()) * 100)
	local weaponspeed = 150
	local activewep = ply:GetActiveWeapon()

	if IsValid(activewep) and activewep:GetClass() ~= "runnerhands" then
		weaponspeed = speed_limit:GetInt()
	end

	if (ismoving or ply:GetMantle() ~= 0) and ply:GetMESprintDelay() < CurTime() and (cmd:KeyDown(IN_SPEED) or ply:GetMantle() ~= 0 or not ply:OnGround() or (not ply:OnGround() or ply:GetMantle() ~= 0) and mv:GetVelocity().z > -450) then
		local mult = 0.6 + math.abs(ply:GetMEMoveLimit() / (speed_limit:GetInt() - 25) - 1)

		if not ply:InOverdrive() and ply:GetMEMoveLimit() > (speed_limit:GetInt() - 100) then
			mult = mult * 0.35
		end

		if ply:GetMEMoveLimit() < 160 then
			mult = mult * ply:GetMEMoveLimit() / 1000
		end

		ply:SetMEMoveLimit(math.Clamp(ply:GetMEMoveLimit() + mult * ply:GetOverdriveMult() * 2, 0, speed_limit:GetInt() * ply:GetOverdriveMult()))
	elseif not ismoving and (not ply:Crouching() or ply:GetCrouchJump()) or CurTime() < ply:GetMESprintDelay() and ply:OnGround() then
		ply:SetMEMoveLimit(math.Clamp(ply:GetMEMoveLimit() - 40, weaponspeed, speed_limit:GetInt() * ply:GetOverdriveMult()))
	end

	if MEAngDiff > 1.25 and ply:GetWallrun() == 0 then
		local slow = MEAngDiff * 0.75
		ply:SetMEMoveLimit(math.max(ply:GetMEMoveLimit() - slow, 160))
	end

	if ply:OnGround() then
		local stepheight = mv:GetOrigin().z - (ply.LastOrigin or vector_origin).z

		if stepheight > 1.5 then
			ply:SetMEMoveLimit(math.Approach(ply:GetMEMoveLimit(), speed_limit:GetInt() - 75, FrameTime() * 100))
		elseif stepheight < -0.8 then
			ply:SetMEMoveLimit(math.Approach(ply:GetMEMoveLimit(), speed_limit:GetInt() + 75, FrameTime() * 100))
		end
	end

	ply.LastOrigin = mv:GetOrigin()

	if ply:GetSliding() then
		ply:SetMEMoveLimit(150)
		ply:SetMaxSpeed(200)
	end

	mv:SetMaxClientSpeed(ply:GetMEMoveLimit())

	ply:SetMEAng(MEAng)

	if sidestep:GetBool() and usingrh and activewep.GetSideStep and not activewep:GetSideStep() and CurTime() > ply:GetSlidingDelay() - 0.2 and ply:GetClimbing() == 0 and ply:OnGround() and not ply:Crouching() and not cmd:KeyDown(IN_FORWARD) and not cmd:KeyDown(IN_JUMP) and cmd:KeyDown(IN_ATTACK2) then
		if mv:KeyDown(IN_MOVELEFT) then
			activewep:SendWeaponAnim(ACT_TURNLEFT45)
			activewep:SetSideStep(true)

			mv:SetVelocity(cmd:GetViewAngles():Right() * -600)

			ply:ViewPunch(Angle(-3, 0, -4.5))

			ParkourEvent("sidestepleft", ply)

			activewep.SideStepDir = ang:Forward()

			if game.SinglePlayer() then
				ply:PlayStepSound(1)
			end
		elseif mv:KeyDown(IN_MOVERIGHT) then
			activewep:SendWeaponAnim(ACT_TURNRIGHT45)
			activewep:SetSideStep(true)

			mv:SetVelocity(cmd:GetViewAngles():Right() * 600)

			ply:ViewPunch(Angle(-3, 0, 4.5))

			ParkourEvent("sidestepright", ply)

			activewep.SideStepDir = ang:Forward()

			if game.SinglePlayer() then
				ply:PlayStepSound(1)
			end
		end
	elseif usingrh and activewep.GetSideStep and activewep:GetSideStep() then
		local forwarddelta = activewep.SideStepDir:Dot(ang:Forward())

		if forwarddelta > 0.35 then
			ply:SetMEMoveLimit(250)
		end

		if forwarddelta < 0.65 then
			forwarddelta = 1
		else
			forwarddelta = forwarddelta * 0.025
		end

		mv:SetForwardSpeed(mv:GetForwardSpeed() * forwarddelta)
		mv:SetSideSpeed(mv:GetSideSpeed() * math.abs(forwarddelta - 1))

		if mv:KeyPressed(IN_JUMP) and not quakejump:GetBool() and activewep:GetWasOnGround() and not ply:GetJumpTurn() and ply:GetViewModel():GetCycle() < 0.25 then
			local vel = mv:GetVelocity()
			vel:Mul(0.75)
			vel.z = -speed_limit:GetInt() + 25

			mv:SetVelocity(vel)

			activewep:SetWasOnGround(false)
		end
	end
end)

if CLIENT then
	-- local jumpseq = {ACT_VM_HAULBACK, ACT_VM_SWINGHARD}

	hook.Add("CreateMove", "MECreateMove", function(cmd)
		local ply = LocalPlayer()
		local usingrh = ply:UsingRH()
		local hardland = CurTime() < (ply.hardlandtime or 0)

		if hardland and not ply:InOverdrive() then
			cmd:RemoveKey(IN_ATTACK2)
			cmd:SetForwardMove(cmd:GetForwardMove() * 0.01)
			cmd:SetSideMove(cmd:GetSideMove() * 0.01)
		end

		if (ply:InOverdrive() or usingrh and ply:GetMoveType() == MOVETYPE_WALK and not hardland and ply:OnGround()) and not cmd:KeyDown(IN_SPEED) and not ply:GetSliding() and not IsValid(ply:GetBalanceEntity()) then
			cmd:SetButtons(cmd:GetButtons() + IN_SPEED)
		end
	end)

	hook.Add("GetMotionBlurValues", "MEBlur", function(h, v, f, r)
		local ply = LocalPlayer()
		local vel = LocalPlayer():GetVelocity()

		if not ply.blurspeed then
			ply.blurspeed = 0
		end

		if inmantle then
			vel = vector_origin
		end

		if vel:Length() > speed_limit:GetInt() + 75 then
			ply.blurspeed = Lerp(0.001, ply.blurspeed, 0.1)
		elseif ply:GetMantle() == 0 then
			ply.blurspeed = math.Approach(ply.blurspeed, 0, 0.005)
		end

		return h, v, ply.blurspeed, r
	end)
end

MMY = 0
MMX = 0

hook.Add("InputMouseApply", "MouseMovement", function(cmd, x, y)
	MMY = y
	MMX = x

	local ply = LocalPlayer()
	local activewep = ply:GetActiveWeapon()
	local usingrh = ply:UsingRH(activewep)

	if not LocalPlayer():OnGround() or usingrh and activewep.GetSideStep and activewep:GetSideStep() then
		MMX = 0
	end
end)

if CLIENT then
	net.Receive("DoorBashAnim", function()
		ArmInterrupt("doorbash")
		LocalPlayer():CLViewPunch(Angle(1.5, -0.75, 0))
	end)
end