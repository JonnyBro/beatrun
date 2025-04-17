util.AddNetworkString("DisarmStart")
local cvardisarm = CreateConVar("Beatrun_Disarm", 1, FCVAR_ARCHIVE, "", 0, 1)

local function Disarm_Init(ply, victim)
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
	if not cvardisarm:GetBool() then return end

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