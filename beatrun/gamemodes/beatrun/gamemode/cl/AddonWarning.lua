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
	["1581533176"] = true,
	["2675972006"] = true,
	["378401390"] = true,
	["2027577882"] = true,
	["1190705063"] = true,
	["123514260"] = true,
	["2416989205"] = true,
	["2591814455"] = true,
	["240159269"] = true,
	["2230307188"] = true,
	["2137973704"] = true,
	["577145478"] = true,
	["1632091428"] = true,
	["1622199072"] = true,
	["2840019616"] = true,
	["583517911"] = true,
	["2106330193"] = true,
	["2593047682"] = true,
	["142911907"] = true,
	["2316713217"] = true,
	["2052642961"] = true,
	["2635378860"] = true,
	["2919957168"] = true,
	["104815552"] = true
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
	string = "NOTICE\nPlease disable the following addons before playing\nor submitting any issues to GitHub:"
}

table.insert(warnpanel.elements, warntext)

local quitbutton = {
	type = "Button",
	font = "AEUIDefault",
	x = warnpanel.w * 0.5,
	y = warnpanel.h * 0.85,
	centered = true,
	color = color_white,
	string = "Return to Main Menu",
	onclick = function(self)
		surface.PlaySound("garrysmod/ui_click.wav")
		MsgC(Color(255, 100, 100), "Quitting Beatrun due to conflicting addons!")

		timer.Simple(0.5, function()
			RunConsoleCommand("killserver")
		end)

		self.onclick = nil
	end
}

table.insert(warnpanel.elements, quitbutton)
AEUI:AddButton(warnpanel, "Play", warnclosebutton, "AEUIDefault", warnpanel.w * 0.5, warnpanel.h * 0.93, true)

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

	for k, v in pairs(engine.GetAddons()) do
		if v.mounted and (v.tags:find("tool") or v.tags:find("Fun") or v.tags:find("Realism")) and not v.tags:find("map") and not v.tags:find("Weapon") and not v.tags:find("Model") then
			addons = addons + 1
		end

		if v.mounted and incompatible[v.wsid] then
			conflictlist.string = conflictlist.string .. v.title .. "\n"
		end
	end

	print(conflictlist.string)

	return addons
end

local function WarningIcon()
	if conflictsfound then
		surface.SetFont("BeatrunHUD")
		surface.SetTextPos(2, 0)
		surface.SetTextColor(220, 20, 20, math.abs(math.sin(CurTime() * 2) * 255))
		surface.DrawText("CONFLICTING ADDONS FOUND")

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