local handik = CreateClientConVar("Beatrun_HandIK", "1", true, false, "Presses the hands flat against walls when bracing on them")

-- upper arm, forearm, hand, then index, middle and pinky finger bases (used to find which way the palm faces)
local armnames = {
	{ "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger2", "ValveBiped.Bip01_L_Finger4" },
	{ "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_R_Finger1", "ValveBiped.Bip01_R_Finger2", "ValveBiped.Bip01_R_Finger4" }
}

-- Hand bone sits at the wrist, this keeps it off the wall by roughly the palm thickness
local palmoffset = 2
local maxcorrection = 16
local maxpalmtilt = math.rad(60)

local contacts = {
	{ want = false, weight = 0, pos = Vector(), normal = Vector() },
	{ want = false, weight = 0, pos = Vector(), normal = Vector() }
}

local viewframe = -1
local viewmapped = false
local realpos, realang = Vector(), Angle()
local armpos, armang = Vector(), Angle()

-- hand: 1 = left, 2 = right
function HandIKSetContact(hand, want, pos, normal)
	local contact = contacts[hand]

	contact.want = want

	if want then
		contact.pos:Set(pos)
		contact.normal:Set(normal)
	end
end

local function SolveElbow(sx, sy, sz, ex, ey, ez, ax, ay, az, tx, ty, tz, px, py, pz)
	local l1 = math.sqrt((ex - sx) ^ 2 + (ey - sy) ^ 2 + (ez - sz) ^ 2)
	local l2 = math.sqrt((ax - ex) ^ 2 + (ay - ey) ^ 2 + (az - ez) ^ 2)

	local ux, uy, uz = tx - sx, ty - sy, tz - sz
	local dist = math.sqrt(ux * ux + uy * uy + uz * uz)

	if dist < 1e-4 then return ex, ey, ez, ax, ay, az end

	ux, uy, uz = ux / dist, uy / dist, uz / dist

	local d = math.Clamp(dist, math.abs(l1 - l2) + 0.01, (l1 + l2) * 0.999)

	local vx, vy, vz = ex - sx, ey - sy, ez - sz
	local along = vx * ux + vy * uy + vz * uz

	vx, vy, vz = vx - ux * along, vy - uy * along, vz - uz * along

	if vx * vx + vy * vy + vz * vz < 1e-4 then
		along = px * ux + py * uy + pz * uz
		vx, vy, vz = px - ux * along, py - uy * along, pz - uz * along
	end

	local vlen = math.sqrt(vx * vx + vy * vy + vz * vz)

	if vlen < 1e-6 then return ex, ey, ez, ax, ay, az end

	vx, vy, vz = vx / vlen, vy / vlen, vz / vlen

	local x = (l1 * l1 - l2 * l2 + d * d) / (2 * d)
	local h = math.sqrt(math.max(l1 * l1 - x * x, 0))

	return sx + ux * x + vx * h, sy + uy * x + vy * h, sz + uz * x + vz * h, sx + ux * d, sy + uy * d, sz + uz * d
end

-- Shortest rotation taking direction a to direction b, as a row-major 3x3.
-- Optionally only a fraction of it and no more than maxangle radians
local function MinArc(ax, ay, az, bx, by, bz, fraction, maxangle)
	local la = math.sqrt(ax * ax + ay * ay + az * az)
	local lb = math.sqrt(bx * bx + by * by + bz * bz)

	if la < 1e-6 or lb < 1e-6 then return 1, 0, 0, 0, 1, 0, 0, 0, 1 end

	ax, ay, az = ax / la, ay / la, az / la
	bx, by, bz = bx / lb, by / lb, bz / lb

	local cx, cy, cz = ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx
	local s = math.sqrt(cx * cx + cy * cy + cz * cz)

	if s < 1e-6 then return 1, 0, 0, 0, 1, 0, 0, 0, 1 end

	local c = ax * bx + ay * by + az * bz

	if fraction or maxangle then
		local angle = math.min(math.atan2(s, c), maxangle or math.pi) * (fraction or 1)

		cx, cy, cz = cx / s, cy / s, cz / s
		c, s = math.cos(angle), math.sin(angle)
	else
		cx, cy, cz = cx / s, cy / s, cz / s
	end

	local t = 1 - c

	return t * cx * cx + c, t * cx * cy - s * cz, t * cx * cz + s * cy,
		t * cx * cy + s * cz, t * cy * cy + c, t * cy * cz - s * cx,
		t * cx * cz - s * cy, t * cy * cz + s * cx, t * cz * cz + c
