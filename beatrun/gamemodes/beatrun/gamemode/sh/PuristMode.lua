if CLIENT then
	PuristMode = CreateClientConVar("Beatrun_PuristMode", "1", true, true, "Purist mode is a clientside preference that severely weakens the ability to strafe while in the air, which is how Mirror's Edge games handle this.\n0 = No restrictions\n1 = Reduced move speed in the air", 0, 1)
end

local PuristModeForce = CreateConVar("Beatrun_PuristModeForce", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Force players to adhere to purist rules", 0, 1)

local function PuristMove(ply, mv, cmd)
	if not ply:OnGround() and not ply:GetGrappling() then
		local purist = PuristMode:GetBool()

		if (purist or PuristModeForce:GetBool()) and ply:WaterLevel() == 0 then
			mv:SetForwardSpeed(mv:GetForwardSpeed() * 0.001)
			mv:SetSideSpeed(mv:GetSideSpeed() * 0.001)

			cmd:SetForwardMove(cmd:GetForwardMove() * 0.001)
			cmd:SetSideMove(cmd:GetSideMove() * 0.001)
		end
	end
end

hook.Add("SetupMove", "PuristMove", PuristMove)