if game.SinglePlayer() then return end

local PlayerXP = {} -- [SteamID64] = { xp = 0, level = 1 }

local function SaveAllXP()
	local data = {}

	for sid, info in pairs(PlayerXP) do
		data[sid] = info
	end

	file.CreateDir("beatrun/server")
	file.Write("beatrun/server/xp.json", util.TableToJSON(data))
end

local function LoadPlayerXP(ply)
	local sid = ply:SteamID64()
	if not sid or sid == "0" or ply:IsBot() then return end

	local datafile = file.Read("beatrun/server/xp.json", "DATA")

	if datafile then
		local data = util.JSONToTable(datafile)
		if data and data[sid] then PlayerXP[sid] = data[sid] end
	end

	if not PlayerXP[sid] then
		PlayerXP[sid] = {
			xp = 0,
			level = 1
		}
	end

	local info = PlayerXP[sid]

	ply:SetNW2Int("Beatrun_XP", info.xp)
	ply:SetNW2Int("Beatrun_Level", info.level)
end

hook.Add("PlayerInitialSpawn", "Beatrun_LoadXP", LoadPlayerXP)
hook.Add("PlayerDisconnected", "Beatrun_SaveXP", SaveAllXP)

timer.Create("Beatrun_SaveXP_Timer", 300, 0, SaveAllXP)

local meta = FindMetaTable("Player")

function meta:GetLevel()
	return self:GetNW2Int("Beatrun_Level", 1)
end

function meta:GetXP()
	return self:GetNW2Int("Beatrun_XP", 0)
end

function meta:SetLevel(newlevel)
	if not IsValid(self) then return end

	local sid = self:SteamID64()

	local info = PlayerXP[sid]
	if not info then return end

	newlevel = math.max(1, math.Round(tonumber(newlevel) or 1))

	info.level = newlevel
	info.xp = CalcXPForNextLevel(newlevel - 1)

	self:SetNW2Int("Beatrun_Level", info.level)
	self:SetNW2Int("Beatrun_XP", info.xp)

	net.Start("Beatrun_XPUpdate")
		net.WriteUInt(info.xp, 32)
		net.WriteUInt(info.level, 16)
	net.Send(self)

	SaveAllXP()
end

function meta:LevelUp()
	if not IsValid(self) then return end

	local sid = self:SteamID64()

	local info = PlayerXP[sid]
	if not info then return end

	local old_level = info.level
	local i = 0

	while true do
		local lastratio = CalcXPForNextLevel(info.level - 1)

		local nextratio = CalcXPForNextLevel(info.level)
		if nextratio == lastratio then break end

		local ratio = (info.xp - lastratio) / (nextratio - lastratio)
		if ratio < 1 then break end

		info.level = info.level + 1

		i = i + 1

		if i > 1000 then break end
	end

	if info.level > old_level then
		net.Start("Beatrun_LevelUpSound")
		net.Send(self)
	end

	self:SetNW2Int("Beatrun_XP", info.xp)
	self:SetNW2Int("Beatrun_Level", info.level)
end

function meta:AddXP(xp)
	local sid = self:SteamID64()
	local info = PlayerXP[sid] or {
		xp = 0,
		level = 1
	}

	info.xp = math.Round((info.xp or 0) + xp)

	PlayerXP[sid] = info

	self:LevelUp()

	net.Start("Beatrun_XPUpdate")
		net.WriteUInt(info.xp, 32)
		net.WriteUInt(info.level, 16)
	net.Send(self)

	if xp > 0 then
		net.Start("Beatrun_FloatingXP")
			net.WriteInt(math.Round(xp), 16)
		net.Send(self)
	end
end

util.AddNetworkString("Beatrun_ParkourEvent")
util.AddNetworkString("Beatrun_XPUpdate")
util.AddNetworkString("Beatrun_FloatingXP")
util.AddNetworkString("Beatrun_LevelUpSound")

local LastEventTime = {} -- [SteamID64] = { event = time }

net.Receive("Beatrun_ParkourEvent", function(len, ply)
	if not IsValid(ply) then return end

	local event = net.ReadString()
	if not ParkourXP[event] then return end

	local sid = ply:SteamID64()

	LastEventTime[sid] = LastEventTime[sid] or {}

	local now = CurTime()
	local last = LastEventTime[sid][event] or 0

	if now - last < 0.5 then -- ratelimit
		return
	end

	LastEventTime[sid][event] = now

	if not ply:Alive() or ply:InVehicle() then return end

	local xp_amount = (ParkourXP[event] or 0) * math.max(math.Round(ply:GetLevel() * 0.05), 1)

	ply:AddXP(xp_amount)
end)
