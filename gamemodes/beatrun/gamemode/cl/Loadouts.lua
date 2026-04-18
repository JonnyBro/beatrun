BEATRUN_WEAPON_BLACKLIST = BEATRUN_WEAPON_BLACKLIST or {}
BEATRUN_GAMEMODES_LOADOUTS = BEATRUN_GAMEMODES_LOADOUTS or {}

local loadoutsFrame
local blacklistFrame
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
		draw.SimpleText("#beatrun.loadoutseditor.title", "AEUIDefault", 10, 12, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
	left:SetWide(220)
	left:Dock(LEFT)
	left:DockMargin(0, 0, 10, 0)

	left.Paint = function(self, w, h) draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().panels.primary) end

	local loadoutList = vgui.Create("DScrollPanel", left)
	loadoutList:Dock(FILL)

	ApplyScrollTheme(loadoutList)

	local right = vgui.Create("DPanel", loadoutsFrame)
	right:SetTall(100)
	right:Dock(FILL)
	right:DockMargin(0, 0, 10, 0)
	right:DockPadding(10, 10, 10, 10)

	right.Paint = function(self, w, h) draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().panels.primary) end

	local weaponList = vgui.Create("DScrollPanel", right)
	weaponList:Dock(FILL)

	ApplyScrollTheme(weaponList)

	local function BuildWeapons()
		weaponList:Clear()

		local loadout = BEATRUN_GAMEMODES_LOADOUTS[SelectedLoadout]
		if not loadout then return end

		table.sort(loadout, function(a, b) return a < b end)

		for _, class in ipairs(loadout) do
			local wep = weapons.GetStored(class)

			local row = weaponList:Add("DPanel")
			row:SetTall(64)
			row:Dock(TOP)
			row:DockMargin(0, 0, 0, 5)

			row.Paint = function(self, w, h) draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().panels.secondary) end

			local icon = vgui.Create("SpawnIcon", row)
			icon:SetModel(wep.WorldModel or "models/props_junk/watermelon01.mdl")
			icon:SetTooltip(false)
			icon:SetMouseInputEnabled(false)
			icon:SetWide(64)
			icon:Dock(LEFT)

			local label = vgui.Create("DLabel", row)
			label:SetText(string.format("%s\n(%s)", language.GetPhrase(wep.PrintName), class))
			label:SetFont("AEUIDefault")
			label:SetTextColor(CurrentTheme().text.primary)
			label:Dock(FILL)
			label:DockMargin(10, 0, 0, 0)

			local delete = vgui.Create("DButton", row)
			delete:SetText("#beatrun.misc.delete")
			delete:SetFont("AEUIDefault")
			delete:SetTextColor(CurrentTheme().buttons.red.t)
			delete:SetWide(loadoutsFrame:GetWide() / 10)
			delete:Dock(RIGHT)
			delete:DockMargin(0, 10, 10, 10)

			delete.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "red") end

			delete.DoClick = function()
				table.RemoveByValue(loadout, class)

				BuildWeapons()
			end
		end
	end

	local function BuildLoadouts()
		loadoutList:Clear()

		for i, _ in ipairs(BEATRUN_GAMEMODES_LOADOUTS) do
			local row = loadoutList:Add("DButton")
			row:SetText(language.GetPhrase("beatrun.loadoutseditor.loadout"):format(i))
			row:SetFont("AEUIDefault")
			row:SetTextColor(CurrentTheme().buttons.red.t)
			row:SetTall(40)
			row:Dock(TOP)
			row:DockMargin(5, 5, 5, 0)
			row:SetContentAlignment(4)

			row.Paint = function(self, w, h)
				local active = i == SelectedLoadout
				local col = active and CurrentTheme().accent or CurrentTheme().panels.secondary
				draw.RoundedBox(6, 0, 0, w, h, col)
			end

			row.DoClick = function()
				SelectedLoadout = i

				BuildWeapons()
			end
		end

		BuildWeapons()
	end

	local bottomLeft = vgui.Create("DPanel", left)
	bottomLeft:SetTall(100)
	bottomLeft:Dock(BOTTOM)
	bottomLeft:DockPadding(10, 0, 10, 10)
	bottomLeft.Paint = nil

	local add = vgui.Create("DButton", bottomLeft)
	add:SetText("#beatrun.misc.add")
	add:SetFont("AEUIDefault")
	add:SetTextColor(CurrentTheme().buttons.green.t)
	add:SetTall(40)
	add:Dock(TOP)
	add:DockMargin(0, 0, 0, 10)

	add.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

	add.DoClick = function()
		table.insert(BEATRUN_GAMEMODES_LOADOUTS, {})

		SelectedLoadout = #BEATRUN_GAMEMODES_LOADOUTS

		BuildLoadouts()
	end

	local del = vgui.Create("DButton", bottomLeft)
	del:SetText("#beatrun.misc.delete")
	del:SetFont("AEUIDefault")
	del:SetTextColor(CurrentTheme().buttons.red.t)
	del:SetTall(40)
	del:Dock(TOP)

	del.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "red") end

	del.DoClick = function()
		table.remove(BEATRUN_GAMEMODES_LOADOUTS, SelectedLoadout)

		SelectedLoadout = math.Clamp(SelectedLoadout, 1, #BEATRUN_GAMEMODES_LOADOUTS)

		BuildLoadouts()
	end

	local bottomRight = vgui.Create("DPanel", right)
	bottomRight:Dock(BOTTOM)
	bottomRight:SetTall(100)
	bottomRight:DockPadding(10, 10, 10, 10)
	bottomRight.Paint = nil

	local addWeapon = vgui.Create("DButton", bottomRight)
	addWeapon:SetText("#beatrun.loadoutseditor.addweapon")
	addWeapon:SetFont("AEUIDefault")
	addWeapon:SetTextColor(CurrentTheme().buttons.green.t)
	addWeapon:SetTall(40)
	addWeapon:Dock(TOP)
	addWeapon:DockMargin(0, 0, 0, 10)

	addWeapon.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

	addWeapon.DoClick = function()
		local menu = DermaMenu()
		local weps = GetWeaponsList()

		table.sort(weps, function(a, b) return a.ClassName < b.ClassName end)

		for _, wep in ipairs(weps) do
			if string.find(wep.ClassName, "base") then continue end
			if BEATRUN_WEAPON_BLACKLIST[wep.ClassName] then continue end
			if table.HasValue(BEATRUN_GAMEMODES_LOADOUTS[SelectedLoadout], wep.ClassName) then continue end

			menu:AddOption(string.format("%s (%s)", wep.PrintName, wep.ClassName), function()
				table.insert(BEATRUN_GAMEMODES_LOADOUTS[SelectedLoadout], wep.ClassName)

				BuildWeapons()
			end)
		end

		menu:Open()
	end

	local save = vgui.Create("DButton", bottomRight)
	save:SetText("#beatrun.misc.save")
	save:SetFont("AEUIDefault")
	save:SetTextColor(CurrentTheme().buttons.green.t)
	save:SetTall(40)
	save:Dock(TOP)

	save.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

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

	OpenLoadoutsMenu()
end)

