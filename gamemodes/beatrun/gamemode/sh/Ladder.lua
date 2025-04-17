if SERVER and game.SinglePlayer() then
	util.AddNetworkString("Ladder_SPFix")
elseif CLIENT and game.SinglePlayer() then
	net.Receive("Ladder_SPFix", function()
		local ply = LocalPlayer()
		local ang = ply:EyeAngles()
		ang.y = ply:GetLadder():GetAngles().y - 180
		ang.x = 0
		ply.OrigEyeAng = ang

		if not ply:OnGround() then
			DoImpactBlur(10)
		end
	end)
end

local function LadderCheck(ply, mv, cmd, ladder)
	local ladderang = ladder:GetAngles()

	if math.abs(math.AngleDifference(cmd:GetViewAngles().y, ladderang.y - 180)) > 30 then return false end

	local zlevel = mv:GetOrigin().z
	local newpos = ladder:GetPos() + ladderang:Forward() * 19
	newpos.z = zlevel

	ladderang.z = 0
	ladderang.x = 0
	ladderang.y = ladderang.y - 180

	local origin = mv:GetOrigin()

	if CLIENT then
		BodyAnimSetEase(origin)
	elseif game.SinglePlayer() then
		ply:SetNW2Vector("SPBAEase", origin)
		ply:SendLua("BodyAnimSetEase(LocalPlayer():GetNW2Vector('SPBAEase'))")
	end

	if CLIENT and IsFirstTimePredicted() then
		local ang = ply:EyeAngles()
		ang.y = ladder:GetAngles().y - 180
		ang.x = 0
		ply.OrigEyeAng = ang

		if not ply:OnGround() then
			DoImpactBlur(10)
		end
	elseif game.SinglePlayer() then
		net.Start("Ladder_SPFix")
		net.Send(ply)
	end

	ply:SetLadder(ladder)
	ply:SetLadderHeight(zlevel - ladder:GetPos().z)

	local event = ply:OnGround() and "ladderenter" or "ladderenterhang"

	ParkourEvent(event, ply)

	ply:SetLadderStartPos(mv:GetOrigin())
	ply:SetLadderEndPos(newpos)

	mv:SetOrigin(newpos)

	ply:SetLadderEntering(true)
	ply:SetLadderHand(true)
	ply:SetMoveType(MOVETYPE_NOCLIP)
	ply.LadderEnd = false
	ply.LadderHardStart = not ply:OnGround()

	if not ply:OnGround() then
		ply:ViewPunch(Angle(10, 0, 0))
		ply:SetLadderDelay(CurTime() + 0.75)
		ply:SetLadderHand(false)
	else
		ply:SetLadderDelay(CurTime() + 0.25)
	end
end

