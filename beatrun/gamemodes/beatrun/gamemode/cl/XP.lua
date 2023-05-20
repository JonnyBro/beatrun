local meta = FindMetaTable("Player")
local XP_max = 2000000
local XP_ratiocache = nil
local parkourevent_lastpos = Vector()

function XP_nextlevel(level)
	return math.Round(0.25 * level^3 + 0.8 * level^2 + 2 * level)
end

local ParkourXP = {
	roll = 3,
	sidestep = 1,
	slide = 1,
	vault = 2,
	climb = 4,
	wallrunh = 2,
	springboard = 2,
	wallrunv = 2,
	coil = 1,
	swingbar = 4,
	step = 1
}
local ParkourXP_RNG = {
	sidestep = 0.1
}
local ParkourXP_PosCheck = {
	climb = true,
	vault = true,
	wallrunh = true,
	wallrunv = true
}
XP_floatingxp = {}

hook.Add("OnParkour", "ParkourXP", function (event)
	local ply = LocalPlayer()

	if ply.InReplay then
		return
	end

	local pos = ply:GetPos()

	if math.random() < (ParkourXP_RNG[event] or 1) and (not ParkourXP_PosCheck[event] or parkourevent_lastpos:Distance(pos) > 200) then
		local xp = (ParkourXP[event] or 0) * math.max(math.Round(ply:GetLevel() * 0.05), 1)

		ply:AddXP(xp)

		if ParkourXP_PosCheck[event] then
			parkourevent_lastpos:Set(pos)
		end
	end
end)

function meta:GetLevel()
	return self.Level or 0
end

function meta:GetLevelRatio()
	local lastratio = XP_nextlevel(self:GetLevel() - 1)
	XP_ratiocache = XP_ratiocache or (self:GetXP() - lastratio) / (XP_nextlevel(self:GetLevel()) - lastratio)

	return XP_ratiocache
end

function meta:SetLevel(level)
	self.Level = level
	XP_ratiocache = nil
end

function meta:LevelUp()
	local i = 0

	while self:GetLevelRatio() >= 1 do
		self:SetLevel(self:GetLevel() + 1)

		i = i + 1

		if i > 1000 then
			break
		end
	end

	if i > 0 then
		self:EmitSound("MirrorsEdge/UI/ME_UI_challenge_end_success.wav", 35, 100 + math.random(-5, 5))
	end
end

function meta:GetXP()
	return self.XP or 0
end

function meta:SetXP(xp)
	self.XP = math.Round(xp)
	XP_ratiocache = nil

	self:LevelUp()
end

function meta:AddXP(xp)
	self.XP = math.Round((self.XP or 0) + xp)
	XP_ratiocache = nil

	self:LevelUp()

	self.LastXP = CurTime()

	if xp > 0 then
		XP_floatingxp[CurTime() + 2] = "+" .. xp
	end
end

local function SaveXP()
	local xp = util.TableToJSON({
		LocalPlayer().XP or 0,
		LocalPlayer().Level or 1
	})
	local xpold = file.Read("beatrun/local/xp.txt", "DATA")

	if xpold then
		xpold = util.Decompress(xpold)

		if LocalPlayer().XP < util.JSONToTable(xpold)[1] then
			return
		end
	end

	local xp = util.Compress(xp)

	file.CreateDir("beatrun/local")
	file.Write("beatrun/local/xp.txt", xp)
end

hook.Add("ShutDown", "SaveXP", SaveXP)

local function LoadXP()
	local xp = file.Read("beatrun/local/xp.txt", "DATA")

	if xp then
		xp = util.JSONToTable(util.Decompress(xp))

		LocalPlayer():SetXP(xp[1])
		LocalPlayer():SetLevel(xp[2])
	else
		LocalPlayer():SetXP(0)
		LocalPlayer():SetLevel(1)
	end
end

hook.Add("InitPostEntity", "LoadXP", LoadXP)
