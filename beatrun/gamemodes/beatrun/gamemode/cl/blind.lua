local function push_right(self, x)
	assert(x ~= nil)

	self.tail = self.tail + 1
	self[self.tail] = x
end

local function push_left(self, x)
	assert(x ~= nil)

	self[self.head] = x
	self.head = self.head - 1
end

local function pop_right(self)
	if self:is_empty() then return nil end

	local r = self[self.tail]
	self[self.tail] = nil
	self.tail = self.tail - 1

	return r
end

local function pop_left(self)
	if self:is_empty() then return nil end

	local r = self[self.head + 1]
	self.head = self.head + 1

	local r = self[self.head]
	self[self.head] = nil

	return r
end

local function length(self)
	return self.tail - self.head
end

local function is_empty(self)
	return self:length() == 0
end

local function iter_left(self)
	local i = self.head

	return function()
		if i < self.tail then
			i = i + 1

			return self[i]
		end
	end
end

local function iter_right(self)
	local i = self.tail + 1

	return function()
		if i > self.head + 1 then
			i = i - 1

			return self[i]
		end
	end
end

local function contents(self)
	local r = {}

	for i = self.head + 1, self.tail do
		r[i - self.head] = self[i]
	end

	return r
end

local methods = {
	push_right = push_right,
	push_left = push_left,
	peek_right = peek_right,
	peek_left = peek_left,
	pop_right = pop_right,
	pop_left = pop_left,
	rotate_right = rotate_right,
	rotate_left = rotate_left,
	remove_right = remove_right,
	remove_left = remove_left,
	iter_right = iter_right,
	iter_left = iter_left,
	length = length,
	is_empty = is_empty,
	contents = contents
}

local function new()
	local r = {
		head = 0,
		tail = 0
	}

	return setmetatable(r, {
		__index = methods
	})
end

local vecmeta = FindMetaTable("Vector")

function vecmeta:LerpTemp(t, start, endpos)
	local xs, ys, zs = start:Unpack()
	local xe, ye, ze = endpos:Unpack()

	self:SetUnpacked(LerpL(t, xs, xe), LerpL(t, ys, ye), LerpL(t, zs, ze))
end

hitpoints = new()
hitcolor = new()
hitnormal = new()
soundpoints = new()
GlitchIntensity = 0
local tr = {}
local tr_result = {}
local randvector = Vector()
-- local box_mins = Vector(-0.5, -0.5, -0.5)
-- local box_maxs = Vector(0.5, 0.5, 0.5)
local awareness = CreateClientConVar("blindness_awareness", 10000, true, false, "Awareness in hu")
local quality = CreateClientConVar("blindness_highquality", 1, true, false, "Draws quads instead of lines")
-- local boxang = Angle()
-- local vanishvec = Vector()
-- local vanishvecrand = Vector()
vanishrandx = 0.5
vanishrandy = 0.5
vanishrandz = 0.5
blindrandx = 0.5
blindrandy = 0.5
blindrandz = 0.5
blindrandobeyglitch = true
vanishlimit = 50
vanishusenormal = true
eyedot = 0.4
local red = Color(255, 0, 0)
local blue = Color(0, 0, 255)
local white = Color(210, 159, 110, 255)
local green = Color(0, 255, 0)
local circle = Material("circle.png", "nocull")
whiteg = white
customcolors = {
	Color(210, 159, 110, 255),
	Color(203, 145, 65, 255),
	Color(205, 205, 220, 255),
	Color(150, 50, 150, 255),
	Color(250, 20, 80, 255),
	Color(250, 120, 40, 255),
	Color(250, 20, 40, 255),
	Color(10, 255, 20, 255)
}
local forcelines = false

function BlindSetColor(newcol)
	white = newcol
end

function BlindGetColor()
	return white
end

local grass = Color(20, 150, 10)
local sand = Color(76, 70, 50)
local glass = Color(10, 20, 150)
local limit = 5400
-- local pinged = false
local camvector = Vector()
local camang = Angle()
local camlerp = 0
local lerp, sound, bgm = nil
blindcolor = {
	0,
	0,
	0
}
local colors = {
	[MAT_DEFAULT] = blue,
	[MAT_GLASS] = glass,
	[MAT_SAND] = sand,
	[MAT_DIRT] = sand,
	[MAT_GRASS] = grass,
	[MAT_FLESH] = red
}
local colorslist = {
	green,
	grass,
	sand,
	glass
}
blindrandrendermin = 0.9
blindinverted = false
blindpopulate = false
blindpopulatespeed = 1000
blindfakepopulate = false
customglitch = false
blindcustomlerp = 0
blindcustompoints = {
	Vector()
}
local blindcustompoints = blindcustompoints
-- local sizemult = 1

