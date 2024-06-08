Synesthesia = Synesthesia or {}
local syn = Synesthesia

function syn:Reset()
	if IsValid(self.channel) then
		if self.channel.Stop then
			self.channel:Stop()
		end

		self.channel = nil
	end

	self.events = nil
	self.curevent = 1
	self.length = 0
	self.lasttime = 0
	self.finished = false

	hook.Remove("PreRender", "Synesthesia")
end

function syn:Looped()
	self.curevent = 1
	self.lasttime = 0
	self.finished = false
end

function syn:Finished()
	self.finished = true
end

function syn:Play(file, events)
	self:Reset()

	sound.PlayFile(file, "noblock", function(a)
		if IsValid(a) then
			timer.Simple(0, function()
				a:EnableLooping(true)
			end)

			self.length = a:GetLength()
			self.channel = a
			self.events = events

			hook.Add("PreRender", "Synesthesia", self.Think)
		else
			ErrorNoHaltWithStack("Failed to play ", file)

			return
		end
	end)
end

function syn:Stop()
	self:Reset()
end

function syn:GetEvents()
	return self.events
end

function syn:CurEvent()
	return self.curevent
end

function syn:UpEvent()
	self.curevent = self.curevent + 1

	return self.curevent
end

function syn:GetLength()
	return self.length
end

function syn:GetTime()
	return self.channel:GetTime()
end

function syn:GetFinished()
	return self.finished
end

function syn:Think()
	local self = syn
	local curtime = self:GetTime()
	local curevent = self:GetEvents()[self:CurEvent()]

	if not self:GetFinished() and curevent[1] <= curtime then
		curevent[2]()

		local nextevent = self:UpEvent()

		if not self:GetEvents()[nextevent] then
			self:Finished()
		end
	end

	if curtime < self.lasttime then
		self:Looped()
	end

	self.lasttime = self:GetTime()
end

local testbuildup = false
local testfovconvar = GetConVar("Beatrun_FOV", 100)
local testfov = 100
local colbeatr = 250
local colbeatg = 120
local colbeatb = 40
local colr = 250
local colg = 120
local colb = 40
local testcurcolor = 1
local testcolor = Color(151, 166, 182)

local function test_beat()
	testfov = testfovconvar:GetFloat()

	BlindGetColor().r = colbeatr
	BlindGetColor().g = colbeatg
	BlindGetColor().b = colbeatb

	if not testbuildup then
		blindrandx = 2
		blindrandy = 2
		blindrandz = 2
	end

	vanishrandx = 0
	vanishrandy = 0
	vanishrandz = 4
	vanishusenormal = false

	LocalPlayer():SetFOV(testfov - 1)
	LocalPlayer():SetFOV(testfov, 1)
end

local function test_beathard()
	BlindGetColor().r = colbeatr
	BlindGetColor().g = colbeatg
	BlindGetColor().b = colbeatb

	if not testbuildup then
		blindrandx = 2
		blindrandy = 2
		blindrandz = 2
	end

	vanishrandx = 0
	vanishrandy = 0
	vanishrandz = 4
	vanishusenormal = false

	LocalPlayer():SetFOV(testfov + 2)
	LocalPlayer():SetFOV(testfov, 2)
end

local function test_color1()
	colbeatb = 200
	colbeatg = 200
	colbeatr = 240
	colb = 185
	colg = 160
	colr = 150
	testcurcolor = 1
end

local function test_color2()
	colbeatb = 5
	colbeatg = 75
	colbeatr = 250
	colb = 40
	colg = 120
	colr = 250
	testcurcolor = 2
end

local function test_pullback()
	eyedot = 0.52
end

local function test_startbuildup()
	blindrandx = 0.5
	blindrandy = 0.5
	blindrandz = 0.5
	testbuildup = true
end

local function test_endbuildup()
	testbuildup = false
end

local function test_think()
	BlindGetColor().r = math.Approach(BlindGetColor().r, colr, FrameTime() * 100)
	BlindGetColor().g = math.Approach(BlindGetColor().g, colg, FrameTime() * 100)
	BlindGetColor().b = math.Approach(BlindGetColor().b, colb, FrameTime() * 100)

	vanishrandx = math.Approach(vanishrandx, 0.5, FrameTime() * 50)
	vanishrandy = math.Approach(vanishrandy, 0.5, FrameTime() * 50)
	vanishrandz = math.Approach(vanishrandz, 0.5, FrameTime() * 50)
	vanishusenormal = vanishrandx == 0.5

	if testcurcolor == 1 then
		eyedot = math.Approach(eyedot, 0.6, FrameTime() * 0.15)
	else
		eyedot = 0.4
	end

	if testbuildup then
		GlitchIntensity = math.Approach(GlitchIntensity, 0.65, FrameTime() * 0.1)

		blindrandx = math.Approach(blindrandx, 1.5, FrameTime() * 0.1)
		blindrandy = math.Approach(blindrandy, 1.5, FrameTime() * 0.1)
		blindrandz = math.Approach(blindrandz, 1.5, FrameTime() * 0.1)
	else
		GlitchIntensity = math.Approach(GlitchIntensity, 0.1, FrameTime() * 4)

		blindrandx = math.Approach(blindrandx, 0.5, FrameTime() * 10)
		blindrandy = math.Approach(blindrandy, 0.5, FrameTime() * 10)
		blindrandz = math.Approach(blindrandz, 0.5, FrameTime() * 10)
	end
end

local testevents = {
	{0, test_color1},
	{0, test_endbuildup},
	{0, test_beat},
	{0.75, test_pullback},
	{1.1, test_pullback},
	{1.9, test_pullback},
	{3.25, test_beat},
	{6.75, test_beat},
	{7.6, test_pullback},
	{8, test_pullback},
	{8.85, test_pullback},
	{9, test_pullback},
	{9.02, test_pullback},
	{10.25, test_beat},
	{13.675, test_beat},
	{14.5, test_pullback},
	{15, test_pullback},
	{15, test_startbuildup},
	{15.8, test_pullback},
	{15.9, test_pullback},
	{16, test_pullback},
	{17.065, test_beat},
	{20.5, test_beat},
	{21.3, test_pullback},
	{21.7, test_pullback},
	{22.5, test_pullback},
	{22.8, test_pullback},
	{22.82, test_pullback},
	{24, test_beat},
	{27.375, test_beathard},
	{27.375, test_color2},
	{30.75, test_beat},
	{34.25, test_beathard},
	{37.65, test_beat},
	{41, test_endbuildup},
	{41.1, test_beat},
	{44, test_startbuildup},
	{44.5, test_beat},
	{48, test_beathard},
	{51.4, test_beat},
	{54.8, test_beat},
	{54.8, test_endbuildup},
	{58.25, test_beat},
	{59, test_startbuildup},
	{61.65, test_beathard},
	{65, test_beat}
}

function test_syn(a)
	if a then
		customglitch = true

		BlindSetColor(testcolor)
		Synesthesia:Play("sound/music/shard/puzzle_012.ogg", testevents)
		hook.Add("PreRender", "test_think", test_think)
	else
		Synesthesia:Stop()
		hook.Remove("PreRender", "test_think")
	end
end

hook.Add("Blind", "syntest", test_syn)