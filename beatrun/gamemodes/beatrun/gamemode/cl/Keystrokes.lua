local showKeystrokes = CreateClientConVar("Beatrun_ShowKeystrokes", 1, true, true)

local color_white = Color(255, 255, 255)
local color_white_t = Color(255, 255, 255, 100)
local color_black = Color(0, 0, 0)
local color_black_t = Color(0, 0, 0, 100)
local size = 35

local function GetFormattedKey(bind)
	local keyBind = input.LookupBinding(bind)

	if keyBind == "MOUSE1" then keyBind = "LMB"
	elseif keyBind == "MOUSE2" then keyBind = "RMB"
	elseif keyBind == "MOUSE3" then keyBind = "MMB" end

	if keyBind then
		return string.upper(keyBind)
	else
		return "?"
	end
end

local function ShowKeyStrokes()
	if showKeystrokes:GetBool() and GetConVar("Beatrun_HUDHidden"):GetInt() == 0 then
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

		if LocalPlayer():KeyDown(IN_FORWARD) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size, 0, size, size)
			draw.SimpleText(forward, "BeatrunHUD", size + 10, size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size, 0, size, size)
			draw.SimpleText(forward, "BeatrunHUD", size + 10, size - 30, color_white)
		end

		if LocalPlayer():KeyDown(IN_USE) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 2, 0, size, size)
			draw.SimpleText(use, "BeatrunHUD", size + 48, size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 2, 0, size, size)
			draw.SimpleText(use, "BeatrunHUD", size + 48, size - 30, color_white)
		end

		if LocalPlayer():KeyDown(IN_RELOAD) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 3, 0, size, size)
			draw.SimpleText(reload, "BeatrunHUD", size * 3 + 12, size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 3, 0, size, size)
			draw.SimpleText(reload, "BeatrunHUD", size * 3 + 12, size - 30, color_white)
		end

		if LocalPlayer():KeyDown(IN_MOVELEFT) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size, size, size)
			draw.SimpleText(moveleft, "BeatrunHUD", size - 23, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size, size, size)
			draw.SimpleText(moveleft, "BeatrunHUD", size - 23, size + 8, color_white)
		end

		if LocalPlayer():KeyDown(IN_BACK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size, size, size, size)
			draw.SimpleText(back, "BeatrunHUD", size + 12, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size, size, size, size)
			draw.SimpleText(back, "BeatrunHUD", size + 12, size + 8, color_white)
		end

		if LocalPlayer():KeyDown(IN_MOVERIGHT) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 2, size, size, size)
			draw.SimpleText(moveright, "BeatrunHUD", size + 48, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 2, size, size, size)
			draw.SimpleText(moveright, "BeatrunHUD", size + 48, size + 8, color_white)
		end

		if LocalPlayer():KeyDown(IN_JUMP) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size * 2, size * 3, size)
			draw.SimpleText(jump, "BeatrunHUD", 28, size * 2 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size * 2, size * 3, size)
			draw.SimpleText(jump, "BeatrunHUD", 28, size * 2 + 8, color_white)
		end

		if LocalPlayer():KeyDown(IN_SPEED) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size * 3, size * 3, size)
			draw.SimpleText(speed, "BeatrunHUD", 28, size * 3 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size * 3, size * 3, size)
			draw.SimpleText(speed, "BeatrunHUD", 28, size * 3 + 8, color_white)
		end

		if LocalPlayer():KeyDown(IN_DUCK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size * 4, size * 3, size)
			draw.SimpleText(duck, "BeatrunHUD", 32, size * 4 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size * 4, size * 3, size)
			draw.SimpleText(duck, "BeatrunHUD", 32, size * 4 + 8, color_white)
		end

		if LocalPlayer():KeyDown(IN_ATTACK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 3, size, size * 2, size)
			draw.SimpleText(attack, "BeatrunHUD", size + 87, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 3, size, size * 2, size)
			draw.SimpleText(attack, "BeatrunHUD", size + 87, size + 8, color_white)
		end

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
