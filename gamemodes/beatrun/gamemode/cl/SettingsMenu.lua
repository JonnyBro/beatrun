local UI = BeatrunUI
local S, L = UI.S, UI.L

local Frame
local CurrentPage = "hud"

local function ChangeConvar(convar, value)
	net.Start("Beatrun_ChangeConvar")
		net.WriteString(convar)
		net.WriteString(tostring(value))
	net.SendToServer()
end

local GAMEMODES = {
	{ key = "datatheft", global = "GM_DATATHEFT", label = "#beatrun.toolsmenu.gamemodes.datatheft" },
	{ key = "deathmatch", global = "GM_DEATHMATCH", label = "#beatrun.toolsmenu.gamemodes.deathmatch" },
	{ key = "infection", global = "GM_INFECTION", label = "#beatrun.toolsmenu.gamemodes.infection" },
	{ key = "eventmode", global = "GM_EVENTMODE", label = "#beatrun.toolsmenu.gamemodes.eventmode" }
}

local PAGES = {
	{
		key = "hud",
		label = "#beatrun.toolsmenu.hud.name",
		items = {
			{ type = "theme" },
			{ type = "check", convar = "Beatrun_GlobalDermaSkin", optional = true, label = "#beatrun.settings.globalskin", desc = "#beatrun.settings.globalskindesc" },
			{ type = "check", convar = "Beatrun_HUDDynamic", label = "#beatrun.toolsmenu.hud.dynamic", desc = "#beatrun.toolsmenu.hud.dynamicdesc" },
			{ type = "check", convar = "Beatrun_HUDSway", label = "#beatrun.toolsmenu.hud.sway", desc = "#beatrun.toolsmenu.hud.swaydesc" },
			{ type = "check", convar = "Beatrun_Nametags", label = "#beatrun.toolsmenu.hud.nametags", desc = "#beatrun.toolsmenu.hud.nametagsdesc" },
			{ type = "check", convar = "Beatrun_HUDXP", label = "#beatrun.toolsmenu.hud.hudxp", desc = "#beatrun.toolsmenu.hud.hudxpdesc" },
			{ type = "combo", convar = "Beatrun_HUDHidden", label = "#beatrun.toolsmenu.hud.hidden", choices = {
				{ "#beatrun.toolsmenu.hud.hidden0", 0 },
				{ "#beatrun.toolsmenu.hud.hidden1", 1 },
				{ "#beatrun.toolsmenu.hud.hidden2", 2 }
			} },
			{ type = "title", label = "#beatrun.toolsmenu.hud.showspeedometer" },
			{ type = "check", convar = "Beatrun_ShowSpeedometer", label = "#beatrun.toolsmenu.hud.showspeedometer", desc = "#beatrun.toolsmenu.hud.showspeedometerdesc" },
			{ type = "combo", convar = "Beatrun_SpeedometerMode", label = "#beatrun.toolsmenu.hud.speedometermode", choices = {
				{ "#beatrun.toolsmenu.hud.speedometermode1", 1 },
				{ "#beatrun.toolsmenu.hud.speedometermode2", 2 },
				{ "#beatrun.toolsmenu.hud.speedometermode3", 3 }
			} },
			{ type = "title", label = "#beatrun.toolsmenu.hud.keystrokes" },
			{ type = "check", convar = "Beatrun_ShowKeystrokes", label = "#beatrun.toolsmenu.hud.keystrokes", desc = "#beatrun.toolsmenu.hud.keystrokesdesc" },
			{ type = "combo", convar = "Beatrun_KeystrokesCorner", label = "#beatrun.toolsmenu.hud.keystrokes_corner", choices = {
				{ "#beatrun.toolsmenu.hud.keystrokes_corner1", 0 },
				{ "#beatrun.toolsmenu.hud.keystrokes_corner2", 1 },
				{ "#beatrun.toolsmenu.hud.keystrokes_corner3", 2 },
				{ "#beatrun.toolsmenu.hud.keystrokes_corner4", 3 }
			} },
			{ type = "slider", convar = "Beatrun_KeystrokesXOffset", label = "#beatrun.toolsmenu.hud.keystrokes_x_offset", min = 0, max = ScrW },
			{ type = "slider", convar = "Beatrun_KeystrokesYOffset", label = "#beatrun.toolsmenu.hud.keystrokes_y_offset", min = 0, max = ScrH },
			{ type = "title", label = "#beatrun.settings.colors" },
			{ type = "color", convar = "Beatrun_HUDTextColor", label = "#beatrun.toolsmenu.hud.textcolor" },
			{ type = "color", convar = "Beatrun_HUDCornerColor", label = "#beatrun.toolsmenu.hud.cornercolor" },
			{ type = "color", convar = "Beatrun_HUDFloatingXPColor", label = "#beatrun.toolsmenu.hud.floatxpcolor" }
		}
	},
	{
		key = "camera",
		label = "#beatrun.toolsmenu.camera.name",
		items = {
			{ type = "slider", convar = "Beatrun_FOV", label = "#beatrun.toolsmenu.camera.fov", desc = "#beatrun.toolsmenu.camera.fovdesc", min = 70, max = 120 },
			{ type = "check", convar = "Beatrun_ViewbobStabilized", label = "#beatrun.toolsmenu.camera.stabilization", desc = "#beatrun.toolsmenu.camera.stabilizationdesc" },
			{ type = "slider", convar = "Beatrun_ViewbobIntensity", label = "#beatrun.toolsmenu.camera.intensity", min = -100, max = 100 },
			{ type = "check", convar = "Beatrun_DisableColorFilter", label = "#beatrun.toolsmenu.camera.colormodifyfilter", desc = "#beatrun.toolsmenu.camera.colormodifyfilterdesc" }
		}
	},
	{
		key = "gameplay",
		label = "#beatrun.toolsmenu.gameplay.name",
		items = {
			{ type = "combo", convar = "Beatrun_AnimSet", label = "#beatrun.toolsmenu.gameplay.animset", choices = {
				{ "#beatrun.toolsmenu.gameplay.animset1", 0 },
				{ "#beatrun.toolsmenu.gameplay.animset2", 1 }
			} },
			{ type = "check", convar = "Beatrun_CatalystCoil", label = "#beatrun.toolsmenu.gameplay.catalystcoil", desc = "#beatrun.toolsmenu.gameplay.catalystcoildesc" },
			{ type = "check", convar = "Beatrun_QuickturnGround", label = "#beatrun.toolsmenu.gameplay.quickturnground", desc = "#beatrun.toolsmenu.gameplay.quickturngrounddesc" },
			{ type = "check", convar = "Beatrun_QuickturnHandsOnly", label = "#beatrun.toolsmenu.gameplay.quickturnhandsonly", desc = "#beatrun.toolsmenu.gameplay.quickturnhandsonlydesc" },
			{ type = "check", convar = "Beatrun_AutoHandSwitching", label = "#beatrun.toolsmenu.gameplay.autohandswitch", desc = "#beatrun.toolsmenu.gameplay.autohandswitchdesc" },
			{ type = "check", convar = "Beatrun_AutoSprint", label = "#beatrun.toolsmenu.gameplay.autosprint", desc = "#beatrun.toolsmenu.gameplay.autosprintdesc" },
			{ type = "check", convar = "Beatrun_PuristMode", label = "#beatrun.toolsmenu.gameplay.puristmode", desc = "#beatrun.toolsmenu.gameplay.puristmodedesc" },
			{ type = "check", convar = "Beatrun_DisableGrapple", label = "#beatrun.toolsmenu.gameplay.disablegrapple", desc = "#beatrun.toolsmenu.gameplay.disablegrappledesc" },
			{ type = "check", convar = "Beatrun_TotsugekiAudio", label = "#beatrun.toolsmenu.moves.totsugekiaudio", desc = "#beatrun.toolsmenu.moves.totsugekiaudiodesc" },
			{ type = "check", convar = "Beatrun_Wind", label = "#beatrun.toolsmenu.gameplay.wind", desc = "#beatrun.toolsmenu.gameplay.winddesc" },
			{ type = "check", convar = "Beatrun_FaithVO", label = "#beatrun.toolsmenu.gameplay.faithvo", desc = "#beatrun.toolsmenu.gameplay.faithvodesc" },
			{ type = "title", label = "#beatrun.toolsmenu.extra.name" },
			{ type = "help", label = "#beatrun.toolsmenu.extra.desc" },
			{ type = "check", convar = "Beatrun_HUDStats", label = "#beatrun.toolsmenu.extra.stats", desc = "#beatrun.toolsmenu.extra.statsdesc" },
			{ type = "check", convar = "Beatrun_HUDVerification", label = "#beatrun.toolsmenu.extra.speedrunsverif", desc = "#beatrun.toolsmenu.extra.speedrunsverifdesc" }
		}
	},
	{
		key = "server",
		label = "#beatrun.toolsmenu.server",
		admin = true,
		items = {
			{ type = "help", label = "#beatrun.settings.serverhint" },
			{ type = "check", server = true, convar = "Beatrun_AllowPropSpawn", label = "#beatrun.toolsmenu.misc.propspawn", desc = "#beatrun.toolsmenu.misc.propspawndesc" },
			{ type = "check", server = true, convar = "Beatrun_AllowWeaponSpawn", label = "#beatrun.toolsmenu.misc.weaponspawn", desc = "#beatrun.toolsmenu.misc.weaponspawndesc" },
			{ type = "check", server = true, convar = "Beatrun_AllowEntitiesSpawn", label = "#beatrun.toolsmenu.misc.enititesspawn", desc = "#beatrun.toolsmenu.misc.enititesspawndesc" },
			{ type = "check", server = true, convar = "Beatrun_DisableOverdrive", label = "#beatrun.toolsmenu.misc.disableoverdrive", desc = "#beatrun.toolsmenu.misc.disableoverdrivedesc" },
			{ type = "check", server = true, convar = "Beatrun_HealthRegen", label = "#beatrun.toolsmenu.misc.healthregen", desc = "#beatrun.toolsmenu.misc.healthregendesc" },
			{ type = "check", server = true, convar = "Beatrun_LeRealisticClimbing", label = "#beatrun.toolsmenu.misc.lerealisticclimbing", desc = "#beatrun.toolsmenu.misc.lerealisticclimbingdesc" },
			{ type = "check", server = true, convar = "Beatrun_LedgeGrabDamage", label = "#beatrun.toolsmenu.misc.ledgegrabdamage", desc = "#beatrun.toolsmenu.misc.ledgegrabdamagedesc" },
			{ type = "check", server = true, convar = "Beatrun_RollSpeedLoss", label = "#beatrun.toolsmenu.gameplay.rollspeedloss", desc = "#beatrun.toolsmenu.gameplay.rollspeedlossdesc" }
		}
	},
	{
		key = "moves",
		label = "#beatrun.toolsmenu.moves.name",
		admin = true,
		items = {
			{ type = "help", label = "#beatrun.toolsmenu.moves.help" },
			{ type = "slider", server = true, convar = "Beatrun_SpeedLimit", label = "#beatrun.toolsmenu.moves.speedlimit", desc = "#beatrun.toolsmenu.moves.speedlimitdesc", min = 325, max = 1000 },
			{ type = "check", server = true, convar = "Beatrun_PuristModeForce", label = "#beatrun.toolsmenu.moves.forcepuristmode", desc = "#beatrun.toolsmenu.moves.forcepuristmodedesc" },
			{ type = "check", server = true, convar = "Beatrun_PuristWallrun", label = "#beatrun.toolsmenu.moves.realisticwallrunning", desc = "#beatrun.toolsmenu.moves.realisticwallrunningdesc" },
			{ type = "combo", server = true, convar = "Beatrun_Kickglitch", label = "#beatrun.toolsmenu.moves.kickglitch", choices = {
				{ "#beatrun.toolsmenu.moves.kickglitch0", 0 },
				{ "#beatrun.toolsmenu.moves.kickglitch1", 1 },
				{ "#beatrun.toolsmenu.moves.kickglitch2", 2 }
			} },
			{ type = "check", server = true, convar = "Beatrun_Dropkick", label = "#beatrun.toolsmenu.moves.dropkick", desc = "#beatrun.toolsmenu.moves.dropkickdesc" },
			{ type = "check", server = true, convar = "Beatrun_QuakeJump", label = "#beatrun.toolsmenu.moves.quakejump", desc = "#beatrun.toolsmenu.moves.quakejumpdesc" },
			{ type = "check", server = true, convar = "Beatrun_SideStep", label = "#beatrun.toolsmenu.moves.sidestep", desc = "#beatrun.toolsmenu.moves.sidestepdesc" },
			{ type = "check", server = true, convar = "Beatrun_Disarm", label = "#beatrun.toolsmenu.moves.disarm", desc = "#beatrun.toolsmenu.moves.disarmdesc" },
			{ type = "title", label = "#beatrun.toolsmenu.moves.divesettings" },
			{ type = "check", server = true, convar = "Beatrun_Totsugeki", label = "#beatrun.toolsmenu.moves.totsugeki", desc = "#beatrun.toolsmenu.moves.totsugekidesc" },
			{ type = "check", server = true, convar = "Beatrun_TotsugekiSpam", label = "#beatrun.toolsmenu.moves.totsugekispam", desc = "#beatrun.toolsmenu.moves.totsugekispamdesc" },
			{ type = "check", server = true, convar = "Beatrun_TotsugekiHeading", label = "#beatrun.toolsmenu.moves.totsugekiheading", desc = "#beatrun.toolsmenu.moves.totsugekiheadingdesc" },
			{ type = "check", server = true, convar = "Beatrun_TotsugekiDir", label = "#beatrun.toolsmenu.moves.totsugekidirection", desc = "#beatrun.toolsmenu.moves.totsugekidirectiondesc" }
		}
	},
	{
		key = "gamemodes",
		label = "#beatrun.toolsmenu.gamemodes.name",
		admin = true,
		items = {
			{ type = "gamemodes" },
			{ type = "title", label = "#beatrun.toolsmenu.gamemodes.infection" },
			{ type = "slider", server = true, convar = "Beatrun_InfectionStartTime", label = "#beatrun.toolsmenu.gamemodes.infectionstarttime", desc = "#beatrun.toolsmenu.gamemodes.infectiontime", min = 1, max = 30 },
			{ type = "slider", server = true, convar = "Beatrun_InfectionGameTime", label = "#beatrun.toolsmenu.gamemodes.infectiongametime", desc = "#beatrun.toolsmenu.gamemodes.infectiontime", min = 10, max = 1200 },
			{ type = "title", label = "#beatrun.settings.loadouts" },
			{ type = "combo", server = true, convar = "Beatrun_RandomLoadouts", label = "#beatrun.randomloadoutsdesc", choices = {
				{ "#beatrun.randombeatrunloadouts", "beatrun" },
				{ "#beatrun.randomanyloadouts", "any" },
				{ "#beatrun.randommwloadouts", "mg_base" },
				{ "#beatrun.randomarc9loadouts", "arc9" },
				{ "#beatrun.randomarccwloadouts", "arccw" },
				{ "#beatrun.randomtfaloadouts", "tfa_" }
			} },
			{ type = "button", label = "#beatrun.toolsmenu.gamemodes.loadoutseditor", command = "beatrun_loadouts_menu" },
			{ type = "button", label = "#beatrun.toolsmenu.gamemodes.blacklisteditor", command = "beatrun_blacklist_menu" }
		}
	}
}

