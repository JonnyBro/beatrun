BeatrunIK = BeatrunIK or {}

-- NOTE: Left the comments because big scary math

-- Middle joint position for a two-bone chain root -> mid -> end when the end has to reach a new target.
-- Keeps the joint in its current bend plane, falls back to bending towards px/py/pz when the chain is straight
function BeatrunIK.SolveTwoBone(rx, ry, rz, mx, my, mz, ex, ey, ez, tx, ty, tz, px, py, pz)
	local l1 = math.sqrt((mx - rx) ^ 2 + (my - ry) ^ 2 + (mz - rz) ^ 2)
	local l2 = math.sqrt((ex - mx) ^ 2 + (ey - my) ^ 2 + (ez - mz) ^ 2)

	local ux, uy, uz = tx - rx, ty - ry, tz - rz
	local dist = math.sqrt(ux * ux + uy * uy + uz * uz)

	if dist < 1e-4 then return mx, my, mz, ex, ey, ez end

	ux, uy, uz = ux / dist, uy / dist, uz / dist

	local d = math.Clamp(dist, math.abs(l1 - l2) + 0.01, (l1 + l2) * 0.999)

	local vx, vy, vz = mx - rx, my - ry, mz - rz
	local along = vx * ux + vy * uy + vz * uz

	vx, vy, vz = vx - ux * along, vy - uy * along, vz - uz * along

	if vx * vx + vy * vy + vz * vz < 1e-4 then
		along = px * ux + py * uy + pz * uz
		vx, vy, vz = px - ux * along, py - uy * along, pz - uz * along
	end

	local vlen = math.sqrt(vx * vx + vy * vy + vz * vz)

	if vlen < 1e-6 then return mx, my, mz, ex, ey, ez end

	vx, vy, vz = vx / vlen, vy / vlen, vz / vlen

	local x = (l1 * l1 - l2 * l2 + d * d) / (2 * d)
	local h = math.sqrt(math.max(l1 * l1 - x * x, 0))

	return rx + ux * x + vx * h, ry + uy * x + vy * h, rz + uz * x + vz * h, rx + ux * d, ry + uy * d, rz + uz * d
end

-- Shortest rotation taking direction a to direction b, as a row-major 3x3.
-- Optionally only a fraction of it and no more than maxangle radians
function BeatrunIK.MinArc(ax, ay, az, bx, by, bz, fraction, maxangle)
	local la = math.sqrt(ax * ax + ay * ay + az * az)
	local lb = math.sqrt(bx * bx + by * by + bz * bz)

	if la < 1e-6 or lb < 1e-6 then return 1, 0, 0, 0, 1, 0, 0, 0, 1 end

	ax, ay, az = ax / la, ay / la, az / la
	bx, by, bz = bx / lb, by / lb, bz / lb

	local cx, cy, cz = ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx
	local s = math.sqrt(cx * cx + cy * cy + cz * cz)

	if s < 1e-6 then return 1, 0, 0, 0, 1, 0, 0, 0, 1 end

	local c = ax * bx + ay * by + az * bz

	cx, cy, cz = cx / s, cy / s, cz / s

	if fraction or maxangle then
		local angle = math.min(math.atan2(s, c), maxangle or math.pi) * (fraction or 1)

		c, s = math.cos(angle), math.sin(angle)
	end

	local t = 1 - c

	return t * cx * cx + c, t * cx * cy - s * cz, t * cx * cz + s * cy,
		t * cx * cy + s * cz, t * cy * cy + c, t * cy * cz - s * cx,
		t * cx * cz - s * cy, t * cy * cz + s * cx, t * cz * cz + c
end

-- Moves a bone by x -> q + R(x - p), rotating its orientation by R as well
function BeatrunIK.MoveBone(ent, bone, r11, r12, r13, r21, r22, r23, r31, r32, r33, px, py, pz, qx, qy, qz)
	local m = ent:GetBoneMatrix(bone)
	if not m then return end

	local m11, m12, m13, tx, m21, m22, m23, ty, m31, m32, m33, tz = m:Unpack()

	tx, ty, tz = tx - px, ty - py, tz - pz

	m:SetUnpacked(
		r11 * m11 + r12 * m21 + r13 * m31, r11 * m12 + r12 * m22 + r13 * m32, r11 * m13 + r12 * m23 + r13 * m33, qx + r11 * tx + r12 * ty + r13 * tz,
		r21 * m11 + r22 * m21 + r23 * m31, r21 * m12 + r22 * m22 + r23 * m32, r21 * m13 + r22 * m23 + r23 * m33, qy + r21 * tx + r22 * ty + r23 * tz,
		r31 * m11 + r32 * m21 + r33 * m31, r31 * m12 + r32 * m22 + r33 * m32, r31 * m13 + r32 * m23 + r33 * m33, qz + r31 * tx + r32 * ty + r33 * tz,
		0, 0, 0, 1
	)

	ent:SetBoneMatrix(bone, m)
