local stress = 0
local breathin = true
nextbreath = 0

hook.Add("Tick", "BreathingLogic", function()
	local ply = LocalPlayer()

	if not IsValid(ply) or not ply:Alive() or ply:WaterLevel() == 3 then return end

	local vel = ply:GetVelocity()
	local CT = CurTime()
	vel.z = 0
	vel = vel:Length()

	if (vel > 100 or ply:GetClimbing() ~= 0) and (ply:OnGround() or ply:GetWallrun() > 0) then
		stress = stress + 0.2
	elseif ply:OnGround() then
		stress = stress - 0.25
	elseif not breathin then
		return
	end

	stress = math.Clamp(stress, -50, 150)

	if stress == -50 and breathin then return end

	local breathtype = breathin and "In" or "Out"
	local breathstring = stress > 50 and "Medium" or "Soft"
	local breathstringdur = vel > 200 and "Short" or "Long"
	local extradur = 0

	if vel > 200 then
		extradur = math.abs(stress / 150 - 1) * 0.25
	end

	if nextbreath < CT then
		ply:FaithVO("Faith.Breath." .. breathstring .. breathstringdur .. breathtype)
		nextbreath = CT + (vel > 200 and 0.5 or 1.25 + math.random(0, 0.1)) + extradur
		breathin = not breathin
	end
end)