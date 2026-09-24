util.AddNetworkString("DisarmStart")

-- Not the best method to filter out imcompatible NPC rigs.
-- Feel free to replace this with something less janky.
local IgnoreDisarm = {
"npc_antlionguard",
"npc_antlion",
"npc_antlion_worker",
"npc_barnacle",
"npc_vortigaunt",
"npc_headcrab",
"npc_headcrab_fast",
"npc_headcrab_black",
"npc_crow",
"npc_pigeon",
"npc_seagull",
"npc_dog",
"npc_combinedropship",
"npc_combinegunship",
"npc_rollermine",
"npc_manhack",
"npc_hunter",
"npc_helicopter",
"npc_strider",
"npc_combine_camera",
"npc_cscanner",
"npc_clawscanner",
"npc_rocket_turret",
"npc_portal_turret_floor",
"npc_security_camera",
"npc_turret_ceiling",
"npc_turret_floor"}

local function Disarm_Init(ply, victim)
	if ply:GetSliding() or ply:GetWallrun() > 0 or ply:GetDive() or not ply:OnGround() then return end -- prevents animation bugs and lua errors

	victim:NextThink(CurTime() + 100)

	victim.InDisarm = true

	victim:DropWeapon()

	net.Start("DisarmStart")
		net.WriteEntity(victim)
	net.Send(ply)

	timer.Simple(1.35, function()
		if IsValid(victim) then
			victim:TakeDamage(victim:Health())
		end
	end)
end

local function Disarm(ply, ent)
	if not GetConVar("Beatrun_Disarm"):GetBool() then return end

  if table.HasValue(IgnoreDisarm,ent:GetClass()) then return end

	if ent:IsNPC() and not ent.InDisarm then
		if ply:KeyPressed(IN_USE) then
			Disarm_Init(ply, ent)
		end
	end
end

hook.Add("PlayerUse", "Disarm", Disarm)

hook.Add("CreateEntityRagdoll", "Disarm_Ragdoll", function(ent, rag)
	if ent.InDisarm then
		rag:Remove()
	end
end)