local function SetValue(item, value)
	if item.server then
		ChangeConvar(item.convar, value)
	else
		RunConsoleCommand(item.convar, tostring(value))
	end
end

local function Description(body, text)
	local hint = UI.MakeLabel(body, text, "AEUIDefault", CurrentTheme().text.muted)
	hint:Dock(TOP)
	hint:DockMargin(0, S(2), 0, S(14))
	hint:SetWrap(true)
	hint:SetAutoStretchVertical(true)

	return hint
end

local function FieldLabel(body, text)
	local label = UI.MakeLabel(body, text, "BeatrunUI")
	label:Dock(TOP)
	label:DockMargin(0, 0, 0, S(6))

	return label
end

local function FieldEnd(body, item)
	if item.desc then
		Description(body, item.desc)
	else
		local spacer = vgui.Create("DPanel", body)
		spacer:SetTall(S(14))
		spacer:Dock(TOP)
		spacer.Paint = nil
	end
end

local builders = {}

builders.title = function(body, item)
	local title = UI.MakeTitle(body, item.label)
	title:DockMargin(0, S(10), 0, S(10))
end

builders.help = function(body, item)
	Description(body, item.label)
end

builders.check = function(body, item)
	local cvar = GetConVar(item.convar)
	local check = vgui.Create("DCheckBoxLabel", body)
	check:SetText(item.label)
	check:SetFont("BeatrunUI")
	check:SetTextColor(CurrentTheme().text.primary)
	check:Dock(TOP)
	check.Button:SetSize(S(20), S(20))

	UI.StyleCheckBox(check.Button)

	if item.server then
		check:SetChecked(cvar and cvar:GetBool() or false)
		check.OnChange = function(_, value) ChangeConvar(item.convar, value and 1 or 0) end
	else
		check:SetConVar(item.convar)
	end

	local hint = Description(body, item.desc or "")
	hint:DockMargin(S(28), S(2), 0, S(14))
