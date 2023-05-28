function CLoadout:GetWeaponIcon(class)
	if file.Exists("materials/entities/" .. class .. ".png", "GAME") then return "entities/" .. class .. ".png" end
	if file.Exists("materials/vgui/entities/" .. class .. ".vtf", "GAME") then return "vgui/entities/" .. class end
end

function CLoadout:UpdateLists()
	if IsValid(self.listAvailable) then
		self:UpdateAvailableList()
	end

	if IsValid(self.listLoadoutItems) then
		self:UpdateLoadoutList()
	end
end

function CLoadout:CreateAvailableWeaponIcon(class)
	local weapon = self.weaponRegistry[class]

	if not weapon then return end
	if self.categoryFilter and weapon.category ~= self.categoryFilter then return end

	if self.filter ~= "" then
		local foundClass = string.find(class, self.filter, 1, true)
		local foundName = string.find(string.lower(weapon.name), self.filter, 1, true)

		if not foundClass and not foundName then return end
	end

	local localPly = LocalPlayer()

	local icon = self.listAvailable:Add("CLoadoutWeaponIcon")
	icon:SetWeaponName(weapon.name)
	icon:SetWeaponClass(class)

	icon.DoClick = function()
		if not localPly:IsAdmin() then
			Derma_Message("You can't edit loadouts.", "Loadout editor", "OK")
		else
			self:AddWeapon(class)
			self:UpdateLoadoutList()
			icon:Remove()
		end
	end

	icon.OpenMenu = function()
		local menu = DermaMenu()

		menu:AddOption("Copy to clipboard", function()
			SetClipboardText(class)
		end)

		menu:Open()
	end
end

function CLoadout:UpdateAvailableList()
	self.listAvailable:Clear()

	local inLoadout = {}

	for _, item in ipairs(DATATHEFT_LOADOUTS[self.loadoutIndex]) do
		inLoadout[item[1]] = true
	end

	for class, _ in SortedPairsByMemberValue(self.weaponRegistry, "name") do
		if not inLoadout[class] then
			self:CreateAvailableWeaponIcon(class)
		end
	end

	self.listAvailable:InvalidateLayout(true)
	self.scrollAvailable:InvalidateLayout()
end