function InvertColors()
	for k, v in ipairs(colorslist) do
		v.r = 255 - v.r
		v.g = 255 - v.g
		v.b = 255 - v.b
	end

	blindinverted = not blindinverted

	if blindinverted then
		white.r = 0
		white.g = 0
		white.b = 0
		sizemult = 4
		blindcolor[1] = 61
		blindcolor[2] = 61
		blindcolor[3] = 61
		blindrandrendermin = 1
	else
		white.r = 210
		white.g = 159
		white.b = 110
		blindcolor[1] = 0
		blindcolor[2] = 0
		blindcolor[3] = 0
		blindrandrendermin = 0.9
	end
end

function TogglePopulate()
	blindfakepopulate = not blindfakepopulate
end

local colorsclass = {
	prop_door_rotating = green,
	func_door_rotating = green,
	func_door = green
}
local blindedsounds = {
	["bad.wav"] = true,
	["music/locloop_unk.wav"] = true,
	["lidar/burst1.wav"] = true,
	["glitch.wav"] = true,
	["A_TT_CD_02.wav"] = true,
	["good.wav"] = true,
	["reset.wav"] = true,
	["ping.wav"] = true,
	["music/locloop.wav"] = true,
	["lidar/burst2.wav"] = true,
	["reset2.wav"] = true,
	["A_TT_CD_01.wav"] = true,
	["lidar/scan.wav"] = true,
	["lidar/burst4.wav"] = true,
	["lidar/burst3.wav"] = true,
	["lidar/scanstop.wav"] = true
}
local trw = {
	collisiongroup = COLLISION_GROUP_WORLD
}
local trwr = {}

local function IsInWorld(pos)
	trw.start = pos
	trw.endpos = pos
	trw.output = trwr

	util.TraceLine(trw)

	return trwr.HitWorld
end

local function RandomizeCam(eyepos, eyeang)
	local ctsin = 1 / (LocalPlayer():GetEyeTrace().Fraction * 200)

	if IsInWorld(eyepos) then
		ctsin = 100
	end

	lerp = Lerp(25 * FrameTime(), camlerp, ctsin)
	camvector.x = eyepos.x + lerp
	camvector.y = eyepos.y + lerp
	camvector.z = eyepos.z + lerp
	camang.p = eyeang.p
	camang.y = eyeang.y
	camang.r = eyeang.r
end

local function populatetrace(eyepos)
	local af = awareness:GetFloat() or 1000
	randvector.x = eyepos.x + math.random(-af, af)
	randvector.y = eyepos.y + math.random(-af, af)
	randvector.z = eyepos.z + math.random(-af * 0.5, af)
	tr.start = eyepos
	tr.endpos = randvector
	tr.output = tr_result

	if not IsValid(tr.filter) then
		tr.filter = LocalPlayer()
	end

	util.TraceLine(tr)

	return tr_result
end

local function Echo(t)
	table.insert(soundpoints, t.Pos)

	if not blindedsounds[t.SoundName] and t.SoundName:Left(3) ~= "te/" then return false end
end

local function PopThatMotherfucker()
	hitpoints:pop_left()
	hitcolor:pop_left()
	hitnormal:pop_left()
end

local blindcolor = blindcolor
local fakepopulatevec = Vector(1, 2, 3)
LOCEntities = LOCEntities or {}
meshtbl = meshtbl or new()
local meshtbl = meshtbl
pausescan = false
local mathrandom = math.random

/*
local function OptimizeMeshes()
	local i = 0
	-- local vertexcount = 0

	for v in meshtbl:iter_left() do
		if i >= 90 then break end

		v:Destroy()
		i = i + 1
	end
end
*/

glob_blindangles = Angle()
glob_blindorigin = Vector()
curmesh = Mesh()
local lastpointcount = 0
local nextcachecheck = 0

