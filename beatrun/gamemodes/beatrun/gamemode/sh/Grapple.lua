local disable_grapple = CreateClientConVar("Beatrun_DisableGrapple", 0, true, true, "Disables grapple ability", 0, 1)

if CLIENT then
	local circle = Material("circlesmooth.png", "nocull smooth")

	hook.Add("HUDPaint", "grappleicon", function()
		local ply = LocalPlayer()

		if disable_grapple:GetBool() then return end
		if ply:GetMantle() ~= 0 or ply:GetClimbing() ~= 0 then return end
		if not ply:Alive() or Course_Name ~= "" then return end

		local activewep = ply:GetActiveWeapon()

		if IsValid(activewep) and activewep:GetClass() ~= "runnerhands" then return end
		if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
		if GetGlobalBool("GM_INFECTION") or GetGlobalBool("GM_DATATHEFT") or GetGlobalBool("GM_DEATHMATCH") then return end

		if not ply.GrappleHUD_tr then
			ply.GrappleHUD_tr = {}
			ply.GrappleHUD_trout = {}
			ply.GrappleHUD_tr.output = ply.GrappleHUD_trout
			ply.GrappleHUD_tr.collisiongroup = COLLISION_GROUP_WEAPON
		end

		if ply:GetGrappling() then
			cam.Start3D()
				local w2s = ply:GetGrapplePos():ToScreen()
			cam.End3D()

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(circle)
			surface.DrawTexturedRect(w2s.x - SScaleX(4), w2s.y - SScaleY(4), SScaleX(8), SScaleY(8))

			return
		end

		if ply:EyeAngles().x > -15 or ply:GetWallrun() ~= 0 then return end

		local trout = ply:GetEyeTrace()
		local dist = trout.HitPos:DistToSqr(ply:GetPos())

		if trout.Fraction > 0 and dist < 2750000 and dist > 90000 then
			cam.Start3D()
				local w2s = trout.HitPos:ToScreen()
			cam.End3D()

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(circle)
			surface.DrawTexturedRect(w2s.x - SScaleX(4), w2s.y - SScaleY(4), SScaleX(8), SScaleY(8))
		end
	end)
end

local zpunchstart = Angle(2, 0, 0)

