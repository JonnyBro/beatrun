if not game.IsDedicated() then return end

util.AddNetworkString("Beatrun_ParkourEvent")
util.AddNetworkString("Beatrun_XPUpdate")
util.AddNetworkString("Beatrun_FloatingXP")
util.AddNetworkString("Beatrun_LevelUpSound")

BEATRUN_PLAYERS_XP = BEATRUN_PLAYERS_XP or {} -- [SteamID] = { xp = 0, level = 1 }

local function SaveAllXP()
	file.CreateDir("beatrun/server")
	file.Write("beatrun/server/xp.json", util.TableToJSON(BEATRUN_PLAYERS_XP))
end

local function LoadAllXP()
	file.CreateDir("beatrun/server")

	local datafile = file.Read("beatrun/server/xp.json", "DATA")
	if not datafile then return end

	local data = util.JSONToTable(datafile) or {}
	BEATRUN_PLAYERS_XP = data
end

local function LoadPlayerXP(ply)
	if ply:IsBot() then return end

	local steamID = ply:SteamID()
	if not steamID or steamID == "0" then return end

	if not BEATRUN_PLAYERS_XP[steamID] then
		BEATRUN_PLAYERS_XP[steamID] = {
			xp = 0,
			level = 1
		}
	end

	local info = BEATRUN_PLAYERS_XP[steamID]

	ply:SetNW2Int("Beatrun_XP", info.xp)
	ply:SetNW2Int("Beatrun_Level", info.level)

	ply:LevelUp()

	net.Start("Beatrun_XPUpdate")
	net.Send(ply)
end

hook.Add("Initialize", "Beatrun_LoadAllXP", LoadAllXP)
hook.Add("PlayerInitialSpawn", "Beatrun_LoadXP", LoadPlayerXP)
hook.Add("ShutDown", "Beatrun_SaveAllXP", SaveAllXP)

timer.Create("Beatrun_SaveAllXP_Timer", 120, 0, SaveAllXP)

local meta = FindMetaTable("Player")

function meta:GetLevel()
	return self:GetNW2Int("Beatrun_Level", 1)
end

function meta:GetXP()
	return self:GetNW2Int("Beatrun_XP", 0)
end

function meta:SetLevel(newlevel)
	if not IsValid(self) then return end
	if self:IsBot() then return end

	local steamID = self:SteamID()

	local info = BEATRUN_PLAYERS_XP[steamID]
	if not info then return end

	newlevel = math.max(1, math.Round(tonumber(newlevel) or 1))

	info.level = newlevel
	info.xp = CalcXPForNextLevel(newlevel - 1)

	self:SetNW2Int("Beatrun_Level", info.level)
	self:SetNW2Int("Beatrun_XP", info.xp)

	net.Start("Beatrun_XPUpdate")
	net.Send(self)

	SaveAllXP()
end

function meta:LevelUp()
	if not IsValid(self) then return end
	if self:IsBot() then return end

	local steamID = self:SteamID()

	local info = BEATRUN_PLAYERS_XP[steamID]
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
	if not IsValid(self) then return end
	if self:IsBot() then return end

	local steamID = self:SteamID()
	local info = BEATRUN_PLAYERS_XP[steamID] or {
		xp = 0,
		level = 1
	}

	info.xp = math.Round((info.xp or 0) + xp)

	BEATRUN_PLAYERS_XP[steamID] = info

	self:LevelUp()

	net.Start("Beatrun_XPUpdate")
	net.Send(self)

	if xp > 0 then
		net.Start("Beatrun_FloatingXP")
			net.WriteInt(math.Round(xp), 16)
		net.Send(self)
	end
end

BEATRUN_PLAYERS_LASTEVENT = BEATRUN_PLAYERS_LASTEVENT or {} -- [SteamID] = { event = time }

net.Receive("Beatrun_ParkourEvent", function(_, ply)
	if not IsValid(ply) then return end
	if ply:IsBot() then return end

	local event = net.ReadString()
	if not ParkourXP[event] then return end

	local steamID = ply:SteamID()

	BEATRUN_PLAYERS_LASTEVENT[steamID] = BEATRUN_PLAYERS_LASTEVENT[steamID] or {}

	local now = CurTime()
	local last = BEATRUN_PLAYERS_LASTEVENT[steamID][event] or 0

	if now - last < 0.5 then -- ratelimit
		return
	end

	BEATRUN_PLAYERS_LASTEVENT[steamID][event] = now

	if not ply:Alive() or ply:InVehicle() then return end

	local xpAmount = (ParkourXP[event] or 0) * math.max(math.Round(ply:GetLevel() * 0.05), 1)

	ply:AddXP(xpAmount)
end)