end

-- Moves a bone by x -> q + R(x - p), rotating its orientation by R as well
local function MoveBone(ent, bone, r11, r12, r13, r21, r22, r23, r31, r32, r33, px, py, pz, qx, qy, qz)
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

local function IsDescendant(ent, bone, ancestor)
	while bone and bone >= 0 do
		if bone == ancestor then return true end

		bone = ent:GetBoneParent(bone)
	end

	return false
end

-- Splits each upper arm subtree into what follows the upper arm, the forearm (twist bones included) and the hand
local function GetArmBones(ent)
	local arms = {}

	for i, names in ipairs(armnames) do
		local upper, fore, hand = ent:LookupBone(names[1]), ent:LookupBone(names[2]), ent:LookupBone(names[3])

		if upper and fore and hand then
			local upperbones, forebones, handbones = {}, {}, {}

			for b = 0, ent:GetBoneCount() - 1 do
				if IsDescendant(ent, b, hand) then
					handbones[#handbones + 1] = b
				elseif IsDescendant(ent, b, fore) then
					forebones[#forebones + 1] = b
				elseif IsDescendant(ent, b, upper) then
					upperbones[#upperbones + 1] = b
				end
			end

			arms[i] = {
				upper = upper, fore = fore, hand = hand,
				index = ent:LookupBone(names[4]), middle = ent:LookupBone(names[5]), pinky = ent:LookupBone(names[6]),
				upperbones = upperbones, forebones = forebones, handbones = handbones
			}
		end
	end

	return arms
end

-- Turns the hand around the wrist so the palm lies flat on the wall. The palm normal comes from the finger bases,
-- with the side facing the wall taken as the palm, so no knowledge of the hand bone's local axes is needed
local function TiltPalm(ent, arm, wx, wy, wz, nx, ny, nz, weight)
	if not arm.index or not arm.middle or not arm.pinky then return end

	local mi, mm, mp = ent:GetBoneMatrix(arm.index), ent:GetBoneMatrix(arm.middle), ent:GetBoneMatrix(arm.pinky)
	if not mi or not mm or not mp then return end

	local _, _, _, ix, _, _, _, iy, _, _, _, iz = mi:Unpack()
	local _, _, _, mx, _, _, _, my, _, _, _, mz = mm:Unpack()
	local _, _, _, px, _, _, _, py, _, _, _, pz = mp:Unpack()

	local dx, dy, dz = mx - wx, my - wy, mz - wz
	local ax, ay, az = px - ix, py - iy, pz - iz
	local palmx, palmy, palmz = dy * az - dz * ay, dz * ax - dx * az, dx * ay - dy * ax

	if palmx * nx + palmy * ny + palmz * nz > 0 then
		palmx, palmy, palmz = -palmx, -palmy, -palmz
	end

	local r11, r12, r13, r21, r22, r23, r31, r32, r33 = MinArc(palmx, palmy, palmz, -nx, -ny, -nz, weight, maxpalmtilt)

	for _, bone in ipairs(arm.handbones) do
		MoveBone(ent, bone, r11, r12, r13, r21, r22, r23, r31, r32, r33, wx, wy, wz, wx, wy, wz)
	end
end

-- Contacts are in world space, but the first person arms are drawn from their own camera inside cam.Start3D
local function ToArmSpace(pos, normal)
	if not viewmapped then return pos, normal end

	local localpos = WorldToLocal(pos, angle_zero, realpos, realang)
	local localnormal = WorldToLocal(normal, angle_zero, vector_origin, realang)

	return LocalToWorld(localpos, angle_zero, armpos, armang), LocalToWorld(localnormal, angle_zero, vector_origin, armang)
end

local function HandIK(ent)
	if FrameNumber() ~= viewframe then return end

	ent.ikarms = ent.ikarms or GetArmBones(ent)

	local pole = viewmapped and -armang:Up() or Vector(0, 0, -1)

	for i, arm in pairs(ent.ikarms) do
		local contact = contacts[i]
		local ms, me, ma = ent:GetBoneMatrix(arm.upper), ent:GetBoneMatrix(arm.fore), ent:GetBoneMatrix(arm.hand)

		if contact.weight > 0 and ms and me and ma then
			local planepos, planenormal = ToArmSpace(contact.pos, contact.normal)

			local _, _, _, sx, _, _, _, sy, _, _, _, sz = ms:Unpack()
			local _, _, _, ex, _, _, _, ey, _, _, _, ez = me:Unpack()
			local _, _, _, ax, _, _, _, ay, _, _, _, az = ma:Unpack()

			local nx, ny, nz = planenormal.x, planenormal.y, planenormal.z
			local dist = (ax - planepos.x) * nx + (ay - planepos.y) * ny + (az - planepos.z) * nz
			local correction = (palmoffset - dist) * contact.weight

			if math.abs(correction) < maxcorrection then
				local ex2, ey2, ez2, ax2, ay2, az2 = SolveElbow(sx, sy, sz, ex, ey, ez, ax, ay, az, ax + nx * correction, ay + ny * correction, az + nz * correction, pole.x, pole.y, pole.z)

				local u11, u12, u13, u21, u22, u23, u31, u32, u33 = MinArc(ex - sx, ey - sy, ez - sz, ex2 - sx, ey2 - sy, ez2 - sz)
				local f11, f12, f13, f21, f22, f23, f31, f32, f33 = MinArc(ax - ex, ay - ey, az - ez, ax2 - ex2, ay2 - ey2, az2 - ez2)

				for _, bone in ipairs(arm.upperbones) do
					MoveBone(ent, bone, u11, u12, u13, u21, u22, u23, u31, u32, u33, sx, sy, sz, sx, sy, sz)
				end

				for _, bone in ipairs(arm.forebones) do
					MoveBone(ent, bone, f11, f12, f13, f21, f22, f23, f31, f32, f33, ex, ey, ez, ex2, ey2, ez2)
				end

				for _, bone in ipairs(arm.handbones) do
					MoveBone(ent, bone, 1, 0, 0, 0, 1, 0, 0, 0, 1, ax, ay, az, ax2, ay2, az2)
				end

				TiltPalm(ent, arm, ax2, ay2, az2, nx, ny, nz, contact.weight)
			end
		end
	end
end

-- Called by JumpArmDraw right before the arm copy sets up its bones for drawing.
-- Without a real view it means the arms are in world space (worldarm anims)
function HandIKBeginArms(bac, viewpos, viewang, drawpos, drawang)
	if contacts[1].weight <= 0 and contacts[2].weight <= 0 then return end

	viewmapped = viewpos ~= nil

	if viewmapped then
		realpos:Set(viewpos)
		realang:Set(viewang)
		armpos:Set(drawpos)
		armang:Set(drawang)
	end

	viewframe = FrameNumber()

	if not bac.handikcallback then
		bac.handikcallback = bac:AddCallback("BuildBonePositions", HandIK)
	end

	-- The copy may already have set up its bones this frame (e.g. for its eyes attachment), which would skip the callback
	bac:InvalidateBoneCache()
end

hook.Add("Think", "BeatrunHandIK", function()
	local ft = FrameTime()
	local enabled = handik:GetBool() and IsValid(BodyAnimArmCopy) and not LocalPlayer():ShouldDrawLocalPlayer()

	for _, contact in ipairs(contacts) do
		contact.weight = math.Approach(contact.weight, enabled and contact.want and 1 or 0, ft * 8)
	end
end)
