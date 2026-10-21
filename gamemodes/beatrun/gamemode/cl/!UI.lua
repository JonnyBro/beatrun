function AEUIFonts()
	surface.CreateFont("AEUISmall", {
		font = "D-DIN",
		shadow = false,
		blursize = 0,
		underline = false,
		rotary = false,
		strikeout = false,
		additive = false,
		antialias = true,
		extended = false,
		scanlines = 0,
		italic = false,
		outline = false,
		symbol = false,
		weight = 500,
		size = ScreenScale(5)
	})

	surface.CreateFont("AEUIDefault", {
		font = "D-DIN",
		shadow = false,
		blursize = 0,
		underline = false,
		rotary = false,
		strikeout = false,
		additive = false,
		antialias = true,
		extended = false,
		scanlines = 0,
		italic = false,
		outline = false,
		symbol = false,
		weight = 500,
		size = ScreenScale(7)
	})

	surface.CreateFont("AEUILarge", {
		font = "D-DIN",
		shadow = false,
		blursize = 0,
		underline = false,
		rotary = false,
		strikeout = false,
		additive = false,
		antialias = true,
		extended = false,
		scanlines = 0,
		italic = false,
		outline = false,
		symbol = false,
		weight = 500,
		size = ScreenScale(12)
	})

	surface.CreateFont("AEUIVeryLarge", {
		font = "D-DIN",
		shadow = false,
		blursize = 0,
		underline = false,
		rotary = false,
		strikeout = false,
		additive = false,
		antialias = true,
		extended = false,
		scanlines = 0,
		italic = false,
		outline = false,
		symbol = false,
		weight = 500,
		size = ScreenScale(18)
	})
end

AEUIFonts()

hook.Add("OnScreenSizeChanged", "AEUI_ScreenSize", function()
	AEUIFonts()
end)

BEATRUN_ACCENT = Color(235, 45, 45)

local ACCENT = BEATRUN_ACCENT
local ACCENT_DARK = Color(190, 30, 30)

local uiTheme = CreateClientConVar("Beatrun_MenuTheme", "beatrun", true, false, language.GetPhrase("beatrun.convars.theme"))

--[[
	Themes

	radius   corner radius of panels and buttons (scaled)
	outline  1px border around panels, like the HUD and AEUI
	edge     solid block on the left of important panels, like the HUD corner
	buttons  t = text, n / h / d = background normal / hovered / pressed,
	         o = border, ht = text when hovered. Fully transparent backgrounds aren't drawn
]]