local function Blindness(origin, angles)
	local ply = LocalPlayer()
	local eyepos = origin
	local eyeang = angles
	local FT = FrameTime()
	local quality = quality:GetBool()
	glob_blindorigin:Set(origin)
	glob_blindangles:Set(angles)
	local hitpointscount = nil
	-- local vel_l = ply:GetVelocity():Length()
	-- local vel = 2.5
	cang = math.pi * 2 / 16 + (ply.offset or 0)
	cpos = Vector(0, math.cos(cang) * 75, math.sin(cang) * 250)
	ply.offset = (ply.offset or 0) + FrameTime()

	if ply.offset >= 180 then
		ply.offset = 0
	end

	local randrender = math.Rand(blindrandrendermin, 1)
	render.Clear(blindcolor[1] * randrender, blindcolor[2] * randrender, blindcolor[3] * randrender, 0)
	render.ClearDepth()
	render.ClearStencil()

	if blindpopulate then
		for i = 0, FT * blindpopulatespeed do
			if not blindfakepopulate then
				local trace = populatetrace(blindorigin or eyepos)

				if trace.Hit then
					hitpoints:push_right(trace.HitPos)
					local invert = mathrandom()

					if invert < 0.05 then
						trace.HitNormal:Mul(-1)
					end

					hitnormal:push_right(trace.HitNormal)
					local hcol = colors[trace.MatType]
					local hcolclass = colorsclass[trace.Entity:GetClass()]
					hitcolor:push_right(hcol or hcolclass or white)

					if limit < hitpoints:length() then
						PopThatMotherfucker()
					end
				end
			else
				hitpoints:push_right(fakepopulatevec)
				hitnormal:push_right(fakepopulatevec)
				hitcolor:push_right(white)

				if limit < hitpoints:length() then
					PopThatMotherfucker()
				end
			end
		end
	end

	hitpointscount = soundpoints:length()

	while limit < hitpointscount do
		soundpoints:pop_left()
		hitpointscount = soundpoints:length()
	end

	RandomizeCam(eyepos, eyeang)

	if sound then
		sound:ChangeVolume((lerp - 0.1) * 0.25)
	end

	cam.Start3D(camvector, camang)

	for k, v in pairs(LOCEntities) do
		if not IsValid(k) then
			LOCEntities[k] = nil
		else
			k:DrawLOC()
		end
	end

	-- local lastpos = hitpoints[hitpoints.tail]
	local f = eyeang:Forward()
	local eyediff = Vector()
	local k = limit
	local k2 = 0
	-- local vanishlimit = vanishlimit
	-- local vanishrandx = vanishrandx
	-- local vanishrandy = vanishrandy
	-- local vanishrandz = vanishrandz
	-- local blindrandx = blindrandx
	-- local blindrandy = blindrandy
	-- local blindrandz = blindrandz
	-- local blindrandobeyglitch = blindrandobeyglitch
	render.SetMaterial(circle)

	if not customglitch then
		GlitchIntensity = lerp
	end

	LocalPlayer().offset = (LocalPlayer().offset or 0) + FrameTime() * 2

	if LocalPlayer().offset >= 180 then
		LocalPlayer().offset = 0
	end

	local ed = eyedot
	local anggg = ply:EyeAngles()
	anggg.x = 0
	local eyep = ply:EyePos() + anggg:Forward() * 200
	local hitindex = 1
	local drawcount = #blindcustompoints
	local drawiters = 0
	local lerpt = blindcustomlerp

	if not pausescan then
		if not curmesh:IsValid() or CurTime() < nextcachecheck then
			-- local dynmesh = nil

			if CurTime() < nextcachecheck then
				if curmesh:IsValid() then
					curmesh:Destroy()
				end

				dynmesh = mesh.Begin(MATERIAL_QUADS, limit)
			else
				curmesh = Mesh()
				dynmesh = mesh.Begin(curmesh, MATERIAL_QUADS, limit)
			end

			for v in hitpoints:iter_right() do
				local col = hitcolor[hitcolor.tail - k2] or BlindGetColor()
				eyediff:Set(v)
				local drawindex = hitindex % drawcount + 1

				if drawindex == 1 then
					drawiters = drawiters + 1
				end

				eyep = blindcustompoints[drawindex] + Vector(math.random() * 2, math.random() * 2, math.random() * 2)

				if drawiters < 2 then
					eyediff:LerpTemp(lerpt, eyediff, eyep)
				end

				eyediff:Sub(eyepos)

				if ed < f:Dot(eyediff) / eyediff:Length() then
					eyediff:Set(v)

					if v ~= fakepopulatevec then
						if quality and not forcelines then
							mesh.QuadEasy(eyediff, hitnormal[hitnormal.tail - k2], 2, 2, col)
						else
							render.DrawLine(eyediff, v, col)
						end
					end

					lastpos = v
				end

				k = k - 1
				k2 = k2 + 1
				hitindex = hitindex + 1
			end

			mesh.End()

			if curmesh:IsValid() then
				curmesh:Draw()
			end
		else
			curmesh:Draw()
		end

		if lastpointcount ~= hitpoints:length() then
			nextcachecheck = CurTime() + 0.1
		end

		lastpointcount = hitpoints:length()
	end

	for v in meshtbl:iter_left() do
		v:Draw()
	end

	hook.Run("Blind3D", origin, angles)
	cam.End3D()
	hook.Run("Blind3DPost", origin, angles)

	-- local ctsin = math.sin(CurTime())
	local col = white
	col.a = alpha

	hook.Run("RenderScreenspaceEffects")

	local AEUIDraw = hook.GetTable().HUDPaint.AEUIDraw

	if AEUIDraw then
		cam.Start2D()
		AEUIDraw()
		cam.End2D()
	end

	return true
