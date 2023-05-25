if CLIENT then
	local gamemodePanel = {
		w = 1200,
		h = 650
	}

	gamemodePanel.x = 960 - gamemodePanel.w * 0.5
	gamemodePanel.y = 540 - gamemodePanel.h * 0.5
	gamemodePanel.bgcolor = Color(32, 32, 32)
	gamemodePanel.outlinecolor = Color(54, 55, 56)
	gamemodePanel.alpha = 0.9
	gamemodePanel.elements = {}

	local function closeButton()
		AEUI:Clear()
	end

	local function infectionButton()
		net.Start("Beatrun_ToggleInfection")
		net.SendToServer()
	end

	local function datatheftButton()
		net.Start("Beatrun_ToggleDataTheft")
		net.SendToServer()
	end

	local loadoutnum = 1
	local maxloadoutnum = 1

	local function createButton()
		net.Start("Beatrun_CreateLoadout")
		net.SendToServer()
		maxloadoutnum = maxloadoutnum + 1
		LocalPlayer():EmitSound("buttonclick.wav")
	end

	local function resetloadoutButton()
		net.Start("Beatrun_ResetLoadouts")
		net.SendToServer()
		loadoutnum = 1
		maxloadoutnum = 1
		LocalPlayer():EmitSound("buttonclick.wav")
	end

	local function leftButton()
		if loadoutnum ~= 1 then
			loadoutnum = loadoutnum - 1
			LocalPlayer():EmitSound("buttonclick.wav")
		end
	end

	local function rightButton()
		if loadoutnum ~= maxloadoutnum then
			loadoutnum = loadoutnum + 1
			LocalPlayer():EmitSound("buttonclick.wav")
		end
	end

	local function isSA()
		return not LocalPlayer():IsSuperAdmin()
	end

	AEUI:AddText(gamemodePanel, "Gamemodes Select", "AEUIVeryLarge", 20, 30)
	AEUI:AddButton(gamemodePanel, "  X  ", closeButton, "AEUILarge", gamemodePanel.w - 47, 0)

	local infectionbutton = AEUI:AddButton(gamemodePanel, "Toggle Infection", infectionButton, "AEUILarge", gamemodePanel.w - 330, gamemodePanel.h - 550)
	infectionbutton.greyed = isSA()
	local datatheftbutton = AEUI:AddButton(gamemodePanel, "Toggle Data Theft", datatheftButton, "AEUILarge", gamemodePanel.w - 330, gamemodePanel.h - 450)
	datatheftbutton.greyed = isSA()
	-- local loadoutbutton = AEUI:AddButton(gamemodePanel, "Create a new loadout", createButton, "AEUILarge", gamemodePanel.w - 330, gamemodePanel.h - 450)
	-- loadoutbutton.greyed = isSA()
	-- local resetbutton = AEUI:AddButton(gamemodePanel, "Resets all loadouts", resetloadoutButton, "AEUILarge", gamemodePanel.w - 330, gamemodePanel.h - 550)
	-- resetbutton.greyed = isSA()
	-- local leftloadout = AEUI:AddButton(gamemodePanel, " < ", leftButton, "AEUILarge", gamemodePanel.w - 225, gamemodePanel.h - 175)
	-- leftloadout.greyed = isSA()
	-- local rightloadout = AEUI:AddButton(gamemodePanel, " > ", rightButton, "AEUILarge", gamemodePanel.w - 150, gamemodePanel.h - 175)
	-- rightloadout.greyed = isSA()

	-- AEUI:AddText(gamemodePanel, "Change through loadouts", "AEUILarge", gamemodePanel.w - 360, gamemodePanel.h - 125)

	local weaponsList = {
		w = 800,
		h = 450,
		x = 979.2 - gamemodePanel.w * 0.5,
		y = 648 - gamemodePanel.h * 0.5,
		bgcolor = Color(32, 32, 32),
		outlinecolor = Color(54, 55, 56),
		alpha = 0.9,
		elements = {}
	}

	function OpenGMMenu(ply)
		AEUI:AddPanel(gamemodePanel)
		AEUI:AddPanel(weaponsList)

		for _, v in pairs(weapons.GetList()) do
			local weaponentry = AEUI:AddText(weaponsList, v.ClassName, "AEUILarge", 10, 40 * #weaponsList.elements)

			function weaponentry:onclick()
				LocalPlayer():EmitSound("buttonclick.wav")
			end

			weaponentry.greyed = sacheck
		end
	end

	hook.Add("InitPostEntity", "GMMenuCommand", function()
		concommand.Add("Beatrun_GMMenu", OpenGMMenu)
		hook.Remove("InitPostEntity", "GMMenuCommand")
	end)

	concommand.Add("Beatrun_GMMenu", OpenGMMenu)

	hook.Add("PlayerButtonDown", "GMMenuBind", function(ply, button)
		if (game.SinglePlayer() or CLIENT and IsFirstTimePredicted()) and button == KEY_F3 then
			ply:ConCommand("Beatrun_GMMenu")
		end
	end)
end

if SERVER then
	util.AddNetworkString("Beatrun_ToggleDataTheft")
	util.AddNetworkString("Beatrun_ToggleInfection")

	local datatheft, infection = false

	net.Receive("Beatrun_ToggleDataTheft", function(_, ply)
		datatheft = not datatheft

		if datatheft then
			Beatrun_StartDataTheft()
		else
			Beatrun_StopDataTheft()
		end
	end)

	net.Receive("Beatrun_ToggleInfection", function(_, ply)
		infection = not infection

		if infection then
			Beatrun_StartInfection()
		else
			Beatrun_StopInfection()
		end
	end)
end