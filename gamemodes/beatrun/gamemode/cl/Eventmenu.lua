local UI = BeatrunUI
local S, L = UI.S, UI.L

local Frame
local Content
local Tabs
local CurrentTab = "players"

local SETTINGS = {
	{ "#beatrun.eventmenu.setting.props", "EM_AllowProps" },
	{ "#beatrun.eventmenu.setting.weapons", "EM_AllowWeapons" },
	{ "#beatrun.eventmenu.setting.vehicles", "EM_AllowVehicles" },
	{ "#beatrun.eventmenu.setting.entities", "EM_AllowEntities" },
	{ "#beatrun.eventmenu.setting.newsuspended", "EM_NewPlayersSuspended" },
	{ "#beatrun.eventmenu.setting.suspendondeath", "EM_SuspendOnDeath" },
	{ "#beatrun.eventmenu.setting.nomelee", "EM_NoMeleeDamage" },
	{ "#beatrun.eventmenu.setting.hidenametags", "EM_HideNametags" }
}

local function IsManager()
	return GetGlobalBool("GM_EVENTMODE", false) and LocalPlayer():GetNW2String("EPlayerStatus", "Member") == "Manager"
end

local function Send(message, ply)
	net.Start(message)
		if ply then net.WriteEntity(ply) end
	net.SendToServer()
end

local function MakeRow(parent, height)
	local row = parent:Add("DPanel")
	row:SetTall(S(height))
	row:Dock(TOP)
	row:DockMargin(0, 0, S(10), S(6))
	row:DockPadding(S(12), S(8), S(10), S(8))

	row.Paint = function(self, w, h)
		local theme = CurrentTheme()

		UI.PaintPanel(w, h, (self:IsHovered() or self:IsChildHovered()) and theme.panels.secondary or theme.panels.primary)
	end

	return row
end

local function BuildPlayers()
	local scroll = UI.MakeScroll(Content)

	local players = player.GetAll()
	local order = { Member = 1, Suspended = 2, Manager = 3 }

	table.sort(players, function(a, b)
		local oa = order[a:GetNW2String("EPlayerStatus", "Member")] or 99
		local ob = order[b:GetNW2String("EPlayerStatus", "Member")] or 99

		if oa ~= ob then return oa < ob end

		return string.lower(a:Nick()) < string.lower(b:Nick())
	end)

	local shown = 0

	for _, ply in ipairs(players) do
		if not IsValid(ply) then continue end

		local status = ply:GetNW2String("EPlayerStatus", "Member")
		if status == "Manager" then continue end

		shown = shown + 1

		local sdata = GetStatusData(status)
		local row = MakeRow(scroll, 52)

		local suspended = status == "Suspended"

		local toggle = UI.MakeButton(row, suspended and "#beatrun.eventmenu.unsuspend" or "#beatrun.eventmenu.suspend", suspended and "secondary" or "danger", "BeatrunUISmall")
		toggle:SetWide(math.max(toggle:GetWide(), S(150)))
		toggle:Dock(RIGHT)
		toggle.DoClick = function() Send(suspended and "Eventmode_Unsuspend" or "Eventmode_Suspend", ply) end

		if ply:IsAdmin() then
			local manager = UI.MakeButton(row, "#beatrun.eventmenu.makemanager", "secondary", "BeatrunUISmall")
			manager:Dock(RIGHT)
			manager:DockMargin(0, 0, S(8), 0)
			manager.DoClick = function() Send("Eventmode_Manager", ply) end
		end

		local avatar = vgui.Create("AvatarImage", row)
		avatar:SetPlayer(ply, 64)
		avatar:SetWide(S(36))
		avatar:Dock(LEFT)
		avatar:DockMargin(0, 0, S(12), 0)

		local name = UI.MakeLabel(row, ply:Nick(), "BeatrunUI")
		name:Dock(TOP)

		local statusLabel = UI.MakeLabel(row, string.upper(L(sdata.label_key)), "BeatrunUISmall", sdata.color)
		statusLabel:Dock(TOP)
	end

	if shown == 0 then
		local empty = UI.MakeLabel(scroll, "#beatrun.eventmenu.noplayers", "BeatrunUI", CurrentTheme().text.muted)
		empty:Dock(TOP)
	end
end

