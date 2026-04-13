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

local XP_ratiocache = nil
local parkourevent_lastpos = Vector()
local meta = FindMetaTable("Player")

function meta:GetLevel()
	if game.SinglePlayer() then return self.Level or 1 end

	return self:GetNW2Int("Beatrun_Level", 1)
end

function meta:GetXP()
	if game.SinglePlayer() then return self.XP or 0 end

	return self:GetNW2Int("Beatrun_XP", 0)
end

function meta:GetLevelRatio()
	local lastratio = CalcXPForNextLevel(self:GetLevel() - 1)

	XP_ratiocache = XP_ratiocache or (self:GetXP() - lastratio) / (CalcXPForNextLevel(self:GetLevel()) - lastratio)

	return XP_ratiocache
end

function meta:LevelUp()
	if not game.SinglePlayer() then return end

	local i = 0

	while self:GetLevelRatio() >= 1 do
		self:SetLevel(self:GetLevel() + 1)

		i = i + 1

		if i > 1000 then break end
	end

	if i > 0 then self:EmitSound("mirrorsedge/UI/ME_UI_challenge_end_success.wav", 35, 100 + math.random(-5, 5)) end
end

function meta:SetLevel(level)
	if game.SinglePlayer() then
		self.Level = level
		self.XP = CalcXPForNextLevel(level - 1)

		XP_ratiocache = nil
	end
end

function meta:SetXP(xp)
	if game.SinglePlayer() then
		self.XP = xp

		XP_ratiocache = nil

		self:LevelUp()
	end
end

function meta:AddXP(xp)
	if game.SinglePlayer() then
		self.XP = math.Round((self.XP or 0) + xp)

		XP_ratiocache = nil

		self:LevelUp()

		self.LastXP = CurTime()

		if xp > 0 then XP_floatingxp[CurTime() + 2] = "+" .. xp end
	end
end

if game.SinglePlayer() then
	function SaveXP()
		local ply = LocalPlayer()
		local data = util.TableToJSON({ ply.XP or 0, ply.Level or 1 })
		local compressed = util.Compress(data)

		file.CreateDir("beatrun/local")
		file.Write("beatrun/local/xp.txt", compressed)
	end

	hook.Add("ShutDown", "SaveXP", SaveXP)

	local function LoadXP()
		local ply = LocalPlayer()
		local data = file.Read("beatrun/local/xp.txt", "DATA")

		if data then
			data = util.JSONToTable(util.Decompress(data))

			ply:SetXP(data[1])
			ply:SetLevel(data[2])
		else
			ply:SetXP(0)
			ply:SetLevel(1)
		end
	end

	hook.Add("InitPostEntity", "LoadXP", LoadXP)

	hook.Add("OnParkour", "ParkourXP", function(event)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local pos = ply:GetPos()

		if math.random() < (ParkourXP_RNG[event] or 1) and (not ParkourXP_PosCheck[event] or parkourevent_lastpos:Distance(pos) > 200) then
			local xp = (ParkourXP[event] or 0) * math.max(math.Round(ply:GetLevel() * 0.05), 1)

			ply:AddXP(xp)

			if ParkourXP_PosCheck[event] then parkourevent_lastpos:Set(pos) end
		end
	end)
else
	hook.Add("OnParkour", "ParkourXP", function(event)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local pos = ply:GetPos()

		if math.random() < (ParkourXP_RNG[event] or 1) and (not ParkourXP_PosCheck[event] or parkourevent_lastpos:Distance(pos) > 200) then
			net.Start("Beatrun_ParkourEvent")
				net.WriteString(event)
			net.SendToServer()

			if ParkourXP_PosCheck[event] then parkourevent_lastpos:Set(pos) end
		end
	end)

	net.Receive("Beatrun_XPUpdate", function() XP_ratiocache = nil end)

	net.Receive("Beatrun_FloatingXP", function()
		local xp = net.ReadInt(16)
		if xp > 0 then XP_floatingxp[CurTime() + 2] = "+" .. xp end
	end)

	net.Receive("Beatrun_LevelUpSound", function() LocalPlayer():EmitSound("mirrorsedge/UI/ME_UI_challenge_end_success.wav", 35, 100 + math.random(-5, 5)) end)
end
