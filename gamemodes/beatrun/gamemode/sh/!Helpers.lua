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

	util.AddNetworkString("Beatrun_RequestLoadouts")
	util.AddNetworkString("Beatrun_SyncLoadouts")
	util.AddNetworkString("Beatrun_UpdateLoadouts")

	BEATRUN_WEAPON_BLACKLIST = BEATRUN_WEAPON_BLACKLIST or {}
	BEATRUN_GAMEMODES_LOADOUTS = BEATRUN_GAMEMODES_LOADOUTS or {}
	-- { { "weapon_357", "weapon_ar2" }, { "weapon_pistol", "weapon_smg1" } }

	function SaveBlacklist()
		file.CreateDir("beatrun")
		file.Write("beatrun/loadouts_blacklist.json", util.TableToJSON(BEATRUN_WEAPON_BLACKLIST))
	end

	function LoadBlacklist()
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
		if file.Exists("beatrun/loadouts.json", "DATA") then
			BEATRUN_GAMEMODES_LOADOUTS = util.JSONToTable(file.Read("beatrun/loadouts.json", "DATA")) or {}
		end
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
	BEATRUN_GAMEMODES_LOADOUTS = BEATRUN_GAMEMODES_LOADOUTS or {}

	local blacklistFrame
	local loadoutsFrame
	local SelectedLoadout = 1

	local function OpenLoadoutsMenu()
		if IsValid(loadoutsFrame) then loadoutsFrame:Remove() end

		loadoutsFrame = vgui.Create("DFrame")
		loadoutsFrame:SetTitle("")
		loadoutsFrame:SetSize(ScrW() * 0.6, ScrH() * 0.6)
		loadoutsFrame:Center()
		loadoutsFrame:DockPadding(10, 30, 0, 10)
		loadoutsFrame:SetDeleteOnClose(true)
		loadoutsFrame:ShowCloseButton(false)
		loadoutsFrame:MakePopup()

		loadoutsFrame.Paint = function(self, w, h)
			draw.RoundedBox(8, 0, 0, w, h, CurrentTheme().bg)
			draw.RoundedBoxEx(8, 0, 0, w, 24, CurrentTheme().header, true, true, false, false)
			draw.SimpleText("Loadout Editor", "AEUIDefault", 10, 12, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local close = vgui.Create("DButton", loadoutsFrame)
		close:SetText("✕")
		close:SetFont("AEUIDefault")
		close:SetTextColor(CurrentTheme().buttons.red.t)
		close:SetSize(24, 24)
		close:SetPos(loadoutsFrame:GetWide() - 24, 0)

		close.Paint = function(self, w, h)
			local bg = self:IsHovered() and CurrentTheme().buttons.red.h or CurrentTheme().buttons.red.n
			local isDown = self:IsDown() and CurrentTheme().buttons.red.d
			draw.RoundedBoxEx(6, 0, 0, w, h, isDown or bg, false, true, false, false)
		end

		close.DoClick = function() loadoutsFrame:Close() end

		local left = vgui.Create("DPanel", loadoutsFrame)
		left:Dock(LEFT)
		left:SetWide(220)
		left:DockMargin(0, 0, 10, 0)
		left.Paint = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().panels.primary)
		end

		local loadoutList = vgui.Create("DScrollPanel", left)
		loadoutList:Dock(FILL)
		ApplyScrollTheme(loadoutList)

		local right = vgui.Create("DPanel", loadoutsFrame)
		right:Dock(FILL)
		right.Paint = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().panels.primary)
		end

		local weaponList = vgui.Create("DScrollPanel", right)
		weaponList:Dock(FILL)
		ApplyScrollTheme(weaponList)

		local function BuildWeapons()
			weaponList:Clear()

			local loadout = BEATRUN_GAMEMODES_LOADOUTS[SelectedLoadout]
			if not istable(loadout) then return end

			for _, class in ipairs(loadout) do
				local wep = weapons.GetStored(class)

				local row = weaponList:Add("DPanel")
				row:SetTall(64)
				row:Dock(TOP)
				row:DockMargin(0, 0, 0, 6)

				row.Paint = function(self, w, h)
					draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().panels.secondary)
				end

				local icon = vgui.Create("SpawnIcon", row)
				icon:Dock(LEFT)
				icon:SetWide(64)
				icon:SetModel(wep.WorldModel or "models/props_junk/watermelon01.mdl")
				icon:SetTooltip(false)
				icon:SetMouseInputEnabled(false)

				local label = vgui.Create("DLabel", row)
				label:Dock(FILL)
				label:DockMargin(10, 0, 0, 0)
				label:SetFont("AEUIDefault")
				label:SetTextColor(CurrentTheme().text.primary)

				label:SetText(string.format("%s\n(%s)", language.GetPhrase(wep.PrintName), class))

				local remove = vgui.Create("DButton", row)
				remove:Dock(RIGHT)
				remove:SetWide(120)
				remove:DockMargin(0, 10, 10, 10)
				remove:SetText("")

				remove.Paint = function(self, w, h)
					ApplyButtonTheme(self, w, h, "red")
					draw.SimpleText("Remove", "AEUIDefault", w / 2, h / 2, CurrentTheme().buttons.red.t, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				remove.DoClick = function()
					table.RemoveByValue(loadout, class)
					BuildWeapons()
				end
			end
		end

		local function BuildLoadouts()
			loadoutList:Clear()

			for i, _ in ipairs(BEATRUN_GAMEMODES_LOADOUTS) do
				local row = loadoutList:Add("DButton")
				row:Dock(TOP)
				row:SetTall(40)
				row:SetText("")
				row:DockMargin(0, 0, 0, 5)

				row.Paint = function(self, w, h)
					local active = (i == SelectedLoadout)
					local col = active and CurrentTheme().accent or CurrentTheme().panels.secondary
					draw.RoundedBox(6, 0, 0, w, h, col)

					draw.SimpleText("Loadout " .. i, "AEUIDefault", 10, h / 2, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end

				row.DoClick = function()
					SelectedLoadout = i
					BuildWeapons()
				end
			end

			BuildWeapons()
		end

		local bottomLeft = vgui.Create("DPanel", left)
		bottomLeft:Dock(BOTTOM)
		bottomLeft:SetTall(60)
		bottomLeft.Paint = nil

		local add = vgui.Create("DButton", bottomLeft)
		add:Dock(LEFT)
		add:SetWide(100)
		add:SetText("+")
		add:SetTextColor(CurrentTheme().buttons.green.t)
		add.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

		add.DoClick = function()
			table.insert(BEATRUN_GAMEMODES_LOADOUTS, {})
			SelectedLoadout = #BEATRUN_GAMEMODES_LOADOUTS
			BuildLoadouts()
		end

		local del = vgui.Create("DButton", bottomLeft)
		del:Dock(RIGHT)
		del:SetWide(100)
		del:SetText("-")
		del:SetTextColor(CurrentTheme().buttons.red.t)
		del.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "red") end

		del.DoClick = function()
			table.remove(BEATRUN_GAMEMODES_LOADOUTS, SelectedLoadout)
			SelectedLoadout = math.Clamp(SelectedLoadout, 1, #BEATRUN_GAMEMODES_LOADOUTS)
			BuildLoadouts()
		end

		local addWeapon = vgui.Create("DButton", right)
		addWeapon:Dock(BOTTOM)
		addWeapon:SetTall(40)
		addWeapon:SetText("Add Weapon")
		addWeapon:SetTextColor(CurrentTheme().buttons.green.t)

		addWeapon.Paint = function(self, w, h)
			ApplyButtonTheme(self, w, h, "green")
		end

		addWeapon.DoClick = function()
			local menu = DermaMenu()

			local weps = GetWeaponsList()

			table.sort(weps, function(a, b)
				return a.ClassName < b.ClassName
			end)

			for _, wep in ipairs(weps) do
				if string.find(wep.ClassName, "base") then continue end
				if BEATRUN_WEAPON_BLACKLIST[wep.ClassName] then continue end

				local text = string.format("%s (%s)", wep.PrintName, wep.ClassName)

				menu:AddOption(text, function()
					table.insert(BEATRUN_GAMEMODES_LOADOUTS[SelectedLoadout], wep.ClassName)
					BuildWeapons()
				end)
			end

			menu:Open()
		end

		local save = vgui.Create("DButton", loadoutsFrame)
		save:Dock(BOTTOM)
		save:SetTall(40)
		save:SetText("Save")
		save:SetTextColor(CurrentTheme().buttons.green.t)

		save.Paint = function(self, w, h)
			ApplyButtonTheme(self, w, h, "green")
		end

		save.DoClick = function()
			net.Start("Beatrun_UpdateLoadouts")
				net.WriteTable(BEATRUN_GAMEMODES_LOADOUTS)
			net.SendToServer()
		end

		BuildLoadouts()
	end

	concommand.Add("beatrun_loadouts_menu", function()
		net.Start("Beatrun_RequestLoadouts")
		net.SendToServer()
	end)

	net.Receive("Beatrun_SyncLoadouts", function()
		BEATRUN_GAMEMODES_LOADOUTS = net.ReadTable()
		OpenLoadoutsMenu()
	end)

	local function OpenBlacklistMenu()
		if IsValid(blacklistFrame) then blacklistFrame:Remove() end

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
				row:SetTall(64)
				row:Dock(TOP)
				row:DockMargin(0, 0, 0, 6)

				row.Paint = function(self, w, h)
					local col = self:IsHovered() and CurrentTheme().panels.secondary or CurrentTheme().panels.primary
					draw.RoundedBox(6, 0, 0, w, h, col)
				end

				local icon = vgui.Create("SpawnIcon", row)
				icon:Dock(LEFT)
				icon:SetWide(64)
				icon:SetModel(wep.WorldModel or "models/props_junk/watermelon01.mdl")
				icon:SetTooltip(false)
				icon:SetMouseInputEnabled(false)

				local label = vgui.Create("DLabel", row)
				label:Dock(FILL)
				label:DockMargin(10, 0, 0, 0)
				label:SetFont("AEUIDefault")
				label:SetTextColor(CurrentTheme().text.primary)
				label:SetText(string.format("%s\n(%s)", language.GetPhrase(wep.PrintName), class))

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
	end

	concommand.Add("beatrun_blacklist_menu", function()
		net.Start("Beatrun_RequestBlacklist")
		net.SendToServer()
	end)

	net.Receive("Beatrun_SyncBlacklist", function()
		BEATRUN_WEAPON_BLACKLIST = net.ReadTable()
		OpenBlacklistMenu()
	end)
end

hook.Add("Initialize", "Beaturn_Load_Blacklist", LoadBlacklist)
