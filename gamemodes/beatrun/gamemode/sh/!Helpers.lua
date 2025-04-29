local vmatrixmeta = FindMetaTable("VMatrix")
local playermeta = FindMetaTable("Player")

CreateConVar("Beatrun_RandomMWLoadouts", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
CreateConVar("Beatrun_RandomARC9Loadouts", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

-- Example loadouts. You can put any SWEP's class name here.
BEATRUN_GAMEMODES_LOADOUTS = {
	{"weapon_357", "weapon_ar2"},
	{"weapon_pistol", "weapon_smg1"}
}

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
local function GetWeaponList()
	if not cachedWeapons then cachedWeapons = weapons.GetList() end
	return cachedWeapons
end

function BeatrunGetRandomMWSWEP(maxAttempts)
	maxAttempts = maxAttempts or 10

	local allWeps = GetWeaponList()

	for _ = 1, maxAttempts do
		local wep = allWeps[math.random(#allWeps)]
		if wep.Base == "mg_base" and not wep.AdminOnly then return wep.ClassName end
	end

	return "weapon_smg1"
end

function BeatrunGetRandomARCSWEP(maxAttempts)
	maxAttempts = maxAttempts or 10

	local allWeps = GetWeaponList()

	for _ = 1, maxAttempts do
		local wep = allWeps[math.random(#allWeps)]
		if string.find(wep.Base, "arc9") and not wep.AdminOnly then return wep.ClassName end
	end

	return "weapon_smg1"
end

function BeatrunMakeLoadout()
	local arc = GetConVar("Beatrun_RandomARC9Loadouts"):GetBool()
	local mw = GetConVar("Beatrun_RandomMWLoadouts"):GetBool()

	if mw then return {BeatrunGetRandomMWSWEP(), BeatrunGetRandomMWSWEP()}
	elseif arc then return {BeatrunGetRandomARCSWEP(), BeatrunGetRandomARCSWEP()}
	else return BEATRUN_GAMEMODES_LOADOUTS[math.random(#BEATRUN_GAMEMODES_LOADOUTS)] end
end

function BeatrunGiveGMLoadout(ply)
	if not IsValid(ply) then return end

	local loadout = BeatrunMakeLoadout()

	for _, v in pairs(loadout) do
		local wep = ply:Give(v)

		if IsValid(wep) then
			timer.Simple(1, function()
				if IsValid(ply) and IsValid(wep) then
					BeatrunGiveAmmo(ply, wep)
				end
			end)
		end
	end
end