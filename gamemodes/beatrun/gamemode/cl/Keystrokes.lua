local showKeystrokes = CreateClientConVar("Beatrun_ShowKeystrokes", 1, true, true)

local Beatrun_HUDHidden = GetConVar("Beatrun_HUDHidden")

local Beatrun_KeystrokesXOffset = CreateClientConVar("Beatrun_KeystrokesXOffset", 0, true, true)
local Beatrun_KeystrokesYOffset = CreateClientConVar("Beatrun_KeystrokesYOffset", 0, true, true)
local Beatrun_KeystrokesCorner = CreateClientConVar("Beatrun_KeystrokesCorner", 0, true, true)

local color_pressed = Color(255, 255, 255, 110)
local color_released = Color(0, 0, 0, 110)
local color_outline = Color(255, 255, 255, 35)
local color_black = Color(0, 0, 0)

local KEYS = {
	{ bind = "+forward", key = IN_FORWARD, x = 1, y = 0 },
	{ bind = "+use", key = IN_USE, x = 2, y = 0 },
	{ bind = "+reload", key = IN_RELOAD, x = 3, y = 0 },
	{ bind = "+moveleft", key = IN_MOVELEFT, x = 0, y = 1 },
	{ bind = "+back", key = IN_BACK, x = 1, y = 1 },
	{ bind = "+moveright", key = IN_MOVERIGHT, x = 2, y = 1 },
	{ bind = "+attack", key = IN_ATTACK, x = 3, y = 1, w = 2 },
	{ bind = "+jump", key = IN_JUMP, x = 0, y = 2, w = 3 },
	{ bind = "+attack2", key = IN_ATTACK2, x = 3, y = 2, w = 2 },
	{ bind = "+speed", key = IN_SPEED, x = 0, y = 3, w = 3 },
	{ bind = "+walk", key = IN_WALK, x = 3, y = 3, w = 2 },
	{ bind = "+duck", key = IN_DUCK, x = 0, y = 4, w = 3 }
}

local COLUMNS, ROWS = 5, 5

local function GetFormattedKey(bind)
	local keyBind = input.LookupBinding(bind)

	if bind == "+attack" and keyBind == "ENTER" and input.LookupKeyBinding(MOUSE_LEFT) == "+attack" then return "LMB" end -- prioritize lmb over enter in +attack

	if keyBind == "MOUSE1" then keyBind = "LMB"
	elseif keyBind == "MOUSE2" then keyBind = "RMB"
	elseif keyBind == "MOUSE3" then keyBind = "MMB" end

	if keyBind then
		return string.upper(keyBind)
	else
		return "?"
	end
end

local function IsBindDown(bind, inKey, ply)
	if bind == "+attack" and input.LookupKeyBinding(MOUSE_LEFT) == "+attack" and input.IsMouseDown(MOUSE_LEFT) then return true end

	local keyName = input.LookupBinding(bind)
	local code = keyName and input.GetKeyCode(keyName)

	if code and code > 0 then return input.IsButtonDown(code) end

	return ply:KeyDown(inKey)
end

local function FitFont(text, width)
	for _, font in ipairs({ "BeatrunUISmall", "AEUISmall" }) do
		surface.SetFont(font)

		if surface.GetTextSize(text) <= width then return font end
	end

	return "AEUISmall"
end

local function ShowKeyStrokes()
	if BuildMode then return end
	if not showKeystrokes:GetBool() or Beatrun_HUDHidden:GetInt() ~= 0 then return end

	local S = BeatrunUI.S
	local cell = S(36)
	local gap = S(2)
	local totalW = COLUMNS * cell
	local totalH = ROWS * cell

	local corner = Beatrun_KeystrokesCorner:GetInt()
	local xoff = Beatrun_KeystrokesXOffset:GetFloat()
	local yoff = Beatrun_KeystrokesYOffset:GetFloat()

	if corner == 1 or corner == 3 then xoff = ScrW() - xoff - totalW end
	if corner == 2 or corner == 3 then yoff = ScrH() - yoff - totalH end

	local lp = LocalPlayer()

	for _, k in ipairs(KEYS) do
		local x = xoff + k.x * cell
		local y = yoff + k.y * cell
		local w = (k.w or 1) * cell - gap
		local h = cell - gap
		local pressed = IsBindDown(k.bind, k.key, lp)
		local text = GetFormattedKey(k.bind)

		surface.SetDrawColor(pressed and color_pressed or color_released)
		surface.DrawRect(x, y, w, h)

		surface.SetDrawColor(color_outline)
		surface.DrawOutlinedRect(x, y, w, h, 1)

		draw.SimpleText(text, FitFont(text, w - S(6)), x + w / 2, y + h / 2, pressed and color_black or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

hook.Add("HUDPaint", "KeyStrokes", ShowKeyStrokes)
