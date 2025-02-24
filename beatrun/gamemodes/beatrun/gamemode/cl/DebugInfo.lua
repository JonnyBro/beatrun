surface.CreateFont("BeatrunDebug", {
	shadow = false,
	blursize = 0,
	underline = false,
	rotary = false,
	strikeout = false,
	additive = false,
	antialias = false,
	extended = false,
	scanlines = 0,
	font = "ProFontWindows",
	italic = false,
	outline = false,
	symbol = false,
	weight = 50,
	size = ScreenScale(6)
})

local color_red = Color(220, 20, 20)
local startx = 0.2
local starty = 0.75

local debugdata = {"BodyAnim", "BodyAnimCycle", "BodyAnimString", "campos", "camang"}
local debugdata2 = {"BodyAnimArmCopy", "TraceCount"}

local debugoffset = {0, 0, 0}
local debuglist = {debugdata, debugdata2}

TraceLine_o = TraceLine_o or util.TraceLine
local TraceLine_o = TraceLine_o
local traces = {}
TraceCount = 0

function TraceLine_d(data)
	local result = TraceLine_o(data)

	table.insert(traces, {Vector(data.start), Vector(data.endpos), result.Hit and color_red or color_white})

	return result
end

local function DrawDebugInfo()
	local sx = ScrW() * startx
	local sy = ScrH() * starty
	-- local htw = 0

	surface.SetFont("BeatrunDebug")
	surface.SetTextPos(sx, sy)
	surface.SetTextColor(255, 255, 255)

	for num, tbl in ipairs(debuglist) do
		htw = 0

		for k, v in ipairs(tbl) do
			local value = _G[v]

			if isnumber(value) then
				value = math.Round(value, 4)
			end

			local text = v .. ": " .. tostring(value)
			local tw, th = surface.GetTextSize(text)
			debugoffset[num + 1] = debugoffset[num + 1] < tw and tw or debugoffset[num + 1]

			surface.SetTextPos(sx + debugoffset[num], sy + th * k)
			surface.DrawText(text)
		end
	end
end

local function RenderTraces()
	cam.Start3D()
		for _, v in ipairs(traces) do
			render.DrawLine(v[1], v[2], v[3], true)
		end
	cam.End3D()

	TraceCount = #traces

	table.Empty(traces)
end

BEATRUN_DEBUG = false

concommand.Add("Beatrun_Debug", function(ply, cmd, args)
	BEATRUN_DEBUG = tobool(args[1])

	print("Beatrun Debug: " .. tostring(BEATRUN_DEBUG))

	if BEATRUN_DEBUG then
		hook.Add("HUDPaint", "DrawDebugInfo", DrawDebugInfo)
		hook.Add("PostRender", "RenderTraces", RenderTraces)

		function GAMEMODE.HUDDrawTargetID()
		end

		util.TraceLine = TraceLine_d
	else
		hook.Remove("HUDPaint", "DrawDebugInfo")
		hook.Remove("PostRender", "RenderTraces")
		util.TraceLine = TraceLine_o
	end
end)