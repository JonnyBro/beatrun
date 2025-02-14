if CLIENT then
	QuickturnGround = CreateClientConVar("Beatrun_QuickturnGround", "0", true, true, language.GetPhrase("beatrun.convars.quickturnground"), 0, 1)
	QuickturnHandsOnly = CreateClientConVar("Beatrun_QuickturnHandsOnly", "1", true, true, language.GetPhrase("beatrun.convars.quickturnhandsonly"), 0, 1)
end

function DoJumpTurn(lookbehind)
	if not LocalPlayer():Alive() then return end

	if VMLegs and VMLegs:IsActive() then
		VMLegs:Remove()
	end

	BodyAnim:SetSequence("jumpturnfly")

	BodyAnimCycle = 0
	BodyAnimSpeed = 1
	BodyLimitX = 40
	BodyLimitY = 75

	if lookbehind then
		local vel = LocalPlayer():GetVelocity()
		vel:Normalize()
		vel.z = 0

		local ang = vel:Angle()
		ang:RotateAroundAxis(Vector(0, 0, 1), 180)

		BodyAnim:SetAngles(ang)

		LocalPlayer().OrigEyeAng = ang
	end
end

function DoJumpTurnStand()
	if not LocalPlayer():Alive() then return end

	if VMLegs and VMLegs:IsActive() then
		VMLegs:Remove()
	end

	if not LocalPlayer():UsingRH() then
		BodyAnim:SetSequence("jumpturnlandstandgun")
	else
		BodyAnim:SetSequence("jumpturnlandstand")

		ParkourEvent("jumpturnlandstand", LocalPlayer(), game.SinglePlayer())
	end

	BodyAnimCycle = 0
	BodyLimitX = 40
	BodyLimitY = 75
end

local standpunch = Angle(-5, 0, 0)