hook.Add("SetupMove", "Grapple", function(ply, mv, cmd)
	if ply:GetMantle() ~= 0 or ply:GetClimbing() ~= 0 then return end
	if ply:GetInfoNum("Beatrun_DisableGrapple", 0) == 1 and Course_Name == "" then return end
	if not ply:Alive() or Course_Name ~= "" and ply:GetNW2Int("CPNum", 1) ~= -1 and not ply:GetNW2Entity("Swingrope"):IsValid() then return end
	if GetGlobalBool("GM_INFECTION") or GetGlobalBool("GM_DATATHEFT") or GetGlobalBool("GM_DEATHMATCH") and not ply:GetNW2Entity("Swingrope"):IsValid() then return end

	local activewep = ply:GetActiveWeapon()
	local usingrh = IsValid(activewep) and activewep:GetClass() == "runnerhands"

	if not ply.Grapple_tr then
		ply.Grapple_tr = {}
		ply.Grapple_trout = {}
		ply.Grapple_tr.output = ply.Grapple_trout
		ply.Grapple_tr.collisiongroup = COLLISION_GROUP_WEAPON
	end

	local grappled = nil

	if not ply:GetGrappling() and ply:GetMelee() == 0 and not ply:OnGround() and ply:GetMoveType() ~= MOVETYPE_NOCLIP and ply:GetSafetyRollKeyTime() < CurTime() and ply:GetWallrun() == 0 and usingrh and cmd:GetViewAngles().x <= -15 then
		local trout = ply:GetEyeTrace()
		local dist = trout.HitPos:DistToSqr(mv:GetOrigin())

		if trout.Fraction > 0 and dist < 2750000 and dist > 90000 and mv:KeyPressed(IN_JUMP) then
			local vel = mv:GetVelocity()
			vel.z = -math.abs(vel.z)

			mv:SetVelocity(vel)

			ply:SetGrapplePos(trout.HitPos)
			ply:SetGrappling(true)
			ply:SetGrappleLength(mv:GetOrigin():Distance(trout.HitPos))
			ply:SetWallrunCount(0)
			ply:SetJumpTurn(false)
			ply:SetCrouchJumpBlocked(false)
			ply:SetNW2Entity("grappleEntity", trout.Entity)
			ply:SetNW2Bool("grappledNonCourse", true)

			if CLIENT_IFTP() or game.SinglePlayer() then
				ply:EmitSound("MirrorsEdge/Gadgets/ME_Magrope_Fire.wav", 40, 100 + math.random(-25, 10))
			end

			ply:ViewPunch(zpunchstart)

			grappled = true

			ply.GrappleLengthOld = ply:GetGrappleLength()
		end
	end

	if ply:GetGrappling() then
		local startshrink = (ply.GrappleLengthOld or 0) - ply:GetGrappleLength() < 200
		local shmovemul = startshrink and 4 or 1

		local pos = mv:GetOrigin()
		local eyepos = mv:GetOrigin()

		local ent = ply:GetNW2Entity("grappleEntity")

		local is_ent_invalid = (ent == NULL or ent == nil) and ply:GetNW2Bool("grappledNonCourse")
		local is_getting_off = (not ply:Alive() or mv:KeyPressed(IN_JUMP) and not grappled and not ply:OnGround() or ply:GetClimbing() ~= 0 or ply:GetMantle() ~= 0 or not usingrh)
		local c_delta = 0
		if not is_ent_invalid then
			c_delta = (ent:GetNWVector("gpos", Vector(0,0,0)) - ent:GetNWVector("glastpos", Vector(0, 0, 0))):Length()
		end

		eyepos.z = eyepos.z + 64

		if is_getting_off or is_ent_invalid or c_delta > 300 then
			if IsValid(ent) and ent ~= NULL then
				ent:SetNWVector("glastpos", nil)
				ent:SetNWVector("gpos", nil)
			end

			ply:SetNW2Bool("grappledNonCourse", false)

			ply:SetGrappling(false)

			if CLIENT_IFTP() or game.SinglePlayer() then
				ply:EmitSound("MirrorsEdge/zipline_detach.wav", 40, 100 + math.random(-25, 10))
			end

			if mv:KeyPressed(IN_JUMP) then
				local ang = cmd:GetViewAngles()
				ang.x = 0
				ang = ang:Forward()
				ang:Mul(200)
				ang.z = 200

				mv:SetVelocity(mv:GetVelocity() * 0.5 + ang)

				ply:SetNW2Entity("Swingrope", nil)
			end

			ParkourEvent("jump", ply)

			table.Empty(ply.ZiplineTraceOut)

			return
		end

		if ply:GetNW2Bool("grappledNonCourse") and ent:GetClass() ~= "worldspawn" then
			ent:SetNWVector("glastpos", ent:GetNWVector("gpos", ent:GetPos()))
			ent:SetNWVector("gpos", ent:GetPos())

			local delta = ent:GetNWVector("gpos", Vector(0,0,0)) - ent:GetNWVector("glastpos", Vector(0, 0, 0))
			ply:SetGrapplePos(ply:GetGrapplePos() + delta)
		end

		if mv:KeyDown(IN_ATTACK) and mv:GetOrigin().z < ply:GetGrapplePos().z - 64 then
			ply:SetGrappleLength(ply:GetGrappleLength() - FrameTime() * 100)
		elseif mv:KeyDown(IN_ATTACK2) then
			ply:SetGrappleLength(ply:GetGrappleLength() + FrameTime() * 100)
		end

		if startshrink then
			ply:SetGrappleLength(ply:GetGrappleLength() - FrameTime() * 250)
		end

		-- local vel = mv:GetVelocity()
		local ang = cmd:GetViewAngles()
		ang.x = 0

		local fmove = ang:Forward() * mv:GetForwardSpeed() * 6e-05 * shmovemul
		local smove = ang:Right() * mv:GetSideSpeed() * 2.5e-05 * shmovemul
		local newvel = fmove + smove
		local gposd = ply:GetGrapplePos()
		local posd = mv:GetOrigin()

		gposd.z = 0
		posd.z = 0
		newvel.z = gposd:Distance(posd) / ply:GetGrappleLength() * 5

		mv:SetVelocity(mv:GetVelocity() + newvel)

		if ply:GetGrappleLength() < ply:GetGrapplePos():Distance(pos) then
			local tr = ply.Grapple_tr
			local trout = ply.Grapple_trout

			tr.start = mv:GetOrigin()

			tr.endpos = mv:GetOrigin()

			local mins, maxs = ply:GetHull()
			mins:Mul(1.01)
			maxs:Mul(1.01)

			tr.mins = mins
			tr.maxs = maxs
			tr.filter = ply
			tr.output = trout

			util.TraceHull(tr)

			local vel = pos - ply:GetGrapplePos()
			vel:Normalize()

			if not trout.Hit then
				mv:SetOrigin(mv:GetOrigin() - vel * (ply:GetGrapplePos():Distance(pos) - ply:GetGrappleLength() - 10))
			end

			mv:SetVelocity(mv:GetVelocity() - vel * (ply:GetGrapplePos():Distance(pos) - ply:GetGrappleLength()))
		end

		if startshrink then
			mv:SetVelocity(mv:GetVelocity() + Vector(0, 0, 2.5))
		end

		if mv:GetOrigin().z > ply:GetGrapplePos().z - 64 then
			mv:SetVelocity(mv:GetVelocity() - Vector(0, 0, 10))
		end
	end
end)

