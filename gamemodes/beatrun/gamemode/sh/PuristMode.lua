if CLIENT then
	CreateClientConVar("Beatrun_PuristMode", "1", true, true, language.GetPhrase("beatrun.convars.puristmode"))
end

local PuristModeForce = CreateConVar("Beatrun_PuristModeForce", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "", 0, 1)

local function PuristMove(ply, mv, cmd)
	if not ply:OnGround() and not ply:GetGrappling() and (tobool(ply:GetInfo("Beatrun_PuristMode")) or PuristModeForce:GetBool()) and ply:WaterLevel() == 0 then
		mv:SetForwardSpeed(mv:GetForwardSpeed() * 0.001)
		mv:SetSideSpeed(mv:GetSideSpeed() * 0.001)

		cmd:SetForwardMove(cmd:GetForwardMove() * 0.001)
		cmd:SetSideMove(cmd:GetSideMove() * 0.001)
	end
end

hook.Add("SetupMove", "PuristMove", PuristMove)