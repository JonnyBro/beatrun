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

-- Random loadouts stuff
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

if SERVER then
	util.AddNetworkString("Beatrun_UpdateBlacklist")
	util.AddNetworkString("Beatrun_SyncBlacklist")
	util.AddNetworkString("Beatrun_RequestBlacklist")

	BEATRUN_WEAPON_BLACKLIST = BEATRUN_WEAPON_BLACKLIST or {}
	BEATRUN_GAMEMODES_LOADOUTS = { { "weapon_357", "weapon_ar2" }, { "weapon_pistol", "weapon_smg1" } }

	function SaveBlacklist()
		file.CreateDir("beatrun")
		file.Write("beatrun/beatrun_loadouts_blacklist.json", util.TableToJSON(BEATRUN_WEAPON_BLACKLIST))
	end

	function LoadBlacklist()
		if file.Exists("beatrun/beatrun_loadouts_blacklist.json", "DATA") then BEATRUN_WEAPON_BLACKLIST = util.JSONToTable(file.Read("beatrun/beatrun_loadouts_blacklist.json", "DATA")) or {} end
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

	function BeatrunGiveAmmo(ply, wep)
		if wep:GetPrimaryAmmoType() ~= -1 then ply:GiveAmmo(10000, wep:GetPrimaryAmmoType(), true) end
		if wep:GetSecondaryAmmoType() ~= -1 then ply:GiveAmmo(5, wep:GetSecondaryAmmoType(), true) end
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

		return BEATRUN_GAMEMODES_LOADOUTS[math.random(#BEATRUN_GAMEMODES_LOADOUTS)]
	end

	function BeatrunGiveGMLoadout(ply)
		if not IsValid(ply) then return end

		local selectedLoadouts = GetConVar("Beatrun_RandomLoadouts"):GetString()
		local loadout = BeatrunGetRandomLoadout(selectedLoadouts)

		for _, v in pairs(loadout) do
			local wep = ply:Give(v)
			if IsValid(wep) then timer.Simple(1, function() if IsValid(ply) and IsValid(wep) then BeatrunGiveAmmo(ply, wep) end end) end
		end
	end
end

if CLIENT then
	BEATRUN_WEAPON_BLACKLIST = BEATRUN_WEAPON_BLACKLIST or {}

	local blacklistFrame

	concommand.Add("beatrun_blacklist_menu", function()
		net.Start("Beatrun_RequestBlacklist")
		net.SendToServer()

		local frameW = math.Clamp(ScrW() * 0.3, 360, 700)
		local frameH = math.Clamp(ScrH() * 0.5, 300, 700)

		blacklistFrame = vgui.Create("DFrame")
		blacklistFrame:SetTitle("")
		blacklistFrame:SetSize(frameW, frameH)
		blacklistFrame:Center()
		blacklistFrame:DockPadding(10, 30, 0, 10)
		blacklistFrame:SetDeleteOnClose(true)
		blacklistFrame:ShowCloseButton(false)
		blacklistFrame:MakePopup()

		blacklistFrame.Paint = function(self, w, h)
			draw.RoundedBox(8, 0, 0, w, h, CurrentTheme().bg)
			draw.RoundedBoxEx(8, 0, 0, w, 24, CurrentTheme().header, true, true, false, false)
			draw.SimpleText("Blacklist for Random Loadouts", "AEUIDefault", 10, 12, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local close = vgui.Create("DButton", blacklistFrame)
		close:SetText("✕")
		close:SetFont("AEUIDefault")
		close:SetTextColor(CurrentTheme().buttons.red.t)
		close:SetSize(24, 24)
		close:SetPos(blacklistFrame:GetWide() - 24, 0)

		close.Paint = function(self, w, h)
			local bg = self:IsHovered() and CurrentTheme().buttons.red.h or CurrentTheme().buttons.red.n
			local isDown = self:IsDown() and CurrentTheme().buttons.red.d

			draw.RoundedBoxEx(6, 0, 0, w, h, isDown or bg, false, true, false, false)
		end

		close.DoClick = function() blacklistFrame:Close() end

		local scroll = vgui.Create("DScrollPanel", blacklistFrame)
		scroll:Dock(FILL)

		ApplyScrollTheme(scroll)

		local allWeps = GetWeaponsList()
		local allWeps = GetWeaponsList()

		local categories = {}

		for _, wep in ipairs(allWeps) do
			if not wep.ClassName then continue end
			if string.find(wep.ClassName, "base") then continue end

			local cat = wep.Category or "Other"

			categories[cat] = categories[cat] or {}

			table.insert(categories[cat], wep)
		end

		local sortedCats = table.GetKeys(categories)

		table.sort(sortedCats)

		for _, cat in ipairs(sortedCats) do
			local weps = categories[cat]

			table.sort(weps, function(a, b) return a.ClassName < b.ClassName end)

			local header = scroll:Add("DPanel")
			header:SetTall(28)
			header:Dock(TOP)
			header:DockMargin(0, 10, 0, 4)

			header.Paint = function(self, w, h)
				draw.RoundedBox(4, 0, 0, w, h, CurrentTheme().header)
				draw.SimpleText(cat, "AEUIDefault", 10, h / 2, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			for _, wep in ipairs(weps) do
				local class = wep.ClassName

				local row = scroll:Add("DPanel")
				row:SetTall(40)
				row:Dock(TOP)
				row:DockMargin(0, 0, 0, 6)

				row.Paint = function(self, w, h)
					local col = self:IsHovered() and CurrentTheme().panels.secondary or CurrentTheme().panels.primary

					draw.RoundedBox(6, 0, 0, w, h, col)
					draw.SimpleText(string.format("%s (%s)", language.GetPhrase(wep.PrintName), class), "AEUIDefault", 10, h / 2, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end

				local toggle = vgui.Create("DButton", row)
				toggle:SetText("")
				toggle:Dock(RIGHT)
				toggle:SetWide(110)
				toggle:DockMargin(0, 6, 6, 6)

				toggle.Paint = function(self, w, h)
					local style = BEATRUN_WEAPON_BLACKLIST[class] and "red" or "green"

					ApplyButtonTheme(self, w, h, style)

					local txt = BEATRUN_WEAPON_BLACKLIST[class] and "Blacklisted" or "Allowed"
					draw.SimpleText(txt, "AEUIDefault", w / 2, h / 2, CurrentTheme().buttons[style].t, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				toggle.DoClick = function()
					local newState = not BEATRUN_WEAPON_BLACKLIST[class]

					net.Start("Beatrun_UpdateBlacklist")
						net.WriteString(class)
						net.WriteBool(newState)
					net.SendToServer()
				end
			end
		end
	end)

	net.Receive("Beatrun_SyncBlacklist", function() BEATRUN_WEAPON_BLACKLIST = net.ReadTable() end)
end

hook.Add("Initialize", "Beaturn_Load_Blacklist", LoadBlacklist)