local cablemat = Material("cable/cable2")
local ropetop = Vector()
local ropelerp = 0
local ropedown = Vector(0, 0, 20)

hook.Add("PostDrawTranslucentRenderables", "GrappleBeam", function()
	local lp = LocalPlayer()

	if lp:GetGrappling() then
		local BA = BodyAnimArmCopy

		if lp:ShouldDrawLocalPlayer() then
			BA = BodyAnim
		end

		if not IsValid(BA) then return end

		BA:SetupBones()

		local rhand = BA:LookupBone("ValveBiped.Bip01_R_Finger41")
		local lhand = BA:LookupBone("ValveBiped.Bip01_L_Finger21")

		if BA:GetBoneMatrix(rhand) == nil then return end

		local rhandpos = BA:GetBoneMatrix(rhand):GetTranslation()
		if not rhandpos then return end

		rhandpos:Sub(BA:GetRight() * 2.5)

		local lhandpos = BA:GetBoneMatrix(lhand):GetTranslation()

		ropetop:Set(lhandpos)

		render.SetMaterial(cablemat)
		render.StartBeam(2)

		local up = (rhandpos - lhandpos):Angle():Forward()
		up:Mul(20)

		rhandpos:Add(up)

		render.DrawBeam(LerpVector(ropelerp, lhandpos - ropedown, rhandpos), lhandpos, 1.5, 0, 1)
		render.DrawBeam(ropetop, lp:GetGrapplePos(), 1.5, 0, 1)

		BodyAnim:SetSequence("grapplecenter")

		ropelerp = math.Approach(ropelerp, 1, FrameTime() * 2)
	else
		ropelerp = 0
	end

	for i, ply in ipairs(player.GetAll()) do
		if ply == lp then continue end

		if ply:GetGrappling() then
			local pos = ply:GetPos()
			pos.z = pos.z + 32
			render.DrawBeam(pos, ply:GetGrapplePos(), 1.5, 0, 1)
		end
	end
end)

function CreateSwingrope(startpos, length)
	if startpos and length then
		local swingrope = ents.Create("br_swingrope")

		swingrope:SetStartPos(startpos)
		swingrope:SetEndPos(startpos - Vector(0, 0, length))
		swingrope:Spawn()

		return swingrope
	end
end

local function Swingrope(ply, mv, cmd)
	if not ply.ZiplineTrace then return end

	if not IsValid(ply:GetZipline()) and not ply:GetGrappling() and not ply:Crouching() and not ply:OnGround() and ply:GetZiplineDelay() < CurTime() then
		local trout = ply.ZiplineTraceOut
		local trentity = trout.Entity

		if IsValid(trentity) and trentity:GetClass() == "br_swingrope" and ply:GetMoveType() == MOVETYPE_WALK then
			local vel = mv:GetVelocity()
			local startpos = trentity:GetStartPos()
			local endpos = trentity:GetEndPos()
			local bestpos = endpos.z < startpos.z and startpos or endpos

			vel.z = -math.abs(vel.z)

			mv:SetVelocity(vel)

			ply:SetGrapplePos(bestpos)
			ply:SetGrappling(true)
			ply:SetGrappleLength(mv:GetOrigin():Distance(bestpos))
			ply:SetWallrunCount(0)
			ply:SetJumpTurn(false)

			ply.GrappleLengthOld = ply:GetGrappleLength() + 200

			ply:SetZiplineDelay(CurTime() + 0.25)
			ply:SetCrouchJumpBlocked(true)
			ply:SetNW2Entity("Swingrope", trentity)

			local eyeang = cmd:GetViewAngles()

			vel.z = 0
			eyeang.x = 0

			mv:SetVelocity(eyeang:Forward() * vel:Length() * 0.85 + vel * 0.65)
		end
	end
end

hook.Add("SetupMove", "Swingrope", Swingrope)