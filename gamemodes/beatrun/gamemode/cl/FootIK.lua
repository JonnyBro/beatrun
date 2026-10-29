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

-- Knee position for a two-bone chain hip -> knee -> ankle when the ankle has to reach a new target.
-- Keeps the knee in its current bend plane, falls back to bending towards fx/fy/fz when the leg is straight
local function SolveKnee(hx, hy, hz, kx, ky, kz, ax, ay, az, tx, ty, tz, fx, fy, fz)
	local l1 = math.sqrt((kx - hx) ^ 2 + (ky - hy) ^ 2 + (kz - hz) ^ 2)
	local l2 = math.sqrt((ax - kx) ^ 2 + (ay - ky) ^ 2 + (az - kz) ^ 2)

	local ux, uy, uz = tx - hx, ty - hy, tz - hz
	local dist = math.sqrt(ux * ux + uy * uy + uz * uz)

	if dist < 1e-4 then return kx, ky, kz, ax, ay, az end

	ux, uy, uz = ux / dist, uy / dist, uz / dist

	local d = math.Clamp(dist, math.abs(l1 - l2) + 0.01, (l1 + l2) * 0.999)

	local vx, vy, vz = kx - hx, ky - hy, kz - hz
	local along = vx * ux + vy * uy + vz * uz

	vx, vy, vz = vx - ux * along, vy - uy * along, vz - uz * along

	if vx * vx + vy * vy + vz * vz < 1e-4 then
		along = fx * ux + fy * uy + fz * uz
		vx, vy, vz = fx - ux * along, fy - uy * along, fz - uz * along
	end

	local vlen = math.sqrt(vx * vx + vy * vy + vz * vz)

	if vlen < 1e-6 then return kx, ky, kz, ax, ay, az end

	vx, vy, vz = vx / vlen, vy / vlen, vz / vlen

	local x = (l1 * l1 - l2 * l2 + d * d) / (2 * d)
	local h = math.sqrt(math.max(l1 * l1 - x * x, 0))

	return hx + ux * x + vx * h, hy + uy * x + vy * h, hz + uz * x + vz * h, hx + ux * d, hy + uy * d, hz + uz * d
end

-- Left-multiplies the rotation part of m by the shortest rotation taking direction a to direction b, then moves it to px/py/pz
local function RotateBoneTowards(m, ax, ay, az, bx, by, bz, px, py, pz)
	local la = math.sqrt(ax * ax + ay * ay + az * az)
	local lb = math.sqrt(bx * bx + by * by + bz * bz)
	local m11, m12, m13, _, m21, m22, m23, _, m31, m32, m33 = m:Unpack()

	if la > 1e-6 and lb > 1e-6 then
		ax, ay, az = ax / la, ay / la, az / la
		bx, by, bz = bx / lb, by / lb, bz / lb

		local cx, cy, cz = ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx
		local s = math.sqrt(cx * cx + cy * cy + cz * cz)

		if s > 1e-6 then
			local c = ax * bx + ay * by + az * bz
			local t = 1 - c

			cx, cy, cz = cx / s, cy / s, cz / s

			local r11, r12, r13 = t * cx * cx + c, t * cx * cy - s * cz, t * cx * cz + s * cy
			local r21, r22, r23 = t * cx * cy + s * cz, t * cy * cy + c, t * cy * cz - s * cx
			local r31, r32, r33 = t * cx * cz - s * cy, t * cy * cz + s * cx, t * cz * cz + c

			m11, m12, m13, m21, m22, m23, m31, m32, m33 =
				r11 * m11 + r12 * m21 + r13 * m31, r11 * m12 + r12 * m22 + r13 * m32, r11 * m13 + r12 * m23 + r13 * m33,
				r21 * m11 + r22 * m21 + r23 * m31, r21 * m12 + r22 * m22 + r23 * m32, r21 * m13 + r22 * m23 + r23 * m33,
				r31 * m11 + r32 * m21 + r33 * m31, r31 * m12 + r32 * m22 + r33 * m32, r31 * m13 + r32 * m23 + r33 * m33
		end
	end

	m:SetUnpacked(m11, m12, m13, px, m21, m22, m23, py, m31, m32, m33, pz, 0, 0, 0, 1)
end

