util.AddNetworkString("Beatrun_UpdateBlacklist")
util.AddNetworkString("Beatrun_SyncBlacklist")
util.AddNetworkString("Beatrun_RequestBlacklist")

util.AddNetworkString("Beatrun_RequestLoadouts")
util.AddNetworkString("Beatrun_SyncLoadouts")
util.AddNetworkString("Beatrun_UpdateLoadouts")

BEATRUN_WEAPON_BLACKLIST = BEATRUN_WEAPON_BLACKLIST or {}
BEATRUN_GAMEMODES_LOADOUTS = BEATRUN_GAMEMODES_LOADOUTS or {}

local function SaveBlacklist()
	file.CreateDir("beatrun")
	file.Write("beatrun/loadouts_blacklist.json", util.TableToJSON(BEATRUN_WEAPON_BLACKLIST))
end

local function LoadBlacklist()
	if file.Exists("beatrun/loadouts_blacklist.json", "DATA") then BEATRUN_WEAPON_BLACKLIST = util.JSONToTable(file.Read("beatrun/loadouts_blacklist.json", "DATA")) or {} end
end

net.Receive("Beatrun_UpdateBlacklist", function(_, ply)
	if not ply:IsAdmin() then return end

	local class = net.ReadString()
	local state = net.ReadBool()

	if state then
		BEATRUN_WEAPON_BLACKLIST[class] = true
	else
		BEATRUN_WEAPON_BLACKLIST[class] = nil
	end

	SaveBlacklist()

	net.Start("Beatrun_SyncBlacklist")
		net.WriteTable(BEATRUN_WEAPON_BLACKLIST)
	net.Broadcast()
end)

net.Receive("Beatrun_RequestBlacklist", function(_, ply)
	net.Start("Beatrun_SyncBlacklist")
		net.WriteTable(BEATRUN_WEAPON_BLACKLIST)
	net.Send(ply)
end)

hook.Add("Initialize", "Beaturn_Load_Blacklist", LoadBlacklist)

local function SaveLoadouts()
	file.CreateDir("beatrun")
	file.Write("beatrun/loadouts.json", util.TableToJSON(BEATRUN_GAMEMODES_LOADOUTS))
end

local function LoadLoadouts()
	if file.Exists("beatrun/loadouts.json", "DATA") then BEATRUN_GAMEMODES_LOADOUTS = util.JSONToTable(file.Read("beatrun/loadouts.json", "DATA")) or {} end
end

net.Receive("Beatrun_RequestLoadouts", function(_, ply)
	net.Start("Beatrun_SyncLoadouts")
		net.WriteTable(BEATRUN_GAMEMODES_LOADOUTS)
	net.Send(ply)
end)

net.Receive("Beatrun_UpdateLoadouts", function(_, ply)
	if not ply:IsAdmin() then return end

	BEATRUN_GAMEMODES_LOADOUTS = net.ReadTable()

	SaveLoadouts()

	net.Start("Beatrun_SyncLoadouts")
		net.WriteTable(BEATRUN_GAMEMODES_LOADOUTS)
	net.Broadcast()
end)

hook.Add("Initialize", "Beatrun_LoadLoadouts", LoadLoadouts)

function BeatrunGiveAmmo(ply, wep)
	if wep:GetPrimaryAmmoType() ~= -1 then ply:GiveAmmo(10000, wep:GetPrimaryAmmoType(), true) end
	if wep:GetSecondaryAmmoType() ~= -1 then ply:GiveAmmo(10, wep:GetSecondaryAmmoType(), true) end
end

function BeatrunGetRandomLoadout(selected)
	local allWeps = GetWeaponsList()
	-- local attempts = math.Round(#allWeps / 5)
	local tbl = {}
	local usedClasses = {}

	while #tbl < 2 --[[and attempts > 0]] do
		-- attempts = attempts - 1
		local wep = allWeps[math.random(#allWeps)]

		if selected == "beatrun" then
			return BEATRUN_GAMEMODES_LOADOUTS[math.random(#BEATRUN_GAMEMODES_LOADOUTS)]
		else
			if string.find(wep.Base, selected) and not string.find(wep.ClassName, "base") and not usedClasses[wep.ClassName] and not BEATRUN_WEAPON_BLACKLIST[wep.ClassName] then
				table.insert(tbl, wep.ClassName)

				usedClasses[wep.ClassName] = true
			end
		end
	end

	if #tbl == 2 then return tbl end

	return {}
end

function BeatrunGiveGMLoadout(ply)
	if not IsValid(ply) then return end

	local selectedLoadouts = GetConVar("Beatrun_RandomLoadouts"):GetString()
	local loadout = BeatrunGetRandomLoadout(selectedLoadouts)
	if not loadout or table.IsEmpty(loadout) then return end

	for _, v in pairs(loadout) do
		local wep = ply:Give(v)

		if IsValid(wep) then timer.Simple(1, function() if IsValid(ply) and IsValid(wep) then BeatrunGiveAmmo(ply, wep) end end) end
	end
end