net.Receive("Beatrun_SyncLoadouts", function()
	BEATRUN_GAMEMODES_LOADOUTS = net.ReadTable()
end)

local function OpenBlacklistMenu()
	if IsValid(blacklistFrame) then blacklistFrame:Remove() end

	blacklistFrame = vgui.Create("DFrame")
	blacklistFrame:SetTitle("")
	blacklistFrame:SetSize(ScrW() * 0.3, ScrH() * 0.5)
	blacklistFrame:Center()
	blacklistFrame:DockPadding(10, 30, 0, 10)
	blacklistFrame:SetDeleteOnClose(true)
	blacklistFrame:ShowCloseButton(false)
	blacklistFrame:MakePopup()

	blacklistFrame.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, CurrentTheme().bg)
		draw.RoundedBoxEx(8, 0, 0, w, 24, CurrentTheme().header, true, true, false, false)
		draw.SimpleText("#beatrun.blacklisteditor.title", "AEUIDefault", 10, 12, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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

	for _, category in ipairs(sortedCats) do
		local weps = categories[category]

		table.sort(weps, function(a, b) return a.ClassName < b.ClassName end)

		local header = scroll:Add("DPanel")
		header:SetTall(28)
		header:Dock(TOP)
		header:DockMargin(0, 10, 0, 4)

		header.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, CurrentTheme().header)
			draw.SimpleText(category, "AEUIDefault", 10, h / 2, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
			icon:SetModel(wep.WorldModel or "models/props_junk/watermelon01.mdl")
			icon:SetTooltip(false)
			icon:SetMouseInputEnabled(false)
			icon:SetWide(64)
			icon:Dock(LEFT)

			local label = vgui.Create("DLabel", row)
			label:SetText(string.format("%s\n(%s)", language.GetPhrase(wep.PrintName), class))
			label:SetFont("AEUIDefault")
			label:SetTextColor(CurrentTheme().text.primary)
			label:Dock(FILL)
			label:DockMargin(10, 0, 0, 0)

			local toggle = vgui.Create("DButton", row)
			toggle:SetText("")
			toggle:SetWide(110)
			toggle:Dock(RIGHT)
			toggle:DockMargin(0, 6, 6, 6)

			toggle.Paint = function(self, w, h)
				local style = BEATRUN_WEAPON_BLACKLIST[class] and "red" or "green"

				ApplyButtonTheme(self, w, h, style)

				draw.SimpleText(BEATRUN_WEAPON_BLACKLIST[class] and "#beatrun.blacklisteditor.blacklisted" or "#beatrun.blacklisteditor.allowed", "AEUIDefault", w / 2, h / 2, CurrentTheme().buttons[style].t, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			toggle.DoClick = function()
				net.Start("Beatrun_UpdateBlacklist")
					net.WriteString(class)
					net.WriteBool(not BEATRUN_WEAPON_BLACKLIST[class])
				net.SendToServer()
			end
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