local transparent = Color(0, 0, 0, 0)
local THEME = {
	beatrun = {
		radius = 0,
		outline = true,
		blur = true,
		accent = ACCENT,
		bg = Color(20, 20, 20, 165),
		header = Color(0, 0, 0, 80),
		primary = Color(255, 255, 255, 60),
		secondary = Color(255, 255, 255, 30),
		border = Color(255, 255, 255, 28),
		edge = Color(235, 235, 235),
		search = ACCENT, -- Color around active text box
		cursor = color_white,
		text = {
			primary = color_white,
			muted = Color(190, 190, 190),
			dark = Color(130, 130, 130),
		},
		buttons = {
			primary = {
				t = Color(14, 14, 14),
				ht = color_white,
				n = Color(235, 235, 235),
				h = ACCENT,
				d = ACCENT_DARK
			},
			secondary = {
				t = color_white,
				ht = ACCENT,
				n = transparent,
				h = ColorAlpha(ACCENT, 18),
				d = ColorAlpha(ACCENT, 40),
				o = Color(255, 255, 255, 110),
				ho = ACCENT
			},
			danger = {
				t = Color(240, 80, 80),
				ht = color_white,
				n = transparent,
				h = Color(200, 25, 25),
				d = Color(160, 20, 20),
				o = Color(200, 25, 25)
			},
			green = {
				t = Color(14, 14, 14),
				n = Color(0, 200, 0),
				h = Color(0, 230, 0),
				d = Color(0, 170, 0)
			},
			red = {
				t = color_white,
				n = Color(200, 25, 25),
				h = Color(225, 40, 40),
				d = Color(170, 20, 20)
			},
			disabled = {
				t = Color(255, 255, 255, 70),
				n = transparent,
				h = transparent,
				d = transparent,
				o = Color(255, 255, 255, 25)
			}
		},
		panels = {
			primary = Color(0, 0, 0, 90),
			secondary = Color(255, 255, 255, 14)
		}
	},
	dark = {
		radius = 6,
		outline = false,
		accent = Color(255, 60, 60),
		bg = Color(40, 40, 40),
		header = Color(50, 50, 50),
		primary = Color(70, 70, 70),
		secondary = Color(80, 80, 80),
		border = Color(80, 80, 80),
		edge = Color(255, 60, 60),
		search = Color(220, 60, 60),
		cursor = color_white,
		text = {
			primary = color_white,
			muted = Color(180, 180, 180),
			dark = Color(150, 150, 150),
		},
		buttons = {
			primary = {
				t = color_white,
				n = Color(220, 55, 55),
				h = Color(240, 70, 70),
				d = Color(200, 45, 45)
			},
			secondary = {
				t = color_white,
				n = Color(75, 75, 75),
				h = Color(95, 95, 95),
				d = Color(110, 110, 110)
			},
			danger = {
				t = Color(255, 110, 110),
				ht = color_white,
				n = transparent,
				h = Color(183, 28, 28),
				d = Color(150, 20, 20),
				o = Color(183, 28, 28)
			},
			green = {
				t = color_white,
				n = Color(46, 125, 50),
				h = Color(56, 142, 60),
				d = Color(67, 160, 71)
			},
			red = {
				t = color_white,
				n = Color(183, 28, 28),
				h = Color(198, 40, 40),
				d = Color(211, 47, 47)
			},
			disabled = {
				t = Color(130, 130, 130),
				n = Color(50, 50, 50),
				h = Color(50, 50, 50),
				d = Color(50, 50, 50)
			}
		},
		panels = {
			primary = Color(58, 58, 58),
			secondary = Color(72, 72, 72)
		}
	},
	light = {
		radius = 6,
		outline = false,
		accent = Color(33, 150, 243),
		bg = Color(245, 247, 250),
		header = Color(230, 233, 238),
		primary = Color(210, 214, 220),
		secondary = Color(225, 229, 235),
		border = Color(210, 214, 220),
		edge = Color(33, 150, 243),
		search = Color(25, 118, 210),
		cursor = color_black,
		text = {
			primary = color_black,
			muted = Color(110, 110, 110),
			dark = Color(70, 70, 70),
		},
		buttons = {
			primary = {
				t = color_white,
				n = Color(33, 150, 243),
				h = Color(25, 118, 210),
				d = Color(21, 101, 192)
			},
			secondary = {
				t = color_black,
				n = Color(215, 219, 225),
				h = Color(200, 210, 220),
				d = Color(185, 198, 212)
			},
			danger = {
				t = Color(198, 40, 40),
				ht = color_white,
				n = transparent,
				h = Color(229, 57, 53),
				d = Color(198, 40, 40),
				o = Color(229, 57, 53)
			},
			green = {
				t = color_white,
				n = Color(76, 175, 80),
				h = Color(67, 160, 71),
				d = Color(56, 142, 60)
			},
			red = {
				t = color_white,
				n = Color(229, 57, 53),
				h = Color(211, 47, 47),
				d = Color(198, 40, 40)
			},
			disabled = {
				t = Color(150, 150, 150),
				n = Color(225, 228, 232),
				h = Color(225, 228, 232),
				d = Color(225, 228, 232)
			}
		},
		panels = {
			primary = Color(255, 255, 255),
			secondary = Color(240, 243, 247)
		}
	}
}

local THEME_ORDER = { "beatrun", "dark", "light" }

for _, theme in pairs(THEME) do
	theme.buttons.close = {
		t = theme.text.muted,
		ht = color_white,
		n = transparent,
		h = Color(200, 25, 25),
		d = Color(160, 20, 20)
	}
