local vmatrixmeta = FindMetaTable("VMatrix")
local playermeta = FindMetaTable("Player")

CreateConVar("Beatrun_RandomLoadouts", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "", 1, 5)

-- Example loadouts. You can put any SWEP's **class names** here.
BEATRUN_GAMEMODES_LOADOUTS = {
	{"weapon_357", "weapon_ar2"},
	{"weapon_pistol", "weapon_smg1"}
}

local weaponBases = {"beatrun", "mg_base", "arc9", "arccw", "tfa_"}

local mtmp = {
	{0, 0, 0, 0},
	{0, 0, 0, 0},
	{0, 0, 0, 0},
	{0, 0, 0, 1}
}

function vmatrixmeta:FastToTable(tbl)
	tbl = tbl or table.Copy(mtmp)

	local tbl1 = tbl[1]
	local tbl2 = tbl[2]
	local tbl3 = tbl[3]

	tbl1[1], tbl1[2], tbl1[3], tbl1[4], tbl2[1], tbl2[2], tbl2[3], tbl2[4], tbl3[1], tbl3[2], tbl3[3], tbl3[4] = self:Unpack()

	return tbl
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

	if IsValid(wep) and wep:GetClass() == "runnerhands" then return true
	else return false end
end

function BeatrunGiveAmmo(ply, wep)
	if wep:GetPrimaryAmmoType() ~= -1 then ply:GiveAmmo(10000, wep:GetPrimaryAmmoType(), true) end
	if wep:GetSecondaryAmmoType() ~= -1 then ply:GiveAmmo(5, wep:GetSecondaryAmmoType(), true) end
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

function BeatrunGetRandomLoadout(selected)
	local allWeps = GetWeaponsList()
	local attempts = math.Round(#allWeps / 5)
	local selectedBase = weaponBases[selected]

	local tbl = {}
	local usedClasses = {}

	while #tbl < 2 and attempts > 0 do
		attempts = attempts - 1
		local wep = allWeps[math.random(#allWeps)]

		if selectedBase == "beatrun" then
			return BEATRUN_GAMEMODES_LOADOUTS[math.random(#BEATRUN_GAMEMODES_LOADOUTS)]
		else
			if string.find(wep.Base, selectedBase) and not string.find(wep.ClassName, "base") and not usedClasses[wep.ClassName] then
				table.insert(tbl, wep.ClassName)
				usedClasses[wep.ClassName] = true
			end
		end
	end

	if #tbl == 2 then return tbl end

	return BEATRUN_GAMEMODES_LOADOUTS[math.random(#BEATRUN_GAMEMODES_LOADOUTS)]
end

function BeatrunGiveGMLoadout(ply)
	if not IsValid(ply) then return end

	local selectedLoadouts = GetConVar("Beatrun_RandomLoadouts"):GetInt()
	local loadout = BeatrunGetRandomLoadout(selectedLoadouts)

	for _, v in pairs(loadout) do
		local wep = ply:Give(v)
		if IsValid(wep) then timer.Simple(1, function() if IsValid(ply) and IsValid(wep) then BeatrunGiveAmmo(ply, wep) end end) end
	end
end