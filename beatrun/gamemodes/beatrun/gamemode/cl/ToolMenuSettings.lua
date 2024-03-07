local function ToggleGamemode(gm)
	net.Start("Beatrun_ToggleGamemode")
		net.WriteString(gm)
	net.SendToServer()
end

hook.Add("AddToolMenuCategories", "Beatrun_Category", function()
	spawnmenu.AddToolCategory("Beatrun", "Client", language.GetPhrase("beatrun.toolsmenu.client"))
	spawnmenu.AddToolCategory("Beatrun", "Server", language.GetPhrase("beatrun.toolsmenu.server"))
end)

hook.Add("PopulateToolMenu", "Beatrun_ToolMenu", function()
	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_courses", language.GetPhrase("beatrun.toolsmenu.courses.name"), "", "", function(panel)
		panel:ClearControls()
		panel:SetName("#beatrun.toolsmenu.courses.desc")

		panel:CheckBox("#beatrun.toolsmenu.courses.faststart", "Beatrun_FastStart")
		panel:ControlHelp("#beatrun.toolsmenu.courses.faststartdesc")

		panel:CheckBox("#beatrun.toolsmenu.courses.checkpointsave", "Beatrun_CPSave")
		panel:ControlHelp("#beatrun.toolsmenu.courses.checkpointsavedesc")

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		panel:TextEntry("#beatrun.toolsmenu.courses.database", "Beatrun_Domain")
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.courses.databasedesc"))

		local apiKeyButton = vgui.Create("DButton", panel)
		apiKeyButton:SetText("#beatrun.toolsmenu.courses.changeapikey")
		apiKeyButton:SetSize(0, 20)
		apiKeyButton.DoClick = function()
			local frame = vgui.Create("DFrame")
			frame:SetTitle("#beatrun.toolsmenu.courses.enterapikey")
			frame:SetSize(300, 100)
			frame:SetDeleteOnClose(true)
			frame:Center()
			frame:MakePopup()

			local TextEntry = vgui.Create("DTextEntry", frame)
			TextEntry:Dock(TOP)

			local okButton = vgui.Create("DButton", frame)
			okButton:SetText("#beatrun.misc.ok")
			okButton:SetPos(25, 60)
			okButton:SetSize(250, 30)
			okButton.DoClick = function()
				local key = string.Replace(TextEntry:GetValue(), " ", "")

				RunConsoleCommand("Beatrun_Apikey", key)
				frame:Close()
			end
		end
		panel:AddItem(apiKeyButton)

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		local saveCourseButton = vgui.Create("DButton", panel)
		saveCourseButton:SetText("#beatrun.toolsmenu.courses.savecourse")
		saveCourseButton:SetSize(0, 20)
		saveCourseButton.DoClick = function()
			local frame = vgui.Create("DFrame")
			frame:SetTitle("#beatrun.toolsmenu.courses.namesavecourse")
			frame:SetSize(300, 100)
			frame:SetDeleteOnClose(true)
			frame:Center()
			frame:MakePopup()

			local TextEntry = vgui.Create("DTextEntry", frame)
			TextEntry:Dock(TOP)

			local okButton = vgui.Create("DButton", frame)
			okButton:SetText("#beatrun.misc.ok")
			okButton:SetPos(25, 60)
			okButton:SetSize(250, 30)
			okButton.DoClick = function()
				local name = string.Replace(TextEntry:GetValue(), " ", "_")

				RunConsoleCommand("Beatrun_SaveCourse", name)
				frame:Close()
			end
		end
		panel:AddItem(saveCourseButton)

		local loadCourseButton = vgui.Create("DButton", panel)
		loadCourseButton:SetText("#beatrun.toolsmenu.courses.loadcourse")
		loadCourseButton:SetSize(0, 20)
		loadCourseButton.DoClick = function()
			local frame = vgui.Create("DFrame")
			frame:SetTitle("#beatrun.toolsmenu.courses.enterloadcourse")
			frame:SetSize(300, 100)
			frame:SetDeleteOnClose(true)
			frame:Center()
			frame:MakePopup()

			local TextEntry = vgui.Create("DTextEntry", frame)
			TextEntry:Dock(TOP)

			local okButton = vgui.Create("DButton", frame)
			okButton:SetText("#beatrun.misc.ok")
			okButton:SetPos(25, 60)
			okButton:SetSize(250, 30)
			okButton.DoClick = function()
				local code = string.Replace(TextEntry:GetValue(), " ", "")

				RunConsoleCommand("Beatrun_LoadCode", code)
				frame:Close()
			end
		end
		panel:AddItem(loadCourseButton)

		local uploadCourseButton = vgui.Create("DButton", panel)
		uploadCourseButton:SetText("#beatrun.toolsmenu.courses.uploadcourse")
		uploadCourseButton:SetSize(0, 20)
		uploadCourseButton.DoClick = function()
			RunConsoleCommand("Beatrun_UploadCourse")
			notification.AddLegacy("#beatrun.misc.checkconsole", NOTIFY_HINT, 5)
		end
		panel:AddItem(uploadCourseButton)

		local updateCourseButton = vgui.Create("DButton", panel)
		updateCourseButton:SetText("#beatrun.toolsmenu.courses.updatecourse")
		updateCourseButton:SetSize(0, 20)
		updateCourseButton.DoClick = function()
			local frame = vgui.Create("DFrame")
			frame:SetTitle("#beatrun.toolsmenu.courses.enterloadcourse")
			frame:SetSize(300, 100)
			frame:SetDeleteOnClose(true)
			frame:Center()
			frame:MakePopup()

			local TextEntry = vgui.Create("DTextEntry", frame)
			TextEntry:Dock(TOP)

			local okButton = vgui.Create("DButton", frame)
			okButton:SetText("#beatrun.misc.ok")
			okButton:SetPos(25, 60)
			okButton:SetSize(250, 30)
			okButton.DoClick = function()
				RunConsoleCommand("Beatrun_UpdateCode", TextEntry:GetValue())
				notification.AddLegacy("#beatrun.misc.checkconsole", NOTIFY_HINT, 5)
				frame:Close()
			end
		end
		panel:AddItem(updateCourseButton)
		panel:Help("#beatrun.toolsmenu.courses.updatecoursehelp")
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_hud", "#beatrun.toolsmenu.hud.name", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("#beatrun.toolsmenu.hud.desc")

		panel:CheckBox("#beatrun.toolsmenu.hud.dynamic", "Beatrun_HUDDynamic")
		panel:ControlHelp("#beatrun.toolsmenu.hud.dynamicdesc")

		panel:CheckBox("#beatrun.toolsmenu.hud.sway", "Beatrun_HUDSway")
		panel:ControlHelp("#beatrun.toolsmenu.hud.swaydesc")

		panel:CheckBox("#beatrun.toolsmenu.hud.reticle", "Beatrun_HUDReticle")
		panel:ControlHelp("#beatrun.toolsmenu.hud.reticledesc")

		panel:CheckBox("#beatrun.toolsmenu.hud.nametags", "Beatrun_Nametags")
		panel:ControlHelp("#beatrun.toolsmenu.hud.nametagsdesc")

		panel:CheckBox("#beatrun.toolsmenu.hud.hudxp", "Beatrun_HUDXP")
		panel:ControlHelp("#beatrun.toolsmenu.hud.hudxpdesc")

		panel:CheckBox("#beatrun.toolsmenu.hud.wind", "Beatrun_Wind")
		panel:ControlHelp("#beatrun.toolsmenu.hud.winddesc")

		panel:NumSlider("#beatrun.toolsmenu.hud.fov", "Beatrun_FOV", 90, 120, 0)
		panel:Help("#beatrun.toolsmenu.hud.fovdesc")

		panel:NumSlider("#beatrun.toolsmenu.hud.hidden", "Beatrun_HUDHidden", 0, 2, 0)
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.hud.hiddendesc"))

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		panel:Help("#beatrun.toolsmenu.hud.textcolor")
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

		panel:Help("#beatrun.toolsmenu.hud.cornercolor")
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

		panel:Help("#beatrun.toolsmenu.hud.floatxpcolor")
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

	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_viewbob", "#beatrun.toolsmenu.viewbob.name", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("#beatrun.toolsmenu.viewbob.desc")

		panel:CheckBox("#beatrun.toolsmenu.viewbob.stabilization", "Beatrun_ViewbobStabilized")
		panel:ControlHelp("#beatrun.toolsmenu.viewbob.stabilizationdesc")

		panel:NumSlider("#beatrun.toolsmenu.viewbob.intensity", "Beatrun_ViewbobIntensity", -100, 100, 0)
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_gameplay", "#beatrun.toolsmenu.gameplay.name", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("#beatrun.toolsmenu.gameplay.desc")

		panel:CheckBox("#beatrun.toolsmenu.gameplay.quickturnground", "Beatrun_QuickturnGround")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.quickturngrounddesc")

		panel:CheckBox("#beatrun.toolsmenu.gameplay.quickturnhandsonly", "Beatrun_QuickturnHandsOnly")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.quickturnhandsonlydesc")

		panel:CheckBox("#beatrun.toolsmenu.gameplay.puristmode", "Beatrun_PuristMode")
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.gameplay.puristmodedesc"))

		panel:CheckBox("#beatrun.toolsmenu.gameplay.disablegrapple", "Beatrun_DisableGrapple")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.disablegrappledesc")
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Server", "beatrun_misc", "#beatrun.toolsmenu.misc.name", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("#beatrun.toolsmenu.misc.desc")

		panel:CheckBox("#beatrun.toolsmenu.misc.propspawn", "Beatrun_AllowPropSpawn")
		panel:ControlHelp("#beatrun.toolsmenu.misc.propspawndesc")

		panel:CheckBox("#beatrun.toolsmenu.misc.overdrivemp", "Beatrun_AllowOverdriveInMultiplayer")
		panel:ControlHelp("#beatrun.toolsmenu.misc.overdrivempdesc")

		panel:CheckBox("#beatrun.toolsmenu.misc.healthregen", "Beatrun_HealthRegen")
		panel:ControlHelp("#beatrun.toolsmenu.misc.healthregendesc")
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Server", "beatrun_moves", "#beatrun.toolsmenu.moves.name", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("#beatrun.toolsmenu.moves.desc")
		panel:Help(language.GetPhrase("beatrun.toolsmenu.moves.help"))

		panel:NumSlider("#beatrun.toolsmenu.moves.speedlimit", "Beatrun_SpeedLimit", 325, 1000, 0)
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.speedlimitdesc"))

		panel:CheckBox("#beatrun.toolsmenu.moves.forcepuristmode", "Beatrun_PuristModeForce")
		panel:ControlHelp("#beatrun.toolsmenu.moves.forcepuristmodedesc")

		panel:CheckBox("#beatrun.toolsmenu.moves.realisticwallrunning", "Beatrun_PuristWallrun")
		panel:ControlHelp("#beatrun.toolsmenu.moves.realisticwallrunningdesc")

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		panel:CheckBox("#beatrun.toolsmenu.moves.kickglitch", "Beatrun_KickGlitch")
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.kickglitchdesc"))

		panel:CheckBox("#beatrun.toolsmenu.moves.kickglitchversion", "Beatrun_OldKickGlitch")
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.kickglitchversiondesc"))

		panel:CheckBox("#beatrun.toolsmenu.moves.quakejump", "Beatrun_QuakeJump")
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.quakejumpdesc"))

		panel:CheckBox("#beatrun.toolsmenu.moves.sidestep", "Beatrun_SideStep")
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.sidestepdesc"))

		panel:CheckBox("#beatrun.toolsmenu.moves.disarm", "Beatrun_Disarm")
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.disarmdesc"))

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		panel:Help("#beatrun.toolsmenu.moves.divesettings")

		panel:CheckBox("#beatrun.toolsmenu.moves.totsugeki", "Beatrun_Totsugeki")
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.totsugekidesc"))

		panel:CheckBox("#beatrun.toolsmenu.moves.totsugekispam", "Beatrun_TotsugekiSpam")
		panel:ControlHelp("#beatrun.toolsmenu.moves.totsugekispamdesc")

		panel:CheckBox("#beatrun.toolsmenu.moves.totsugekiheading", "Beatrun_TotsugekiHeading")
		panel:ControlHelp("#beatrun.toolsmenu.moves.totsugekiheadingdesc")

		panel:CheckBox("#beatrun.toolsmenu.moves.totsugekidirection", "Beatrun_TotsugekiDir")
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.totsugekidirectiondesc"))
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Server", "beatrun_gamemodes", "#beatrun.toolsmenu.gamemodes.name", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("#beatrun.toolsmenu.gamemodes.desc")

		panel:NumSlider("#beatrun.toolsmenu.gamemodes.infectionstarttime", "Beatrun_InfectionStartTime", 5, 20, 0)
		panel:Help("#beatrun.toolsmenu.gamemodes.infectiontime")

		panel:NumSlider("#beatrun.toolsmenu.gamemodes.infectiongametime", "Beatrun_InfectionGameTime", 30, 600, 0)
		panel:Help("#beatrun.toolsmenu.gamemodes.infectiontime")

		local InfectionButton = vgui.Create("DButton", panel)
		InfectionButton:SetText("#beatrun.toolsmenu.gamemodes.infection")
		InfectionButton:SetSize(0, 20)
		InfectionButton.DoClick = function()
			if GetGlobalBool("GM_DEATHMATCH") or GetGlobalBool("GM_DATATHEFT") then
				InfectionButton:SetText("#beatrun.toolsmenu.gamemodes.error")

				timer.Simple(2, function()
					InfectionButton:SetText("#beatrun.toolsmenu.gamemodes.infection")
				end)

				return
			end

			ToggleGamemode("infection")
		end
		panel:AddItem(InfectionButton)

		local DatatheftButton = vgui.Create("DButton", panel)
		DatatheftButton:SetText("#beatrun.toolsmenu.gamemodes.datatheft")
		DatatheftButton:SetSize(0, 20)
		DatatheftButton.DoClick = function()
			if GetGlobalBool("GM_INFECTION") or GetGlobalBool("GM_DEATHMATCH") then
				DatatheftButton:SetText("#beatrun.toolsmenu.gamemodes.error")

				timer.Simple(2, function()
					DatatheftButton:SetText("#beatrun.toolsmenu.gamemodes.datatheft")
				end)

				return
			end

			ToggleGamemode("datatheft")
		end
		panel:AddItem(DatatheftButton)

		local DeathmatchButton = vgui.Create("DButton", panel)
		DeathmatchButton:SetText("#beatrun.toolsmenu.gamemodes.deathmatch")
		DeathmatchButton:SetSize(0, 20)
		DeathmatchButton.DoClick = function()
			if GetGlobalBool("GM_INFECTION") or GetGlobalBool("GM_DATATHEFT") then
				DeathmatchButton:SetText("#beatrun.toolsmenu.gamemodes.error")

				timer.Simple(2, function()
					DeathmatchButton:SetText("#beatrun.toolsmenu.gamemodes.deathmatch")
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
