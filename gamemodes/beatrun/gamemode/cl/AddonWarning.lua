if not game.SinglePlayer() then return end

local conflictsfound = false

local welcome = {
	w = 700,
	h = 400
}

welcome.x = 960 - welcome.w * 0.5
welcome.y = 540 - welcome.h * 0.5
welcome.bgcolor = Color(32, 32, 32)
welcome.outlinecolor = Color(54, 55, 56)
welcome.alpha = 0.9
welcome.elements = {}

local function warnclosebutton(self)
	AEUI:Clear()

	conflictsfound = true
end

local addons = 0

local incompatible = {
	["2155366756"] = true, -- VManip (Base)
	["2364206712"] = true, -- [VManip] Vaulting
	["2416989205"] = true, -- [VManip] Quick Slide
	["1581533176"] = true, -- The Aperture [Reupload]
	["2675972006"] = true, -- Custom Loadout
	["378401390"] = true, -- Quake/Half-Life View bobbing
	["2027577882"] = true, -- Mantle + Wallrun
	["1190705063"] = true, -- Lerped View Models
	["123514260"] = true, -- SharpeYe
	["2416989205"] = true, -- Quick Slide
	["2591814455"] = true, -- [PF] Half-Life: Alyx
	["240159269"] = true, -- S.M.A.R.T.:Smooth Parkour Movement
	["2230307188"] = true, -- EFT Walk Sounds (Footsteps)
	["2137973704"] = true, -- [PF] Modern Warfare 2
	["577145478"] = true, -- ViewMod
	["1632091428"] = true, -- Fine Speed
	["1622199072"] = true, -- SaVav Parkour Mod
	["2840019616"] = true, -- cBobbing (Reupped & Fixed)
	["583517911"] = true, -- Eye View Attachment
	["2106330193"] = true, -- BSMod Punch SWEP + Kick & KillMoves
	["2593047682"] = true, -- Viewpunch Viewbob
	["142911907"] = true, -- Advanced Combat Rolls
	["2316713217"] = true, -- Player Speeds Changer 2.0 [REUPLOAD]
	["2635378860"] = true, -- MW/WZ Skydive/Parachute + Infil
	["2919957168"] = true, -- Modern Warfare II - Takedowns & Revive System
	["2600234804"] = true, -- ASTW2 - Base Weapons
	["2824714462"] = true, -- [TFA] Screen Shake
	["3037375111"] = true, -- Quick Slide With Legs
	["748422181"] = true, -- FOV Changer
	["2919970981"] = true, -- Realistic Fragmentation System [OLD]
	["112806637"] = true, -- Gmod Legs 3
	["678037029"] = true, -- Enhanced Camera
	["2497150824"] = true -- Smooth Camera
}

local warnpanel = {
	w = 500,
	h = 350
}

warnpanel.x = 960 - warnpanel.w * 0.5
warnpanel.y = 540 - warnpanel.h * 0.5
warnpanel.bgcolor = Color(32, 32, 32)
warnpanel.outlinecolor = Color(54, 55, 56)
warnpanel.alpha = 0.9
warnpanel.elements = {}

local conflictpanel = {
	w = 400,
	h = 150,
	x = 1008 - warnpanel.w * 0.5,
	y = 648 - warnpanel.h * 0.5,
	bgcolor = Color(32, 32, 32),
	outlinecolor = Color(54, 55, 56),
	alpha = 1,
	elements = {}
}

local warntext = {
	type = "Text",
	font = "AEUIDefault",
	x = warnpanel.w * 0.5,
	y = warnpanel.h * 0.125,
	centered = true,
	color = color_white,
	string = language.GetPhrase("beatrun.addonwarning.warntext")
}

table.insert(warnpanel.elements, warntext)

local quitbutton = {
	type = "Button",
	font = "AEUIDefault",
	x = warnpanel.w * 0.5,
	y = warnpanel.h * 0.85,
	centered = true,
	color = color_white,
	string = "#beatrun.addonwarning.quitbutton",
	onclick = function(self)
		surface.PlaySound("garrysmod/ui_click.wav")

		timer.Simple(0.2, function()
			RunConsoleCommand("disconnect")
		end)
	end
}

table.insert(warnpanel.elements, quitbutton)
AEUI:AddButton(warnpanel, "#beatrun.addonwarning.play", warnclosebutton, "AEUIDefault", warnpanel.w * 0.5, warnpanel.h * 0.93, true)

local conflictlist = {
	type = "Text",
	font = "AEUIDefault",
	x = 0,
	y = 0,
	centered = false,
	color = color_white,
	string = ""
}

table.insert(conflictpanel.elements, conflictlist)

local function CheckAddons()
	addons = 0

	for _, v in pairs(engine.GetAddons()) do
		if v.mounted and (v.tags:find("tool") or v.tags:find("Fun") or v.tags:find("Realism")) and not v.tags:find("map") and not v.tags:find("Weapon") and not v.tags:find("Model") then
			addons = addons + 1
		end

		if v.mounted and incompatible[v.wsid] then
			conflictlist.string = conflictlist.string .. v.title .. "\n"
		end
	end

	return addons
end

local function WarningIcon()
	if conflictsfound then
		surface.SetFont("BeatrunHUD")
		surface.SetTextPos(2, 0)
		surface.SetTextColor(220, 20, 20, math.abs(math.sin(CurTime() * 2) * 255))
		surface.DrawText("#beatrun.addonwarning.conflictfound")

		return
	else
		surface.SetDrawColor(15, 15, 15, 125)
	end
end

if CheckAddons() >= 1 then
	hook.Add("HUDPaint", "AddonWarning", WarningIcon)
else
	hook.Remove("HUDPaint", "AddonWarning")
end

if conflictlist.string ~= "" then
	timer.Simple(0, function()
		AEUI:AddPanel(warnpanel)
		AEUI:AddPanel(conflictpanel)
	end)
end