end

function BeatrunIK.MoveBones(ent, bones, r11, r12, r13, r21, r22, r23, r31, r32, r33, px, py, pz, qx, qy, qz)
	for _, bone in ipairs(bones) do
		BeatrunIK.MoveBone(ent, bone, r11, r12, r13, r21, r22, r23, r31, r32, r33, px, py, pz, qx, qy, qz)
	end
end

function BeatrunIK.GetBonePos(ent, bone)
	local m = ent:GetBoneMatrix(bone)
	if not m then return end

	local _, _, _, x, _, _, _, y, _, _, _, z = m:Unpack()

	return x, y, z
end

local function IsDescendant(ent, bone, ancestor)
	while bone and bone >= 0 do
		if bone == ancestor then return true end

		bone = ent:GetBoneParent(bone)
	end

	return false
end

-- The bone and everything under it
function BeatrunIK.GetSubtree(ent, bone)
	local bones = {}

	for b = 0, ent:GetBoneCount() - 1 do
		if IsDescendant(ent, b, bone) then
			bones[#bones + 1] = b
		end
	end

	return bones
end

-- Rotation by angle radians around the unit axis ax/ay/az, as a row-major 3x3
function BeatrunIK.AxisAngle(ax, ay, az, angle)
	local c, s = math.cos(angle), math.sin(angle)
	local t = 1 - c

	return t * ax * ax + c, t * ax * ay - s * az, t * ax * az + s * ay,
		t * ax * ay + s * az, t * ay * ay + c, t * ay * az - s * ax,
		t * ax * az - s * ay, t * ay * az + s * ax, t * az * az + c
end

-- Looks up a root -> mid -> end chain and splits the root's subtree into what follows each of the three
-- (twist bones go with their segment, fingers and toes with the end), names past the third end up in chain.extra
function BeatrunIK.GetChain(ent, names)
	local root, mid, tip = ent:LookupBone(names[1]), ent:LookupBone(names[2]), ent:LookupBone(names[3])
	if not root or not mid or not tip then return end

	local rootbones, midbones, endbones = {}, {}, {}

	for b = 0, ent:GetBoneCount() - 1 do
		if IsDescendant(ent, b, tip) then
			endbones[#endbones + 1] = b
		elseif IsDescendant(ent, b, mid) then
			midbones[#midbones + 1] = b
		elseif IsDescendant(ent, b, root) then
			rootbones[#rootbones + 1] = b
		end
	end

	local chain = {
		root = root, mid = mid, tip = tip,
		rootbones = rootbones, midbones = midbones, endbones = endbones,
		extra = {}
	}

	for i = 4, #names do
		chain.extra[i - 3] = ent:LookupBone(names[i])
	end

	return chain
end

-- Bends the chain so its end reaches tx/ty/tz, moving every bone of the subtree along.
-- Returns the new end position, which can be short of the target if it is out of reach
function BeatrunIK.ReachChain(ent, chain, tx, ty, tz, px, py, pz)
	local rx, ry, rz = BeatrunIK.GetBonePos(ent, chain.root)
	local mx, my, mz = BeatrunIK.GetBonePos(ent, chain.mid)
	local ex, ey, ez = BeatrunIK.GetBonePos(ent, chain.tip)

	if not rx or not mx or not ex then return end

	local mx2, my2, mz2, ex2, ey2, ez2 = BeatrunIK.SolveTwoBone(rx, ry, rz, mx, my, mz, ex, ey, ez, tx, ty, tz, px, py, pz)

	local u11, u12, u13, u21, u22, u23, u31, u32, u33 = BeatrunIK.MinArc(mx - rx, my - ry, mz - rz, mx2 - rx, my2 - ry, mz2 - rz)
	local l11, l12, l13, l21, l22, l23, l31, l32, l33 = BeatrunIK.MinArc(ex - mx, ey - my, ez - mz, ex2 - mx2, ey2 - my2, ez2 - mz2)

	BeatrunIK.MoveBones(ent, chain.rootbones, u11, u12, u13, u21, u22, u23, u31, u32, u33, rx, ry, rz, rx, ry, rz)
	BeatrunIK.MoveBones(ent, chain.midbones, l11, l12, l13, l21, l22, l23, l31, l32, l33, mx, my, mz, mx2, my2, mz2)
	BeatrunIK.MoveBones(ent, chain.endbones, 1, 0, 0, 0, 1, 0, 0, 0, 1, ex, ey, ez, ex2, ey2, ez2)

	return ex2, ey2, ez2
end