local function LadderThink(ply, mv, cmd, ladder)
	mv:SetForwardSpeed(0)
	mv:SetSideSpeed(0)

	cmd:ClearMovement()

	if ply:GetLadderEntering() then
		local lerprate = 2

		if ply.LadderHardStart then
			lerprate = 5
		end

		mv:SetOrigin(ply:GetLadderEndPos())

		if ply:GetLadderLerp() >= 1 then
			ply:SetLadderEntering(false)

			return
		end

		ply:SetLadderLerp(math.min(ply:GetLadderLerp() + FrameTime() * lerprate, 1))

		return
	end

	if mv:KeyDown(IN_FORWARD) and ply:GetLadderDelay() < CurTime() and ply:GetLadderHeight() < ladder:GetLadderHeight() then
		local pos = mv:GetOrigin()

		ply:SetLadderDelay(CurTime() + 0.35)
		ply:SetLadderStartPos(pos)

		pos.z = pos.z + 15.75

		ply:SetLadderEndPos(pos)
		ply:SetLadderLerp(0)
		ply:SetLadderHand(not ply:GetLadderHand())
		ply:ViewPunch(Angle(0, 0, ply:GetLadderHand() and -1.5 or 1.5))

		local event = ply:GetLadderHand() and "ladderclimbleft" or "ladderclimbright"

		ParkourEvent(event, ply)

		ply.LadderDown = false
	elseif mv:KeyDown(IN_BACK) and ply:GetLadderDelay() < CurTime() and ply:GetLadderHeight() > 1 then
		local pos = mv:GetOrigin()

		ply:SetLadderDelay(CurTime() + 0.15)
		ply:SetLadderStartPos(pos)

		pos.z = pos.z - (85 + math.min(ply:GetLadderHeight() - 85, 0))

		ply:SetLadderEndPos(pos)
		ply:SetLadderLerp(0)
		ply:SetLadderHand(false)

		if not ply.LadderDown then
			ParkourEvent("ladderclimbdownfast", ply)
		end

		ply.LadderDown = true
	elseif ply.LadderDown and ply:GetLadderDelay() < CurTime() then
		ply.LadderDown = false

		if CLIENT and IsFirstTimePredicted() then
			ply:CLViewPunch(Angle(5, 0, 0))
			BodyAnim:SetSequence("ladderclimbuprighthandstill")
		elseif game.SinglePlayer() then
			ply:ViewPunch(Angle(5, 0, 0))
			ply:SendLua("BodyAnim:SetSequence('ladderclimbuprighthandstill')")
		end
	end

	ply:SetLadderHeight(ply:GetPos().z - ladder:GetPos().z)

	if ladder:GetLadderHeight() <= ply:GetLadderHeight() and not ply.LadderEnd then
		if not ply.LadderTrace then
			ply.LadderTraceOut = {}

			ply.LadderTrace = {
				mask = MASK_SHOT_HULL,
				collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
				maxs = maxs,
				mins = mins,
				output = ply.LadderTraceOut
			}
		end

		local tr = ply.LadderTrace
		local trout = ply.LadderTraceOut

		ply.LadderTrace.start = mv:GetOrigin() + Vector(0, 0, 100) + ladder:GetAngles():Forward() * -35
		ply.LadderTrace.endpos = ply.LadderTrace.start - Vector(0, 0, 150)
		ply.LadderTrace.filter = ply

		util.TraceLine(tr)

		if trout.Hit then
			ply:SetLadderDelay(CurTime() + 4)
			ply:SetLadderLerp(0)
			ply:SetLadderStartPos(mv:GetOrigin())
			ply:SetLadderEndPos(trout.HitPos)
			ply.LadderEnd = true

			local event = ply:GetLadderHand() and "ladderexittoplefthand" or "ladderexittoprighthand"

			ParkourEvent(event, ply)
		end
	end

	if ply:GetLadderLerp() < 1 then
		local lerp = ply:GetLadderLerp()
		local lerprate = 4

		if ply.LadderEnd then
			lerprate = 1.5

			if ply:GetLadderDelay() - CurTime() > 3.7 then
				lerprate = 0.01
			else
				lerprate = math.Clamp(lerprate * lerp * 10, 0.45, 2)

				if lerp < 0.5 then
					if CLIENT and IsFirstTimePredicted() then
						ply:CLViewPunch(Angle(0.5, 0, 0))
					elseif game.SinglePlayer() then
						ply:ViewPunch(Angle(0.5, 0, 0))
					end
				end
			end
		end

		mv:SetOrigin(LerpVector(ply:GetLadderLerp(), ply:GetLadderStartPos(), ply:GetLadderEndPos()))
		ply:SetLadderLerp(math.min(ply:GetLadderLerp() + FrameTime() * lerprate, 1))
	else
		mv:SetOrigin(ply:GetLadderEndPos())

		if ply.LadderEnd then
			ply:SetMoveType(MOVETYPE_WALK)
			ply:SetLadder(nil)
		end
	end

	if mv:KeyDown(IN_DUCK) then
		local ladderangf = ladder:GetAngles():Forward()
		local newpos = mv:GetOrigin()
		local facing = {
			pos = math.Round(ladderangf.x) == 1 and "x" or math.Round(ladderangf.x) == -1 and "x" or math.Round(ladderangf.y) == 1 and "y" or math.Round(ladderangf.y) == -1 and "y",
			num = math.Round(ladderangf.x) == 1 and 40  or math.Round(ladderangf.x) == -1 and -40 or math.Round(ladderangf.y) == 1 and 40  or math.Round(ladderangf.y) == -1 and -40,
		}

		newpos[facing.pos] = mv:GetOrigin()[facing.pos] + facing.num

		mv:SetOrigin(newpos)
		mv:SetVelocity(vector_origin)

		if CLIENT and IsFirstTimePredicted() then
			BodyAnim:SetSequence("jumpfast")
		elseif game.SinglePlayer() then
			ply:SendLua("BodyAnim:SetSequence('jumpfast')")
		end

		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetLadder(nil)

		return
	end

	mv:SetVelocity(vector_origin)
	mv:SetButtons(0)
end

local function Ladder(ply, mv, cmd)
	if not ply.LadderTrace then
		ply.LadderTrace = {}
		ply.LadderTraceOut = {}
		ply.LadderTrace.mask = MASK_PLAYERSOLID
		ply.LadderTrace.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
	end

	if not IsValid(ply:GetLadder()) and not ply:Crouching() then
		local tr = ply.LadderTrace
		tr.output = ply.LadderTraceOut
		tr.start = mv:GetOrigin() + Vector(0, 0, 64)
		tr.endpos = tr.start + cmd:GetViewAngles():Forward() * 100
		tr.filter = ply

		util.TraceLine(tr)

		local eyetr = ply.LadderTraceOut
		local eyetrentity = eyetr.Entity
		local fraction = eyetr.Fraction

		if (fraction or 1) <= 0.35 and eyetrentity:GetClass() == "br_ladder" and ply:GetMoveType() == MOVETYPE_WALK then
			LadderCheck(ply, mv, cmd, eyetrentity)
		end
	end

	if IsValid(ply:GetLadder()) then
		LadderThink(ply, mv, cmd, ply:GetLadder())
	end
end

hook.Add("SetupMove", "Ladder", Ladder)

local ladderang = Angle()
local laddertraceup = Vector(0, 0, 10000)
local laddertracedown = Vector(0, 0, -10000)

function CreateLadder(pos, angy, mul)
	if isvector(pos) and angy then
		ladderang[2] = angy

		if not mul then
			-- local ledgedetect = nil
			maxheight = util.QuickTrace(pos, laddertraceup).HitPos
			maxheight:Sub(ladderang:Forward() * 10)
			maxheight = util.QuickTrace(maxheight, laddertracedown).HitPos.z

			mul = (maxheight - pos.z) / 125 + 0.1
		end

		local ladder = ents.Create("br_ladder")

		pos:Add(ladderang:Forward() * 10)

		ladder:SetPos(pos)
		ladder:SetAngles(ladderang)
		ladder:Spawn()
		ladder:LadderHeight(mul)

		return ladder
	end
end