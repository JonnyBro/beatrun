local errorc = Color(255, 25, 25)

local whitelist = {
	c_ladderanim = true
}

local whitelistanims = fbanims

local function BodyAnimAntiStuck()
	if not IsValid(BodyAnim) then return end

	local ply = LocalPlayer()

	if not deleteonend and not whitelist[BodyAnimMDLString] and not whitelistanims[BodyAnimString] and not ply:GetSliding() and ply:GetWallrun() == 0 then
		RemoveBodyAnim()
		MsgC(errorc, "Removing potentially stuck anim!!\n")
	end
end

hook.Add("Think", "PacketLossFix", BodyAnimAntiStuck)