end

function CurrentTheme()
	return THEME[string.lower(uiTheme:GetString())] or THEME.beatrun
end

local function S(px)
	if px == 0 then return 0 end
	return math.max(1, math.Round(px * ScrH() / 1080))
end

local function L(phrase)
	return language.GetPhrase(string.TrimLeft(phrase, "#"))
end

local function CreateMenuFonts()
	for name, size in pairs({
		BeatrunUISmall = 6,
		BeatrunUI = 7,
		BeatrunUILarge = 10
	}) do
		surface.CreateFont(name, {
			font = "x14y24pxHeadUpDaisy",
			extended = true,
			antialias = false,
			shadow = true,
			scanlines = 2,
			weight = 500,
			size = ScreenScale(size)
		})
	end
end

CreateMenuFonts()

hook.Add("OnScreenSizeChanged", "BeatrunUI_Fonts", CreateMenuFonts)

local blurMaterial = Material("pp/blurscreen")

local function DrawPanelBlur(panel)
	if render.GetDXLevel() < 90 then return end

	local x, y = panel:LocalToScreen(0, 0)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blurMaterial)

	for i = 1, 3 do
		blurMaterial:SetFloat("$blur", i / 3 * 5)
		blurMaterial:Recompute()

		render.UpdateScreenEffectTexture()

		surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
	end
end

local function PaintWindowBackground(panel, w, h)
	local theme = CurrentTheme()

	if theme.blur then DrawPanelBlur(panel) end

	draw.RoundedBox(S(theme.radius), 0, 0, w, h, theme.bg)
end

local function PaintPanel(w, h, color, withEdge)
	local theme = CurrentTheme()
	local radius = S(theme.radius)

	color = color or theme.panels.primary

	draw.RoundedBox(radius, 0, 0, w, h, color)

	if withEdge then
		local edge = S(4)
		if radius > 0 then
			draw.RoundedBoxEx(radius, 0, 0, edge + radius, h, theme.edge, true, false, true, false)
			surface.SetDrawColor(color)
			surface.DrawRect(edge, 0, radius, h)
		else
			surface.SetDrawColor(theme.edge)
			surface.DrawRect(0, 0, edge, h)
		end
	end

	if theme.outline then
		surface.SetDrawColor(theme.border)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
end

function ApplyScrollTheme(panel)
	local bar = panel:GetVBar()

	bar:SetWide(S(8))

	bar.Paint = function() end
	bar.btnUp.Paint = function() end
	bar.btnDown.Paint = function() end

	bar.btnGrip.Paint = function(self, w, h)
		local theme = CurrentTheme()
		draw.RoundedBox(S(theme.radius), 0, 0, w, h, self:IsHovered() and theme.accent or theme.primary)
	end
end

function ApplyButtonTheme(self, w, h, style)
	local theme = CurrentTheme()

	local enabled = self:IsEnabled()
	if not enabled then
		self:SetCursor("arrow")
		style = "disabled"
	end

	local colors = theme.buttons[style] or theme.buttons.secondary
	local hovered = enabled and self:IsHovered()

	local bg = enabled and self:IsDown() and colors.d or hovered and colors.h or colors.n
	if bg.a > 0 then draw.RoundedBox(S(theme.radius), 0, 0, w, h, bg) end

	local border = hovered and (colors.ho or colors.o) or colors.o

	if border then
		surface.SetDrawColor(border)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	self:SetTextColor(hovered and colors.ht or colors.t)
end

local function MakeLabel(parent, text, font, color)
	local label = vgui.Create("DLabel", parent)
	label:SetText(text)
	label:SetFont(font or "BeatrunUI")
	label:SetTextColor(color or CurrentTheme().text.primary)
	label:SizeToContents()

	return label
end

local function MakeTitle(parent, text)
	local label = MakeLabel(parent, "// " .. string.upper(L(text)), "BeatrunUI")
	label:Dock(TOP)
	label:DockMargin(0, 0, 0, S(10))

	return label
end

