local kickglitch = CreateConVar("Beatrun_KickGlitch", "2", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Kickglitch mode. 0: disabled, 1: datae-style (velocity multiplier), 2: Mirror's Edge-style (invisible platform)", 0, 2)
local dropkick = CreateConVar("Beatrun_Dropkick", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY }, "Attack during a crouch jump to do a dropkick", 0, 1)

local tr = {}
local tr_result = {}

MELEE_JUMPCOILKICK = 7
MELEE_WRRIGHT = 6
MELEE_WRLEFT = 5
MELEE_DROPKICK = 4
MELEE_AIRKICK = 3
MELEE_SLIDEKICK = 2
MELEE_PUNCH = 1

local meleedata = {
	{
		"meleeslide", 0.15, 1, function(ply, mv, cmd)
			ply:CLViewPunch(Angle(2, 0, 0))
		end,
		angle_zero, 20
	},
	{
		"meleeslide", 0.175, 0.6, function(ply, mv, cmd)
			if CLIENT and IsFirstTimePredicted() then
				ply:CLViewPunch(Angle(0.05, 0, -1))
			elseif game.SinglePlayer() then
				ply:ViewPunch(Angle(0.1, 0, -1.5))
			end
		end,
		Angle(-4, 0, 0), 50, true
	},
	{
		"meleeairstill", 0.1, 1, function(ply, mv, cmd)
			if CLIENT and IsFirstTimePredicted() then
				ply:CLViewPunch(Angle(0.5, 0, -0.1))
			elseif game.SinglePlayer() then
				ply:ViewPunch(Angle(1, 0, -0.25))
			end
		end,
		Angle(-15, 0, -5), 50
	},
	{
		"meleeair", 0.15, 1, function(ply, mv, cmd)
			if CLIENT and IsFirstTimePredicted() then
				ply:CLViewPunch(Angle(0.05, 0, -1))
			elseif game.SinglePlayer() then
				ply:ViewPunch(Angle(0.1, 0, -1.5))
			end
		end,
		Angle(-5, 0, -2.5), 50
	}
}

meleedata[MELEE_WRLEFT] = {
	"meleewrleft", 0.2, 0.75, function(ply, mv, cmd)
		if CLIENT and IsFirstTimePredicted() then
			ply:CLViewPunch(Angle(0.075, 0, 1))
		elseif game.SinglePlayer() then
			ply:ViewPunch(Angle(0.1, 0, 1.5))
		end

		ply:SetWallrunTime(0)

		local vel = mv:GetVelocity()
		vel.z = 50

		mv:SetVelocity(vel)

		if CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
			local ang = ply:EyeAngles()
			ang.y = ang.y + (CurTime() - ply:GetMeleeDelay()) / 0.15 * 0.25

			ply:SetEyeAngles(ang)
		end
	end,
	Angle(-5, 0, 2.5), 80
}

meleedata[MELEE_WRRIGHT] = {
	"meleewrright", 0.2, 0.75, function(ply, mv, cmd)
		if CLIENT and IsFirstTimePredicted() then
			ply:CLViewPunch(Angle(0.075, 0, -1))
		elseif game.SinglePlayer() then
			ply:ViewPunch(Angle(0.1, 0, -1.5))
		end

		ply:SetWallrunTime(0)

		local vel = mv:GetVelocity()
		vel.z = 50

		mv:SetVelocity(vel)

		if CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
			local ang = ply:EyeAngles()
			ang.y = ang.y - (CurTime() - ply:GetMeleeDelay()) / 0.15 * 0.25

			ply:SetEyeAngles(ang)
		end
	end,
	Angle(-5, 0, -2.5), 80
}

meleedata[MELEE_JUMPCOILKICK] = {
		"jumpcoilkick", 0.25, 1, function(ply, mv, cmd) -- 2nd value is melee time, 3rd one is melee delay
			if CLIENT and IsFirstTimePredicted() then
				ply:CLViewPunch(Angle(0.05, 0, -1))
			elseif game.SinglePlayer() then
				ply:ViewPunch(Angle(0.1, 0, -1.5))
			end
		end,
		Angle(-5, 0, -2.5), 70
}

local doors = {
	prop_door_rotating = true,
	func_door_rotating = true
}

local function KeyMelee(ply, mv)
	return mv:KeyPressed(IN_ALT2) or mv:KeyPressed(IN_ATTACK) and ply:UsingRH()
end