end

builders.slider = function(body, item)
	local cvar = GetConVar(item.convar)

	FieldLabel(body, item.label)

	local slider = UI.MakeSlider(body)
	slider:Dock(TOP)
	slider:SetMin(item.min)
	slider:SetMax(isfunction(item.max) and item.max() or item.max)
	slider:SetDecimals(0)

	if item.server then
		slider:SetValue(cvar and cvar:GetFloat() or item.min)
		slider.OnValueChanged = function(_, value)
			timer.Create("BeatrunSettings_" .. item.convar, 0.3, 1, function() ChangeConvar(item.convar, math.Round(value)) end)
		end
	else
		slider:SetConVar(item.convar)
	end

	FieldEnd(body, item)
end

builders.combo = function(body, item)
	local cvar = GetConVar(item.convar)
	local current = cvar and cvar:GetString() or ""

	FieldLabel(body, item.label)

	local combo = UI.MakeComboBox(body)
	combo:Dock(TOP)

	for _, choice in ipairs(item.choices) do
		combo:AddChoice(L(choice[1]), choice[2], tostring(choice[2]) == current)
	end

	combo.OnSelect = function(_, _, _, value) SetValue(item, value) end

	FieldEnd(body, item)
end

builders.theme = function(body)
	FieldLabel(body, "#beatrun.coursesmenu.settings.theme")

	local current = string.lower(UI.ThemeConVar:GetString())
	local combo = UI.MakeComboBox(body)
	combo:Dock(TOP)

	for _, key in ipairs(UI.THEME_ORDER) do
		combo:AddChoice(L("beatrun.coursesmenu.themes." .. key), key, key == current)
	end

	combo.OnSelect = function(_, _, _, key)
		if key == current then return end

		UI.ThemeConVar:SetString(key)

		CloseSettingsMenu()
		OpenSettingsMenu()
	end

	FieldEnd(body, {})
