-- format: multiline
local loadoutValues = {
	"#beatrun.randombeatrunloadouts",
	"#beatrun.randommwloadouts",
	"#beatrun.randomarc9loadouts",
	"#beatrun.randomarccwloadouts",
	"#beatrun.randomtfaloadouts",
}

local function ToggleGamemode(gm)
	net.Start("Beatrun_ToggleGamemode")
		net.WriteString(gm)
	net.SendToServer()
end

local function ChangeConvar(convar, value)
	net.Start("Beatrun_ChangeConvar")
		net.WriteString(convar)
		net.WriteString(tostring(value))
	net.SendToServer()
end

hook.Add("AddToolMenuCategories", "Beatrun_Category", function()
	spawnmenu.AddToolCategory("Beatrun", "Client", language.GetPhrase("beatrun.toolsmenu.client"))
	spawnmenu.AddToolCategory("Beatrun", "Server", language.GetPhrase("beatrun.toolsmenu.server"))
	spawnmenu.AddToolCategory("Beatrun", "Extra", language.GetPhrase("beatrun.toolsmenu.extra"))
end)

hook.Add("PopulateToolMenu", "Beatrun_ToolMenu", function()
	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_courses", "#beatrun.toolsmenu.courses.name", "", "", function(panel)
		panel:Clear()
		panel:SetName("#beatrun.toolsmenu.courses.desc")

		panel:CheckBox("#beatrun.toolsmenu.courses.raceyourghost", "Beatrun_CourseGhost")
		panel:ControlHelp("#beatrun.toolsmenu.courses.raceyourghostdesc")

		panel:CheckBox("#beatrun.toolsmenu.courses.faststart", "Beatrun_FastStart")
		panel:ControlHelp("#beatrun.toolsmenu.courses.faststartdesc")

		panel:CheckBox("#beatrun.toolsmenu.courses.checkpointsave", "Beatrun_CPSave")
		panel:ControlHelp("#beatrun.toolsmenu.courses.checkpointsavedesc")

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_hud", "#beatrun.toolsmenu.hud.name", "", "", function(panel)
		panel:Clear()
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
		local HudTextColor = vgui.Create("DColorMixer")
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
		local HudCornerColor = vgui.Create("DColorMixer")
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
		local HudFXPColor = vgui.Create("DColorMixer")
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
		panel:Clear()
		panel:SetName("#beatrun.toolsmenu.camera.desc")

		panel:CheckBox("#beatrun.toolsmenu.camera.colormodifyfilter", "Beatrun_DisableColorFilter")
		panel:ControlHelp("#beatrun.toolsmenu.camera.colormodifyfilterdesc")

		panel:CheckBox("#beatrun.toolsmenu.camera.stabilization", "Beatrun_ViewbobStabilized")
		panel:ControlHelp("#beatrun.toolsmenu.camera.stabilizationdesc")

		panel:NumSlider("#beatrun.toolsmenu.camera.intensity", "Beatrun_ViewbobIntensity", -100, 100, 0)

		panel:NumSlider("#beatrun.toolsmenu.camera.fov", "Beatrun_FOV", 90, 120, 0)
		panel:Help("#beatrun.toolsmenu.camera.fovdesc")
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Client", "beatrun_gameplay", "#beatrun.toolsmenu.gameplay.name", "", "", function(panel)
		panel:Clear()
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
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.puristmodedesc")

		panel:CheckBox("#beatrun.toolsmenu.gameplay.disablegrapple", "Beatrun_DisableGrapple")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.disablegrappledesc")

		local rollSpeedLossToggle = vgui.Create("DCheckBoxLabel")
		rollSpeedLossToggle:SetText("#beatrun.toolsmenu.gameplay.rollspeedloss")
		rollSpeedLossToggle:SetDark(true)
		rollSpeedLossToggle:SetChecked(GetConVar("Beatrun_RollSpeedLoss"):GetBool())
		function rollSpeedLossToggle:OnChange(value)
			ChangeConvar("Beatrun_RollSpeedLoss", value and 1 or 0)
		end
		panel:AddItem(rollSpeedLossToggle)
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.rollspeedlossdesc")

		panel:CheckBox("#beatrun.toolsmenu.moves.totsugekiaudio", "Beatrun_TotsugekiAudio")
		panel:ControlHelp("#beatrun.toolsmenu.moves.totsugekiaudiodesc")

		panel:CheckBox("#beatrun.toolsmenu.gameplay.wind", "Beatrun_Wind")
		panel:ControlHelp("#beatrun.toolsmenu.gameplay.winddesc")
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Server", "beatrun_misc", "#beatrun.toolsmenu.misc.name", "", "", function(panel)
		panel:Clear()
		panel:SetName("#beatrun.toolsmenu.misc.desc")

		local propSpawnToggle = vgui.Create("DCheckBoxLabel")
		propSpawnToggle:SetText("#beatrun.toolsmenu.misc.propspawn")
		propSpawnToggle:SetDark(true)
		propSpawnToggle:SetChecked(GetConVar("Beatrun_AllowPropSpawn"):GetBool())
		function propSpawnToggle:OnChange(value)
			ChangeConvar("Beatrun_AllowPropSpawn", value and 1 or 0)
		end
		panel:AddItem(propSpawnToggle)
		panel:ControlHelp("#beatrun.toolsmenu.misc.propspawndesc")

		local weaponSpawnToggle = vgui.Create("DCheckBoxLabel")
		weaponSpawnToggle:SetText("#beatrun.toolsmenu.misc.weaponspawn")
		weaponSpawnToggle:SetDark(true)
		weaponSpawnToggle:SetChecked(GetConVar("Beatrun_AllowWeaponSpawn"):GetBool())
		function weaponSpawnToggle:OnChange(value)
			print(value)
			print(value and 1 or 0)
			ChangeConvar("Beatrun_AllowWeaponSpawn", value and 1 or 0)
		end
		panel:AddItem(weaponSpawnToggle)
		panel:ControlHelp("#beatrun.toolsmenu.misc.weaponspawndesc")

		local overdriveMpToggle = vgui.Create("DCheckBoxLabel")
		overdriveMpToggle:SetText("#beatrun.toolsmenu.misc.overdrivemp")
		overdriveMpToggle:SetDark(true)
		overdriveMpToggle:SetChecked(GetConVar("Beatrun_AllowOverdriveInMultiplayer"):GetBool())
		function overdriveMpToggle:OnChange(value)
			ChangeConvar("Beatrun_AllowOverdriveInMultiplayer", value and 1 or 0)
		end
		panel:AddItem(overdriveMpToggle)
		panel:ControlHelp("#beatrun.toolsmenu.misc.overdrivempdesc")

		local healthRegenToggle = vgui.Create("DCheckBoxLabel")
		healthRegenToggle:SetText("#beatrun.toolsmenu.misc.healthregen")
		healthRegenToggle:SetDark(true)
		healthRegenToggle:SetChecked(GetConVar("Beatrun_HealthRegen"):GetBool())
		function healthRegenToggle:OnChange(value)
			ChangeConvar("Beatrun_HealthRegen", value and 1 or 0)
		end
		panel:AddItem(healthRegenToggle)
		panel:ControlHelp("#beatrun.toolsmenu.misc.healthregendesc")

		local realisticClimbingToggle = vgui.Create("DCheckBoxLabel")
		realisticClimbingToggle:SetText("#beatrun.toolsmenu.misc.lerealisticclimbing")
		realisticClimbingToggle:SetDark(true)
		realisticClimbingToggle:SetChecked(GetConVar("Beatrun_LeRealisticClimbing"):GetBool())
		function realisticClimbingToggle:OnChange(value)
			ChangeConvar("Beatrun_LeRealisticClimbing", value and 1 or 0)
		end
		panel:AddItem(realisticClimbingToggle)
		panel:ControlHelp("#beatrun.toolsmenu.misc.lerealisticclimbingdesc")
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Server", "beatrun_moves", "#beatrun.toolsmenu.moves.name", "", "", function(panel)
		panel:Clear()
		panel:SetName("#beatrun.toolsmenu.moves.desc")
		panel:Help(language.GetPhrase("beatrun.toolsmenu.moves.help"))

		local speedLimitSlider = vgui.Create("DNumSlider")
		speedLimitSlider:SetText("#beatrun.toolsmenu.moves.speedlimit")
		speedLimitSlider:SetDark(true)
		speedLimitSlider:SetMinMax(325, 1000)
		speedLimitSlider:SetDecimals(0)
		speedLimitSlider:SetValue(GetConVar("Beatrun_SpeedLimit"):GetInt())
		function speedLimitSlider:OnValueChanged(value)
			ChangeConvar("Beatrun_SpeedLimit", math.Truncate(value, 0))
		end
		panel:AddItem(speedLimitSlider)
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.speedlimitdesc"))

		local forcePuristModeToggle = vgui.Create("DCheckBoxLabel")
		forcePuristModeToggle:SetText("#beatrun.toolsmenu.moves.forcepuristmode")
		forcePuristModeToggle:SetDark(true)
		forcePuristModeToggle:SetChecked(GetConVar("Beatrun_PuristModeForce"):GetBool())
		function forcePuristModeToggle:OnChange(value)
			ChangeConvar("Beatrun_PuristModeForce", value and 1 or 0)
		end
		panel:AddItem(forcePuristModeToggle)
		panel:ControlHelp("#beatrun.toolsmenu.moves.forcepuristmodedesc")

		local puristWallrunToggle = vgui.Create("DCheckBoxLabel")
		puristWallrunToggle:SetText("#beatrun.toolsmenu.moves.realisticwallrunning")
		puristWallrunToggle:SetDark(true)
		puristWallrunToggle:SetChecked(GetConVar("Beatrun_PuristWallrun"):GetBool())
		function puristWallrunToggle:OnChange(value)
			ChangeConvar("Beatrun_PuristWallrun", value and 1 or 0)
		end
		panel:AddItem(puristWallrunToggle)
		panel:ControlHelp("#beatrun.toolsmenu.moves.realisticwallrunningdesc")

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		panel:Help("#beatrun.toolsmenu.moves.kickglitch")
		local kickGlitchSelect = vgui.Create("DComboBox")
		kickGlitchSelect:SetValue("#beatrun.toolsmenu.moves.kickglitch" .. GetConVar("Beatrun_Kickglitch"):GetInt())
		kickGlitchSelect:AddChoice("#beatrun.toolsmenu.moves.kickglitch0", 0)
		kickGlitchSelect:AddChoice("#beatrun.toolsmenu.moves.kickglitch1", 1)
		kickGlitchSelect:AddChoice("#beatrun.toolsmenu.moves.kickglitch2", 2)
		kickGlitchSelect:SetSortItems(false)
		function kickGlitchSelect:OnSelect(_, _, value)
			ChangeConvar("Beatrun_Kickglitch", value)
		end
		panel:AddItem(kickGlitchSelect)

		local quakeJumpToggle = vgui.Create("DCheckBoxLabel")
		quakeJumpToggle:SetText("#beatrun.toolsmenu.moves.quakejump")
		quakeJumpToggle:SetDark(true)
		quakeJumpToggle:SetChecked(GetConVar("Beatrun_QuakeJump"):GetBool())
		function quakeJumpToggle:OnChange(value)
			ChangeConvar("Beatrun_QuakeJump", value and 1 or 0)
		end
		panel:AddItem(quakeJumpToggle)
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.quakejumpdesc"))

		local sideStepToggle = vgui.Create("DCheckBoxLabel")
		sideStepToggle:SetText("#beatrun.toolsmenu.moves.sidestep")
		sideStepToggle:SetDark(true)
		sideStepToggle:SetChecked(GetConVar("Beatrun_SideStep"):GetBool())
		function sideStepToggle:OnChange(value)
			ChangeConvar("Beatrun_SideStep", value and 1 or 0)
		end
		panel:AddItem(sideStepToggle)
		panel:ControlHelp(language.GetPhrase("beatrun.toolsmenu.moves.sidestepdesc"))

		local disarmToggle = vgui.Create("DCheckBoxLabel")
		disarmToggle:SetText("#beatrun.toolsmenu.moves.disarm")
		disarmToggle:SetDark(true)
		disarmToggle:SetChecked(GetConVar("Beatrun_Disarm"):GetBool())
		function disarmToggle:OnChange(value)
			ChangeConvar("Beatrun_Disarm", value and 1 or 0)
		end
		panel:AddItem(disarmToggle)
		panel:ControlHelp("#beatrun.toolsmenu.moves.disarmdesc")

		local divider = vgui.Create("DHorizontalDivider")
		panel:AddItem(divider)

		panel:Help("#beatrun.toolsmenu.moves.divesettings")

		local totsugekiToggle = vgui.Create("DCheckBoxLabel")
		totsugekiToggle:SetText("#beatrun.toolsmenu.moves.totsugeki")
		totsugekiToggle:SetDark(true)
		totsugekiToggle:SetChecked(GetConVar("Beatrun_Totsugeki"):GetBool())
		function totsugekiToggle:OnChange(value)
			ChangeConvar("Beatrun_Totsugeki", value and 1 or 0)
		end
		panel:AddItem(totsugekiToggle)
		panel:ControlHelp("#beatrun.toolsmenu.moves.totsugekidesc")

		local totsugekiSpamToggle = vgui.Create("DCheckBoxLabel")
		totsugekiSpamToggle:SetText("#beatrun.toolsmenu.moves.totsugekispam")
		totsugekiSpamToggle:SetDark(true)
		totsugekiSpamToggle:SetChecked(GetConVar("Beatrun_TotsugekiSpam"):GetBool())
		function totsugekiSpamToggle:OnChange(value)
			ChangeConvar("Beatrun_TotsugekiSpam", value and 1 or 0)
		end
		panel:AddItem(totsugekiSpamToggle)
		panel:ControlHelp("#beatrun.toolsmenu.moves.totsugekispamdesc")

		local totsugekiHeadingToggle = vgui.Create("DCheckBoxLabel")
		totsugekiHeadingToggle:SetText("#beatrun.toolsmenu.moves.totsugekiheading")
		totsugekiHeadingToggle:SetDark(true)
		totsugekiHeadingToggle:SetChecked(GetConVar("Beatrun_TotsugekiHeading"):GetBool())
		function totsugekiHeadingToggle:OnChange(value)
			ChangeConvar("Beatrun_TotsugekiHeading", value and 1 or 0)
		end
		panel:AddItem(totsugekiHeadingToggle)
		panel:ControlHelp("#beatrun.toolsmenu.moves.totsugekiheadingdesc")

		local totsugekiDirToggle = vgui.Create("DCheckBoxLabel")
		totsugekiDirToggle:SetText("#beatrun.toolsmenu.moves.totsugekidirection")
		totsugekiDirToggle:SetDark(true)
		totsugekiDirToggle:SetChecked(GetConVar("Beatrun_TotsugekiDir"):GetBool())
		function totsugekiDirToggle:OnChange(value)
			ChangeConvar("Beatrun_TotsugekiDir", value and 1 or 0)
		end
		panel:AddItem(totsugekiDirToggle)
		panel:ControlHelp("#beatrun.toolsmenu.moves.totsugekidirectiondesc")
	end)

	spawnmenu.AddToolMenuOption("Beatrun", "Server", "beatrun_gamemodes", "#beatrun.toolsmenu.gamemodes.name", "", "", function(panel)
		panel:Clear()
		panel:SetName("#beatrun.toolsmenu.gamemodes.desc")

		local infectionStartTimeSlider = vgui.Create("DNumSlider")
		infectionStartTimeSlider:SetText("#beatrun.toolsmenu.gamemodes.infectionstarttime")
		infectionStartTimeSlider:SetDark(true)
		infectionStartTimeSlider:SetMinMax(1, 30)
		infectionStartTimeSlider:SetDecimals(0)
		infectionStartTimeSlider:SetValue(GetConVar("Beatrun_InfectionStartTime"):GetInt())
		function infectionStartTimeSlider:OnValueChanged(value)
			ChangeConvar("Beatrun_InfectionStartTime", math.Truncate(value, 0))
		end
		panel:AddItem(infectionStartTimeSlider)
		panel:Help("#beatrun.toolsmenu.gamemodes.infectiontime")

		local infectionGameTimeSlider = vgui.Create("DNumSlider")
		infectionGameTimeSlider:SetText("#beatrun.toolsmenu.gamemodes.infectiongametime")
		infectionGameTimeSlider:SetDark(true)
		infectionGameTimeSlider:SetMinMax(10, 1200)
		infectionGameTimeSlider:SetDecimals(0)
		infectionGameTimeSlider:SetValue(GetConVar("Beatrun_InfectionGameTime"):GetInt())
		function infectionGameTimeSlider:OnValueChanged(value)
			ChangeConvar("Beatrun_InfectionGameTime", math.Truncate(value, 0))
		end
		panel:AddItem(infectionGameTimeSlider)
		panel:Help("#beatrun.toolsmenu.gamemodes.infectiontime")

		local InfectionButton = vgui.Create("DButton")
		InfectionButton:SetText("#beatrun.toolsmenu.gamemodes.infection")
		InfectionButton:SetSize(0, 20)
		InfectionButton.DoClick = function()
			if GetGlobalBool("GM_DEATHMATCH") or GetGlobalBool("GM_DATATHEFT") or GetGlobalBool("GM_EVENTMODE") then
				InfectionButton:SetText("#beatrun.toolsmenu.gamemodes.error")

				timer.Simple(2, function()
					InfectionButton:SetText("#beatrun.toolsmenu.gamemodes.infection")
				end)

				return
			end

			ToggleGamemode("infection")
		end
		panel:AddItem(InfectionButton)

		local EventmodeButton = vgui.Create("DButton")
		EventmodeButton:SetText("#beatrun.toolsmenu.gamemodes.eventmode")
		EventmodeButton:SetSize(0, 20)
		EventmodeButton.DoClick = function()
			if GetGlobalBool("GM_DEATHMATCH") or GetGlobalBool("GM_DATATHEFT") or GetGlobalBool("GM_INFECTION") then
				EventmodeButton:SetText("#beatrun.toolsmenu.gamemodes.error")

				timer.Simple(2, function()
					EventmodeButton:SetText("#beatrun.toolsmenu.gamemodes.eventmode")
				end)

				return
			end

			ToggleGamemode("eventmode")
		end
		panel:AddItem(EventmodeButton)

		panel:Help("#beatrun.randomloadouts")
		local loadoutSelect = vgui.Create("DComboBox")
		loadoutSelect:SetValue(loadoutValues[GetConVar("Beatrun_RandomLoadouts"):GetInt() or 1])
		loadoutSelect:AddChoice("#beatrun.randombeatrunloadouts", 1)
		loadoutSelect:AddChoice("#beatrun.randommwloadouts", 2)
		loadoutSelect:AddChoice("#beatrun.randomarc9loadouts", 3)
		loadoutSelect:AddChoice("#beatrun.randomarccwloadouts", 4)
		loadoutSelect:AddChoice("#beatrun.randomtfaloadouts", 5)
		loadoutSelect:SetSortItems(false)
		function loadoutSelect:OnSelect(_, _, value)
			ChangeConvar("Beatrun_RandomLoadouts", value)
		end
		panel:AddItem(loadoutSelect)
		panel:ControlHelp("#beatrun.randomloadoutsdesc")

		local DatatheftButton = vgui.Create("DButton")
		DatatheftButton:SetText("#beatrun.toolsmenu.gamemodes.datatheft")
		DatatheftButton:SetSize(0, 20)
		DatatheftButton.DoClick = function()
			if GetGlobalBool("GM_INFECTION") or GetGlobalBool("GM_DEATHMATCH") or GetGlobalBool("GM_EVENTMODE") then
				DatatheftButton:SetText("#beatrun.toolsmenu.gamemodes.error")

				timer.Simple(2, function()
					DatatheftButton:SetText("#beatrun.toolsmenu.gamemodes.datatheft")
				end)

				return
			end

			ToggleGamemode("datatheft")
		end
		panel:AddItem(DatatheftButton)

		local DeathmatchButton = vgui.Create("DButton")
		DeathmatchButton:SetText("#beatrun.toolsmenu.gamemodes.deathmatch")
		DeathmatchButton:SetSize(0, 20)
		DeathmatchButton.DoClick = function()
			if GetGlobalBool("GM_INFECTION") or GetGlobalBool("GM_DATATHEFT") or GetGlobalBool("GM_EVENTMODE") then
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
		panel:Clear()
		panel:SetName("#beatrun.toolsmenu.extra.desc")

		panel:CheckBox("#beatrun.toolsmenu.extra.stats", "Beatrun_HUDStats")
		panel:ControlHelp("#beatrun.toolsmenu.extra.statsdesc")

		panel:CheckBox("#beatrun.toolsmenu.extra.speedrunsverif", "Beatrun_HUDVerification")
		panel:ControlHelp("#beatrun.toolsmenu.extra.speedrunsverifdesc")
	end)
end)
