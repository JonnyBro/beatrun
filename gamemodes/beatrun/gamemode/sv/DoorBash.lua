local doors = {
	["func_door_rotating"] = true,
	["prop_door_rotating"] = true
}

util.AddNetworkString("DoorBashAnim")

hook.Add("PlayerUse", "DoorBash", function(ply, ent)
	if doors[ent:GetClass()] then
		if ply:GetVelocity():Length() < 100 or ply:Crouching() then return end
		if ent.bashdelay and ent.bashdelay > CurTime() then return end
		if ent:GetInternalVariable("m_bLocked") then return end

		local speed = ent:GetInternalVariable("speed")

		if not ent.oldspeed then
			ent.oldspeed = speed
			ent.bashdelay = 0
		end

		net.Start("DoorBashAnim")
		net.Send(ply)

		ent:SetSaveValue("speed", ent.oldspeed * 4)
		ent:Use(ply)
		ent.bashdelay = CurTime() + 1
		ent:SetCycle(1)
		ent:Fire("Lock")

		timer.Simple(1, function()
			if IsValid(ent) then
				ent:SetSaveValue("speed", ent.oldspeed)
				ent:Fire("Unlock")
			end
		end)

		ent:EmitSound("Door.Barge")

		return false
	end
end)