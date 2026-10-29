local UI = BeatrunUI
local S = UI.S

local SKIN = table.Copy(derma.GetNamedSkin("Default"))

SKIN.PrintName = "Beatrun"
SKIN.Author = "Jonny_Bro"

local transparent = Color(0, 0, 0, 0)

local function UpdateColours()
	local t = CurrentTheme()
	local text, muted, accent, border = t.text.primary, t.text.muted, t.accent, t.border
	local c = SKIN.Colours

	SKIN.text_bright = text
	SKIN.text_normal = text
	SKIN.text_dark = text
	SKIN.text_highlight = accent

	SKIN.colTextEntryBG = t.panels.primary
	SKIN.colTextEntryBorder = border
	SKIN.colTextEntryText = text
	SKIN.colTextEntryTextHighlight = accent
	SKIN.colTextEntryTextCursor = t.cursor
	SKIN.colTextEntryTextPlaceholder = muted
	SKIN.colNumSliderNotch = border

	c.Window.TitleActive = text
	c.Window.TitleInactive = muted

	c.Button.Normal = t.buttons.secondary.t
	c.Button.Hover = t.buttons.secondary.ht
	c.Button.Down = t.buttons.secondary.ht
	c.Button.Disabled = t.buttons.disabled.t

	for _, state in ipairs({ "Normal", "Hover", "Down" }) do
		c.Tab.Active[state] = text
		c.Tab.Inactive[state] = state == "Normal" and ColorAlpha(text, 200) or accent
	end

	c.Tab.Active.Disabled = muted
	c.Tab.Inactive.Disabled = muted

	c.Label.Default = text
	c.Label.Bright = text
	c.Label.Dark = text
	c.Label.Highlight = accent

	c.Tree.Lines = border
	c.Tree.Normal = text
	c.Tree.Hover = accent
	c.Tree.Selected = text

	local props = c.Properties
	props.Line_Normal = transparent
	props.Line_Selected = ColorAlpha(accent, 40)
	props.Line_Hover = t.panels.secondary
	props.Title = text
	props.Column_Normal = t.panels.primary
	props.Column_Selected = ColorAlpha(accent, 40)
	props.Column_Hover = t.panels.secondary
	props.Border = border
	props.Label_Normal = text
	props.Label_Selected = text
	props.Label_Hover = accent
	props.Label_Disabled = muted

	c.Category.Header = text
	c.Category.Header_Closed = muted

	for _, line in ipairs({ c.Category.Line, c.Category.LineAlt }) do
		line.Text = text
		line.Text_Hover = accent
		line.Text_Selected = text
		line.Text_Disabled = muted
		line.Button = line == c.Category.LineAlt and t.panels.secondary or transparent
		line.Button_Hover = ColorAlpha(accent, 18)
		line.Button_Selected = ColorAlpha(accent, 40)
		line.Button_Disabled = transparent
	end

	c.TooltipText = text
end

local function Fill(w, h, color)
	draw.RoundedBox(S(CurrentTheme().radius), 0, 0, w, h, color)
end

local function Outline(w, h, color)
	surface.SetDrawColor(color)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
end

