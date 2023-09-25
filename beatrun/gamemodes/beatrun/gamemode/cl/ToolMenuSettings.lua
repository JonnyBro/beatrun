local function ToggleGamemode(gm)
	net.Start("Beatrun_ToggleGamemode")
		net.WriteString(gm)
	net.SendToServer()
end

hook.Add("AddToolMenuCategories", "Beatrun_Category", function()
	spawnmenu.AddToolCategory("Beatrun", "Client", "Client")
	spawnmenu.AddToolCategory("Beatrun", "Server", "Server")
end)

hook.Add("PopulateToolMenu", "Beatrun_ToolMenu", function()
	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_courses", "Courses", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("Courses Setttings")

		panel:CheckBox("Fast Start", "Beatrun_FastStart")
		panel:ControlHelp("Faster countdown in courses")

		panel:CheckBox("Save at Checkpoint", "Beatrun_CPSave")
		panel:ControlHelp("Respawn at last hit checkpoint in courses")

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		panel:TextEntry("Courses server", "Beatrun_Domain")
		panel:ControlHelp("Database domain\nDefault: courses.beatrun.ru")

		local apiKeyButton = vgui.Create("DButton", panel)
		apiKeyButton:SetText("Change API Key")
		apiKeyButton:SetSize(0, 20)
		apiKeyButton.DoClick = function()
			local frame = vgui.Create("DFrame")
			frame:SetTitle("Enter your API Key")
			frame:SetSize(300, 100)
			frame:SetDeleteOnClose(true)
			frame:Center()
			frame:MakePopup()

			local TextEntry = vgui.Create("DTextEntry", frame)
			TextEntry:Dock(TOP)

			local okButton = vgui.Create("DButton", frame)
			okButton:SetText("OK")
			okButton:SetPos(25, 60)
			okButton:SetSize(250, 30)
			okButton.DoClick = function()
				RunConsoleCommand("Beatrun_Apikey", TextEntry:GetValue())
				frame:Close()
			end
		end
		panel:AddItem(apiKeyButton)

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		local saveCourseButton = vgui.Create("DButton", panel)
		saveCourseButton:SetText("Save current course to a file")
		saveCourseButton:SetSize(0, 20)
		saveCourseButton.DoClick = function()
			local frame = vgui.Create("DFrame")
			frame:SetTitle("Enter a name for your course")
			frame:SetSize(300, 100)
			frame:SetDeleteOnClose(true)
			frame:Center()
			frame:MakePopup()

			local TextEntry = vgui.Create("DTextEntry", frame)
			TextEntry:Dock(TOP)

			local okButton = vgui.Create("DButton", frame)
			okButton:SetText("OK")
			okButton:SetPos(25, 60)
			okButton:SetSize(250, 30)
			okButton.DoClick = function()
				RunConsoleCommand("Beatrun_SaveCourse", TextEntry:GetValue())
				frame:Close()
			end
		end
		panel:AddItem(saveCourseButton)

		local loadCodeButton = vgui.Create("DButton", panel)
		loadCodeButton:SetText("Load a course from the database")
		loadCodeButton:SetSize(0, 20)
		loadCodeButton.DoClick = function()
			local frame = vgui.Create("DFrame")
			frame:SetTitle("Enter course code")
			frame:SetSize(300, 100)
			frame:SetDeleteOnClose(true)
			frame:Center()
			frame:MakePopup()

			local TextEntry = vgui.Create("DTextEntry", frame)
			TextEntry:Dock(TOP)

			local okButton = vgui.Create("DButton", frame)
			okButton:SetText("OK")
			okButton:SetPos(25, 60)
			okButton:SetSize(250, 30)
			okButton.DoClick = function()
				RunConsoleCommand("Beatrun_LoadCode", TextEntry:GetValue())
				frame:Close()
			end
		end
		panel:AddItem(loadCodeButton)

		local uploadCourseButton = vgui.Create("DButton", panel)
		uploadCourseButton:SetText("Upload current course to the database")
		uploadCourseButton:SetSize(0, 20)
		uploadCourseButton.DoClick = function()
			RunConsoleCommand("Beatrun_UploadCourse")
			notification.AddLegacy("Open your console for the code!", NOTIFY_HINT, 5)
		end
		panel:AddItem(uploadCourseButton)

		local updateCodeButton = vgui.Create("DButton", panel)
		updateCodeButton:SetText("Update a course on the database")
		updateCodeButton:SetSize(0, 20)
		updateCodeButton.DoClick = function()
			local frame = vgui.Create("DFrame")
			frame:SetTitle("Enter course code")
			frame:SetSize(300, 100)
			frame:SetDeleteOnClose(true)
			frame:Center()
			frame:MakePopup()

			local TextEntry = vgui.Create("DTextEntry", frame)
			TextEntry:Dock(TOP)

			local okButton = vgui.Create("DButton", frame)
			okButton:SetText("OK")
			okButton:SetPos(25, 60)
			okButton:SetSize(250, 30)
			okButton.DoClick = function()
				RunConsoleCommand("Beatrun_UpdateCode", TextEntry:GetValue())
				notification.AddLegacy("Open your console for server's response!", NOTIFY_HINT, 5)
				frame:Close()
			end
		end
		panel:AddItem(updateCodeButton)
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_hud", "HUD", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("HUD Setttings")

		panel:CheckBox("Dynamic HUD", "Beatrun_HUDDynamic")
		panel:ControlHelp("Hides HUD when moving")

		panel:CheckBox("HUD Sway", "Beatrun_HUDSway")
		panel:ControlHelp("Toggles HUD swaying")

		panel:CheckBox("Dot", "Beatrun_HUDReticle")
		panel:ControlHelp("Shows a dot in the center of the screen")

		panel:CheckBox("Nametags", "Beatrun_Nametags")
		panel:ControlHelp("Toggles nametags above players")

		panel:CheckBox("Floating XP", "Beatrun_HUDXP")
		panel:ControlHelp("Show total XP near your nickname")

		panel:CheckBox("Wind", "Beatrun_Wind")
		panel:ControlHelp("Wind noises when running")

		panel:NumSlider("FOV", "Beatrun_FOV", 90, 120, 0)
		panel:ControlHelp("You need to respawn after changing the FOV!")

		panel:NumSlider("Hide HUD", "Beatrun_HUDHidden", 0, 2, 0)
		panel:ControlHelp("0 - Shown\n1 - Gamemode only\n2 - Hidden")

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		panel:Help("HUD Text Color")
		local HudTextColor = vgui.Create("DColorMixer", panel)
		HudTextColor:Dock(FILL)
		HudTextColor:SetPalette(true)
		HudTextColor:SetAlphaBar(true)
		HudTextColor:SetWangs(true)
		HudTextColor:SetColor(string.ToColor(GetConVar("Beatrun_HUDTextColor"):GetString()))
		function HudTextColor:ValueChanged(color)
			RunConsoleCommand("Beatrun_HUDTextColor", string.FromColor(color))
		end
		panel:AddItem(HudTextColor)

		panel:Help("HUD Corners Color")
		local HudCornerColor = vgui.Create("DColorMixer", panel)
		HudCornerColor:Dock(FILL)
		HudCornerColor:SetPalette(true)
		HudCornerColor:SetAlphaBar(true)
		HudCornerColor:SetWangs(true)
		HudCornerColor:SetColor(string.ToColor(GetConVar("Beatrun_HUDCornerColor"):GetString()))
		function HudCornerColor:ValueChanged(color)
			RunConsoleCommand("Beatrun_HUDCornerColor", string.FromColor(color))
		end
		panel:AddItem(HudCornerColor)

		panel:Help("HUD Floating XP Color")
		local HudFXPColor = vgui.Create("DColorMixer", panel)
		HudFXPColor:Dock(FILL)
		HudFXPColor:SetPalette(true)
		HudFXPColor:SetAlphaBar(true)
		HudFXPColor:SetWangs(true)
		HudFXPColor:SetColor(string.ToColor(GetConVar("Beatrun_HUDFloatingXPColor"):GetString()))
		function HudFXPColor:ValueChanged(color)
			RunConsoleCommand("Beatrun_HUDFloatingXPColor", string.FromColor(color))
		end
		panel:AddItem(HudFXPColor)
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_viewbob", "Viewbob", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("Viewbob Settings")

		panel:CheckBox("Viewbob Stabilization", "Beatrun_ViewbobStabilized")
		panel:ControlHelp("Turn on to reduce motion sickness by making viewbobbing keep the player's look position centered")
		panel:NumSlider("Viewbob Intensity", "Beatrun_ViewbobIntensity", -100, 100, 0)
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_gameplay", "Gameplay", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("Gameplay Settings")

		panel:CheckBox("Quickturn", "Beatrun_QuickturnGround")
		panel:ControlHelp("Enables quickturning with secondary attack while on the ground")

		panel:CheckBox("Quickturn Hands Only", "Beatrun_QuickturnHandsOnly")
		panel:ControlHelp("Enables quickturning with \"Runner Hands\" only")

		panel:CheckBox("Purist Mode", "Beatrun_PuristMode")
		panel:ControlHelp("Purist mode is a clientside preference that severely weakens the ability to strafe while in the air, which is how Mirror's Edge games handle this.\nDisabled = No restrictions\nEnabled = Reduced move speed in the air")

		panel:CheckBox("Disable Grapple Ability", "Beatrun_DisableGrapple")
		panel:ControlHelp("Disables grapple ability")
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Server", "beatrun_main", "Main", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("Misc Settings")

		panel:CheckBox("Prop Spawning", "Beatrun_AllowPropSpawn")
		panel:ControlHelp("Allows players without admin rights to spawn props, entities and weapons")

		panel:CheckBox("Overdrive in Multiplayer", "Beatrun_AllowOverdriveInMultiplayer")
		panel:ControlHelp("Allows Overdrive usage on the server\nDoesn't affect singleplayer")
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Server", "beatrun_moves", "Moves", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("Moves Settings")
		panel:Help("You Can Dive with Ctrl + RMB While Midair!\nOverdrive Toggles with E + LMB.")

		panel:NumSlider("Speed Limit", "Beatrun_SpeedLimit", 325, 1000, 0)
		panel:ControlHelp("Changes player's speed limit (325 is default)")

		panel:CheckBox("Force Purist Mode", "Beatrun_PuristModeForce")
		panel:ControlHelp("Forces Purist Mode for all players")

		panel:CheckBox("\"Realistic\" wallrunning", "Beatrun_PuristWallrun")
		panel:ControlHelp("You don't lose speed when starting wallrunning when disabled")

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		panel:CheckBox("Kick-Glitch", "Beatrun_KickGlitch")
		panel:ControlHelp("Toggles Kick-Glitch Move\nLMB when Wallrunning and Then Jumping Right After")

		panel:CheckBox("Kick-Glitch Version", "Beatrun_OldKickGlitch")
		panel:ControlHelp("Enabled - Old Kick-Glitch\nDisabled - New Kick-Glitch\nNew version uses mechanic from Mirror's Edge that spawns a small platform under a player")

		panel:CheckBox("Quake Jump", "Beatrun_QuakeJump")
		panel:ControlHelp("Toggles Quake Jump Move\nPress RMB Right After Side Step")

		panel:CheckBox("Side Step", "Beatrun_SideStep")
		panel:ControlHelp("Toggles Side Step Move\nA/D + RMB")

		panel:CheckBox("Disarm", "Beatrun_Disarm")
		panel:ControlHelp("Toggles Ability to Disarm NPC\nInteract with NPC")

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		panel:Help("Dive Settings")

		panel:CheckBox("Totsugeki", "Beatrun_Totsugeki")
		panel:ControlHelp("Toggles Totsugeki Move\nDive After Quake Jump")

		panel:CheckBox("Totsugeki Spam", "Beatrun_TotsugekiSpam")
		panel:ControlHelp("Toggles Ability to Spam Totsugeki")

		panel:CheckBox("Totsugeki Heading", "Beatrun_TotsugekiHeading")
		panel:ControlHelp("Allows to Totsugeki on X axis (up/down)")

		panel:CheckBox("Totsugeki Direction", "Beatrun_TotsugekiDir")
		panel:ControlHelp("Allows to Totsugeki into Another Direction\nCombined with Spam and Heading Allows You to Fly =)")
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Server", "beatrun_gamemodes", "Gamemodes", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("Gamemodes Settings")

		local InfectionButton = vgui.Create("DButton", panel)
		InfectionButton:SetText("Toggle Infection Gamemode")
		InfectionButton:SetSize(0, 20)
		InfectionButton.DoClick = function()
			if GetGlobalBool("GM_DEATHMATCH") or GetGlobalBool("GM_DATATHEFT") then
				InfectionButton:SetText("Another gamemode is running!")
				timer.Simple(2, function()
					InfectionButton:SetText("Toggle Infection Gamemode")
				end)
				return
			end

			ToggleGamemode("infection")
		end
		panel:AddItem(InfectionButton)

		local DatatheftButton = vgui.Create("DButton", panel)
		DatatheftButton:SetText("Toggle Data Theft Gamemode")
		DatatheftButton:SetSize(0, 20)
		DatatheftButton.DoClick = function()
			if GetGlobalBool("GM_INFECTION") or GetGlobalBool("GM_DEATHMATCH") then
				DatatheftButton:SetText("Another gamemode is running!")
				timer.Simple(2, function()
					DatatheftButton:SetText("Toggle Data Theft Gamemode")
				end)
				return
			end

			ToggleGamemode("datatheft")
		end
		panel:AddItem(DatatheftButton)

		local DeathmatchButton = vgui.Create("DButton", panel)
		DeathmatchButton:SetText("Toggle Deathmatch Gamemode")
		DeathmatchButton:SetSize(0, 20)
		DeathmatchButton.DoClick = function()
			if GetGlobalBool("GM_INFECTION") or GetGlobalBool("GM_DATATHEFT") then
				DeathmatchButton:SetText("Another gamemode is running!")
				timer.Simple(2, function()
					DeathmatchButton:SetText("Toggle Deathmatch Gamemode")
				end)
				return
			end

			ToggleGamemode("deathmatch")
		end
		panel:AddItem(DeathmatchButton)

		-- local divider = vgui.Create("DHorizontalDivider")
		-- panel:AddItem(divider)

		-- local LoadoutMenuButton = vgui.Create("DButton", panel)
		-- LoadoutMenuButton:SetText("Open Loadouts Menu")
		-- LoadoutMenuButton:SetSize(0, 20)
		-- LoadoutMenuButton.DoClick = function()
		-- 	local frame = vgui.Create("DFrame")
		-- 	frame:SetTitle("Loadouts menu")
		-- 	frame:SetSize(400, 300)
		-- 	frame:SetDeleteOnClose(true)
		-- 	frame:Center()
		-- 	frame:MakePopup()

		-- 	local TextEntry = vgui.Create("DTextEntry", frame)
		-- 	TextEntry:Dock(TOP)

		-- 	local okButton = vgui.Create("DButton", frame)
		-- 	okButton:SetText("Change API Key")
		-- 	okButton:SetPos(25, 60)
		-- 	okButton:SetSize(250, 30)
		-- 	okButton.DoClick = function()
		-- 		RunConsoleCommand("Beatrun_LoadoutMenu", TextEntry:GetValue())
		-- 		frame:Close()
		-- 	end
		-- end
		-- panel:AddItem(LoadoutMenuButton)
	end)
end)