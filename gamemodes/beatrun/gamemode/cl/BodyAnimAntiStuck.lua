local errorc = Color(255, 25, 25)

local whitelist = {
	c_ladderanim = true
}

local function BodyAnimAntiStuck()
	if not IsValid(BodyAnim) then return end

	local ply = LocalPlayer()

	if not deleteonend and not whitelist[BodyAnimMDLString] and not (fbanims and fbanims[BodyAnimString]) and not ply:GetSliding() and ply:GetWallrun() == 0 then
		RemoveBodyAnim()
		MsgC(errorc, "Removing potentially stuck anim!!\n")
	end
end

hook.Add("Think", "BodyAnimAntiStuck", BodyAnimAntiStuck)
