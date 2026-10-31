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

local wallruntr = {
	start = Vector(),
	endpos = Vector(),
	mask = MASK_PLAYERSOLID,
	collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
}

-- 2 = wall on the right, 3 = wall on the left
local function WallrunHand(ply)
	local wallrun = ply:GetWallrun()
	if wallrun ~= 2 and wallrun ~= 3 or ply:GetMelee() ~= 0 then return end

	wallruntr.start:Set(ply:GetShootPos())
	wallruntr.endpos:Set(wallruntr.start - ply:GetWallrunDir() * 40)
	wallruntr.filter = ply

	local tr = util.TraceLine(wallruntr)

	if tr.Hit then
		HandIKSetContact(wallrun == 2 and 2 or 1, true, tr.HitPos, tr.HitNormal)
	end
end

local handbones = { "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_R_Hand" }

-- Hanging origin sits this far below the top of the ledge
local hangheight = 77

local hangtr = {
	start = Vector(),
	endpos = Vector(),
	mask = MASK_PLAYERSOLID,
	collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
}

-- On a sloped ledge each hand goes up or down by how much higher the ledge is under it than under the body,
-- so a flat ledge leaves the animation alone. The hands are read from the arm copy (hang anims draw it in the world),
-- BodyAnim's arms are moved away by JumpAnim to hide them
local function IsHanging(ply)
	local climbing = ply:GetClimbing()

	return (climbing == 1 or climbing == 3 or climbing == 4) and IsValid(BodyAnimArmCopy) and IsValid(BodyAnim)
end

local function HangHands(ply)
	local bac = BodyAnimArmCopy
	-- The drawn body's position, smoothed between ticks in multiplayer unlike GetPos
	local top = BodyAnim:GetPos().z + hangheight

	hangtr.filter = ply

	for i, name in ipairs(handbones) do
		local bone = bac:LookupBone(name)
		local pos = bone and bac:GetBonePosition(bone)

		if pos then
			hangtr.start:SetUnpacked(pos.x, pos.y, top + 30)
			hangtr.start:Add(ply:GetClimbingAngle():Forward() * 4)
			hangtr.endpos:Set(hangtr.start)
			hangtr.endpos.z = top - 30

			local tr = util.TraceLine(hangtr)

			if tr.Hit and not tr.StartSolid and tr.HitNormal.z > 0.7 then
				HandIKSetContact(i, true, tr.HitPos, tr.HitNormal, tr.HitPos.z - top)
			else
				HandIKSetContact(i, false)
			end
		else
			HandIKSetContact(i, false)
		end
	end
end

-- Every frame, the hands move while shimmying and a 33 hz update made them step
hook.Add("Think", "HandHangLedge", function()
	local ply = LocalPlayer()

	if IsValid(ply) and IsHanging(ply) then
		HangHands(ply)
	end
end)

hook.Add("Tick", "HandStandWall", function()
	if nextWallCheck > CurTime() then return end -- lets not spam checks
	nextWallCheck = CurTime() + 0.03 -- ~33 hz should be fast enough

	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	-- Hanging hands are handled every frame by HandHangLedge
	if IsHanging(ply) then
		IsPlyInStandWall = false

		return
	end

	HandIKSetContact(1, false)
	HandIKSetContact(2, false)

	WallrunHand(ply)

	if not WallBrace:GetBool() then return end

	local bac = BodyAnimArmCopy
	local bac_seq = IsValid(bac) and bac:GetSequenceName(bac:GetSequence()) or ""
	if ply:GetMelee() ~= 0 or (ArmInterrupting(bac) and not standWallAnims[bac_seq]) or ply:GetSafetyRollTime() > CurTime() or (ply:GetDive() or ply:GetDiveSliding() or string.StartsWith(BodyAnimString, "diveslideend")) then IsPlyInStandWall = false return end

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

		if leftHand_trace.Hit then HandIKSetContact(1, true, leftHand_trace.HitPos, leftHand_trace.HitNormal) end
		if rightHand_trace.Hit then HandIKSetContact(2, true, rightHand_trace.HitPos, rightHand_trace.HitNormal) end

		if not ply:ShouldDrawLocalPlayer() then BodyLimitX = 30 end -- no point in locking the view in thirdperson ¯\_(ツ)_/¯

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
		return 0.8
	end
end)

hook.Add("CreateMove", "HandStandWallBlockAttack", function(cmd)
	if IsValid(BodyAnimArmCopy) and standWallAnims[BodyAnimArmCopy:GetSequenceName(BodyAnimArmCopy:GetSequence())] and not LocalPlayer():ShouldDrawLocalPlayer() then
		cmd:RemoveKey(IN_ATTACK)
	end
end)
