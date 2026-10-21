BEATRUN_WEAPON_BLACKLIST = BEATRUN_WEAPON_BLACKLIST or {}
BEATRUN_GAMEMODES_LOADOUTS = BEATRUN_GAMEMODES_LOADOUTS or {}

local UI = BeatrunUI

local loadoutsFrame
local blacklistFrame
local SelectedLoadout = 1

local function RestoreScroll(scroll, y)
	local vbar = scroll:GetVBar()

	scroll:InvalidateLayout(true)
	vbar:SetScroll(y)

	timer.Simple(0, function() if IsValid(vbar) then vbar:SetScroll(y) end end)
end

local function MakeWeaponRow(scroll, wep, class)
	local S = UI.S

	local row = scroll:Add("DPanel")
	row:SetTall(S(68))
	row:Dock(TOP)
	row:DockMargin(0, 0, S(10), S(6))
	row:DockPadding(S(6), S(6), S(10), S(6))

	row.Paint = function(self, w, h)
		local theme = CurrentTheme()

		UI.PaintPanel(w, h, (self:IsHovered() or self:IsChildHovered()) and theme.panels.secondary or theme.panels.primary)
	end

	local icon = vgui.Create("SpawnIcon", row)
	icon:SetModel(wep and wep.WorldModel or "models/props_junk/watermelon01.mdl")
	icon:SetTooltip(false)
	icon:SetMouseInputEnabled(false)
	icon:SetWide(S(56))
	icon:Dock(LEFT)
	icon:DockMargin(0, 0, S(12), 0)

	return row
end

local function MakeWeaponText(row, wep, class)
	local info = vgui.Create("DPanel", row)
	info:Dock(FILL)
	info.Paint = nil

	local name = UI.MakeLabel(info, language.GetPhrase(wep and wep.PrintName or class), "BeatrunUI")
	name:Dock(TOP)
	name:DockMargin(0, UI.S(6), 0, 0)

	local classLabel = UI.MakeLabel(info, class, "BeatrunUISmall", CurrentTheme().text.muted)
	classLabel:Dock(TOP)
end