local function BuildActions()
	local actions = {
		{ "#beatrun.eventmenu.action.bring", "Eventmode_BringMembers", "secondary" },
		{ "#beatrun.eventmenu.action.setpoint", "Eventmode_SetSpawn", "secondary" },
		{ "#beatrun.eventmenu.action.teleport", "Eventmode_TeleportMembersToPoint", "secondary" },
		{ "#beatrun.eventmenu.action.unsuspendall", "Eventmode_UnsuspendAll", "secondary" },
		{ "#beatrun.eventmenu.action.suspendall", "Eventmode_SuspendAll", "danger" }
	}

	for _, action in ipairs(actions) do
		local row = vgui.Create("DPanel", Content)
		row:SetTall(S(42))
		row:Dock(TOP)
		row:DockMargin(0, 0, 0, S(6))
		row.Paint = nil

		local btn = UI.MakeButton(row, action[1], action[3], "BeatrunUI")
		btn:Dock(FILL)
		btn.DoClick = function() Send(action[2]) end

		local hint = UI.MakeLabel(row, L(action[1] .. ".hint"), "AEUIDefault", CurrentTheme().text.muted)
		hint:SetWide(S(330))
		hint:SetWrap(true)
		hint:Dock(RIGHT)
		hint:DockMargin(S(14), 0, 0, 0)
	end
end

local function BuildSettings()
	for _, setting in ipairs(SETTINGS) do
		local label, var = setting[1], setting[2]

		local row = vgui.Create("DButton", Content)
		row:SetTall(S(40))
		row:Dock(TOP)
		row:DockMargin(0, 0, 0, S(6))
		row:SetText("")
		row:SetCursor("hand")

		row.Paint = function(self, w, h)
			local theme = CurrentTheme()
			local on = GetGlobalBool(var, false)
			local box = h - S(16)

			UI.PaintPanel(w, h, self:IsHovered() and theme.panels.secondary or theme.panels.primary)

			surface.SetDrawColor(self:IsHovered() and theme.accent or theme.border)
			surface.DrawOutlinedRect(S(10), S(8), box, box, 1)

			if on then
				surface.SetDrawColor(theme.accent)
				surface.DrawRect(S(10) + S(4), S(8) + S(4), box - S(8), box - S(8))
			end

			draw.SimpleText(L(label), "BeatrunUI", S(10) + box + S(12), h / 2, theme.text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.upper(L(on and "beatrun.eventmenu.on" or "beatrun.eventmenu.off")), "BeatrunUISmall", w - S(12), h / 2, on and theme.accent or theme.text.muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

		row.DoClick = function()
			net.Start("Eventmode_ToggleVar")
				net.WriteString(var)
			net.SendToServer()
		end
	end
end

local builders = {
	players = BuildPlayers,
	actions = BuildActions,
	settings = BuildSettings
}

local function Rebuild()
	if not IsValid(Content) then return end

	Content:Clear()
	builders[CurrentTab]()
end

local function CloseMenu()
	if IsValid(Frame) then Frame:Remove() end

	Frame = nil
end

local function OpenMenu()
	if IsValid(Frame) then return CloseMenu() end
	if not IsManager() then return end

	Frame = UI.MakeWindow("#beatrun.eventmenu.title", math.min(ScrW() * 0.8, S(860)), math.min(ScrH() * 0.8, S(640)))

	Frame.Think = function(self)
		if not IsManager() then CloseMenu() end
	end

	Tabs = UI.MakeTabBar(Frame, 40)
	Tabs:DockMargin(0, 0, 0, S(12))

	Content = vgui.Create("DPanel", Frame)
	Content:Dock(FILL)
	Content.Paint = nil

	for _, key in ipairs({ "players", "actions", "settings" }) do
		Tabs:AddTab(key, "#beatrun.eventmenu.tab." .. key, function()
			CurrentTab = key
			Rebuild()
		end)
	end

	Tabs:Select(CurrentTab)
end

net.Receive("Eventmode_UpdatePlayerStatus", function()
	timer.Simple(0.1, function()
		if IsValid(Frame) and CurrentTab == "players" then Rebuild() end
	end)
end)

hook.Add("ShutDown", "EventMenu_ShutdownRemove", CloseMenu)

local lastPress = 0

hook.Add("Think", "EventMenu_Open", function()
	if input.IsKeyDown(KEY_F2) and CurTime() > lastPress + 0.2 then
		lastPress = CurTime()

		OpenMenu()
	end
end)
