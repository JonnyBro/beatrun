util.AddNetworkString("Eventmode_SetSpawn")
util.AddNetworkString("Eventmode_ToggleVar")
util.AddNetworkString("Eventmode_BringMembers")
util.AddNetworkString("Eventmode_TeleportMembersToPoint")

local spawnPos = nil

net.Receive("Eventmode_SetSpawn", function(len, ply)
	if ply:GetNW2String("EPlayerStatus") ~= "Manager" then return end

	spawnPos = ply:GetPos()

	hook.Add("PlayerSpawn", "EventMemberSpawnpoint", function(pl) if GetGlobalBool("GM_EVENTMODE") and spawnPos then if pl:GetNW2String("EPlayerStatus") == "Member" then timer.Simple(0, function() if IsValid(pl) then pl:SetPos(spawnPos) end end) end end end)
end)

net.Receive("Eventmode_ToggleVar", function(len, ply)
	if ply:GetNW2String("EPlayerStatus") ~= "Manager" then return end

	local var = net.ReadString()
	local cur = GetGlobalBool(var, false)

	SetGlobalBool(var, not cur)
end)

net.Receive("Eventmode_BringMembers", function(len, ply)
	if not IsValid(ply) or ply:GetNW2String("EPlayerStatus") ~= "Manager" then return end

	local members = {}
	for _, pl in ipairs(player.GetAll()) do
		if IsValid(pl) and pl:IsPlayer() and pl:GetNW2String("EPlayerStatus") == "Member" then table.insert(members, pl) end
	end

	if #members == 0 then return end

	local center = ply:GetPos()
	local radius = 64

	for i, m in ipairs(members) do
		local angle = (i - 1) * 2 * math.pi / #members
		local offset = Vector(math.cos(angle) * radius, math.sin(angle) * radius, 0)

		timer.Simple(0, function()
			if IsValid(m) and IsValid(ply) then
				local dest = center + offset
				dest.z = dest.z + 1

				m:SetPos(dest)
			end
		end)
	end
end)

net.Receive("Eventmode_TeleportMembersToPoint", function(len, ply)
	if not IsValid(ply) or ply:GetNW2String("EPlayerStatus") ~= "Manager" then return end
	if not spawnPos then return end

	local members = {}
	for _, pl in ipairs(player.GetAll()) do
		if IsValid(pl) and pl:IsPlayer() and pl:GetNW2String("EPlayerStatus") == "Member" then table.insert(members, pl) end
	end

	if #members == 0 then return end

	local center = spawnPos
	local radius = 64

	for i, m in ipairs(members) do
		local angle = (i - 1) * 2 * math.pi / #members
		local offset = Vector(math.cos(angle) * radius, math.sin(angle) * radius, 0)

		timer.Simple(0, function()
			if IsValid(m) then
				local dest = center + offset
				dest.z = dest.z + 1

				m:SetPos(dest)
			end
		end)
	end
end)