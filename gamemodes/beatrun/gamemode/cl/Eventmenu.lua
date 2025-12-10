if not CLIENT then return end

if not AEUI then
	ErrorNoHalt("[EventMenu] AEUI not found! Make sure !UI.lua is loaded before this file.\n")
	return
end

local MainPanel = nil
local PlayersPanel = nil
local CurrentTab = "players"
local PANEL_W = 720
local PANEL_H = 560
local PADDING = 20

local function CloseMenu()
	if PlayersPanel then
		AEUI:RemovePanel(PlayersPanel)
		PlayersPanel = nil
	end

	if MainPanel then
		AEUI:RemovePanel(MainPanel)
		MainPanel = nil
	end

	hook.Remove("Think", "EventMenu_EscapeClose")
end

local function RebuildPlayersPanel()
	if PlayersPanel then AEUI:RemovePanel(PlayersPanel) end

	local content_y = MainPanel and MainPanel.content_y + 45 or 160

	PlayersPanel = {
		x = MainPanel.x + PADDING,
		y = MainPanel.y + content_y,
		w = PANEL_W - PADDING * 2,
		h = PANEL_H - content_y - 40,
		bgcolor = Color(28, 28, 28, 240),
		outlinecolor = Color(60, 60, 60),
		alpha = 1,
		elements = {},
		scroll = 0,
		maxscroll = nil
	}

	AEUI:AddPanel(PlayersPanel)

	local y_offset = 6
	local players = player.GetAll()

	table.sort(players, function(a, b)
		local order = { Member = 1, Suspended = 2, Manager = 3 }

		local sa = a:GetNW2String("EPlayerStatus", "Member")
		local sb = b:GetNW2String("EPlayerStatus", "Member")

		local oa = order[sa] or 99
		local ob = order[sb] or 99
		if oa ~= ob then return oa < ob end

		return string.lower(a:Nick()) < string.lower(b:Nick())
	end)

	for _, ply in ipairs(players) do
		if not IsValid(ply) then continue end

		local status = ply:GetNW2String("EPlayerStatus", "Member")
		if status == "Manager" then continue end

		local sdata = GetStatusData(status)
		local label = ply:Nick() .. " - " .. status

		local btn = AEUI:AddButton(PlayersPanel, label, function()
			local st = ply:GetNW2String("EPlayerStatus", "Member")

			if st == "Suspended" then
				net.Start("Eventmode_Unsuspend")
					net.WriteEntity(ply)
				net.SendToServer()
			elseif st == "Member" then
				net.Start("Eventmode_Suspend")
					net.WriteEntity(ply)
				net.SendToServer()
			end

			timer.Simple(.2, function()
				if MainPanel and CurrentTab == "players" then RebuildPlayersPanel() end
			end)
		end, "AEUIDefault", 8, y_offset, false, sdata.color)

		if btn then
			btn.w = PlayersPanel.w - 16
			btn.h = 24
		end

		y_offset = y_offset + 30
	end
end