-- Rotates a bone around a pivot by the shortest rotation taking straight up to the normal nx/ny/nz
local function TiltBone(ent, bone, nx, ny, nz, px, py, pz)
	local m = ent:GetBoneMatrix(bone)
	if not m then return end

	local s = math.sqrt(nx * nx + ny * ny)
	local kx, ky = -ny / s, nx / s
	local c, t = nz, 1 - nz

	local r11, r12, r13 = c + t * kx * kx, t * kx * ky, s * ky
	local r21, r22, r23 = t * kx * ky, c + t * ky * ky, -s * kx
	local r31, r32, r33 = -s * ky, s * kx, c

	local m11, m12, m13, tx, m21, m22, m23, ty, m31, m32, m33, tz = m:Unpack()

	tx, ty, tz = tx - px, ty - py, tz - pz

	m:SetUnpacked(
		r11 * m11 + r12 * m21 + r13 * m31, r11 * m12 + r12 * m22 + r13 * m32, r11 * m13 + r12 * m23 + r13 * m33, px + r11 * tx + r12 * ty + r13 * tz,
		r21 * m11 + r22 * m21 + r23 * m31, r21 * m12 + r22 * m22 + r23 * m32, r21 * m13 + r22 * m23 + r23 * m33, py + r21 * tx + r22 * ty + r23 * tz,
		r31 * m11 + r32 * m21 + r33 * m31, r31 * m12 + r32 * m22 + r33 * m32, r31 * m13 + r32 * m23 + r33 * m33, pz + r31 * tx + r32 * ty + r33 * tz,
		0, 0, 0, 1
	)

	ent:SetBoneMatrix(bone, m)
end

local function GetLegBones(ent)
	local legs = {}

	for i, names in ipairs(legnames) do
		local thigh, calf, foot = ent:LookupBone(names[1]), ent:LookupBone(names[2]), ent:LookupBone(names[3])

		if thigh and calf and foot then
			local footchildren = {}

			for b = 0, ent:GetBoneCount() - 1 do
				local parent = ent:GetBoneParent(b)

				while parent and parent >= 0 do
					if parent == foot then
						footchildren[#footchildren + 1] = b

						break
					end

					parent = ent:GetBoneParent(parent)
				end
			end

			legs[i] = { thigh = thigh, calf = calf, foot = foot, footchildren = footchildren }
		end
	end

	return legs
end

local function FootIK(ent)
	if ikweight <= 0 then return end

	ent.iklegs = ent.iklegs or GetLegBones(ent)

	local fwd = ent:GetAngles():Forward()

	for i, leg in pairs(ent.iklegs) do
		local lift = footlift[i] * ikweight
		local mt, mc, mf = ent:GetBoneMatrix(leg.thigh), ent:GetBoneMatrix(leg.calf), ent:GetBoneMatrix(leg.foot)

		if lift > 0.01 and mt and mc and mf then
			local _, _, _, hx, _, _, _, hy, _, _, _, hz = mt:Unpack()
			local _, _, _, kx, _, _, _, ky, _, _, _, kz = mc:Unpack()
			local _, _, _, ax, _, _, _, ay, _, _, _, az = mf:Unpack()

			local kx2, ky2, kz2, ax2, ay2, az2 = SolveKnee(hx, hy, hz, kx, ky, kz, ax, ay, az, ax, ay, az + lift, fwd.x, fwd.y, fwd.z)

			RotateBoneTowards(mt, kx - hx, ky - hy, kz - hz, kx2 - hx, ky2 - hy, kz2 - hz, hx, hy, hz)
			RotateBoneTowards(mc, ax - kx, ay - ky, az - kz, ax2 - kx2, ay2 - ky2, az2 - kz2, kx2, ky2, kz2)

			mf:SetTranslation(Vector(ax2, ay2, az2))

			ent:SetBoneMatrix(leg.thigh, mt)
			ent:SetBoneMatrix(leg.calf, mc)
			ent:SetBoneMatrix(leg.foot, mf)

			local dx, dy, dz = ax2 - ax, ay2 - ay, az2 - az

			for _, child in ipairs(leg.footchildren) do
				local m = ent:GetBoneMatrix(child)

				if m then
					local _, _, _, cx, _, _, _, cy, _, _, _, cz = m:Unpack()

					m:SetTranslation(Vector(cx + dx, cy + dy, cz + dz))
					ent:SetBoneMatrix(child, m)
				end
			end
		end

		local normal = footnormal[i]
		local nx, ny, nz = normal.x * ikweight, normal.y * ikweight, 1 + (normal.z - 1) * ikweight
		local nlen = math.sqrt(nx * nx + ny * ny + nz * nz)

		mf = ent:GetBoneMatrix(leg.foot)

		if mf and nx * nx + ny * ny > 1e-6 * nlen * nlen then
			nx, ny, nz = nx / nlen, ny / nlen, nz / nlen

			local _, _, _, ax, _, _, _, ay, _, _, _, az = mf:Unpack()

			TiltBone(ent, leg.foot, nx, ny, nz, ax, ay, az)

			for _, child in ipairs(leg.footchildren) do
				TiltBone(ent, child, nx, ny, nz, ax, ay, az)
			end
		end
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

		-- The body drops so the lower foot reaches its ground, the other foot is then lifted by bending its knee
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