local function OpenLoadoutsMenu()
	if IsValid(loadoutsFrame) then loadoutsFrame:Remove() end

	UI = BeatrunUI

	local S = UI.S

	loadoutsFrame = UI.MakeWindow("#beatrun.loadoutseditor.title", math.min(ScrW() * 0.6, S(1150)), math.min(ScrH() * 0.6, S(650)))

	local left = vgui.Create("DPanel", loadoutsFrame)
	left:SetWide(S(240))
	left:Dock(LEFT)
	left:DockMargin(0, 0, S(12), 0)
	left:DockPadding(S(10), S(10), S(10), S(10))

	left.Paint = function(self, w, h) UI.PaintPanel(w, h) end

	local bottomLeft = vgui.Create("DPanel", left)
	bottomLeft:SetTall(S(32) * 2 + S(8))
	bottomLeft:Dock(BOTTOM)
	bottomLeft.Paint = nil

	local loadoutList = UI.MakeScroll(left)
	loadoutList:DockMargin(0, 0, 0, S(10))

	local right = vgui.Create("DPanel", loadoutsFrame)
	right:Dock(FILL)
	right:DockPadding(S(10), S(10), S(10), S(10))

	right.Paint = function(self, w, h) UI.PaintPanel(w, h) end

	local bottomRight = vgui.Create("DPanel", right)
	bottomRight:SetTall(S(32))
	bottomRight:Dock(BOTTOM)
	bottomRight.Paint = nil

	local weaponList = UI.MakeScroll(right)
	weaponList:DockMargin(0, 0, 0, S(10))

	local function BuildWeapons(keepScroll)
		local scrollY = weaponList:GetVBar():GetScroll()

		weaponList:Clear()

		local loadout = BEATRUN_GAMEMODES_LOADOUTS[SelectedLoadout]
		if not loadout then return end

		table.sort(loadout, function(a, b) return a < b end)

		for _, class in ipairs(loadout) do
			local wep = weapons.GetStored(class)
			local row = MakeWeaponRow(weaponList, wep, class)

			local delete = UI.MakeButton(row, "#beatrun.misc.delete", "danger")
			delete:SetWide(math.max(delete:GetWide(), S(110)))
			delete:Dock(RIGHT)
			delete:DockMargin(S(8), S(12), 0, S(12))

			delete.DoClick = function()
				table.RemoveByValue(loadout, class)

				BuildWeapons(true)
			end

			MakeWeaponText(row, wep, class)
		end

		if keepScroll then RestoreScroll(weaponList, scrollY) end
	end

	local function BuildLoadouts(keepWeaponsScroll)
		local scrollY = loadoutList:GetVBar():GetScroll()

		loadoutList:Clear()

		for i, _ in ipairs(BEATRUN_GAMEMODES_LOADOUTS) do
			local row = loadoutList:Add("DButton")
			row:SetText(string.upper(language.GetPhrase("beatrun.loadoutseditor.loadout"):format(i)))
			row:SetFont("BeatrunUI")
			row:SetTall(S(38))
			row:Dock(TOP)
			row:DockMargin(0, 0, S(10), S(4))
			row:SetContentAlignment(4)
			row:SetTextInset(S(14), 0)
			row:SetCursor("hand")

			row.Paint = function(self, w, h)
				local theme = CurrentTheme()
				local active = i == SelectedLoadout

				if active then
					UI.PaintPanel(w, h, theme.panels.secondary, true)
				elseif self:IsHovered() then
					UI.PaintPanel(w, h, theme.panels.secondary)
				end

				self:SetTextColor((active and theme.text.primary) or (self:IsHovered() and theme.accent) or theme.text.muted)
			end

			row.DoClick = function()
				SelectedLoadout = i

				BuildWeapons()
			end
		end

		RestoreScroll(loadoutList, scrollY)

		BuildWeapons(keepWeaponsScroll)
	end

	local add = UI.MakeButton(bottomLeft, "#beatrun.misc.add", "secondary")
	add:Dock(TOP)
	add:DockMargin(0, 0, 0, S(8))

	add.DoClick = function()
		table.insert(BEATRUN_GAMEMODES_LOADOUTS, {})

		SelectedLoadout = #BEATRUN_GAMEMODES_LOADOUTS

		BuildLoadouts()
	end

	local del = UI.MakeButton(bottomLeft, "#beatrun.misc.delete", "danger")
	del:Dock(TOP)

	del.DoClick = function()
		table.remove(BEATRUN_GAMEMODES_LOADOUTS, SelectedLoadout)

		SelectedLoadout = math.Clamp(SelectedLoadout, 1, #BEATRUN_GAMEMODES_LOADOUTS)

		BuildLoadouts()
	end

	local save = UI.MakeButton(bottomRight, "#beatrun.misc.save", "primary")
	save:SetWide(math.max(save:GetWide(), S(140)))
	save:Dock(RIGHT)

	save.DoClick = function()
		net.Start("Beatrun_UpdateLoadouts")
			net.WriteTable(BEATRUN_GAMEMODES_LOADOUTS)
		net.SendToServer()
	end

	local addWeapon = UI.MakeButton(bottomRight, "#beatrun.loadoutseditor.addweapon", "secondary")
	addWeapon:Dock(LEFT)

	addWeapon.DoClick = function()
		local menu = DermaMenu()
		local weps = GetWeaponsList()

		local loadout = BEATRUN_GAMEMODES_LOADOUTS[SelectedLoadout]
		if not istable(loadout) then return end

		table.sort(weps, function(a, b) return a.ClassName < b.ClassName end)

		for _, wep in ipairs(weps) do
			if string.find(wep.ClassName, "base") then continue end
			if BEATRUN_WEAPON_BLACKLIST[wep.ClassName] then continue end
			if table.HasValue(loadout, wep.ClassName) then continue end

			menu:AddOption(string.format("%s (%s)", wep.PrintName, wep.ClassName), function()
				table.insert(loadout, wep.ClassName)

				BuildWeapons(true)
			end)
		end

		menu:Open()
	end

	loadoutsFrame.Refresh = function() BuildLoadouts(true) end

	BuildLoadouts()
end

concommand.Add("beatrun_loadouts_menu", function()
	net.Start("Beatrun_RequestLoadouts")
	net.SendToServer()

	OpenLoadoutsMenu()
end)

net.Receive("Beatrun_SyncLoadouts", function()
	BEATRUN_GAMEMODES_LOADOUTS = net.ReadTable()

	SelectedLoadout = math.Clamp(SelectedLoadout or 1, 1, #BEATRUN_GAMEMODES_LOADOUTS)

	if IsValid(loadoutsFrame) then loadoutsFrame:Refresh() end
end)

local function OpenBlacklistMenu()
	if IsValid(blacklistFrame) then blacklistFrame:Remove() end

	UI = BeatrunUI

	local S = UI.S

	blacklistFrame = UI.MakeWindow("#beatrun.blacklisteditor.title", math.min(ScrW() * 0.35, S(700)), math.min(ScrH() * 0.6, S(700)))

	local scroll = UI.MakeScroll(blacklistFrame)

	local allWeps = GetWeaponsList()
	local categories = {}

	for _, wep in ipairs(allWeps) do
		if not wep.ClassName then continue end
		if string.find(wep.ClassName, "base") then continue end

		local category = wep.Category or "Other"

		categories[category] = categories[category] or {}

		table.insert(categories[category], wep)
	end

	local sortedCats = table.GetKeys(categories)

	table.sort(sortedCats)

	for i, category in ipairs(sortedCats) do
		local weps = categories[category]

		table.sort(weps, function(a, b) return a.ClassName < b.ClassName end)

		local header = UI.MakeTitle(scroll, category)
		header:DockMargin(0, i == 1 and 0 or S(14), 0, S(8))

		for _, wep in ipairs(weps) do
			local class = wep.ClassName
			local row = MakeWeaponRow(scroll, wep, class)

			local toggle = UI.MakeButton(row, "#beatrun.blacklisteditor.allowed", "secondary")
			toggle:SetWide(S(150))
			toggle:Dock(RIGHT)
			toggle:DockMargin(S(8), S(12), 0, S(12))

			toggle.Think = function(self)
				local blocked = BEATRUN_WEAPON_BLACKLIST[class] and true or false
				if self.blocked == blocked then return end

				self.blocked = blocked
				self.style = blocked and "red" or "secondary"
				self:SetText(blocked and "#beatrun.blacklisteditor.blacklisted" or "#beatrun.blacklisteditor.allowed")
			end

			toggle.DoClick = function()
				net.Start("Beatrun_UpdateBlacklist")
					net.WriteString(class)
					net.WriteBool(not BEATRUN_WEAPON_BLACKLIST[class])
				net.SendToServer()
			end

			MakeWeaponText(row, wep, class)
		end
	end
end

concommand.Add("beatrun_blacklist_menu", function()
	net.Start("Beatrun_RequestBlacklist")
	net.SendToServer()

	OpenBlacklistMenu()
end)

net.Receive("Beatrun_SyncBlacklist", function()
	BEATRUN_WEAPON_BLACKLIST = net.ReadTable()
end)