function CLoadout:UpdateLoadoutList()
	self.comboLoadouts._blockCallback = true
	self.comboLoadouts:Clear()

	for index, loadout in ipairs(DATATHEFT_LOADOUTS) do
		self.comboLoadouts:AddChoice(tostring(index), nil, index == self.loadoutIndex)
	end

	self.comboLoadouts._blockCallback = nil
	self.listLoadoutItems:Clear()

	local items = DATATHEFT_LOADOUTS[self.loadoutIndex]

	for index, item in ipairs(items) do
		local class = item[1]
		local icon = self.listLoadoutItems:Add("CLoadoutWeaponIcon")
		icon:SetWeaponClass(class)
		icon._itemIndex = index

		icon.DoClick = function()
			self:RemoveWeapon(index)
			self:CreateAvailableWeaponIcon(class)
			icon:Remove()
		end

		local regWeapon = self.weaponRegistry[class]

		if not regWeapon then
			if not self.hintedMissingWeapons then
				self.hintedMissingWeapons = true

				Derma_Message("This loadout has weapons that are currently unavailable.\nMake sure they are installed to use them.", "Missing weapons", "OK")
			end

			icon:SetWeaponName(class)
			icon:SetMaterial("icon16/cancel.png")

			continue
		end

		icon:SetWeaponName(regWeapon.name)

		if regWeapon.adminOnly then
			icon:SetAdminOnly(true)
		end

		if not regWeapon.noPrimary then
			icon.Primary = item[2]
		end

		if not regWeapon.noSecondary then
			icon.Secondary = item[3]
		end
	end

	self.labelCount:SetTextColor(#items > self:GetWeaponLimit() and Color(255, 50, 50) or color_white)
	self.labelCount:SetText(string.format("%d/%d", #items, self:GetWeaponLimit()))
	self.labelCount:SizeToContents()

	self.listLoadoutItems:InvalidateLayout(true)

	self.scrollLoadoutItems:InvalidateLayout()
end

function CLoadout:ShowPanel()
	if IsValid(self.frame) then
		self.frame:Close()
		self.frame = nil

		return
	end

	local frameW = math.max(ScrW() * 0.6, 820)
	local frameH = math.max(ScrH() * 0.6, 500)
	frameW = math.Clamp(frameW, 600, ScrW())
	frameH = math.Clamp(frameH, 400, ScrH())

	local frame = vgui.Create("DFrame")
	frame:SetTitle("Click on any weapon to add/remove it from your loadout.")
	frame:SetPos(0, 0)
	frame:SetSize(frameW, frameH)
	frame:SetSizable(true)
	frame:SetDraggable(true)
	frame:SetDeleteOnClose(true)
	frame:SetScreenLock(true)
	frame:SetMinWidth(600)
	frame:SetMinHeight(400)
	frame:Center()
	frame:MakePopup()

	self.frame = frame

	frame._maximized = false
	frame.btnMaxim:SetDisabled(false)

	frame.btnClose.DoClick = function()
		frame:Close()
	end

	frame.OnClose = function()
		self:Apply()
	end

	local leftPanel = vgui.Create("DPanel", frame)
	local rightPanel = vgui.Create("DPanel", frame)

	local function PaintBackground(_, sw, sh)
		surface.SetDrawColor(32, 32, 32, 255)
		surface.DrawRect(0, 0, sw, sh)
	end

	leftPanel.Paint = PaintBackground
	rightPanel.Paint = PaintBackground

	local div = vgui.Create("DHorizontalDivider", frame)
	div:Dock(FILL)
	div:SetLeft(leftPanel)
	div:SetRight(rightPanel)
	div:SetDividerWidth(4)
	div:SetLeftMin(200)
	div:SetRightMin(200)
	div:SetLeftWidth(frameW * 0.56)

	frame.btnMaxim.DoClick = function()
		if frame._maximized then
			frame:SetSize(frame._oldDimensions[1], frame._oldDimensions[2])
			frame:Center()
			frame._maximized = false
			frame._oldDimensions = nil
		else
			frame._maximized = true

			frame._oldDimensions = {frame:GetWide(), frame:GetTall()}

			frame:SetPos(0, 0)
			frame:SetSize(ScrW(), ScrH())
		end

		frame:SetDraggable(not frame._maximized)
		frame:SetSizable(not frame._maximized)
		div:SetLeftWidth(frame:GetWide() * 0.56)
	end

	----- LEFT PANEL STUFF
	self.comboCategory = vgui.Create("DComboBox", leftPanel)
	self.comboCategory:SetFont("Trebuchet24")
	self.comboCategory:SetSortItems(false)
	self.comboCategory:SetTextColor(Color(150, 255, 150))
	self.comboCategory:SetTall(30)
	self.comboCategory:Dock(TOP)
	self.comboCategory:DockMargin(2, 2, 2, 2)
	self.comboCategory:AddChoice("Available weapons", nil, true)

	for _, name in ipairs(self.categories) do
		self.comboCategory:AddChoice(name)
	end

	self.comboCategory.Paint = function(_, sw, sh)
		surface.SetDrawColor(0, 0, 0, 240)
		surface.DrawRect(0, 0, sw, sh)
	end

	self.comboCategory.OnSelect = function(_, index)
		index = tonumber(index) - 1

		if index == 0 then
			self.categoryFilter = nil
		else
			self.categoryFilter = self.categories[index]
		end

		self:UpdateLists()
	end

	local entrySearch = vgui.Create("DTextEntry", leftPanel)
	entrySearch:SetFont("ChatFont")
	entrySearch:SetMaximumCharCount(64)
	entrySearch:SetTabbingDisabled(true)
	entrySearch:SetPlaceholderText("Search...")
	entrySearch:SetTall(38)
	entrySearch:Dock(BOTTOM)

	entrySearch.OnChange = function(s)
		self.filter = string.lower(string.Trim(s:GetText()))
		self:UpdateAvailableList()
	end

	-- available weapons list
	self.scrollAvailable = vgui.Create("DScrollPanel", leftPanel)
	self.scrollAvailable:Dock(FILL)

	self.listAvailable = vgui.Create("DIconLayout", self.scrollAvailable)
	self.listAvailable:Dock(FILL)
	self.listAvailable:DockMargin(0, 0, 0, 0)
	self.listAvailable:SetSpaceX(4)
	self.listAvailable:SetSpaceY(4)

	----- RIGHT PANEL STUFF
	local panelOptions = vgui.Create("DPanel", rightPanel)
	panelOptions:SetTall(32)
	panelOptions:Dock(TOP)
	panelOptions:DockPadding(2, 2, 2, 2)
	panelOptions:SetPaintBackground(false)

	local buttonCopy = vgui.Create("DButton", panelOptions)
	buttonCopy:SetText("")
	buttonCopy:SetImage("icon16/brick_go.png")
	buttonCopy:SetTooltip("Add weapons from your inventory")
	buttonCopy:SetWide(24)
	buttonCopy:Dock(RIGHT)

	buttonCopy.DoClick = function()
		Derma_Query("This will add all weapons that you're currently holding to this loadout. Continue?", "Add weapons from your inventory", "Yes", function()
			self:AddInventoryWeapons()
		end, "No")
	end

	local buttonRemove = vgui.Create("DButton", panelOptions)
	buttonRemove:SetText("")
	buttonRemove:SetImage("icon16/delete.png")
	buttonRemove:SetTooltip("Delete loadout")
	buttonRemove:SetWide(24)
	buttonRemove:Dock(RIGHT)

	buttonRemove.DoClick = function()
		local loadoutName = DATATHEFT_LOADOUTS[self.loadoutIndex].name
		local helpText = string.format("Are you sure you want to delete \"%s\"?", loadoutName)

		Derma_Query(helpText, "Delete loadout", "Yes", function()
			self:DeleteLoadout(self.loadoutIndex)
			self:Save()
		end, "No")
	end

	local buttonNew = vgui.Create("DButton", panelOptions)
	buttonNew:SetText("")
	buttonNew:SetImage("icon16/add.png")
	buttonNew:SetTooltip("Create loadout")
	buttonNew:SetWide(24)
	buttonNew:Dock(RIGHT)

	buttonNew.DoClick = function()
		self.loadoutIndex = self:CreateLoadout(self.loadoutIndex + 1)
		self:Save()
		self:UpdateLists()
	end

	self.comboLoadouts = vgui.Create("DComboBox", panelOptions)
	self.comboLoadouts:SetFont("Trebuchet24")
	self.comboLoadouts:SetSortItems(false)
	self.comboLoadouts:Dock(FILL)
	self.comboLoadouts:SetTextColor(Color(193, 202, 255))

	self.comboLoadouts.Paint = function(_, sw, sh)
		surface.SetDrawColor(0, 0, 0, 240)
		surface.DrawRect(0, 0, sw, sh)
	end

	self.comboLoadouts.OnSelect = function(s, index)
		if s._blockCallback then return end

		self.loadoutIndex = tonumber(index)
		self.hintedMissingWeapons = nil

		self:UpdateLists()
	end

	local panelToggle = vgui.Create("DPanel", rightPanel)
	panelToggle:SetTall(52)
	panelToggle:Dock(BOTTOM)
	panelToggle:DockPadding(8, 8, 8, 8)
	panelToggle._animState = self.enabled and 1 or 0

	panelToggle.Paint = function(s, sw, sh)
		s._animState = Lerp(FrameTime() * 10, s._animState, self.enabled and 1 or 0)

		surface.SetDrawColor(50 + 50 * (1 - s._animState), 50 + 50 * s._animState, 50)
		surface.DrawRect(0, 0, sw, sh)
	end

	self.labelCount = vgui.Create("DLabel", panelToggle)
	self.labelCount:SetText("0/0")
	self.labelCount:Dock(RIGHT)

	self.scrollLoadoutItems = vgui.Create("DScrollPanel", rightPanel)
	self.scrollLoadoutItems:Dock(FILL)
	self.listLoadoutItems = vgui.Create("DIconLayout", self.scrollLoadoutItems)
	self.listLoadoutItems:Dock(FILL)
	self.listLoadoutItems:DockMargin(0, 0, 0, 0)
	self.listLoadoutItems:SetSpaceX(4)
	self.listLoadoutItems:SetSpaceY(4)

	self:UpdateLists()
end

if engine.ActiveGamemode() == "beatrun" then
	list.Set("DesktopWindows", "CLoadoutDesktopIcon", {
		title = "DataTheft loadouts editor",
		icon = "entities/weapon_smg1.png",
		init = function()
			CLoadout:ShowPanel()
		end
	})
end

do
	local WeaponIcon = {}

	local iconMaterials = {
		ammo = Material("icon16/bullet_yellow.png")
	}

	AccessorFunc(WeaponIcon, "m_bAdminOnly", "AdminOnly")
	AccessorFunc(WeaponIcon, "m_bFavorite", "Favorite")

	function WeaponIcon:Init()
		self:SetPaintBackground(false)
		self:SetSize(140, 128)
		self:SetText("")
		self:SetDoubleClickingEnabled(false)

		self.Image = self:Add("DImage")
		self.Image:SetPos(0, 0)
		self.Image:SetSize(128, 128)
		self.Image:SetVisible(false)
		self.Image:SetKeepAspect(false)

		self.WeaponName = ""
		self.WeaponClass = ""
		self.Border = 0
		self.TextColor = Color(255, 255, 255, 255)
		self.TextOutlineColor = Color(0, 0, 0, 255)
	end

	function WeaponIcon:SetWeaponName(name)
		self.WeaponName = name
	end

	function WeaponIcon:SetWeaponClass(class)
		self.WeaponClass = class
		local icon_path = CLoadout:GetWeaponIcon(class)

		if icon_path then
			self:SetMaterial(icon_path)
		end
	end

	function WeaponIcon:SetMaterial(name)
		self.m_MaterialName = name
		local mat = Material(name)

		if not mat or mat:IsError() then
			name = name:Replace("entities/", "VGUI/entities/")
			name = name:Replace(".png", "")
			mat = Material(name)
		end

		if not mat or mat:IsError() then return end
		self.Image:SetMaterial(mat)
	end

	function WeaponIcon:DoClick()
	end

	function WeaponIcon:OpenMenu()
	end

	function WeaponIcon:PaintOver()
	end

	function WeaponIcon:Paint(w, h)
		self.Border = self.Depressed and 8 or 0
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)

		self.Image:PaintAt(self.Border, self.Border, w - self.Border * 2, h - self.Border * 2)
		render.PopFilterMin()
		render.PopFilterMag()

		if self:IsHovered() or self.Depressed or self:IsChildHovered() then
			surface.SetDrawColor(255, 255, 255, 255)
		else
			surface.SetDrawColor(0, 0, 0, 255)
		end

		surface.DrawOutlinedRect(0, 0, w, h, 4)
		local infoH = 20
		local infoY = h - infoH - 4

		surface.SetDrawColor(30, 30, 30, 240)
		surface.DrawRect(4, infoY, w - 8, infoH)
		draw.SimpleTextOutlined(self.WeaponName, "Default", 8, infoY + infoH * 0.5, self.TextColor, 0, 1, 1, self.TextOutlineColor)
		surface.SetDrawColor(255, 255, 255, 255)

		local str

		if self.Primary then
			if self.Secondary then
				str = self.Primary .. "/" .. self.Secondary
			else
				str = self.Primary
			end
		elseif self.Secondary then
			str = self.Secondary
		end

		if str then
			surface.SetMaterial(iconMaterials.ammo)
			surface.DrawTexturedRect(w - 18, infoY + 3, 16, 16)

			draw.SimpleTextOutlined(str, "Default", w - 18, infoY + infoH * 0.5, self.TextColor, 2, 1, 1, self.TextOutlineColor)
		end
	end

	vgui.Register("CLoadoutWeaponIcon", WeaponIcon, "DButton")
end