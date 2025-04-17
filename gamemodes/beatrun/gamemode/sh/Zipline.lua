if SERVER and game.SinglePlayer() then
	util.AddNetworkString("Zipline_SPFix")
elseif CLIENT and game.SinglePlayer() then
	net.Receive("Zipline_SPFix", function()
		local ply = LocalPlayer()
		local zipline = ply:GetZipline()

		if not IsValid(zipline) then return end

		local startpos = zipline:GetStartPos()
		local endpos = zipline:GetEndPos()

		if net.ReadBool() then
			local startp = startpos
			startpos = endpos
			endpos = startp
		end

		ply.OrigEyeAng = (endpos - startpos):Angle()
	end)
end

local function ZiplineCheck(ply, mv, cmd, zipline)
	local startpos = zipline:GetStartPos()
	local endpos = zipline:GetEndPos()

	if zipline:GetTwoWay() and cmd:GetViewAngles():Forward():Dot((endpos - startpos):Angle():Forward()) < 0.5 then
		local startp = startpos
		startpos = endpos
		endpos = startp

		ply.ZiplineTwoWay = true
	else
		ply.ZiplineTwoWay = false
	end

	local _, near = util.DistanceToLine(startpos, endpos, mv:GetOrigin())
	local neardist = near:Distance(endpos)
	local totaldist = startpos:Distance(endpos)
	local start = math.abs(neardist / totaldist - 1)

	if start < 1 then
		local tr = ply.ZiplineTrace
		local trout = ply.ZiplineTraceOut
		local omins = tr.mins
		local omaxs = tr.maxs

		tr.start = LerpVector(start, startpos, endpos)
		tr.endpos = tr.start
		tr.mins, tr.maxs = ply:GetHull()

		util.TraceHull(tr)

		if trout.Hit and trout.Entity ~= zipline then
			local div = startpos:Distance(endpos)
			local fail = true

			for _ = 1, 32 do
				start = start + 25 / div
				tr.start = LerpVector(start, startpos, endpos)
				tr.endpos = tr.start
				util.TraceHull(tr)

				if not trout.Hit or trout.Entity == zipline and start < 1 then
					fail = false
					break
				end
			end

			if fail then
				tr.maxs = omaxs
				tr.mins = omins

				ply:SetZiplineDelay(CurTime() + 0.1)

				return
			end
		end

		tr.maxs = omaxs
		tr.mins = omins

		local origin = mv:GetOrigin()

		if CLIENT then
			BodyAnimSetEase(origin)
		elseif game.SinglePlayer() then
			ply:SetNW2Vector("SPBAEase", origin)
			ply:SendLua("BodyAnimSetEase(LocalPlayer():GetNW2Vector('SPBAEase'))")
		end

		mv:SetOrigin(near)
		ply:SetJumpTurn(false)
		ply:SetZipline(zipline)
		ply:SetZiplineStart(start)
		ply:SetZiplineFraction(start)
		ply:SetDive(false)
		ply:SetCrouchJump(false)
		ply:SetWallrunCount(0)

		local vel = mv:GetVelocity()
		vel.z = 0

		ply:SetZiplineSpeed(math.min(vel:Length(), 750))
		ply:SetCrouchJumpBlocked(false)

		if CLIENT and IsFirstTimePredicted() then
			ply.OrigEyeAng = (endpos - startpos):Angle()
		elseif game.SinglePlayer() then
			net.Start("Zipline_SPFix")
				net.WriteBool(ply.ZiplineTwoWay)
			net.Send(ply)
		end

		if CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
			ply:EmitSound("ZiplineLoop")
			ply:EmitSound("ZiplineStart")
		end

		ParkourEvent("ziplinestart", ply)
	end
end

-- local zipvec = Vector(0, 0, 85)