local function MakeButton(parent, text, style, font)
	local btn = vgui.Create("DButton", parent)
	btn:SetText(text)
	btn:SetFont(font or "BeatrunUISmall")
	btn:SetCursor("hand")
	btn:SetTall(S(32))
	btn:SizeToContentsX(S(32))

	btn.style = style or "secondary"
	btn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, self.style) end

	return btn
end

local function MakeTextEntry(parent, placeholder)
	local entry = vgui.Create("DTextEntry", parent)
	entry:SetPlaceholderText(placeholder)
	entry:SetFont("BeatrunUI")
	entry:SetTall(S(32))
	entry:SetPaintBackground(false)

	entry.Paint = function(self, w, h)
		local theme = CurrentTheme()

		draw.RoundedBox(S(theme.radius), 0, 0, w, h, theme.panels.primary)
		surface.SetDrawColor(self:HasFocus() and theme.search or theme.border)
		surface.DrawOutlinedRect(0, 0, w, h, 1)

		self:DrawTextEntryText(theme.text.primary, theme.accent, theme.cursor)

		if self:GetValue() == "" then draw.SimpleText(self:GetPlaceholderText(), self:GetFont(), 5, h / 2, theme.text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
	end

	return entry
end

local function StyleCheckBox(checkbox)
	checkbox.Paint = function(self, w, h)
		local theme = CurrentTheme()

		draw.RoundedBox(S(theme.radius), 0, 0, w, h, theme.panels.secondary)
		surface.SetDrawColor(self:IsHovered() and theme.accent or theme.border)
		surface.DrawOutlinedRect(0, 0, w, h, 1)

		if self:GetChecked() then draw.RoundedBox(S(theme.radius), S(4), S(4), w - S(8), h - S(8), theme.accent) end
	end
end

local function MakeWindow(title, w, h)
	local headerH = S(30)

	local frame = vgui.Create("DFrame")
	frame:SetTitle("")
	frame:SetSize(math.min(w, ScrW() - S(40)), math.min(h, ScrH() - S(40)))
	frame:Center()
	frame:DockPadding(S(16), headerH + S(14), S(16), S(16))
	frame:SetDeleteOnClose(true)
	frame:ShowCloseButton(false)
	frame:MakePopup()
	frame.Paint = function(self, pw, ph)
		local theme = CurrentTheme()
		local radius = S(theme.radius)

		PaintWindowBackground(self, pw, ph)
		draw.RoundedBoxEx(radius, 0, 0, pw, headerH, theme.header, true, true, false, false)

		if theme.outline then
			surface.SetDrawColor(theme.border)
			surface.DrawOutlinedRect(0, 0, pw, ph, 1)
		end

		draw.SimpleText(string.upper(L(title)), "BeatrunUI", S(12), headerH / 2, theme.text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local close = MakeButton(frame, "✕", "close")
	close:SetSize(headerH, headerH)
	close:SetPos(frame:GetWide() - headerH, 0)
	close.DoClick = function() if IsValid(frame) then frame:Close() end end

	return frame
end


local function MakeScroll(parent)
	local scroll = vgui.Create("DScrollPanel", parent)
	scroll:Dock(FILL)

	ApplyScrollTheme(scroll)

	return scroll
end

local function MakeTabBar(parent, height)
	local bar = vgui.Create("DPanel", parent)
	bar:SetTall(S(height or 40))
	bar:Dock(TOP)
	bar:DockPadding(S(12), 0, S(12), 0)
	bar.tabs = {}

	bar.Paint = function(self, w, h)
		local theme = CurrentTheme()

		surface.SetDrawColor(theme.border)
		surface.DrawLine(0, h - 1, w, h - 1)
	end

	bar.PerformLayout = function(self, w)
		if not self.wrap then return end

		local rowH = S(height or 40)
		local x, y = S(12), 0

		for _, tab in ipairs(self:GetChildren()) do
			if x + tab:GetWide() > w - S(12) and x > S(12) then
				x = S(12)
				y = y + rowH
			end

			tab:SetPos(x, y)
			tab:SetTall(rowH)

			x = x + tab:GetWide()
		end

		if self:GetTall() ~= y + rowH then self:SetTall(y + rowH) end
	end

	function bar:AddTab(key, label, onSelect)
		local tab = vgui.Create("DButton", self)
		tab:SetText(string.upper(L(label)))
		tab:SetFont("BeatrunUISmall")
		tab:SetCursor("hand")
		tab:SizeToContentsX(self.tabPadding or S(24))

		if not self.wrap then tab:Dock(LEFT) end

		tab.Paint = function(btn, w, h)
			local theme = CurrentTheme()
			local active = self.active == key

			btn:SetTextColor((active and theme.text.primary) or (btn:IsHovered() and theme.accent) or theme.text.muted)

			if active then
				surface.SetDrawColor(theme.accent)
				surface.DrawRect(0, h - S(3), w, S(3))
			end
		end

		tab.DoClick = function() if self.active ~= key then self:Select(key) end end

		self.tabs[key] = { button = tab, onSelect = onSelect }

		return tab
	end

	function bar:Select(key)
		local tab = self.tabs[key]
		if not tab then return end

		self.active = key

		if tab.onSelect then tab.onSelect(key) end
	end

	return bar
end

local function MakeKeyHint(parent, keyText, text)
	local hint = vgui.Create("DPanel", parent)
	hint.keyText = string.upper(L(keyText))
	hint.text = L(text)

	local function size()
		local pad = S(6)

		surface.SetFont("BeatrunUISmall")
		local kw, kh = surface.GetTextSize(hint.keyText)
		local tw = surface.GetTextSize(hint.text)

		return kw + pad * 2, kh + S(6), tw
	end

	local capW, capH, textW = size()
	hint:SetSize(capW + S(8) + textW, capH)

	hint.Paint = function(self, w, h)
		local theme = CurrentTheme()

		surface.SetDrawColor(theme.panels.primary)
		surface.DrawRect(0, 0, capW, h)

		surface.SetDrawColor(theme.text.muted)
		surface.DrawOutlinedRect(0, 0, capW, h, 1)

		draw.SimpleText(self.keyText, "BeatrunUISmall", capW / 2, h / 2, theme.text.primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(self.text, "BeatrunUISmall", capW + S(8), h / 2, theme.text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	return hint
end

local function IsCursorOverUI()
	local hovered = vgui.GetHoveredPanel()

	return IsValid(hovered) and hovered ~= vgui.GetWorldPanel() and hovered ~= GetHUDPanel()
end

local largeWindowFrame, largeWindowOpen = -1, false

local function IsLargeWindowOpen()
	local frame = FrameNumber()
	if frame == largeWindowFrame then return largeWindowOpen end

	largeWindowFrame, largeWindowOpen = frame, false

	local minArea = ScrW() * ScrH() * 0.2

	for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
		if panel ~= g_ContextMenu and panel:IsVisible() and panel:IsMouseInputEnabled() and panel:GetWide() * panel:GetTall() >= minArea then
			largeWindowOpen = true

			break
		end
	end

	return largeWindowOpen
end

local function IsTyping()
	local focus = vgui.GetKeyboardFocus()

	return IsValid(focus) and focus:GetClassName() == "TextEntry"
end

BeatrunUI = {
	S = S,
	L = L,
	THEME = THEME,
	THEME_ORDER = THEME_ORDER,
	ThemeConVar = uiTheme,
	DrawPanelBlur = DrawPanelBlur,
	PaintWindowBackground = PaintWindowBackground,
	PaintPanel = PaintPanel,
	MakeWindow = MakeWindow,
	MakeButton = MakeButton,
	MakeLabel = MakeLabel,
	MakeTitle = MakeTitle,
	MakeTextEntry = MakeTextEntry,
	MakeScroll = MakeScroll,
	MakeTabBar = MakeTabBar,
	MakeKeyHint = MakeKeyHint,
	StyleCheckBox = StyleCheckBox,
	IsCursorOverUI = IsCursorOverUI,
	IsLargeWindowOpen = IsLargeWindowOpen,
	IsTyping = IsTyping
}