local function Quickturn(ply, mv, cmd)
	local keypressed = ply:Alive() and mv:KeyPressed(IN_ATTACK2) and (ply:GetInfoNum("Beatrun_QuickturnHandsOnly", 0) == 1 and ply:UsingRH() or ply:GetInfoNum("Beatrun_QuickturnHandsOnly", 0) == 0)

	if ply:GetWallrun() ~= 0 then
		if mv:KeyDown(IN_BACK) and mv:KeyPressed(IN_JUMP) or ply:GetQuickturn() then
			keypressed = true

			if ply:GetWallrun() == 4 and not ply:GetQuickturn() then
				keypressed = false
			end
		end

		if mv:KeyPressed(IN_JUMP) and (mv:KeyDown(IN_MOVELEFT) or mv:KeyDown(IN_MOVERIGHT)) then
			keypressed = true

			ply.vwrturn = mv:KeyDown(IN_MOVERIGHT) and 1 or -1

			local eyeang = cmd:GetViewAngles()
			eyeang.x = 0

			ply.vwrdot = -ply:GetWallrunDir():Dot(eyeang:Forward())
			ply:SetWallrunTime(CurTime())
			ply:SetQuickturn(true)
			ply:SetQuickturnTime(CurTime())
			ply:SetQuickturnAng(cmd:GetViewAngles())
		end
	end

	if not ply:GetQuickturn() and not ply:GetJumpTurn() and not ply:GetCrouchJump() and not ply:GetGrappling() and not ply:GetSliding() and keypressed and not mv:KeyDown(IN_MOVELEFT) and not mv:KeyDown(IN_MOVERIGHT) and (ply:GetWallrun() > 0 or not ply:OnGround() or ply:GetInfoNum("Beatrun_QuickturnGround", 0) == 1 and not ply:Crouching()) then
		if ply:GetWallrun() == 0 and not ply:OnGround() then
			local eyedir = cmd:GetViewAngles()
			eyedir.x = 0
			eyedir = eyedir:Forward()

			local vel = mv:GetVelocity()
			vel.z = 0

			local lookahead = vel:GetNormalized():Dot(eyedir) >= 0.85
			local lookbehind = vel:GetNormalized():Dot(eyedir) < -0.5

			if not lookahead and not lookbehind and ply:WaterLevel() < 3 and not IsValid(ply:GetSwingbar()) and not IsValid(ply:GetZipline()) then
				return
			elseif (lookahead or lookbehind) and ply:WaterLevel() < 3 and not IsValid(ply:GetSwingbar()) and not IsValid(ply:GetZipline()) then
				if CLIENT and IsFirstTimePredicted() then
					DoJumpTurn(lookbehind)
				elseif game.SinglePlayer() then
					ply:SendLua("DoJumpTurn(" .. tostring(lookbehind) .. ")")
				end

				ply:SetJumpTurn(true)

				if lookbehind then return end

				ply:ViewPunch(Angle(2.5, 0, 5))
			end

			if IsValid(ply:GetSwingbar()) then
				ply:SetSBDir(not ply:GetSBDir())
				ply:SetSBOffset(math.abs(ply:GetSBOffset() - 100))
				ply:SetSBPeak(0)
			end
		end

		if not ply:UsingRH() and ply:GetWallrun() >= 2 then return end

		ply:SetQuickturn(true)
		ply:SetQuickturnTime(CurTime())
		ply:SetQuickturnAng(cmd:GetViewAngles())

		if ply:GetWallrun() == 1 then
			ply:SetWallrun(4)
			ply:SetWallrunTime(CurTime() + 0.75)

			if CLIENT and IsFirstTimePredicted() then
				BodyLimitX = 90
				BodyLimitY = 180
				BodyAnimCycle = 0
				BodyAnimSpeed = 2
				BodyAnim:SetSequence("wallrunverticalturn")
			elseif game.SinglePlayer() then
				ply:SendLua("BodyLimitX=90 BodyLimitY=180 BodyAnimCycle=0 BodyAnim:SetSequence(\"wallrunverticalturn\")")
			end

			local activewep = ply:GetActiveWeapon()

			if ply:UsingRH() then
				activewep:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				activewep:SetBlockAnims(true)
			end
		end
	end

	if ply:GetJumpTurn() then
		mv:SetForwardSpeed(0)
		mv:SetSideSpeed(0)
		mv:SetUpSpeed(0)

		if not ply:OnGround() then
			mv:SetButtons(bit.bor(mv:GetButtons(), IN_FORWARD))
		end

		if ply:OnGround() or ply:GetMoveType() == MOVETYPE_NOCLIP then
			ply:SetViewOffsetDucked(Vector(0, 0, 17))
			ply:SetViewOffset(Vector(0, 0, 64))
		else
			ply:SetViewOffset(Vector(0, 0, 17))
		end

		if (ply:OnGround() or ply:WaterLevel() >= 3) and (mv:KeyPressed(IN_JUMP) or mv:KeyPressed(IN_FORWARD)) or ply:GetMoveType() == MOVETYPE_NOCLIP or not ply:Alive() then
			ply:SetJumpTurn(false)
			ply:SetJumpTurnRecovery(CurTime() + 1)
			ply:SetViewOffsetDucked(Vector(0, 0, 32))

			if CLIENT then
				DoJumpTurnStand()
			elseif game.SinglePlayer() then
				ply:SendLua("DoJumpTurnStand()")
			end
		end

		if ply:OnGround() then
			mv:SetButtons(bit.bor(mv:GetButtons(), IN_DUCK))
		end
	end

	if CurTime() < ply:GetJumpTurnRecovery() then
		mv:SetForwardSpeed(0)
		mv:SetSideSpeed(0)
		mv:SetUpSpeed(0)
		mv:SetButtons(0)

		cmd:ClearMovement()

		if not ply:OnGround() and ply:GetMoveType() ~= MOVETYPE_NOCLIP and ply:WaterLevel() < 3 then
			ply:SetJumpTurn(true)
		end

		standpunch.x = -math.abs(math.min(CurTime() - ply:GetJumpTurnRecovery() + 0.5, 0))

		if not ply:UsingRH() then
			standpunch.x = standpunch.x * 0.1
			standpunch.z = standpunch.x * 10
		else
			standpunch.x = standpunch.x * 15
			standpunch.z = 0
		end

		if CLIENT and IsFirstTimePredicted() then
			ply:CLViewPunch(standpunch)
		elseif game.SinglePlayer() then
			ply:ViewPunch(standpunch)
		end
	end

	if ply:GetQuickturn() then
		local wr = ply:GetWallrun()
		local target = ply:GetQuickturnAng()
		local dir = wr == 2 and 1 or -1

		if ply.vwrturn ~= 0 then
			target.y = target.y - 90 * ply.vwrturn * ply.vwrdot
		else
			target.y = target.y + ((wr == 2 or wr == 3) and 115 * dir or 180)
		end

		local diff = CurTime() - ply:GetQuickturnTime()
		local lerptime = diff * 6.5
		local lerp = Lerp(math.min(lerptime, 1), ply:GetQuickturnAng().y, target.y)

		target.y = lerp

		if CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
			ply:SetEyeAngles(target)
		end

		if lerptime >= 1 then
			ply:SetQuickturn(false)
		end
	else
		ply.vwrturn = 0
	end
end

hook.Add("SetupMove", "Quickturn", Quickturn)