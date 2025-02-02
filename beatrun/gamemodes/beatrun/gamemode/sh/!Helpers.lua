local vmatrixmeta = FindMetaTable("VMatrix")
local playermeta = FindMetaTable("Player")

CreateConVar("Beatrun_RandomMWLoadouts", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})
CreateConVar("Beatrun_RandomARC9Loadouts", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

BEATRUN_GAMEMODES_LOADOUTS = {
	{"weapon_357", "weapon_ar2"}
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
	local activewep = wep or self:GetActiveWeapon()

	if IsValid(activewep) and activewep:GetClass() == "runnerhands" then
		return true
	else
		return false
	end
end

function playermeta:notUsingRH(wep)
	local activewep = wep or self:GetActiveWeapon()

	if IsValid(activewep) and activewep:GetClass() ~= "runnerhands" then
		return true
	else
		return false
	end
end

function Beatrun_GiveAmmo(weapon, ply)
	if weapon:GetPrimaryAmmoType() ~= -1 then ply:GiveAmmo(10000, weapon:GetPrimaryAmmoType(), true) end
	if weapon:GetSecondaryAmmoType() ~= -1 then ply:GiveAmmo(5, weapon:GetSecondaryAmmoType(), true) end
end

function Beatrun_getRandomMWBaseSWEP()
	local allWep = weapons.GetList()
	local wepIndex = math.random(#allWep)
	local wep = allWep[wepIndex]

	if wep.Base == "mg_base" and not wep.AdminOnly then
		return wep
	else
		return Beatrun_getRandomMWBaseSWEP()
	end
end

function Beatrun_getRandomARC9SWEP()
	local allWep = weapons.GetList()
	local wepIndex = math.random(#allWep)
	local wep = allWep[wepIndex]

	if wep.Base == "arc9_cod2019_base" and not wep.AdminOnly then
		return wep
	else
		return Beatrun_getRandomARC9SWEP()
	end
end

function Beatrun_GiveGMWeapon(ply)
	if GetConVar("Beatrun_RandomMWLoadouts"):GetBool() and not GetConVar("Beatrun_RandomARC9Loadouts"):GetBool() then
		for i = 0, 1 do
			local swep = Beatrun_getRandomMWBaseSWEP()
			local w = ply:Give(swep.ClassName)

			timer.Simple(1, function()
				Beatrun_GiveAmmo(w, ply)
			end)
		end
	elseif GetConVar("Beatrun_RandomARC9Loadouts"):GetBool() and not GetConVar("Beatrun_RandomMWLoadouts"):GetBool() then
		for i = 0, 1 do
			-- We don't need ammo because ARC9 got the infinite ammo option

			local swep = Beatrun_getRandomARC9SWEP()
			ply:Give(swep.ClassName)
		end
	elseif not GetConVar("Beatrun_RandomARC9Loadouts"):GetBool() and not GetConVar("Beatrun_RandomMWLoadouts"):GetBool() then
		for _, b in ipairs(BEATRUN_GAMEMODES_LOADOUTS[math.random(#BEATRUN_GAMEMODES_LOADOUTS)]) do
			local w = ply:Give(b)

			timer.Simple(1, function()
				Beatrun_GiveAmmo(w, ply)
			end)
		end
	end
end
