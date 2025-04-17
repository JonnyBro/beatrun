local punch = Angle(0.5, 0, 0)
local punchland = Angle(10, 0, 0.5)
local punchthink = Angle()

if SERVER then
	util.AddNetworkString("CrouchJumpSP")
elseif CLIENT and game.SinglePlayer() then
	net.Receive("CrouchJumpSP", function()
		local ply = LocalPlayer()

		if ply:GetMoveType() == MOVETYPE_NOCLIP then return end

		if BodyAnimArmCopy then
			BodyAnimCycle = 0
			BodyAnimCrouchLerp = 0
			BodyAnimCrouchLerpZ = ply:GetPos().z - 32

			local ang = ply:EyeAngles()
			ang.x = 0

			ply.OrigEyeAng = ang
			BodyLimitX = 40

			return
		end
	end)
end

hook.Add("SetupMove", "CrouchJump", function(ply, mv, cmd)
	if ply:OnGround() and ply:GetCrouchJumpBlocked() then
		ply:SetCrouchJumpBlocked(false)
	end

	if ply:GetMoveType() == MOVETYPE_NOCLIP then return end

	local activewep = ply:GetActiveWeapon()

	if ply:Alive() and not ply:GetCrouchJumpBlocked() and not IsValid(ply:GetZipline()) and not IsValid(ply:GetLadder()) and ply:GetClimbing() == 0 and not ply:GetJumpTurn() and ply:GetMantle() == 0 and not ply:OnGround() and ply:GetVelocity().z > -350 and ply:GetCrouchJumpTime() < CurTime() and ply:GetWallrun() == 0 and mv:KeyPressed(IN_DUCK) then
		if CLIENT then
			local ang = ply:EyeAngles()
			ang.x = 0
			BodyLimitX = 40
			ply.OrigEyeAng = ang

			if IsFirstTimePredicted() then
				BodyAnimCycle = 0
				BodyAnimCrouchLerp = 0

				if ply:UsingRH() then
					BodyAnimCrouchLerpZ = mv:GetOrigin().z - 32
				else
					BodyAnimCrouchLerpZ = mv:GetOrigin().z
				end
			end
		end

		if game.SinglePlayer() then
			net.Start("CrouchJumpSP")
				net.WriteBool(true)
			net.Send(ply)

			ply:SetNW2Float("BodyAnimCrouchLerpZ", ply:GetPos().z - 32)
		end

		ParkourEvent("coil", ply)

		ply:SetCrouchJump(true)
		ply:SetCrouchJumpTime(CurTime() + 1)
		ply:ViewPunch(punch)
		ply:SetViewOffsetDucked(Vector(0, 0, 28))

		if ply:UsingRH() then
			activewep:SendWeaponAnim(ACT_VM_HOLSTER)
		end
	elseif (ply:OnGround() or ply:GetCrouchJumpTime() < CurTime() or not ply:Alive()) and ply:GetCrouchJump() then
		if game.SinglePlayer() then
			net.Start("CrouchJumpSP")
				net.WriteBool(false)
			net.Send(ply)
		end

		ply:SetCrouchJump(false)

		if ply:UsingRH() then
			activewep:SendWeaponAnim(ACT_VM_DRAW)
		end

		if ply:OnGround() and not ply:GetDive() then
			ply:ViewPunch(punchland)

			local event = "landcoil"

			ParkourEvent(event, ply)
		end

		ply:SetViewOffsetDucked(Vector(0, 0, 32))
		ply:SetCrouchJumpTime(0)
	elseif ply:GetCrouchJump() then
		if CLIENT and IsFirstTimePredicted() then
			local p = CurTime() - ply:GetCrouchJumpTime()

			if ply:GetDive() then
				p = p + 0.5
			end

			punchthink.x = math.max(p + 0.5, -0)

			ply:CLViewPunch(punchthink)
		elseif game.SinglePlayer() then
			local p = CurTime() - ply:GetCrouchJumpTime()

			if ply:GetDive() then
				p = p + 0.5
			end

			punchthink.x = math.max(p + 0.75, -0)

			ply:ViewPunch(punchthink)
		end
	end
end)

hook.Add("CreateMove", "VManipCrouchJumpDuck", function(cmd)
	local ply = LocalPlayer()

	if ply:GetCrouchJump() and ply:GetMoveType() == MOVETYPE_WALK and not ply:OnGround() and not ply:GetDive() then
		cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_DUCK))
	end

	if ply:GetCrouchJumpBlocked() and cmd:KeyDown(IN_DUCK) then
		cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_BULLRUSH))
		cmd:RemoveKey(IN_DUCK)
	end
end)