end

builders.color = function(body, item)
	local cvar = GetConVar(item.convar)

	FieldLabel(body, item.label)

	local mixer = vgui.Create("DColorMixer", body)
	mixer:SetTall(S(190))
	mixer:Dock(TOP)
	mixer:DockMargin(0, 0, 0, S(16))
	mixer:SetPalette(false)
	mixer:SetAlphaBar(true)
	mixer:SetWangs(true)

	if cvar then mixer:SetColor(string.ToColor(cvar:GetString())) end

	mixer.ValueChanged = function(_, color) RunConsoleCommand(item.convar, string.FromColor(color)) end
end

builders.button = function(body, item)
	local btn = UI.MakeButton(body, item.label, "secondary", "BeatrunUI")
	btn:Dock(TOP)
	btn:DockMargin(0, 0, 0, S(8))
	btn.DoClick = function() RunConsoleCommand(item.command) end
end

builders.gamemodes = function(body)
	FieldLabel(body, "#beatrun.toolsmenu.gamemodes.desc")

	for _, gm in ipairs(GAMEMODES) do
		local btn = UI.MakeButton(body, gm.label, "secondary", "BeatrunUI")
		btn:Dock(TOP)
		btn:DockMargin(0, 0, 0, S(8))

		btn.Think = function(self)
			local style = GetGlobalBool(gm.global) and "primary" or "secondary"
			if self.style ~= style and not self.errorUntil then self.style = style end

			if self.errorUntil and CurTime() > self.errorUntil then
				self.errorUntil = nil
				self:SetText(gm.label)
			end
		end

		btn.DoClick = function(self)
			for _, other in ipairs(GAMEMODES) do
				if other ~= gm and GetGlobalBool(other.global) then
					self.errorUntil = CurTime() + 2
					self.style = "danger"
					self:SetText("#beatrun.toolsmenu.gamemodes.error")

					return
				end
			end

			net.Start("Beatrun_ToggleGamemode")
				net.WriteString(gm.key)
			net.SendToServer()
		end
	end

	local spacer = vgui.Create("DPanel", body)
	spacer:SetTall(S(6))
	spacer:Dock(TOP)
	spacer.Paint = nil
