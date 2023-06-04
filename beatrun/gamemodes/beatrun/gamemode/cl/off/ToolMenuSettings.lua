local function StartInfection()
	net.Start("Beatrun_ToggleGamemode")
		net.WriteString("infection")
	net.SendToServer()
end

local function StartDataTheft()
	net.Start("Beatrun_ToggleGamemode")
		net.WriteString("datatheft")
	net.SendToServer()
end

hook.Add("AddToolMenuCategories", "Beatrun_Category", function()
	spawnmenu.AddToolCategory("Beatrun", "Client", "Client")
end)

hook.Add("PopulateToolMenu", "Beatrun_ToolMenu", function()
	--[[
		Beatrun_FOV

		Beatrun_HUDXP
		Beatrun_HUDSway
		Beatrun_HUDDynamic
		Beatrun_HUDHidden
		Beatrun_HUDReticle

		Beatrun_HUDTextColor
		Beatrun_HUDCornerColor
		Beatrun_HUDFloatingXPColor

		Beatrun_MinimalVM
		Beatrun_Wind
	--]]
	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_hud", "HUD", "", "", function(panel)
		panel:ClearControls()

		panel:SetName("HUD Setttings")

		panel:CheckBox("Show total XP near your nickname", "Beatrun_HUDXP")
		panel:CheckBox("Display HUD swaying", "Beatrun_HUDSway")
		panel:CheckBox("Hide HUD when moving", "Beatrun_HUDDynamic")
		panel:CheckBox("Display a dot in the center of the screen", "Beatrun_HUDReticle")

		panel:NumSlider("FOV", "Beatrun_FOV", 90, 120, 0)
		panel:ControlHelp("You need to respawn after changing FOV!")

		panel:NumSlider("Hide HUD", "Beatrun_HUDHidden", 0, 2, 0)
		panel:ControlHelp("0 - Shown\n1 - Gamemode only\n2 - Hidden")

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		panel:Help("HUD Text Color")

		local HudTextColor = vgui.Create("DColorMixer", Frame)
		HudTextColor:Dock(FILL)
		HudTextColor:SetPalette(true)
		HudTextColor:SetAlphaBar(true)
		HudTextColor:SetWangs(true)
		HudTextColor:SetColor(string.ToColor(GetConVar("Beatrun_HUDTextColor"):GetString()))
		function HudTextColor:ValueChanged(color)
			RunConsoleCommand("Beatrun_HUDTextColor", string.FromColor(col))
		end

		panel:AddItem(HudTextColor)
	end)
end)