end

blinded = false

local function BlindnessPreUI()
	if blinded then
		cam.Start3D()
		render.Clear(10, 10, 10, 0)
		cam.End3D()
		draw.NoTexture()
	end
end

-- local te = "te/metamorphosis/"
/*
local jingles = {
	land = te .. "3-linedrop",
	jump = te .. "1-linemove",
	jumpwallrun = te .. "3-spin",
	wallrunh = te .. "3-spin",
	wallrunv = te .. "3-spin",
	coil = te .. "3-spin"
}
local jinglescount = {
	jump = 6,
	wallrunh = 6,
	jumpwallrun = 6,
	wallrunv = 6,
	land = 11,
	coil = 6
}

local function BlindnessJingles(event)
	if jingles[event] then
		LocalPlayer():EmitSound(jingles[event] .. math.random(1, jinglescount[event]) .. ".wav")
	end
end
*/

function ToggleBlindness(toggle)
	blinded = toggle

	if blinded then
		local ply = LocalPlayer()
		local activewep = ply:GetActiveWeapon()
		local usingrh = IsValid(activewep) and activewep:GetClass() == "runnerhands"

		if usingrh and activewep.RunWind1 then
			activewep.RunWind1:Stop()
			activewep.RunWind2:Stop()
		end

		gui.HideGameUI()
		hook.Add("EntityEmitSound", "Echo", Echo)
		hook.Add("RenderScene", "Blindness", Blindness)
		hook.Add("PreDrawHUD", "Blindness", BlindnessPreUI)
		hook.Add("RenderScreenspaceEffects", "CA", RenderCA)

		local milestone = ply:GetLevel() >= 100
		local bgmstring = milestone and "music/locloop.wav" or "music/locloop_unk.wav"
		forcelines = not milestone

		BlindSetColor(milestone and customcolors[1] or customcolors[3])

		if not sound then
			sound = CreateSound(LocalPlayer(), "glitch.wav")
		end

		if not bgm then
			bgm = CreateSound(LocalPlayer(), bgmstring)
		end

		sound:PlayEx(0, 100)

		if incredits then
			EmitSound("music/Sunrise.mp3", vector_origin, -2, 0, 1, 75, SND_SHOULDPAUSE)
		end

		hook.Run("Blind", true)
	else
		hook.Remove("EntityEmitSound", "Echo")
		hook.Remove("RenderScene", "Blindness")
		hook.Remove("PreDrawHUD", "Blindness")
		hook.Remove("RenderScreenspaceEffects", "CA")
		surface.SetAlphaMultiplier(1)

		if sound then
			sound:Stop()
		end

		if bgm then
			bgm:Stop()
			bgm = nil
		end

		hook.Run("Blind", false)
	end
end

function cool()
	local k = limit
	local k2 = 0
	a = Mesh(circle)
	mesh.Begin(a, MATERIAL_QUADS, limit)

	-- local ed = Vector()
	-- local meshlen = meshtbl:length()

	for v in hitpoints:iter_right() do
		mesh.QuadEasy(v, hitnormal[hitnormal.tail - k2], 2, 2, hitcolor[hitcolor.tail - k2] or white)
		k = k - 1
		k2 = k2 + 1
	end

	mesh.End()
	meshtbl:push_right(a)

	if meshtbl:length() > 160 then
		meshtbl:pop_left():Destroy()
	end
end

net.Receive("BlindPlayers", function()
	ToggleBlindness(net.ReadBool())
end)

net.Receive("BlindNPCKilled", function()
	LocalPlayer():EmitSound("bad.wav", 50, 100 + math.random(-5, 2))
end)

hook.Add("OnEntityCreated", "BlindnessEntities", function(ent)
	timer.Simple(0.5, function()
		if IsValid(ent) and ent.DrawLOC then
			LOCEntities[ent] = true
		end
	end)
end)

hook.Add("InitPostEntity", "Beatrun_LOC", function()
	if GetGlobalBool("LOC") then
		ToggleBlindness(true)
	end

	hook.Remove("EntityEmitSound", "zzz_TFA_EntityEmitSound")
	hook.Remove("InitPostEntity", "Beatrun_LOC")
end)