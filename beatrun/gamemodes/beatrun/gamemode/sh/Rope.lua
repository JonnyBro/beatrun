local yaw = 0
local pitch = 0

hook.Add("CreateMove", "Rope", function(cmd)
	local ply = LocalPlayer()
	local vtl = viewtiltlerp

	if not ply:GetGrappling() or not IsValid(BodyAnim) or not IsValid(BodyAnimArmCopy) then
		pitch = 0
		yaw = 0
		vtl.z = vtl.z ~= 0 and math.Approach(viewtiltlerp.z, 0, FrameTime() * (10 + math.abs(vtl.z) * 5)) or vtl.z

		return
	end

	local ang = LocalPlayer():EyeAngles()
	ang.x = 0

	local grapplepos = LocalPlayer():GetGrapplePos()
	local vel = LocalPlayer():GetVelocity()
	vel.z = 0

	velf = vel:Dot(ang:Forward()) * 80
	velr = vel:Dot(ang:Right()) * 80

	grapplepos.z = 0

	local mul = (grapplepos - LocalPlayer():EyePos()):Dot(ang:Forward()) > 0 and 1 or -1
	grapplepos = vel * mul

	local y = math.Clamp(-grapplepos:Dot(ang:Forward()), -90, 90)
	local p = math.Clamp(-grapplepos:Dot(ang:Right()), -90, 90)

	pitch = Lerp(FrameTime() * 1.5, pitch, p)
	yaw = Lerp(FrameTime() * 1.5, yaw, y)

	BodyAnim:SetPoseParameter("rope_yaw", yaw)
	BodyAnimArmCopy:SetPoseParameter("rope_yaw", yaw)
	BodyAnim:SetPoseParameter("rope_pitch", pitch)
	BodyAnimArmCopy:SetPoseParameter("rope_pitch", pitch)

	viewtiltlerp.z = -pitch * 0.1
end)