local function Glyph(text, w, h, color)
	draw.SimpleText(text, "DermaDefault", w / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function StateColor(panel, normal)
	local t = CurrentTheme()

	if not panel:IsEnabled() then return t.text.dark end
	if panel.Depressed or panel.Hovered then return t.accent end

	return normal or t.text.muted
end

function SKIN:PaintPanel(panel, w, h)
	if not panel.m_bBackground then return end

	Fill(w, h, CurrentTheme().panels.primary)
end

function SKIN:PaintShadow() end

function SKIN:PaintFrame(panel, w, h)
	local t = CurrentTheme()

	UI.PaintWindowBackground(panel, w, h)

	surface.SetDrawColor(t.header)
	surface.DrawRect(0, 0, w, 24)

	if t.outline then Outline(w, h, t.border) end
end

function SKIN:PaintButton(panel, w, h)
	if not panel.m_bBackground then return end

	local colors = CurrentTheme().buttons[panel:IsEnabled() and "secondary" or "disabled"]
	local bg = (panel.Depressed or panel:IsSelected() or panel:GetToggle()) and colors.d or panel.Hovered and colors.h or colors.n

	if bg.a > 0 then Fill(w, h, bg) end

	local border = panel.Hovered and (colors.ho or colors.o) or colors.o
	if border then Outline(w, h, border) end
end

function SKIN:PaintTree(panel, w, h)
	if not panel.m_bBackground then return end

	Fill(w, h, CurrentTheme().panels.primary)
end

local function PaintCheck(panel, w, h)
	local t = CurrentTheme()

	Fill(w, h, t.panels.secondary)
	Outline(w, h, panel.Hovered and panel:IsEnabled() and t.accent or t.border)

	if panel:GetChecked() then
		draw.RoundedBox(S(t.radius), 3, 3, w - 6, h - 6, panel:IsEnabled() and t.accent or t.text.dark)
	end
end

SKIN.PaintCheckBox = function(_, panel, w, h) PaintCheck(panel, w, h) end
SKIN.PaintRadioButton = function(_, panel, w, h) PaintCheck(panel, w, h) end

function SKIN:PaintExpandButton(panel, w, h)
	Glyph(panel:GetExpanded() and "−" or "+", w, h, CurrentTheme().text.muted)
end

function SKIN:PaintTextEntry(panel, w, h)
	local t = CurrentTheme()

	if panel.m_bBackground then
		Fill(w, h, t.panels.primary)
		Outline(w, h, panel:HasFocus() and t.search or t.border)
	end

	local placeholder = panel.GetPlaceholderText and panel:GetPlaceholderText()

	if placeholder and placeholder:Trim() ~= "" and (not panel:GetText() or panel:GetText() == "") then
		if placeholder:StartsWith("#") then placeholder = placeholder:sub(2) end

		local oldText = panel:GetText()

		panel:SetText(language.GetPhrase(placeholder))
		panel:DrawTextEntryText(t.text.muted, t.accent, t.cursor)
		panel:SetText(oldText)

		return
	end

	panel:DrawTextEntryText(panel:IsEnabled() and t.text.primary or t.text.dark, t.accent, t.cursor)
end

function SKIN:PaintMenu(panel, w, h)
	local t = CurrentTheme()

	surface.SetDrawColor(ColorAlpha(t.bg, 245))
	surface.DrawRect(0, 0, w, h)

	Outline(w, h, t.border)
end

function SKIN:PaintMenuSpacer(panel, w, h)
	surface.SetDrawColor(CurrentTheme().border)
	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintMenuOption(panel, w, h)
	local t = CurrentTheme()

	if panel.m_bBackground and panel:IsEnabled() and (panel.Hovered or panel.Highlight) then
		surface.SetDrawColor(t.panels.secondary)
		surface.DrawRect(0, 0, w, h)
	end

	if panel:GetChecked() then
		draw.RoundedBox(S(t.radius), 8, h / 2 - 4, 8, 8, t.accent)
	end
end

function SKIN:PaintMenuRightArrow(panel, w, h)
	Glyph("›", w, h, CurrentTheme().text.muted)
end

function SKIN:PaintPropertySheet(panel, w, h)
	local t = CurrentTheme()
	local tab = panel:GetActiveTab()
	local offset = tab and tab:GetTall() or 0

	surface.SetDrawColor(ColorAlpha(t.bg, 230))
	surface.DrawRect(0, offset, w, h - offset)

	surface.SetDrawColor(t.border)
	surface.DrawLine(0, offset, w, offset)
end

function SKIN:PaintTab(panel, w, h)
	if panel:IsActive() then return self:PaintActiveTab(panel, w, h) end

	local t = CurrentTheme()

	surface.SetDrawColor(ColorAlpha(t.bg, 200))
	surface.DrawRect(0, 0, w, h)

	if panel.Hovered then
		surface.SetDrawColor(t.panels.secondary)
		surface.DrawRect(0, 0, w, h)
	end
end

function SKIN:PaintActiveTab(panel, w, h)
	local t = CurrentTheme()

	surface.SetDrawColor(ColorAlpha(t.bg, 230))
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(t.accent)
	surface.DrawRect(0, 0, w, 2)
end

local function WindowButton(glyph, closing)
	return function(_, panel, w, h)
		if not panel.m_bBackground then return end

		local t = CurrentTheme()

		if panel.Hovered and panel:IsEnabled() then Fill(w, h, closing and t.buttons.danger.h or t.panels.secondary) end

		Glyph(glyph, w, h, panel:IsEnabled() and t.text.primary or t.text.dark)
	end
end

SKIN.PaintWindowCloseButton = WindowButton("✕", true)
SKIN.PaintWindowMinimizeButton = WindowButton("–")
SKIN.PaintWindowMaximizeButton = WindowButton("□")

function SKIN:PaintVScrollBar() end
function SKIN:PaintHScrollBar() end

function SKIN:PaintScrollBarGrip(panel, w, h)
	local t = CurrentTheme()

	Fill(w, h, (panel.Depressed or panel.Hovered) and t.accent or t.primary)
end

local function ArrowButton(glyph)
	return function(_, panel, w, h)
		if not panel.m_bBackground then return end

		Glyph(glyph, w, h, StateColor(panel))
	end
end

SKIN.PaintButtonUp = ArrowButton("▴")
SKIN.PaintButtonDown = ArrowButton("▾")
SKIN.PaintButtonLeft = ArrowButton("◂")
SKIN.PaintButtonRight = ArrowButton("▸")

function SKIN:PaintComboDownArrow(panel, w, h)
	local combo = panel.ComboBox

	Glyph(combo:IsMenuOpen() and "▴" or "▾", w, h, StateColor(combo))
end

function SKIN:PaintComboBox(panel, w, h)
	local t = CurrentTheme()

	Fill(w, h, t.panels.primary)
	Outline(w, h, panel:IsEnabled() and (panel.Hovered or panel:IsMenuOpen()) and t.accent or t.border)
end

function SKIN:PaintListBox(panel, w, h)
	Fill(w, h, CurrentTheme().panels.primary)
end

function SKIN:PaintNumberUp(panel, w, h)
	Glyph("▴", w, h, StateColor(panel))
end

function SKIN:PaintNumberDown(panel, w, h)
	Glyph("▾", w, h, StateColor(panel))
end

function SKIN:PaintTreeNodeButton(panel, w, h)
	if not panel.m_bSelected then return end

	local textW = panel:GetTextSize()

	surface.SetDrawColor(ColorAlpha(CurrentTheme().accent, 40))
	surface.DrawRect(38, 0, textW + 6, h)
end

function SKIN:PaintSelection(panel, w, h)
	surface.SetDrawColor(ColorAlpha(CurrentTheme().accent, 40))
	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintSliderKnob(panel, w, h)
	local t = CurrentTheme()

	draw.RoundedBox(S(t.radius), 2, 2, w - 4, h - 4, panel:IsEnabled() and t.accent or t.text.dark)
end

function SKIN:PaintNumSlider(panel, w, h)
	surface.SetDrawColor(CurrentTheme().panels.secondary)
	surface.DrawRect(8, h / 2 - 1, w - 15, 2)
end

function SKIN:PaintProgress(panel, w, h)
	local t = CurrentTheme()

	Fill(w, h, t.panels.secondary)
	surface.SetDrawColor(t.accent)
	surface.DrawRect(0, 0, w * panel:GetFraction(), h)
end

function SKIN:PaintCollapsibleCategory(panel, w, h)
	local t = CurrentTheme()
	local header = panel:GetHeaderHeight()

	surface.SetDrawColor(t.header)
	surface.DrawRect(0, 0, w, math.min(h, header))

	if h > header then
		surface.SetDrawColor(t.panels.primary)
		surface.DrawRect(0, header, w, h - header)
	end

	if not panel:GetExpanded() then
		draw.SimpleText("▾", "DermaDefault", w - 10, header / 2, t.text.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function SKIN:PaintCategoryList(panel, w, h)
	Fill(w, h, CurrentTheme().panels.primary)
end

function SKIN:PaintListViewLine(panel, w, h)
	local t = CurrentTheme()

	if panel:IsSelected() then
		surface.SetDrawColor(ColorAlpha(t.accent, 50))
	elseif panel.Hovered then
		surface.SetDrawColor(t.panels.secondary)
	elseif panel.m_bAlt then
		surface.SetDrawColor(ColorAlpha(t.panels.secondary, t.panels.secondary.a / 2))
	else
		return
	end

	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintListView(panel, w, h)
	if not panel.m_bBackground then return end

	Fill(w, h, CurrentTheme().panels.primary)
end

function SKIN:PaintTooltip(panel, w, h)
	local t = CurrentTheme()

	surface.SetDrawColor(ColorAlpha(t.bg, 245))
	surface.DrawRect(0, 0, w, h)

	Outline(w, h, t.border)
end

function SKIN:PaintMenuBar(panel, w, h)
	surface.SetDrawColor(CurrentTheme().header)
	surface.DrawRect(0, 0, w, h)
end

UpdateColours()

derma.DefineSkin("Beatrun", "Beatrun HUD style", SKIN)

cvars.AddChangeCallback("Beatrun_MenuTheme", function()
	UpdateColours()
	derma.RefreshSkins()
end, "BeatrunDermaSkin")

local globalSkin = CreateClientConVar("Beatrun_GlobalDermaSkin", "0", true, false, "", 0, 1)

hook.Add("ForceDermaSkin", "BeatrunDermaSkin", function()
	if globalSkin:GetBool() then return "Beatrun" end
end)

cvars.AddChangeCallback("Beatrun_GlobalDermaSkin", function() derma.RefreshSkins() end, "BeatrunDermaSkin")
