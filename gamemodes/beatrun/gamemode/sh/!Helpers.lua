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

function CalcXPForNextLevel(level)
	return math.Round(0.25 * level ^ 3 + 0.8 * level ^ 2 + 2 * level)
end

function LerpL(t, a, b)
	return a + (b - a) * t
end

function LerpC(t, a, b, powa)
	return a + (b - a) * math.pow(t, powa)
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