local function MeleeType(ply, mv, cmd)
	if IsValid(ply:GetZipline()) or ply:GetGrappling() or IsValid(ply:GetLadder())  or IsValid(ply:GetSwingbar()) or ply:GetDive() or ply:InVehicle() or (ply:GetCrouchJump() and not dropkick:GetBool()) then return 0 end

	if ply:GetWallrun() ~= 0 then
		if ply:GetWallrun() == 1 then return ply:GetMelee() end

		ply:SetMelee(ply:GetWallrun() == 3 and MELEE_WRLEFT or MELEE_WRRIGHT)
	elseif not ply:OnGround() then
		local vel = mv:GetVelocity()
		vel.z = 0

		local melee = vel:Length() > 100 and MELEE_DROPKICK or MELEE_AIRKICK

		if ply:GetCrouchJump() and dropkick:GetBool() then
			melee = MELEE_JUMPCOILKICK
			ply:SetCrouchJump(false)
			ply:SetSlidingDelay(CurTime() + 0.4)
		end

		ply:SetMelee(melee)
	else
		ply:SetMelee(ply:GetSliding() and not ply:GetDiveSliding() and MELEE_SLIDEKICK or 0)
	end

	return ply:GetMelee()
end

local function MeleeCheck(ply, mv, cmd)
	local melee = MeleeType(ply, mv, cmd)

	if melee == 0 then return end

	ParkourEvent(meleedata[melee][1], ply)

	ply:SetMeleeTime(CurTime() + meleedata[melee][2])
	ply:SetMeleeDelay(CurTime() + meleedata[melee][3])

	ply.MeleeDir = mv:GetVelocity()
	ply.MeleeDir.z = 0
	ply.MeleeDir:Normalize()

	if ply.MeleeDir:Length() < 1 and not ply:GetSliding() then
		ply.MeleeDir = ply:GetAimVector()
		if melee == MELEE_JUMPCOILKICK  and ply.MeleeDir.z < 0 then ply.MeleeDir.z = 0 end -- makes it harder to hit the ground to cancel the jumpturn landing
	end
end

local function MeleeThink(ply, mv, cmd)
	if ply:GetMeleeTime() <= CurTime() then
		if ply:GetMelee() == MELEE_WRLEFT or ply:GetMelee() == MELEE_WRRIGHT then
			ply.MeleeDir = ply:GetAimVector()
		end

		ply:ViewPunch(meleedata[ply:GetMelee()][5] or angle_zero)
		ply:SetMeleeTime(0)
		local offset = not ply:OnGround() and Vector(0, 0, -10) or vector_origin
		tr.start = ply:GetShootPos() + offset
		tr.endpos = ply:GetShootPos() + ply.MeleeDir * 75  + offset
		tr.filter = ply
		if ply:GetMelee() == MELEE_JUMPCOILKICK then
			tr.mins = Vector(-12, -12, -46)
			tr.maxs = Vector(12, 12, 16)
		else
			tr.mins = Vector(-8, -8, ply:OnGround() and -8 or -64)
			tr.maxs = Vector(8, 8, 11)
		end
		tr.output = tr_result
		tr.mask = MASK_SHOT_HULL

		ply:LagCompensation(true)
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)

		util.TraceHull(tr)

		ply:LagCompensation(false)

		if ply:GetMelee() == 5 or ply:GetMelee() == 6 then
			local vel = mv:GetVelocity()
			-- why is getwallrundir in the thousands?
			vel:Add(ply:GetWallrunDir():GetNormalized() * 0.5 * vel:Length())

			mv:SetVelocity(vel)
		end

		if tr_result.Hit then
			if SERVER then
				ply:EmitSound(meleedata[ply:GetMelee()][7] and "Melee.Foot" or "Melee.Fist")
			end

			if ply:GetMelee() == MELEE_DROPKICK then
				ParkourEvent("meleeairhit", ply)
			elseif ply:GetMelee() == MELEE_JUMPCOILKICK then
				ParkourEvent("jumpcoilkickhit", ply)

				if CLIENT and IsFirstTimePredicted() then -- something to make the jumpcoilkick less OP
					ply.hardlandtime = CurTime() + 1
				elseif game.SinglePlayer() then
					ply:SendLua("LocalPlayer().hardlandtime = CurTime() + 1")
				end

				mv:SetVelocity(-ply.MeleeDir * 90 + Vector(0, 0, 150))
				--mv:SetVelocity(-ply:GetForward * 90 +jumpcoilkick_knockbackUp)
			end

			local ent = tr_result.Entity

			if SERVER and IsValid(ent) and (not ent:IsPlayer() or Course_Name == "" and not GetGlobalBool("GM_INFECTION") and not GetGlobalBool("EM_NoMeleeDamage") and GetConVar("sbox_playershurtplayers"):GetBool()) then
				local d = DamageInfo()
					d:SetDamage(meleedata[ply:GetMelee()][6])
					d:SetAttacker(ply)
					d:SetInflictor(ply)
					d:SetDamageType(DMG_CLUB)
					d:SetDamagePosition(tr.start)
					d:SetDamageForce(ply:EyeAngles():Forward() * 7000)
				ent:TakeDamageInfo(d)

				if SERVER and ent:GetClass() == "func_breakable_surf" then
					ent:Input("Shatter", nil, nil, Vector(0, 0, 250))

					timer.Simple(0, function()
						local BLEH = ents.Create("prop_physics")
						BLEH:SetPos(tr_result.HitPos)
						BLEH:SetAngles(angle_zero)
						BLEH:SetModel("models/props_junk/wood_crate001a.mdl")
						BLEH:SetNoDraw(true)
						BLEH:SetCollisionGroup(COLLISION_GROUP_WORLD)
						BLEH:Spawn()
						BLEH:Activate()

						timer.Simple(0.01, function()
							if BLEH and IsValid(BLEH) then
								BLEH:Remove()
							end
						end)
					end)
				end

				if ent:IsNPC() then
					ent:SetActivity(ACT_FLINCH_HEAD)
					--if ply:GetMelee() == MELEE_JUMPCOILKICK then ent:SetVelocity(ply.MeleeDir * 220 + Vector(0, 0, 50)) end
				end

				if doors[ent:GetClass()] then
					if ent:GetInternalVariable("m_bLocked") then return end

					local speed = ent:GetInternalVariable("speed")

					if not ent.oldspeed then
						ent.oldspeed = speed
						ent.bashdelay = 0
					end

					ent:SetSaveValue("speed", ent.oldspeed * 4)
					ent:Use(ply)
					ent.bashdelay = CurTime() + 1
					ent:SetCycle(1)
					ent:Fire("Lock")

					timer.Simple(1, function()
						if IsValid(ent) then
							ent:SetSaveValue("speed", ent.oldspeed)
							ent:Fire("Unlock")
						end
					end)

					ent:EmitSound("Door.Barge")

					return false
				end
			end

			if game.SinglePlayer() or CLIENT and IsFirstTimePredicted() then
				util.ScreenShake(vector_origin, 2.5, 10, 0.25, 0)
			end
		elseif ply:GetMelee() == MELEE_JUMPCOILKICK then
			ply:SetJumpTurn(true) -- if we dont hit anything we will fall on our back
		end
	else
		meleedata[ply:GetMelee()][4](ply, mv, cmd)
	end