local function ZiplineThink(ply, mv, cmd, zipline)
	local fraction = ply:GetZiplineFraction()
	local speed = ply:GetZiplineSpeed()
	local startpos = zipline:GetStartPos()
	local endpos = zipline:GetEndPos()
	local dir = (endpos - startpos):Angle():Forward()

	if zipline:GetTwoWay() and ply.ZiplineTwoWay then
		local startp = startpos
		startpos = endpos
		endpos = startp

		dir:Mul(-1)
	end

	if fraction >= 1 or cmd:KeyDown(IN_DUCK) then
		ply:SetZipline(nil)
		ply:SetMoveType(MOVETYPE_WALK)

		mv:SetVelocity(dir * speed * 0.75)

		ply:SetZiplineDelay(CurTime() + 0.75)

		if CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
			ply:EmitSound("ZiplineEnd")
			ply:StopSound("ZiplineLoop")

			if game.SinglePlayer() then
				ply:SendLua("viewtiltlerp.z = BodyAnimEyeAng.z")
			else
				viewtiltlerp.z = BodyAnimEyeAng.z
			end
		end

		return
	end

	local newfraction = math.Approach(fraction, 1, FrameTime() * speed / startpos:Distance(endpos))

	ply:SetZiplineFraction(newfraction)

	local ziplerp = LerpVector(newfraction, startpos, endpos)
	ziplerp:Sub(zipline:GetUp() * 75)

	local tr = ply.ZiplineTrace
	local trout = ply.ZiplineTraceOut
	local omins = tr.mins
	local omaxs = tr.maxs

	tr.start = ziplerp
	tr.endpos = ziplerp
	tr.mins, tr.maxs = ply:GetHull()

	util.TraceHull(tr)

	if trout.Hit and trout.Entity ~= zipline and newfraction > 0.1 then
		ply:SetZipline(nil)
		ply:SetMoveType(MOVETYPE_WALK)

		mv:SetVelocity(dir * speed * 0.75)

		ply:SetZiplineDelay(CurTime() + 0.75)

		if CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
			ply:EmitSound("ZiplineEnd")
			ply:StopSound("ZiplineLoop")

			if game.SinglePlayer() then
				ply:SendLua("viewtiltlerp.z = BodyAnimEyeAng.z")
			else
				viewtiltlerp.z = BodyAnimEyeAng.z
			end
		end

		tr.maxs = omaxs
		tr.mins = omins

		return
	end

	tr.maxs = omaxs
	tr.mins = omins

	mv:SetOrigin(ziplerp)

	ply:SetZiplineSpeed(math.Approach(speed, 750, FrameTime() * 250))

	mv:SetVelocity(dir * speed)
	mv:SetButtons(0)
	mv:SetForwardSpeed(0)
	mv:SetSideSpeed(0)
	mv:SetUpSpeed(0)
end

local function Zipline(ply, mv, cmd)
	if not ply.ZiplineTrace then
		ply.ZiplineTrace = {}
		ply.ZiplineTraceOut = {}

		local tr = ply.ZiplineTrace
		local mins, maxs = ply:GetHull()

		mins.z = maxs.z * 0.8
		maxs.z = maxs.z * 2
		mins:Mul(2)
		maxs:Mul(2)
		mins.z = mins.z * 0.5
		maxs.z = maxs.z * 0.5

		tr.maxs = maxs
		tr.mins = mins
		ply.ZiplineTrace.mask = MASK_PLAYERSOLID
		ply.ZiplineTrace.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
	end

	if not IsValid(ply:GetZipline()) and not ply:GetGrappling() and (not ply:Crouching() or ply:GetDive()) and not ply:OnGround() and ply:GetZiplineDelay() < CurTime() then
		local tr = ply.ZiplineTrace
		local trout = ply.ZiplineTraceOut

		tr.output = trout
		tr.start = mv:GetOrigin()
		tr.endpos = tr.start
		tr.filter = ply

		util.TraceHull(tr)
		local trentity = trout.Entity

		if IsValid(trentity) and trentity:GetClass() == "br_zipline" and ply:GetMoveType() == MOVETYPE_WALK then
			ZiplineCheck(ply, mv, cmd, trentity)
		end
	end

	if IsValid(ply:GetZipline()) then
		ZiplineThink(ply, mv, cmd, ply:GetZipline())
	end
end

hook.Add("SetupMove", "Zipline", Zipline)

function CreateZipline(startpos, endpos)
	if startpos and endpos then
		local zipline = ents.Create("br_zipline")

		zipline:SetStartPos(startpos)
		zipline:SetEndPos(endpos)
		zipline:Spawn()

		return zipline
	end
end

if CLIENT then
	hook.Add("Think", "ZiplineSoundFix", function()
		if not IsValid(LocalPlayer():GetZipline()) then
			LocalPlayer():StopSound("ZiplineLoop")
		end
	end)
end
