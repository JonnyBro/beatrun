local kickglitch = CreateConVar("Beatrun_KickGlitch", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Kickglitch mode. 0: disabled, 1: datae-style (velocity multiplier), 2: Mirror's Edge-style (invisible platform)", 1, 3)

local tr = {}
local tr_result = {}
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

meleedata[5] = {
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

meleedata[6] = {
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

local doors = {
	prop_door_rotating = true,
	func_door_rotating = true
}

local function KeyMelee(ply, mv)
	return mv:KeyPressed(IN_ALT2) or mv:KeyPressed(IN_ATTACK) and ply:UsingRH()
end

local function MeleeType(ply, mv, cmd)
	if IsValid(ply:GetZipline()) or ply:GetGrappling() or IsValid(ply:GetLadder()) then return 0 end

	if ply:GetWallrun() ~= 0 then
		if ply:GetWallrun() == 1 then return ply:GetMelee() end

		ply:SetMelee(ply:GetWallrun() == 3 and MELEE_WRLEFT or MELEE_WRRIGHT)
	elseif not ply:OnGround() then
		local vel = mv:GetVelocity()
		vel.z = 0

		ply:SetMelee(vel:Length() > 100 and MELEE_DROPKICK or MELEE_AIRKICK)
	else
		ply:SetMelee(ply:GetSliding() and MELEE_SLIDEKICK or 0)
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

	if ply.MeleeDir:Length() < 1 then
		ply.MeleeDir = ply:GetAimVector()
	end
end

local function MeleeThink(ply, mv, cmd)
	if ply:GetMeleeTime() <= CurTime() then
		if ply:GetMelee() == MELEE_WRLEFT or ply:GetMelee() == MELEE_WRRIGHT then
			ply.MeleeDir = ply:GetAimVector()
		end

		ply:ViewPunch(meleedata[ply:GetMelee()][5] or angle_zero)
		ply:SetMeleeTime(0)

		tr.start = ply:GetShootPos()
		tr.endpos = ply:GetShootPos() + ply.MeleeDir * 75
		tr.filter = ply
		tr.mins = Vector(-8, -8, ply:OnGround() and -8 or -64)
		tr.maxs = Vector(8, 8, 16)
		tr.output = tr_result
		tr.mask = MASK_SHOT_HULL

		ply:LagCompensation(true)
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)

		util.TraceHull(tr)

		ply:LagCompensation(false)

		if ply:GetMelee() >= 5 then
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
			end

			local ent = tr_result.Entity

			if SERVER and IsValid(ent) and (not ent:IsPlayer() or Course_Name == "" and not GetGlobalBool("GM_INFECTION") and GetConVar("sbox_playershurtplayers"):GetBool()) then
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
						BLEH:SetAngles(Angle(0, 0, 0))
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
				util.ScreenShake(Vector(0, 0, 0), 2.5, 10, 0.25, 0)
			end
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

	if ply:GetMeleeDelay() < CurTime() and ply:GetMelee() ~= 0 and ply:GetMelee() >= 5 and not ply:OnGround() then
		if kickglitch:GetInt() == 2 and mv:KeyDown(IN_JUMP) then
			local vel = mv:GetVelocity()
			vel:Mul(1.25)
			vel.z = 300

			mv:SetVelocity(vel)
		elseif kickglitch:GetInt() == 3 then
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

				timer.Simple(0.3, function() SafeRemoveEntity(platform) end)
			end

			ParkourEvent("jumpslow", ply)
		end
	end

	if ply:GetMeleeDelay() < CurTime() and ply:GetMelee() ~= 0 then
		ply:SetMeleeTime(0)
		ply:SetMelee(0)
	end

	if KeyMelee(ply, mv) and ply:GetMeleeDelay() < CurTime() and ply:GetMeleeTime() == 0 and not ply:GetCrouchJump() and not ply:GetJumpTurn() and ply:GetClimbing() == 0 and ply:GetMantle() == 0 then
		MeleeCheck(ply, mv, cmd)
	end

	if ply:GetMeleeTime() ~= 0 then
		MeleeThink(ply, mv, cmd)
	end
end)