end

hook.Add("SetupMove", "Melee", function(ply, mv, cmd)
	if not ply:Alive() then
		ply:SetMeleeTime(0)
		ply:SetMelee(0)

		return
	end

	if ply:GetMeleeDelay() < CurTime() and ply:GetMelee() ~= 0 and (ply:GetMelee() == 5 or ply:GetMelee() == 6) and not ply:OnGround() then
		if kickglitch:GetInt() == 1 and mv:KeyDown(IN_JUMP) then
			local vel = mv:GetVelocity()
			vel:Mul(1.25)
			vel.z = 300

			mv:SetVelocity(vel)
		elseif kickglitch:GetInt() == 2 then
			if SERVER then
				local platform = ents.Create("prop_physics")

				local pos = ply:GetPos()
				pos.z = pos.z - 8

				platform:SetModel("models/hunter/plates/plate1x1.mdl")
				platform:SetPos(pos)
				platform:SetColor(Color(0, 0, 0, 0))
				platform:SetRenderMode(RENDERMODE_TRANSCOLOR)
				platform:Spawn()

				local phys = platform:GetPhysicsObject()
				phys:EnableMotion(false)

				timer.Simple(.5, function() SafeRemoveEntity(platform) end)
			end

			ParkourEvent("jumpslow", ply)
		end
	end

	if ply:GetMeleeDelay() < CurTime() and ply:GetMelee() ~= 0 then
		ply:SetMeleeTime(0)
		ply:SetMelee(0)
	end

	if KeyMelee(ply, mv) and ply:GetMeleeDelay() < CurTime() and ply:GetMeleeTime() == 0 and not ply:GetJumpTurn() and ply:GetClimbing() == 0 and ply:GetMantle() == 0 and (not ply:GetCrouchJump() or (ply:GetCrouchJumpTime() - CurTime()) > 0.4) then
		MeleeCheck(ply, mv, cmd)
	end

	if ply:GetMeleeTime() ~= 0 then
		MeleeThink(ply, mv, cmd)
	end
end)