local gamemodePanel = {
	w = 1200,
	h = 650,
	bgcolor = Color(32, 32, 32),
	outlinecolor = Color(54, 55, 56),
	alpha = 0.9,
	elements = {}
}

gamemodePanel.x = 960 - gamemodePanel.w * 0.5
gamemodePanel.y = 540 - gamemodePanel.h * 0.5

local function closeButton()
	AEUI:Clear()
end

local function infectionButton()
	net.Start("Beatrun_ToggleGamemode")
		net.WriteString("infection")
	net.SendToServer()
end

local function datatheftButton()
	net.Start("Beatrun_ToggleGamemode")
		net.WriteString("datatheft")
	net.SendToServer()
end

-- local function createButton()
-- 	net.Start("Beatrun_CreateLoadout")
-- 	net.SendToServer()
-- 	maxloadoutnum = maxloadoutnum + 1
-- 	LocalPlayer():EmitSound("buttonclick.wav")
-- end

local function isSA()
	return not LocalPlayer():IsSuperAdmin()
end

AEUI:AddText(gamemodePanel, "Gamemodes Select", "AEUIVeryLarge", 20, 30)
AEUI:AddButton(gamemodePanel, "  X  ", closeButton, "AEUILarge", gamemodePanel.w - 47, 0)

local infectionbutton = AEUI:AddButton(gamemodePanel, "Toggle Infection", infectionButton, "AEUILarge", gamemodePanel.w - 330, gamemodePanel.h - 550)
infectionbutton.greyed = isSA
local datatheftbutton = AEUI:AddButton(gamemodePanel, "Toggle Data Theft", datatheftButton, "AEUILarge", gamemodePanel.w - 330, gamemodePanel.h - 450)
datatheftbutton.greyed = isSA
-- local loadoutbutton = AEUI:AddButton(gamemodePanel, "Create a new loadout", createButton, "AEUILarge", gamemodePanel.w - 330, gamemodePanel.h - 450)
-- loadoutbutton.greyed = isSA
-- local resetbutton = AEUI:AddButton(gamemodePanel, "Resets all loadouts", resetloadoutButton, "AEUILarge", gamemodePanel.w - 330, gamemodePanel.h - 550)
-- resetbutton.greyed = isSA
-- local leftloadout = AEUI:AddButton(gamemodePanel, " < ", leftButton, "AEUILarge", gamemodePanel.w - 225, gamemodePanel.h - 175)
-- leftloadout.greyed = isSA
-- local rightloadout = AEUI:AddButton(gamemodePanel, " > ", rightButton, "AEUILarge", gamemodePanel.w - 150, gamemodePanel.h - 175)
-- rightloadout.greyed = isSA
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

	local loaded_weapons = {}

	for i, _ in pairs(DATATHEFT_LOADOUTS) do
		for _, v in pairs(DATATHEFT_LOADOUTS[i]) do
			table.insert(loaded_weapons, v)
		end
	end

	for _, v in pairs(weapons.GetList()) do
		if not string.find(v.ClassName:lower(), "base") then
			local weaponentry = AEUI:AddText(weaponsList, v.ClassName, "AEUILarge", 10, 40 * #weaponsList.elements)
			function weaponentry:onclick()
				LocalPlayer():EmitSound("buttonclick.wav")
			end
			weaponentry.greyed = isSA
		end
	end
end

hook.Add("InitPostEntity", "GMMenuCommand", function()
	concommand.Add("Beatrun_GamemodesMenu", OpenGMMenu)
	hook.Remove("InitPostEntity", "GMMenuCommand")
end)

concommand.Add("Beatrun_GamemodesMenu", OpenGMMenu)