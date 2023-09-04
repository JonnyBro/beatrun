local dircache = nil

hook.Add("PlayerFootstepME", "Balance", function(ply, pos, foot, sound, volume, filter, skipcheck)
	if IsValid(ply:GetBalanceEntity()) then return end

	if not ply.BalanceTrace then
		ply.BalanceTrace = {}
		ply.BalanceTraceOut = {}
		ply.BalanceTrace.mask = MASK_PLAYERSOLID
		ply.BalanceTrace.output = ply.BalanceTraceOut
		ply.BalanceTrace.mins, ply.BalanceTrace.maxs = ply:GetHull()
		ply.BalanceTraceOut.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
	end

	local tr = ply.BalanceTrace
	local trout = ply.BalanceTraceOut

	tr.filter = ply
	tr.start = pos
	tr.endpos = pos - Vector(0, 0, 25)

	util.TraceHull(tr)

	if trout.Entity.Balance then
		ply:SetBalance(0.1)
		ply:SetBalanceEntity(trout.Entity)

		timer.Simple(0, function()
			ParkourEvent("walkbalancefwd", ply)
		end)

		if CLIENT then
			BodyAnimSetEase(ply:GetPos())
		elseif game.SinglePlayer() then
			ply:SetNW2Vector("SPBAEase", ply:GetPos())
			ply:SendLua("BodyAnimSetEase(LocalPlayer():GetNW2Vector('SPBAEase'))")
		end
	end
end)

hook.Add("SetupMove", "Balance", function(ply, mv, cmd)
	if IsValid(ply:GetBalanceEntity()) then
		local balance = ply:GetBalanceEntity()

		mv:SetForwardSpeed(math.max(mv:GetForwardSpeed() * 0.01, 0))

		local _, nearest, distlen = util.DistanceToLine(balance:GetPos(), balance:GetPos() + balance:GetAngles():Up() * balance:GetBalanceLength(), mv:GetOrigin())
		local distend = balance:GetPos():Distance(balance:GetPos() + balance:GetAngles():Up() * balance:GetBalanceLength())

		nearest.z = mv:GetOrigin().z

		mv:SetOrigin(nearest)
		mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))

		cmd:RemoveKey(IN_JUMP)

		local tr = ply.BalanceTrace
		tr.start = mv:GetOrigin()
		tr.endpos = tr.start - Vector(0, 0, 50)
		tr.filter = ply

		util.TraceLine(tr)

		if mv:KeyDown(IN_MOVELEFT) then
			ply:SetBalance(math.Clamp(ply:GetBalance() - FrameTime() * (60 + math.abs(ply:GetBalance())), -100, 100))
		elseif mv:KeyDown(IN_MOVERIGHT) then
			ply:SetBalance(math.Clamp(ply:GetBalance() + FrameTime() * (60 + math.abs(ply:GetBalance())), -100, 100))
		end

		mv:SetSideSpeed(0)

		if mv:KeyPressed(IN_FORWARD) then
			ParkourEvent("walkbalancefwd", ply)
		elseif not mv:KeyDown(IN_FORWARD) and mv:GetVelocity():Length() > 0 then
			ParkourEvent("walkbalancestill", ply)
		end

		if CLIENT and IsFirstTimePredicted() and mv:KeyPressed(IN_ATTACK2) then
			dircache.y = dircache.y - 180
		end

		local mult = mv:KeyDown(IN_FORWARD) and 50 or 200

		if math.abs(ply:GetBalance()) < 5 then
			mult = mult * 0.1
		end

		if math.abs(ply:GetBalance()) > 60 then
			mult = mult * 2
		end

		ply:SetBalance(math.Clamp(ply:GetBalance() + ply:GetBalance() / mult, -100, 100))

		local out = ply.BalanceTraceOut

		if out.Entity ~= balance and not out.Entity:IsPlayer() or distlen < 25 or distend < distlen + 30 or math.abs(ply:GetBalance()) >= 100 then
			ParkourEvent("fall", ply)

			if math.abs(ply:GetBalance()) >= 100 then
				if CLIENT then
					BodyAnimSetEase(mv:GetOrigin())
				elseif game.SinglePlayer() then
					ply:SetNW2Vector("SPBAEase", mv:GetOrigin())
					ply:SendLua("BodyAnimSetEase(LocalPlayer():GetNW2Vector('SPBAEase'))")
				end

				ParkourEvent(ply:GetBalance() > 0 and "walkbalancefalloffright" or "walkbalancefalloffleft", ply)

				local bang = ply:GetBalanceEntity():GetAngles()
				local tr = ply.BalanceTrace
				local trout = ply.BalanceTraceOut
				local ang = cmd:GetViewAngles()
				ang.x = 0

				if ang:Forward():Dot(bang:Up()) > 0.5 then
					local fallpos = mv:GetOrigin() + ply:GetBalanceEntity():GetAngles():Right() * 0.75 * ply:GetBalance()

					tr.start = fallpos
					tr.endpos = fallpos

					util.TraceHull(tr)

					if not trout.Hit then
						mv:SetOrigin(fallpos)
					else
						mv:SetOrigin(mv:GetOrigin() - Vector(0, 0, 100))
					end
				else
					local fallpos = mv:GetOrigin() + ply:GetBalanceEntity():GetAngles():Right() * -0.75 * ply:GetBalance()

					tr.start = fallpos
					tr.endpos = fallpos

					util.TraceHull(tr)

					if not trout.Hit then
						mv:SetOrigin(fallpos)
					else
						mv:SetOrigin(mv:GetOrigin() - Vector(0, 0, 100))
					end
				end
			end

			ply:SetBalanceEntity(nil)
			ply:SetMEMoveLimit(150)
		end
	elseif ply:KeyDown(IN_WALK) and ply:OnGround() and mv:GetVelocity():Length() >= 65 then
		hook.GetTable().PlayerFootstepME.Balance(ply, mv:GetOrigin())
	end
