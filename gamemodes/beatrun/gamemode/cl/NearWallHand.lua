local WallBrace = CreateClientConVar("Beatrun_WallBrace", "1", true, false, "", 0, 1)
local IsPlyInStandWall = false

local standWallAnims = {
	standhandwallright = true,
	standhandwallleft = true,
	standhandwallboth = true,
	standhandwallrightdown = true,
	standhandwallleftdown = true,
	standhandwallbothdown = true
}

local down = Vector(0, 0, -3)

local nextWallCheck = 4 -- start out at 4 to prevent any errors when the game boots up ¯\_(ツ)_/¯

hook.Add("Tick", "HandStandWall", function()
	if not WallBrace:GetBool() then return end

	if nextWallCheck > CurTime() then return end -- lets not spam checks
	nextWallCheck = CurTime() + 0.03 -- ~33 hz should be fast enough

	local ply = LocalPlayer()
	local bac = BodyAnimArmCopy
	local bac_seq = IsValid(bac) and bac:GetSequenceName(bac:GetSequence()) or ""
	if not IsValid(ply) or ply:GetMelee() ~= 0 or (ArmInterrupting(bac) and not standWallAnims[bac_seq]) or ply:GetSafetyRollTime() > CurTime() or (ply:GetDive() or ply:GetDiveSliding() or string.StartsWith(BodyAnimString, "diveslideend")) then IsPlyInStandWall = false return end

	local rh = ply:GetActiveWeapon()

	if not ply:OnGround() or ply:InVehicle() or not ply:UsingRH() or ply:GetJumpTurn() or ply:GetWallrun() ~= 0 or ply:GetClimbing() ~= 0 or (rh.GetSideStep and rh:GetSideStep()) then
		IsPlyInStandWall = false

		if standWallAnims[bac_seq] then
			bac:SetCycle(1) -- no time to play the down animations
		end

		return
	end

	local traceDir = ply:EyeAngles()
	traceDir.z = 0
	traceDir.x = 0

	local length = 22.5 -- this is the shortest lenght that works well with corners

	local hand_offset =  traceDir:Right() * 5.5
	traceDir = traceDir:Forward()
	local shoot_pos = ply:GetShootPos()

	local leftHand_trace = util.TraceLine({
		start = shoot_pos - hand_offset + down,
		endpos = (shoot_pos - hand_offset + down) + traceDir * length,
		filter = ply, -- no need to check for other players since u cant get close enough to trigger the hands
		mask = MASK_PLAYERSOLID,
		collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
	})

	local rightHand_trace = util.TraceLine({
		start = shoot_pos + hand_offset + down,
		endpos = (shoot_pos + hand_offset + down) + traceDir * length,
		filter = ply,
		mask = MASK_PLAYERSOLID,
		collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
	})

	if (leftHand_trace.Hit or rightHand_trace.Hit) and not (ply:KeyDown(IN_BACK) and ply:GetVelocity():Length() > 10) and ply:WaterLevel() <= 1 then --TODO: figure out how to get if the player is moving backwards with only the velocity (dont rely on keydown)
		IsPlyInStandWall = true

		if not ply:ShouldDrawLocalPlayer() then BodyLimitX = 10 end -- no point in locking the view in thirdperson ¯\_(ツ)_/¯

		if leftHand_trace.Hit and rightHand_trace.Hit then
			ArmInterrupt("standhandwallboth")
		elseif rightHand_trace.Hit then
			ArmInterrupt("standhandwallright")
		else
			ArmInterrupt("standhandwallleft")
		end
	elseif IsPlyInStandWall then
		if standWallAnims[bac_seq] then
			ArmInterrupt(bac_seq .. "down")
		end
		IsPlyInStandWall = false
	end

	if standWallAnims[bac_seq] and not IsPlyInStandWall and not ply:ShouldDrawLocalPlayer() then
		BodyLimitX = 45
	end
end)

hook.Add("AdjustMouseSensitivity", "HandStandWallSense", function()
	if IsPlyInStandWall and not LocalPlayer():ShouldDrawLocalPlayer() then
		return 0.65
	end
end)

hook.Add("CreateMove", "HandStandWallBlockAttack", function(cmd)
	if IsValid(BodyAnimArmCopy) and standWallAnims[BodyAnimArmCopy:GetSequenceName(BodyAnimArmCopy:GetSequence())] and not LocalPlayer():ShouldDrawLocalPlayer() then
		cmd:RemoveKey(IN_ATTACK)
	end
end)