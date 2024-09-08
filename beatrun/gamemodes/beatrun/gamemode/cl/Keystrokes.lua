local showKeystrokes = CreateClientConVar("Beatrun_ShowKeystrokes", 1, true, true)

local color_white = Color(255, 255, 255)
local color_white_t = Color(255, 255, 255, 100)
local color_black = Color(0, 0, 0)
local color_black_t = Color(0, 0, 0, 100)
local size = 35

local function ShowKeyStrokes()
	if showKeystrokes:GetBool() and GetConVar("Beatrun_HUDHidden"):GetInt() == 0 then
		-- Key W
		if LocalPlayer():KeyDown(IN_FORWARD) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size, 0, size, size)
			draw.SimpleText("W", "BeatrunHUD", size + 10, size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size, 0, size, size)
			draw.SimpleText("W", "BeatrunHUD", size + 10, size - 30, color_white)
		end

		-- Key E
		if LocalPlayer():KeyDown(IN_USE) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 2, 0, size, size)
			draw.SimpleText("E", "BeatrunHUD", size + 48, size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 2, 0, size, size)
			draw.SimpleText("E", "BeatrunHUD", size + 48, size - 30, color_white)
		end

		-- Key R
		if LocalPlayer():KeyDown(IN_RELOAD) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 3, 0, size, size)
			draw.SimpleText("R", "BeatrunHUD", size * 3 + 12, size - 30, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 3, 0, size, size)
			draw.SimpleText("R", "BeatrunHUD", size * 3 + 12, size - 30, color_white)
		end

		-- Key A
		if LocalPlayer():KeyDown(IN_MOVELEFT) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size, size, size)
			draw.SimpleText("A", "BeatrunHUD", size - 23, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size, size, size)
			draw.SimpleText("A", "BeatrunHUD", size - 23, size + 8, color_white)
		end

		-- Key S
		if LocalPlayer():KeyDown(IN_BACK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size, size, size, size)
			draw.SimpleText("S", "BeatrunHUD", size + 12, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size, size, size, size)
			draw.SimpleText("S", "BeatrunHUD", size + 12, size + 8, color_white)
		end

		-- Key D
		if LocalPlayer():KeyDown(IN_MOVERIGHT) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 2, size, size, size)
			draw.SimpleText("D", "BeatrunHUD", size + 48, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 2, size, size, size)
			draw.SimpleText("D", "BeatrunHUD", size + 48, size + 8, color_white)
		end

		-- Space
		if LocalPlayer():KeyDown(IN_JUMP) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size * 2, size * 3, size)
			draw.SimpleText("SPACE", "BeatrunHUD", 28, size * 2 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size * 2, size * 3, size)
			draw.SimpleText("SPACE", "BeatrunHUD", 28, size * 2 + 8, color_white)
		end

		-- Shift
		if LocalPlayer():KeyDown(IN_SPEED) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size * 3, size * 3, size)
			draw.SimpleText("SHIFT", "BeatrunHUD", 28, size * 3 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size * 3, size * 3, size)
			draw.SimpleText("SHIFT", "BeatrunHUD", 28, size * 3 + 8, color_white)
		end

		-- Ctrl
		if LocalPlayer():KeyDown(IN_DUCK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(0, size * 4, size * 3, size)
			draw.SimpleText("CTRL", "BeatrunHUD", 32, size * 4 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(0, size * 4, size * 3, size)
			draw.SimpleText("CTRL", "BeatrunHUD", 32, size * 4 + 8, color_white)
		end

		-- Left Mouse
		if LocalPlayer():KeyDown(IN_ATTACK) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 3, size, size * 2, size)
			draw.SimpleText("LMB", "BeatrunHUD", size + 87, size + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 3, size, size * 2, size)
			draw.SimpleText("LMB", "BeatrunHUD", size + 87, size + 8, color_white)
		end

		-- Right Mouse
		if LocalPlayer():KeyDown(IN_ATTACK2) then
			surface.SetDrawColor(color_white_t)
			surface.DrawRect(size * 3, size * 2, size * 2, size)
			draw.SimpleText("RMB", "BeatrunHUD", size + 86, size * 2 + 8, color_black)
		else
			surface.SetDrawColor(color_black_t)
			surface.DrawRect(size * 3, size * 2, size * 2, size)
			draw.SimpleText("RMB", "BeatrunHUD", size + 86, size * 2 + 8, color_white)
		end
	end
end

hook.Add("HUDPaint", "KeyStrokes", ShowKeyStrokes)