local function RebuildMainPanel()
	if MainPanel then AEUI:RemovePanel(MainPanel) end

	if PlayersPanel then
		AEUI:RemovePanel(PlayersPanel)
		PlayersPanel = nil
	end

	local px = math.floor((1920 - PANEL_W) / 2 + 0.5)
	local py = math.floor((1080 - PANEL_H) / 2 + 0.5)

	MainPanel = {
		x = px,
		y = py,
		w = PANEL_W,
		h = PANEL_H,
		bgcolor = Color(18, 18, 18, 240),
		outlinecolor = Color(70, 70, 70),
		alpha = 1,
		elements = {},
		scroll = 0,
		maxscroll = nil
	}

	AEUI:AddPanel(MainPanel)

	AEUI:Text(MainPanel, "Event Mode Manager", "AEUIVeryLarge", MainPanel.w * 0.5, 37.5, true, color_white)

	surface.SetFont("AEUIVeryLarge")
	local _, th_title = surface.GetTextSize("Event Mode Manager")
	local line_gap = 12
	local line_thickness = 2

	AEUI:AddImage(MainPanel, Material("vgui/white"), nil, 20, 30 + th_title * 0.5 + line_gap, MainPanel.w - 40, line_thickness, color_white)

	local line1_y = 30 + th_title * 0.5 + line_gap

	surface.SetFont("AEUILarge")
	local _, th_tab = surface.GetTextSize("PLAYERS")
	local tab_y = line1_y + line_thickness + 35

	local tabs = {
		{ name = "PLAYERS", id = "players" },
		{ name = "ACTIONS", id = "actions" },
		{ name = "SETTINGS", id = "settings" }
	}

	local centers = {
		20 + 140 * 0.5,
		MainPanel.w * 0.5,
		MainPanel.w - 20 - 140 * 0.5
	}

	for i, tab in ipairs(tabs) do
		local btn = AEUI:AddButton(MainPanel, tab.name, function()
			CurrentTab = tab.id
			RebuildMainPanel()
		end, "AEUILarge", centers[i], tab_y, true, color_white)

		if btn then
			btn.w = 140
			btn.h = 28
			if tab.id == CurrentTab then btn.color = Color(0, 200, 0) end
		end
	end

	local line2_y = tab_y + th_tab * 0.5 + line_gap

	AEUI:AddImage(MainPanel, Material("vgui/white"), nil, 20, line2_y, MainPanel.w - 40, line_thickness, color_white)

	MainPanel.content_y = line2_y + line_thickness + 12

	if CurrentTab == "players" then
		AEUI:Text(MainPanel, "Players:", "AEUILarge", 20, MainPanel.content_y, false, color_white)
		RebuildPlayersPanel()

	elseif CurrentTab == "actions" then
		AEUI:Text(MainPanel, "Actions:", "AEUILarge", 20, MainPanel.content_y, false, color_white)

		local y = MainPanel.content_y + 45

		local function AddAction(label, send)
			local btn = AEUI:AddButton(MainPanel, label, function()
				if send then send() end
			end, "AEUIDefault", 20, y, false, color_white)

			if btn then
				btn.w = MainPanel.w - PADDING * 2
				btn.h = 28
			end
			y = y + 30
		end

		AddAction("Bring members", function()
			net.Start("Eventmode_BringMembers") net.SendToServer()
		end)

		AddAction("Set members point", function()
			net.Start("Eventmode_SetSpawn") net.SendToServer()
		end)

		AddAction("Teleport members to point", function()
			net.Start("Eventmode_TeleportMembersToPoint") net.SendToServer()
		end)

		AddAction("Unsuspend all players", function()
			net.Start("Eventmode_UnsuspendAll") net.SendToServer()
		end)

		AddAction("Suspend all players", function()
			net.Start("Eventmode_SuspendAll") net.SendToServer()
		end)

	elseif CurrentTab == "settings" then
		AEUI:Text(MainPanel, "Settings:", "AEUILarge", 20, MainPanel.content_y, false, color_white)

		local y = MainPanel.content_y + 45

		local toggles = {
			{"Allow members prop spawning", "EM_AllowProps"},
			{"Allow members gun spawning", "EM_AllowWeapons"},
			{"New players suspended", "EM_NewPlayersSuspended"},
			{"Suspend at death", "EM_SuspendOnDeath"},
			{"No melee damage", "EM_NoMeleeDamage"},
			{"Hide nametags", "EM_HideNametags"}
		}

		for _, t in ipairs(toggles) do
			local name, var = t[1], t[2]
			local current = GetGlobalBool(var, false)
			local label = string.format("%s: %s", name, current and "YES" or "NO")

			local btn = AEUI:AddButton(MainPanel, label, function()
				net.Start("Eventmode_ToggleVar")
					net.WriteString(var)
				net.SendToServer()

				timer.Simple(0.2, function()
					if MainPanel and CurrentTab == "settings" then RebuildMainPanel() end
				end)
			end, "AEUIDefault", 20, y, false, color_white)

			if btn then
				btn.w = MainPanel.w - PADDING * 2
				btn.h = 26
			end

			y = y + 30
		end
	end
end

local function OpenMenu()
	if MainPanel then
		CloseMenu()
		return
	end

	if not GetGlobalBool("GM_EVENTMODE", false) then return end
	if LocalPlayer():GetNW2String("EPlayerStatus", "Member") ~= "Manager" then return end

	RebuildMainPanel()

	hook.Add("Think", "EventMenu_EscapeClose", function()
		if input.IsKeyDown(KEY_ESCAPE) then CloseMenu() end
	end)
end

concommand.Add("Beatrun_Eventmenu", OpenMenu)

net.Receive("Eventmode_UpdatePlayerStatus", function()
	timer.Simple(.1, function()
		if MainPanel then RebuildMainPanel() end
	end)
end)

hook.Add("ShutDown", "EventMenu_ShutdownRemove", CloseMenu)
hook.Add("InitPostEntity", "EventMenu_Init", function() end)
