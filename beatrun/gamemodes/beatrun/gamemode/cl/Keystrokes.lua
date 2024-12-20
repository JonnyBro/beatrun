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

local Beatrun_HUDHidden = GetConVar("Beatrun_HUDHidden")

local xoff = 0
local yoff = 0

local Beatrun_KeystrokesXOffset = CreateClientConVar("Beatrun_KeystrokesXOffset", 0, true, true)
local Beatrun_KeystrokesYOffset = CreateClientConVar("Beatrun_KeystrokesYOffset", 0, true, true)
local Beatrun_KeystrokesCorner = CreateClientConVar("Beatrun_KeystrokesCorner", 0, true, true)

local function ShowKeyStrokes()
	if showKeystrokes:GetBool() and Beatrun_HUDHidden:GetInt() == 0 then
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

		local h = ScrH()
		local w = ScrW()

		local lp = LocalPlayer()

		if Beatrun_KeystrokesCorner:GetInt() == 0 then
			xoff = Beatrun_KeystrokesXOffset:GetFloat()
			yoff = Beatrun_KeystrokesYOffset:GetFloat()
		elseif Beatrun_KeystrokesCorner:GetInt() == 1 then
			xoff = w - Beatrun_KeystrokesXOffset:GetFloat() - size * 5
			yoff = Beatrun_KeystrokesYOffset:GetFloat()
		elseif Beatrun_KeystrokesCorner:GetInt() == 2 then
			xoff = Beatrun_KeystrokesXOffset:GetFloat()
			yoff = h - Beatrun_KeystrokesYOffset:GetFloat() - size * 5
		elseif Beatrun_KeystrokesCorner:GetInt() == 3 then
			xoff = w - Beatrun_KeystrokesXOffset:GetFloat() - size * 5
			yoff = h - Beatrun_KeystrokesYOffset:GetFloat() - size * 5
		end


		if lp:KeyDown(IN_FORWARD) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(xoff + size, yoff + 0, size, size)
			draw.SimpleText(forward, "BeatrunHUD", xoff + size + 10, yoff + size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(xoff + size, yoff + 0, size, size)
			draw.SimpleText(forward, "BeatrunHUD", xoff + size + 10, yoff + size - 30, color_white)
		end

		if lp:KeyDown(IN_USE) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(xoff + size * 2, yoff + 0, size, size)
			draw.SimpleText(use, "BeatrunHUD", xoff + size + 48, yoff + size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(xoff + size * 2, yoff + 0, size, size)
			draw.SimpleText(use, "BeatrunHUD", xoff + size + 48, yoff + size - 30, color_white)
		end

		if lp:KeyDown(IN_RELOAD) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(xoff + size * 3, yoff + 0, size, size)
			draw.SimpleText(reload, "BeatrunHUD", xoff + size * 3 + 12, yoff + size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(xoff + size * 3, yoff + 0, size, size)
			draw.SimpleText(reload, "BeatrunHUD", xoff + size * 3 + 12, yoff + size - 30, color_white)
		end

		if lp:KeyDown(IN_MOVELEFT) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(xoff + 0, yoff + size, size, size)
			draw.SimpleText(moveleft, "BeatrunHUD", xoff + size - 23, yoff + size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(xoff + 0, yoff + size, size, size)
			draw.SimpleText(moveleft, "BeatrunHUD", xoff + size - 23, yoff + size + 8, color_white)
		end

		if lp:KeyDown(IN_BACK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(xoff + size, yoff + size, size, size)
			draw.SimpleText(back, "BeatrunHUD", xoff + size + 12, yoff + size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(xoff + size, yoff + size, size, size)
			draw.SimpleText(back, "BeatrunHUD", xoff + size + 12, yoff + size + 8, color_white)
		end

		if lp:KeyDown(IN_MOVERIGHT) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(xoff + size * 2, yoff + size, size, size)
			draw.SimpleText(moveright, "BeatrunHUD", xoff + size + 48, yoff + size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(xoff + size * 2, yoff + size, size, size)
			draw.SimpleText(moveright, "BeatrunHUD", xoff + size + 48, yoff + size + 8, color_white)
		end

		if lp:KeyDown(IN_JUMP) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(xoff + 0 , yoff + size * 2, size * 3, size)
			draw.SimpleText(jump, "BeatrunHUD", xoff + 25, yoff + size * 2 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(xoff + 0, yoff + size * 2, size * 3, size)
			draw.SimpleText(jump, "BeatrunHUD", xoff + 25, yoff + size * 2 + 8, color_white)
		end

		if lp:KeyDown(IN_SPEED) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(xoff + 0, yoff + size * 3, size * 3, size)
			draw.SimpleText(speed, "BeatrunHUD", xoff + 25, yoff + size * 3 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(xoff + 0, yoff + size * 3, size * 3, size)
			draw.SimpleText(speed, "BeatrunHUD", xoff + 25, yoff + size * 3 + 8, color_white)
		end

		if lp:KeyDown(IN_DUCK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(xoff + 0, yoff + size * 4, size * 3, size)
			draw.SimpleText(duck, "BeatrunHUD", xoff + 32, yoff + size * 4 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(xoff + 0, yoff + size * 4, size * 3, size)
			draw.SimpleText(duck, "BeatrunHUD", xoff + 32, yoff + size * 4 + 8, color_white)
		end

		if lp:KeyDown(IN_ATTACK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(xoff + size * 3, yoff + size, size * 2, size)
			draw.SimpleText(attack, "BeatrunHUD", xoff + size + 87, yoff + size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(xoff + size * 3, yoff + size, size * 2, size)
			draw.SimpleText(attack, "BeatrunHUD", xoff + size + 87, yoff + size + 8, color_white)
		end

		if lp:KeyDown(IN_ATTACK2) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(xoff + size * 3, yoff + size * 2, size * 2, size)
			draw.SimpleText(attack2, "BeatrunHUD", xoff + size + 86, yoff + size * 2 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(xoff + size * 3, yoff + size * 2, size * 2, size)
			draw.SimpleText(attack2, "BeatrunHUD", xoff + size + 86, yoff + size * 2 + 8, color_white)
		end
	end
end

hook.Add("HUDPaint", "KeyStrokes", ShowKeyStrokes)
