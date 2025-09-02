local function ToggleGamemode(gm)
	net.Start("Beatrun_ToggleGamemode")
		net.WriteString(gm)
	net.SendToServer()
end

hook.Add("AddToolMenuCategories", "Beatrun_Category", function()
	spawnmenu.AddToolCategory("Beatrun", "Client", language.GetPhrase("beatrun.toolsmenu.client"))
	spawnmenu.AddToolCategory("Beatrun", "Server", language.GetPhrase("beatrun.toolsmenu.server"))
	spawnmenu.AddToolCategory("Beatrun", "Extra", language.GetPhrase("beatrun.toolsmenu.extra"))
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
			frame:SetSize(300, 110)
			frame:SetDeleteOnClose(true)
			frame:Center()
			frame:MakePopup()

			local text = vgui.Create("DTextEntry", frame)
			text:Dock(TOP)

			local checkbox = vgui.Create("DCheckBox", frame)
			checkbox:SetPos(5, 55)
			checkbox:SetValue(false)

			local slider = vgui.Create("DNumSlider", frame)
			slider:SetText("#beatrun.toolsmenu.courses.savesetspeed")
			slider:SetPos(25, 55)
			slider:SetSize(280, 20)
			slider:SetDecimals(0)
			slider:SetMin(325)
			slider:SetMax(1000)
			slider:SetValue(325)

			local okButton = vgui.Create("DButton", frame)
			okButton:SetText("#beatrun.misc.ok")
			okButton:SetPos(25, 80)
			okButton:SetSize(250, 25)
			okButton.DoClick = function()
				local name = text:GetValue()
				local speed = tostring(slider:GetValue())

				SaveCourse(name, speed or 0)
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

		panel:CheckBox("#beatrun.toolsmenu.hud.nametags", "Beatrun_Nametags")
		panel:ControlHelp("#beatrun.toolsmenu.hud.nametagsdesc")

		panel:CheckBox("#beatrun.toolsmenu.hud.hudxp", "Beatrun_HUDXP")
		panel:ControlHelp("#beatrun.toolsmenu.hud.hudxpdesc")

		panel:CheckBox("#beatrun.toolsmenu.hud.showspeedometer", "Beatrun_ShowSpeedometer")
		panel:ControlHelp("#beatrun.toolsmenu.hud.showspeedometerdesc")

		panel:CheckBox("#beatrun.toolsmenu.hud.keystrokes", "Beatrun_ShowKeystrokes")
		panel:ControlHelp("#beatrun.toolsmenu.hud.keystrokesdesc")

		panel:NumSlider("#beatrun.toolsmenu.hud.keystrokes_x_offset", "Beatrun_KeystrokesXOffset", 0, ScrW(), 0)
		panel:NumSlider("#beatrun.toolsmenu.hud.keystrokes_y_offset", "Beatrun_KeystrokesYOffset", 0, ScrH(), 0)

		local keystrokecorner = panel:ComboBox("#beatrun.toolsmenu.hud.keystrokes_corner", "Beatrun_KeystrokesCorner")
		keystrokecorner:AddChoice("#beatrun.toolsmenu.hud.keystrokes_corner1", 0)
		keystrokecorner:AddChoice("#beatrun.toolsmenu.hud.keystrokes_corner2", 1)
		keystrokecorner:AddChoice("#beatrun.toolsmenu.hud.keystrokes_corner3", 2)
		keystrokecorner:AddChoice("#beatrun.toolsmenu.hud.keystrokes_corner4", 3)
		keystrokecorner:SetSortItems(false)

		local speedomode = panel:ComboBox("#beatrun.toolsmenu.hud.speedometermode", "Beatrun_SpeedometerMode")
		speedomode:AddChoice("#beatrun.toolsmenu.hud.speedometermode1", 1)
		speedomode:AddChoice("#beatrun.toolsmenu.hud.speedometermode2", 2)
		speedomode:AddChoice("#beatrun.toolsmenu.hud.speedometermode3", 3)
		speedomode:SetSortItems(false)

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

	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_camera", "#beatrun.toolsmenu.camera.name", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("#beatrun.toolsmenu.camera.desc")

		panel:CheckBox("#beatrun.toolsmenu.camera.stabilization", "Beatrun_ViewbobStabilized")
		panel:ControlHelp("#beatrun.toolsmenu.camera.stabilizationdesc")

		panel:NumSlider("#beatrun.toolsmenu.camera.intensity", "Beatrun_ViewbobIntensity", -100, 100, 0)

		panel:NumSlider("#beatrun.toolsmenu.camera.fov", "Beatrun_FOV", 90, 120, 0)
		panel:Help("#beatrun.toolsmenu.camera.fovdesc")
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_gameplay", "#beatrun.toolsmenu.gameplay.name", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("#beatrun.toolsmenu.gameplay.desc")

		local animsetting = panel:ComboBox("#beatrun.toolsmenu.gameplay.animset", "Beatrun_AnimSet")
		animsetting:AddChoice("#beatrun.toolsmenu.gameplay.animset1", 0)
		animsetting:AddChoice("#beatrun.toolsmenu.gameplay.animset2", 1)
		animsetting:SetSortItems(false)

		panel:CheckBox("#beatrun.toolsmenu.gameplay.catalystcoil", "Beatrun_CatalystCoil")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.catalystcoildesc")

		panel:CheckBox("#beatrun.toolsmenu.gameplay.quickturnground", "Beatrun_QuickturnGround")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.quickturngrounddesc")

		panel:CheckBox("#beatrun.toolsmenu.gameplay.quickturnhandsonly", "Beatrun_QuickturnHandsOnly")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.quickturnhandsonlydesc")

		panel:CheckBox("#beatrun.toolsmenu.gameplay.autohandswitch", "Beatrun_AutoHandSwitching")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.autohandswitchdesc")

		panel:CheckBox("#beatrun.toolsmenu.gameplay.puristmode", "Beatrun_PuristMode")
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.gameplay.puristmodedesc"))

		panel:CheckBox("#beatrun.toolsmenu.gameplay.disablegrapple", "Beatrun_DisableGrapple")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.disablegrappledesc")

		panel:CheckBox("#beatrun.toolsmenu.gameplay.rollspeedloss", "Beatrun_RollSpeedLoss")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.rollspeedlossdesc")

		panel:CheckBox("#beatrun.toolsmenu.moves.totsugekiaudio", "Beatrun_TotsugekiAudio")
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.totsugekiaudiodesc"))

		panel:CheckBox("#beatrun.toolsmenu.gameplay.wind", "Beatrun_Wind")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.winddesc")
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

		panel:CheckBox("#beatrun.toolsmenu.misc.lerealisticclimbing", "Beatrun_LeRealisticClimbing")
		panel:ControlHelp("#beatrun.toolsmenu.misc.lerealisticclimbingdesc")
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

		local kickglitchdrop = panel:ComboBox("#beatrun.toolsmenu.moves.kickglitch", "Beatrun_Kickglitch")
		kickglitchdrop:AddChoice("#beatrun.toolsmenu.moves.kickglitch1", 1)
		kickglitchdrop:AddChoice("#beatrun.toolsmenu.moves.kickglitch2", 2)
		kickglitchdrop:AddChoice("#beatrun.toolsmenu.moves.kickglitch3", 3)
		kickglitchdrop:SetSortItems(false)

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

		local loadouts = panel:ComboBox("#beatrun.randomloadouts", "Beatrun_RandomLoadouts")
		loadouts:AddChoice("#beatrun.randombeatrunloadouts", 1)
		loadouts:AddChoice("#beatrun.randommwloadouts", 2)
		loadouts:AddChoice("#beatrun.randomarc9loadouts", 3)
		loadouts:AddChoice("#beatrun.randomarccwloadouts", 4)
		loadouts:AddChoice("#beatrun.randomtfaloadouts", 5)
		loadouts:SetSortItems(false)
		panel:ControlHelp("#beatrun.randomloadoutsdesc")

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
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Extra", "beatrun_extra", "#beatrun.toolsmenu.extra.name", "", "", function(panel)
		panel:ClearControls()
		panel:SetName("#beatrun.toolsmenu.extra.desc")

		panel:CheckBox("#beatrun.toolsmenu.extra.stats", "Beatrun_HUDStats")
		panel:ControlHelp("#beatrun.toolsmenu.extra.statsdesc")

		panel:CheckBox("#beatrun.toolsmenu.extra.speedrunsverif", "Beatrun_HUDVerification")
		panel:ControlHelp("#beatrun.toolsmenu.extra.speedrunsverifdesc")
	end)
end)
