local showKeystrokes = CreateClientConVar("Beatrun_ShowKeystrokes", 1, true, true)

local color_white = Color(255, 255, 255)
local color_white_t = Color(255, 255, 255, 100)
local color_black = Color(0, 0, 0)
local color_black_t = Color(0, 0, 0, 100)
local size = 35

local function GetFormattedKey(bind)
	string = input.LookupBinding(bind)

	if string == "MOUSE1" then string = "LMB"
	elseif string == "MOUSE2" then string = "RMB"
	elseif string == "MOUSE3" then string = "MMB" end

	if string then
		return string.upper(string)
	else
		return "???"
	end
end

local function ShowKeyStrokes()
	if showKeystrokes:GetBool() and GetConVar("Beatrun_HUDHidden"):GetInt() == 0 then
		-- will have inconsistent indent on GH web view, thanks github
		-- absolutely indented correctly, view in an editor like vscode
        local forward = GetFormattedKey("+forward")
        local back = GetFormattedKey("+back")
        local moveleft = GetFormattedKey("+moveleft")
        local moveright = GetFormattedKey("+moveright")
        local use = GetFormattedKey("+use")
        local reload = GetFormattedKey("+reload")
        local jump = GetFormattedKey("+jump")
        local speed = GetFormattedKey("+speed")
        local duck = GetFormattedKey("+duck")
        local attack = GetFormattedKey("+attack")
        local attack2 = GetFormattedKey("+attack2")

		if attack == "MOUSE1" then attack = "LMB" end
		if attack2 == "MOUSE2" then attack2 = "RMB" end

		-- Key W
		if LocalPlayer():KeyDown(IN_FORWARD) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size, 0, size, size)
			draw.SimpleText(forward, "BeatrunHUD", size + 10, size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size, 0, size, size)
			draw.SimpleText(forward, "BeatrunHUD", size + 10, size - 30, color_white)
		end

		-- Key E
		if LocalPlayer():KeyDown(IN_USE) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 2, 0, size, size)
			draw.SimpleText(use, "BeatrunHUD", size + 48, size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 2, 0, size, size)
			draw.SimpleText(use, "BeatrunHUD", size + 48, size - 30, color_white)
		end

		-- Key R
		if LocalPlayer():KeyDown(IN_RELOAD) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 3, 0, size, size)
			draw.SimpleText(reload, "BeatrunHUD", size * 3 + 12, size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 3, 0, size, size)
			draw.SimpleText(reload, "BeatrunHUD", size * 3 + 12, size - 30, color_white)
		end

		-- Key A
		if LocalPlayer():KeyDown(IN_MOVELEFT) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size, size, size)
			draw.SimpleText(moveleft, "BeatrunHUD", size - 23, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size, size, size)
			draw.SimpleText(moveleft, "BeatrunHUD", size - 23, size + 8, color_white)
		end

		-- Key S
		if LocalPlayer():KeyDown(IN_BACK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size, size, size, size)
			draw.SimpleText(back, "BeatrunHUD", size + 12, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size, size, size, size)
			draw.SimpleText(back, "BeatrunHUD", size + 12, size + 8, color_white)
		end

		-- Key D
		if LocalPlayer():KeyDown(IN_MOVERIGHT) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 2, size, size, size)
			draw.SimpleText(moveright, "BeatrunHUD", size + 48, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 2, size, size, size)
			draw.SimpleText(moveright, "BeatrunHUD", size + 48, size + 8, color_white)
		end

		-- Space
		if LocalPlayer():KeyDown(IN_JUMP) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size * 2, size * 3, size)
			draw.SimpleText(jump, "BeatrunHUD", 28, size * 2 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size * 2, size * 3, size)
			draw.SimpleText(jump, "BeatrunHUD", 28, size * 2 + 8, color_white)
		end

		-- Shift
		if LocalPlayer():KeyDown(IN_SPEED) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size * 3, size * 3, size)
			draw.SimpleText(speed, "BeatrunHUD", 28, size * 3 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size * 3, size * 3, size)
			draw.SimpleText(speed, "BeatrunHUD", 28, size * 3 + 8, color_white)
		end

		-- Ctrl
		if LocalPlayer():KeyDown(IN_DUCK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size * 4, size * 3, size)
			draw.SimpleText(duck, "BeatrunHUD", 32, size * 4 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size * 4, size * 3, size)
			draw.SimpleText(duck, "BeatrunHUD", 32, size * 4 + 8, color_white)
		end

		-- Left Mouse
		if LocalPlayer():KeyDown(IN_ATTACK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 3, size, size * 2, size)
			draw.SimpleText(attack, "BeatrunHUD", size + 87, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 3, size, size * 2, size)
			draw.SimpleText(attack, "BeatrunHUD", size + 87, size + 8, color_white)
		end

		-- Right Mouse
		if LocalPlayer():KeyDown(IN_ATTACK2) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 3, size * 2, size * 2, size)
			draw.SimpleText(attack2, "BeatrunHUD", size + 86, size * 2 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 3, size * 2, size * 2, size)
			draw.SimpleText(attack2, "BeatrunHUD", size + 86, size * 2 + 8, color_white)
		end
	end
end

hook.Add("HUDPaint", "KeyStrokes", ShowKeyStrokes)
