local IK = BeatrunIK

local handik = CreateClientConVar("Beatrun_HandIK", "1", true, false, "Presses the hands flat against walls when bracing on them")

local armnames = {
	{ "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger2", "ValveBiped.Bip01_L_Finger4" },
	{ "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_R_Finger1", "ValveBiped.Bip01_R_Finger2", "ValveBiped.Bip01_R_Finger4" }
}

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

local function TiltPalm(ent, arm, wx, wy, wz, nx, ny, nz, weight)
	local index, middle, pinky = arm.extra[1], arm.extra[2], arm.extra[3]
	if not index or not middle or not pinky then return end

	local ix, iy, iz = IK.GetBonePos(ent, index)
	local mx, my, mz = IK.GetBonePos(ent, middle)
	local px, py, pz = IK.GetBonePos(ent, pinky)

	if not ix or not mx or not px then return end

	local dx, dy, dz = mx - wx, my - wy, mz - wz
	local ax, ay, az = px - ix, py - iy, pz - iz
	local palmx, palmy, palmz = dy * az - dz * ay, dz * ax - dx * az, dx * ay - dy * ax

	if palmx * nx + palmy * ny + palmz * nz > 0 then
		palmx, palmy, palmz = -palmx, -palmy, -palmz
	end

	local r11, r12, r13, r21, r22, r23, r31, r32, r33 = IK.MinArc(palmx, palmy, palmz, -nx, -ny, -nz, weight, maxpalmtilt)

	IK.MoveBones(ent, arm.endbones, r11, r12, r13, r21, r22, r23, r31, r32, r33, wx, wy, wz, wx, wy, wz)
end

local function ToArmSpace(pos, normal)
	if not viewmapped then return pos, normal end

	local localpos = WorldToLocal(pos, angle_zero, realpos, realang)
	local localnormal = WorldToLocal(normal, angle_zero, vector_origin, realang)

	return LocalToWorld(localpos, angle_zero, armpos, armang), LocalToWorld(localnormal, angle_zero, vector_origin, armang)
end

local function HandIK(ent)
	if FrameNumber() ~= viewframe then return end

	if not ent.ikarms then
		ent.ikarms = {}

		for i, names in ipairs(armnames) do
			ent.ikarms[i] = IK.GetChain(ent, names)
		end
	end

	local pole = viewmapped and -armang:Up() or Vector(0, 0, -1)

	for i, arm in pairs(ent.ikarms) do
		local contact = contacts[i]
		if contact.weight <= 0 then continue end

		local ax, ay, az = IK.GetBonePos(ent, arm.tip)
		if not ax then continue end

		local planepos, planenormal = ToArmSpace(contact.pos, contact.normal)
		local nx, ny, nz = planenormal.x, planenormal.y, planenormal.z
		local dist = (ax - planepos.x) * nx + (ay - planepos.y) * ny + (az - planepos.z) * nz
		local correction = (palmoffset - dist) * contact.weight

		if math.abs(correction) < maxcorrection then
			ax, ay, az = IK.ReachChain(ent, arm, ax + nx * correction, ay + ny * correction, az + nz * correction, pole.x, pole.y, pole.z)

			if ax then
				TiltPalm(ent, arm, ax, ay, az, nx, ny, nz, contact.weight)
			end
		end
	end
end

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

	bac:InvalidateBoneCache()
end

hook.Add("Think", "BeatrunHandIK", function()
	local ft = FrameTime()
	local enabled = handik:GetBool() and IsValid(BodyAnimArmCopy) and not LocalPlayer():ShouldDrawLocalPlayer()

	for _, contact in ipairs(contacts) do
		contact.weight = math.Approach(contact.weight, enabled and contact.want and 1 or 0, ft * 8)
	end
end)