end)

local angy = 0
local attack2 = false

hook.Add("CreateMove", "Balance", function(cmd)
	local ply = LocalPlayer()

	if IsValid(ply:GetBalanceEntity()) and IsValid(BodyAnim) then
		local ang = cmd:GetViewAngles()
		local bang = dircache or ply:GetBalanceEntity():GetAngles()

		if not dircache then
			local angx = ang.x
			ang.x = 0

			if ang:Forward():Dot(bang:Up()) > 0.5 then
				bang:RotateAroundAxis(bang:Right(), 180)
			end

			ang.x = angx
			dircache = bang
		end

		if game.SinglePlayer() then
			if cmd:KeyDown(IN_ATTACK2) and not attack2 then
				dircache.y = dircache.y - 180
				attack2 = true
			elseif not cmd:KeyDown(IN_ATTACK2) then
				attack2 = false
			end
		end

		angy = math.ApproachAngle(angy, bang.y, FrameTime() * 150)
		ang.y = angy

		cmd:SetViewAngles(ang)

		BodyAnim:SetPoseParameter("lean_roll", math.Clamp(ply:GetBalance(), -60, 60))

		if IsValid(BodyAnimArmCopy) then
			BodyAnimArmCopy:SetPoseParameter("lean_roll", math.Clamp(ply:GetBalance(), -60, 60))
		end

		local moving = ply:KeyDown(IN_FORWARD)

		if ply:GetVelocity():Length() == 0 and BodyAnimString == "walkbalancefwd" then
			BodyAnim:SetSequence("walkbalancestill")
		end

		if ply:GetBalance() >= 60 and moving then
			BodyAnim:SetSequence("walkbalancelosebalanceright")
		elseif ply:GetBalance() <= -60 and moving then
			BodyAnim:SetSequence("walkbalancelosebalanceleft")
		elseif BodyAnim:GetSequence() == BodyAnim:LookupSequence("walkbalancelosebalanceleft") or BodyAnim:GetSequence() == BodyAnim:LookupSequence("walkbalancelosebalanceright") then
			if moving then
				BodyAnim:SetSequence("walkbalancefwd")
			else
				BodyAnim:SetSequence("walkbalancestill")
			end
		elseif BodyAnimString:Left(5) ~= "walkb" then
			BodyAnim:SetSequence("walkbalancefwd")
		end

		BodyLimitX = 90
		lockang2 = true
	else
		if IsValid(BodyAnim) and BodyAnim:GetSequence() == BodyAnim:LookupSequence("walkbalancefwd") then
			BodyAnim:SetSequence("runfwd")
		end

		if lockang2 then
			viewtiltlerp.z = BodyAnimEyeAng.z
		end

		angy = cmd:GetViewAngles().y
		lockang2 = false
		dircache = nil
	end
end)