end

local function BuildPage(content, page)
	content:Clear()

	local scroll = UI.MakeScroll(content)
	local body = scroll:GetCanvas()
	body:DockPadding(S(20), S(16), math.max(S(20), content:GetWide() - S(680)), S(20))

	for _, item in ipairs(page.items) do
		if item.optional and not GetConVar(item.convar) then continue end

		builders[item.type](body, item)
	end
end

function CloseSettingsMenu()
	if IsValid(Frame) then Frame:Remove() end

	Frame = nil
end

function OpenSettingsMenu()
	if IsValid(Frame) then return CloseSettingsMenu() end

	Frame = UI.MakeWindow("#beatrun.settings.title", math.min(ScrW() * 0.8, S(900)), math.min(ScrH() * 0.85, S(780)))

	local tabs = UI.MakeTabBar(Frame, 40)
	tabs.wrap = true

	local content = vgui.Create("DPanel", Frame)
	content:Dock(FILL)
	content.Paint = nil

	local isAdmin = LocalPlayer():IsAdmin()
	local available = {}

	for _, page in ipairs(PAGES) do
		if page.admin and not isAdmin then continue end

		available[page.key] = true

		tabs:AddTab(page.key, page.label, function()
			CurrentPage = page.key

			BuildPage(content, page)
		end)
	end

	Frame:InvalidateLayout(true)
	tabs:Select(available[CurrentPage] and CurrentPage or "hud")
end

concommand.Add("beatrun_settings", OpenSettingsMenu)

list.Set("DesktopWindows", "BeatrunSettings", {
	title = "#beatrun.settings.desktop",
	icon = "vgui/melogo.png",
	width = 1,
	height = 1,
	onewindow = false,
	init = function(_, window)
		window:Remove()

		CloseSettingsMenu()
		OpenSettingsMenu()
	end
})
