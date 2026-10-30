local IK = BeatrunIK

local footik = CreateClientConVar("Beatrun_FootIK", "1", true, false, "Places the feet on stairs and slopes while standing")

local ikanims = {
	stand = true,
	crouchstill = true,
	walktostandleft = true,
	crouchtostandleft = true
}

local legnames = {
	{ "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_L_Foot" },
	{ "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_Foot" }
}

local maxdrop = 18
local maxlift = 24
-- Steeper ground than this (about 45 degrees) is treated as flat for the foot tilt
local mintiltz = 0.7

local ikweight = 0
local footdrop = 0
local footlift = { 0, 0 }
local ground = { 0, 0 }
local footnormal = { Vector(0, 0, 1), Vector(0, 0, 1) }
local groundnormal = Vector()

local trout = {}
local tr = {
	start = Vector(),
	endpos = Vector(),
	mask = MASK_PLAYERSOLID,
	output = trout
}

local function FootIK(ent)
	if ikweight <= 0 then return end

	if not ent.iklegs then
		ent.iklegs = {}

		for i, names in ipairs(legnames) do
			ent.iklegs[i] = IK.GetChain(ent, names)
		end
	end

	local fwd = ent:GetAngles():Forward()

	for i, leg in pairs(ent.iklegs) do
		local lift = footlift[i] * ikweight
		local ax, ay, az = IK.GetBonePos(ent, leg.tip)

		if not ax then continue end

		if lift > 0.01 then
			ax, ay, az = IK.ReachChain(ent, leg, ax, ay, az + lift, fwd.x, fwd.y, fwd.z)

			if not ax then continue end
		end

		local normal = footnormal[i]
		local r11, r12, r13, r21, r22, r23, r31, r32, r33 = IK.MinArc(0, 0, 1, normal.x, normal.y, normal.z, ikweight)

		IK.MoveBones(ent, leg.endbones, r11, r12, r13, r21, r22, r23, r31, r32, r33, ax, ay, az, ax, ay, az)
	end
end

hook.Add("BodyAnimStart", "BeatrunFootIK", function()
	if IsValid(BodyAnim) then
		BodyAnim:AddCallback("BuildBonePositions", FootIK)
	end
end)

hook.Add("Think", "BeatrunFootIK", function()
	local ply = LocalPlayer()
	local ft = FrameTime()

	local active = footik:GetBool() and IsValid(BodyAnim) and ikanims[BodyAnimString] and ply:OnGround() and ply:GetMoveType() == MOVETYPE_WALK and ply:GetVelocity():Length2D() < 60 and not ply:ShouldDrawLocalPlayer()

	ikweight = math.Approach(ikweight, active and 1 or 0, ft * 10)

	if active then
		local origin = ply:GetPos()

		tr.filter = ply

		for i, names in ipairs(legnames) do
			local bone = BodyAnim:LookupBone(names[3])
			local footpos = bone and BodyAnim:GetBonePosition(bone)

			ground[i] = 0
			groundnormal:SetUnpacked(0, 0, 1)

			if footpos then
				tr.start:SetUnpacked(footpos.x, footpos.y, origin.z + maxlift)
				tr.endpos:SetUnpacked(footpos.x, footpos.y, origin.z - maxdrop - 2)

				util.TraceLine(tr)

				if trout.Hit and not trout.StartSolid then
					ground[i] = trout.HitPos.z - origin.z

					if trout.HitNormal.z > mintiltz then
						groundnormal:Set(trout.HitNormal)
					end
				end
			end

			footnormal[i]:Set(LerpVector(1 - math.exp(-ft * 25), footnormal[i], groundnormal))
			footnormal[i]:Normalize()
		end

		local drop = math.Clamp(-math.min(ground[1], ground[2], 0), 0, maxdrop)
		local k = 1 - math.exp(-ft * 25)

		footdrop = Lerp(k, footdrop, drop)
		footlift[1] = Lerp(k, footlift[1], math.Clamp(ground[1] + drop, 0, maxlift))
		footlift[2] = Lerp(k, footlift[2], math.Clamp(ground[2] + drop, 0, maxlift))
	elseif ikweight <= 0 then
		footdrop = 0
		footlift[1], footlift[2] = 0, 0
		footnormal[1]:SetUnpacked(0, 0, 1)
		footnormal[2]:SetUnpacked(0, 0, 1)
	end

	BodyAnimFootDrop = footdrop * ikweight
end)
