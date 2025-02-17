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

local depth = 0

function BeatrunGetRandomMWSWEP()
	local allWeps = weapons.GetList()
	local swep = allWeps[math.random(#allWeps)]

	if swep.Base == "mg_base" and not swep.AdminOnly then return swep.ClassName
	else
		if depth > 5 then
			depth = 0
			return
		end

		depth = depth + 1
		BeatrunGetRandomMWSWEP()
	end
end

function BeatrunGetRandomARCSWEP()
	local allWeps = weapons.GetList()
	local swep = allWeps[math.random(#allWeps)]

	if swep.Base == "arc9_cod2019_base" and not swep.AdminOnly then return swep.ClassName
	else
		if depth > 5 then
			depth = 0
			return
		end

		depth = depth + 1
		BeatrunGetRandomARCSWEP()
	end
end

function BeatrunMakeLoadout()
	local arc, mw = GetConVar("Beatrun_RandomARC9Loadouts"):GetBool(), GetConVar("Beatrun_RandomMWLoadouts"):GetBool()

	if arc and not mw then return {BeatrunGetRandomARCSWEP(), BeatrunGetRandomARCSWEP()}
	elseif not arc and mw then return {BeatrunGetRandomMWSWEP(), BeatrunGetRandomMWSWEP()}
	elseif not arc and not mw then return BEATRUN_GAMEMODES_LOADOUTS[math.random(#BEATRUN_GAMEMODES_LOADOUTS)] end
end

function BeatrunGiveGMLoadout(ply)
	local loadout = BeatrunMakeLoadout()

	for _, v in pairs(loadout) do
		local wep = ply:Give(v)

		timer.Simple(1, function() BeatrunGiveAmmo(ply, wep) end)
	end
end
