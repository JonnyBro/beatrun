Beatrun_NPCs = Beatrun_NPCs or {}
local npctbl = Beatrun_NPCs

hook.Add("OnEntityCreated", "NPCTracker", function(ent)
	if IsValid(ent) and ent:IsNPC() then
		table.insert(Beatrun_NPCs, ent)

		ent.OldProficiency = ent:GetCurrentWeaponProficiency()
		ent.NextProficiency = 0
	end
end)

hook.Add("EntityRemoved", "NPCTracker", function(ent)
	for k, npc in ipairs(npctbl) do
		if not IsValid(npc) then
			table.remove(npctbl, k)
		end
	end
end)

local updaterate = 0.2
local updatetime = 0

hook.Add("Tick", "NPCBehavior", function()
	local CT = CurTime()
	if updatetime > CT then return end

	for k, npc in ipairs(npctbl) do
		if not IsValid(npc) then continue end

		local enemy = npc:GetEnemy()

		if not IsValid(enemy) or not enemy:IsPlayer() then continue end

		if enemy:GetJumpTurn() or enemy:GetSliding() or enemy:GetWallrun() > 0 or enemy:GetVelocity():Length() > 300 then
			npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_POOR)
			npc.NextProficiency = CT + 1
		elseif CT > npc.NextProficiency then
			npc:SetCurrentWeaponProficiency(npc.OldProficiency or WEAPON_PROFICIENCY_GOOD)
		end
	end

	updatetime = CT + updaterate
end)