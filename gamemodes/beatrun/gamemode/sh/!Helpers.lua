ParkourXP = {
	roll = 3,
	sidestep = 1,
	slide = 1,
	vault = 2,
	climb = 4,
	wallrunh = 2,
	springboard = 2,
	wallrunv = 2,
	coil = 1,
	swingbar = 4,
	step = 1
}

CreateConVar("Beatrun_RandomLoadouts", "beatrun", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY }, "")

-- Migrate old vars
if table.HasValue({ "1", "2", "3", "4", "5" }, GetConVar("Beatrun_RandomLoadouts"):GetString()) then GetConVar("Beatrun_RandomLoadouts"):SetString("beatrun") end
-- if not table.HasValue({ 1, 2, 3 }, GetConVar("Beatrun_SpeedometerMode"):GetInt()) then GetConVar("Beatrun_SpeedometerMode"):SetInt(1) end -- TODO: FIXME

function CalcXPForNextLevel(level)
	return math.Round(0.25 * level ^ 3 + 0.8 * level ^ 2 + 2 * level)
end

function LerpL(t, a, b)
	return a + (b - a) * t
end

function TraceSetData(tbl, start, endpos, mins, maxs, filter)
	tbl.start = start
	tbl.endpos = endpos

	if tbl.mins then
		tbl.mins = mins
		tbl.maxs = maxs
	end

	if filter then
		tbl.filter = filter
	elseif not maxs then
		tbl.filter = mins
	end
end

function TraceParkourMask(tbl)
	tbl.mask = MASK_PLAYERSOLID
	tbl.collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT
end

local vmatrixmeta = FindMetaTable("VMatrix")

local mtmp = {
	{ 0, 0, 0, 0 },
	{ 0, 0, 0, 0 },
	{ 0, 0, 0, 0 },
	{ 0, 0, 0, 1 }
}

function vmatrixmeta:FastToTable(tbl)
	tbl = tbl or table.Copy(mtmp)

	local tbl1 = tbl[1]
	local tbl2 = tbl[2]
	local tbl3 = tbl[3]

	tbl1[1], tbl1[2], tbl1[3], tbl1[4], tbl2[1], tbl2[2], tbl2[3], tbl2[4], tbl3[1], tbl3[2], tbl3[3], tbl3[4] = self:Unpack()

	return tbl
end

local playermeta = FindMetaTable("Player")

function playermeta:SetMantleData(startpos, endpos, lerp, mantletype)
	self:SetMantleStartPos(startpos)
	self:SetMantleEndPos(endpos)
	self:SetMantleLerp(lerp)
	self:SetMantle(mantletype)
end

function playermeta:SetWallrunData(wr, wrtime, dir)
	local count = self:GetWallrunCount()

	self:SetWallrun(wr)
	self:SetWallrunCount(count + 1)
	self:SetWallrunTime(wrtime)
	self:SetWallrunSoundTime(CurTime() + 0.1)
	self:SetWallrunDir(dir)
end

function playermeta:UsingRH(wep)
	wep = wep or self:GetActiveWeapon()

	if IsValid(wep) and wep:GetClass() == "runnerhands" then return true end

	return false
end

local cachedWeapons = nil

function GetWeaponsList()
	if not cachedWeapons then
		cachedWeapons = {}

		for _, wep in pairs(weapons.GetList()) do
			if wep.ClassName and not wep.AdminOnly then table.insert(cachedWeapons, wep) end
		end
	end

	return cachedWeapons
end

RANDOM_LOADOUT_BASES = { "mg_base", "arc9", "arccw", "tfa_" }

local function MatchesBase(wep, selected)
	local base = isstring(wep.Base) and wep.Base or ""

	if selected then return string.find(base, selected, 1, true) ~= nil end

	for _, b in ipairs(RANDOM_LOADOUT_BASES) do
		if string.find(base, b, 1, true) then return true end
	end

	return false
end

local NOT_WEAPONS = {
	gmod_camera = true,
	gmod_tool = true,
	manhack_welder = true,
	runnerhands = true,
	weapon_physgun = true
}

local function AddToPool(pool, seen, class, name, category)
	if seen[class] or NOT_WEAPONS[class] or string.find(class, "base", 1, true) then return end

	seen[class] = true

	table.insert(pool, { ClassName = class, PrintName = name or class, Category = category or "Other" })
end

-- selected: one of RANDOM_LOADOUT_BASES, "any" or nil for every weapon
function GetRandomLoadoutPool(selected)
	local pool, seen = {}, {}

	if selected == "any" then selected = nil end

	if not selected then
		for class, data in pairs(list.Get("Weapon")) do
			AddToPool(pool, seen, class, data.PrintName, data.Category)
		end
	end

	for _, wep in ipairs(GetWeaponsList()) do
		if MatchesBase(wep, selected) then AddToPool(pool, seen, wep.ClassName, wep.PrintName, wep.Category) end
	end

	return pool
end

local ply_mins = Vector(-16, -16, 0)
local ply_maxs = Vector(16, 16, 72)

function PlayerCannotStand(ply)
	if not IsValid(ply) then return false end

	local startPos = ply:GetPos()
	local endPos = startPos + Vector(0, 0, 16)

	local tr = util.TraceHull({
		start = startPos,
		endpos = endPos,
		mins = ply_mins,
		maxs = ply_maxs,
		filter = ply
	})

	return tr and tr.Hit or false
end
