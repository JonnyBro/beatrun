AddCSLuaFile()

DEFINE_BASECLASS("player_default")

if CLIENT then
	CreateConVar("cl_playercolor", "0.24 0.34 0.41", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")
	CreateConVar("cl_weaponcolor", "0.30 1.80 2.10", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")
	CreateConVar("cl_playerskin", "0", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The skin to use, if the model has any")
	CreateConVar("cl_playerbodygroups", "0", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The bodygroups to use, if the model has any")

	local lframeswepclass = lframeswepclass or ""
end

local PLAYER = {}

PLAYER.DuckSpeed = 0.01 -- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed = 0.01 -- How fast to go from ducking, to not ducking

PLAYER.TauntCam = TauntCamera()

PLAYER.WalkSpeed = 200
PLAYER.RunSpeed = 400

function PLAYER:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self.Player:NetworkVar("Float", 0, "MEMoveLimit")
	self.Player:NetworkVar("Float", 1, "MESprintDelay")
	self.Player:NetworkVar("Float", 2, "MEAng")

	self.Player:NetworkVar("Int", 0, "Climbing")
	self.Player:NetworkVar("Float", 3, "ClimbingTime")
	self.Player:NetworkVar("Vector", 0, "ClimbingStart")
	self.Player:NetworkVar("Vector", 1, "ClimbingEnd")
	self.Player:NetworkVar("Vector", 7, "ClimbingEndOld")
	self.Player:NetworkVar("Float", 24, "ClimbingDelay")
	self.Player:NetworkVar("Angle", 3, "ClimbingAngle")

	self.Player:NetworkVar("Int", 1, "Wallrun")
	self.Player:NetworkVar("Float", 4, "WallrunTime")
	self.Player:NetworkVar("Float", 5, "WallrunSoundTime")
	self.Player:NetworkVar("Vector", 2, "WallrunDir")
	self.Player:NetworkVar("Vector", 8, "WallrunOrigVel")
	self.Player:NetworkVar("Int", 4, "WallrunCount")

	self.Player:NetworkVar("Bool", 0, "Sliding")
	self.Player:NetworkVar("Float", 6, "SlidingTime")
	self.Player:NetworkVar("Float", 7, "SlidingDelay")
	self.Player:NetworkVar("Vector", 4, "SlidingLastPos")
	self.Player:NetworkVar("Float", 18, "SlidingVel")
	self.Player:NetworkVar("Float", 19, "SlidingStrafe")
	self.Player:NetworkVar("Bool", 9, "SlidingSlippery")
	self.Player:NetworkVar("Float", 20, "SlidingSlipperyUpdate")
	self.Player:NetworkVar("Angle", 2, "SlidingAngle")

	self.Player:NetworkVar("Bool", 1, "StepRight")
	self.Player:NetworkVar("Float", 8, "StepRelease")

	self.Player:NetworkVar("Bool", 2, "Grappling")
	self.Player:NetworkVar("Vector", 3, "GrapplePos")
	self.Player:NetworkVar("Float", 29, "GrappleLength")

	self.Player:NetworkVar("Entity", 0, "Swingbar")

	self.Player:NetworkVar("Bool", 3, "CrouchJump")
	self.Player:NetworkVar("Float", 9, "CrouchJumpTime")
	self.Player:NetworkVar("Bool", 12, "CrouchJumpBlocked")

	self.Player:NetworkVar("Float", 9, "SafetyRollKeyTime")
	self.Player:NetworkVar("Float", 10, "SafetyRollTime")
	self.Player:NetworkVar("Angle", 0, "SafetyRollAng")

	self.Player:NetworkVar("Bool", 4, "Quickturn")
	self.Player:NetworkVar("Float", 10, "QuickturnTime")
	self.Player:NetworkVar("Angle", 1, "QuickturnAng")

	self.Player:NetworkVar("Bool", 5, "WallrunElevated")

	--We have to store this info on the player as multiple people can use one swingbar
	self.Player:NetworkVar("Float", 11, "SBOffset")
	self.Player:NetworkVar("Float", 12, "SBOffsetSpeed")
	self.Player:NetworkVar("Float", 13, "SBStartLerp")
	self.Player:NetworkVar("Float", 14, "SBDelay")
	self.Player:NetworkVar("Int", 2, "SBPeak")
	self.Player:NetworkVar("Bool", 6, "SBDir")
	self.Player:NetworkVar("Entity", 1, "SwingbarLast")

	self.Player:NetworkVar("Entity", 2, "Swingpipe")
	self.Player:NetworkVar("Entity", 3, "Rabbit")
	self.Player:NetworkVar("Int", 3, "RabbitSeat")

	self.Player:NetworkVar("Float", 15, "OverdriveCharge")
	self.Player:NetworkVar("Float", 16, "OverdriveMult")

	self.Player:NetworkVar("Bool", 7, "JumpTurn")
	self.Player:NetworkVar("Float", 17, "JumpTurnRecovery")

	self.Player:NetworkVar("Bool", 8, "WasOnGround")

	self.Player:NetworkVar("Entity", 4, "Ladder")
	self.Player:NetworkVar("Float", 21, "LadderDelay")
	self.Player:NetworkVar("Float", 22, "LadderHeight")
	self.Player:NetworkVar("Bool", 10, "LadderEntering")
	self.Player:NetworkVar("Bool", 11, "LadderHand")
	self.Player:NetworkVar("Vector", 5, "LadderStartPos")
	self.Player:NetworkVar("Vector", 6, "LadderEndPos")
	self.Player:NetworkVar("Float", 23, "LadderLerp")

	self.Player:NetworkVar("Entity", 5, "Zipline")
	self.Player:NetworkVar("Float", 21, "ZiplineStart")
	self.Player:NetworkVar("Float", 22, "ZiplineFraction")
	self.Player:NetworkVar("Float", 23, "ZiplineSpeed")
	self.Player:NetworkVar("Float", 25, "ZiplineDelay")

	self.Player:NetworkVar("Int", 5, "MeleeDamage")
	self.Player:NetworkVar("Float", 26, "MeleeTime")
	self.Player:NetworkVar("Float", 27, "MeleeDelay")
	self.Player:NetworkVar("Int", 6, "Melee")

	self.Player:NetworkVar("Float", 28, "Balance")
	self.Player:NetworkVar("Entity", 6, "BalanceEntity")

	self.Player:NetworkVar("Bool", 13, "Dive")
end

function PLAYER:Loadout()
	if GetGlobalBool("GM_DATATHEFT") or GetGlobalBool("GM_DEATHMATCH") then
		BeatrunGiveGMLoadout(self.Player)
	else
		self.Player:RemoveAllAmmo()
	end

	self.Player:Give("runnerhands")
	self.Player:SelectWeapon("runnerhands")

	self.Player:SetJumpPower(230)
	self.Player:SetCrouchedWalkSpeed(0.5)
	self.Player:SetFOV(self.Player:GetInfoNum("Beatrun_FOV", 100))
	self.Player:SetCanZoom(false)
end

function PLAYER:SetModel()
	BaseClass.SetModel(self)

	local skin = self.Player:GetInfoNum("cl_playerskin", 0)

	self.Player:SetSkin(skin)

	local groups = self.Player:GetInfo("cl_playerbodygroups")

	if groups == nil then
		groups = ""
	end

	local groups = string.Explode(" ", groups)

	for k = 0, self.Player:GetNumBodyGroups() - 1 do
		self.Player:SetBodygroup(k, tonumber(groups[k + 1]) or 0)
	end
end

if SERVER then
	util.AddNetworkString("BeatrunSpawn")
end

function PLAYER:Spawn()
	BaseClass.Spawn(self)

	local ply = self.Player
	local col = ply:GetInfo("cl_playercolor")

	ply:SetPlayerColor(Vector(col))

	local faststartmult = (ply:GetInfoNum("Beatrun_FastStart", 0) > 0 and 0.5) or 1
	local col = Vector(ply:GetInfo("cl_weaponcolor"))

	if col:Length() < 0.001 then
		col = Vector(0.001, 0.001, 0.001)
	end

	ply:SetWeaponColor(col)

	local CPSave = false

	if Course_Name ~= "" and Course_StartPos ~= vector_origin then
		if ply:GetInfoNum("Beatrun_CPSave", 0) >= 1 and ply:GetNW2Float("CPNum", 1) > 1 and ply.CPSavePos and ply.LastSpawnTime + 0.6 < CurTime() then
			ply:SetPos(ply.CPSavePos)
			ply:SetEyeAngles(ply.CPSaveAng)
			ply:SetLocalVelocity(ply.CPSaveVel)
			ply:LoadParkourState()

			CPSave = true
		else
			ply.CPSavePos = nil
			ply.CPsaveAng = nil
			ply.CPsaveVel = nil

			ply:SetPos(Course_StartPos)
			ply:SetEyeAngles(Angle(0, Course_StartAng, 0))
			ply:SetLocalVelocity(vector_origin)

			--Failsafe
			timer.Simple(0.1, function()
				ply:SetLocalVelocity(vector_origin)
				ply:SetPos(Course_StartPos)
			end)

			-- ReplayStop(ply)
			-- ReplayStart(ply)
		end
	end

	if not ply.InReplay and not CPSave then
		ply:SetNW2Float("CPNum", 1)
	end

	if not CPSave then
		ply.Course_StartTime = CurTime() + (2 * faststartmult)

		net.Start("BeatrunSpawn")
			net.WriteFloat(CurTime())
			net.WriteBool(ply.InReplay)
		net.Send(ply)

		ply.SpawnFreezeTime = CurTime() + (1.75 * faststartmult)
	end

	ply:SetCustomCollisionCheck(true)

	if GetGlobalBool("GM_DATATHEFT") then
		ply:DataTheft_Bank()
	end

	ply:SetAvoidPlayers(false)
	ply:SetLaggedMovementValue(0) --otherwise they drift off

	timer.Simple(0.1, function()
		ply:SetLaggedMovementValue(1)
	end)

	if ply.SlideLoopSound and ply.SlideLoopSound.Stop then
		ply.SlideLoopSound:Stop()
	end

	ply:ResetParkourState()
	ply:SetOverdriveCharge(0)
	ply:SetOverdriveMult(1)
	ply.LastSpawnTime = CurTime()
end

hook.Add("IsSpawnpointSuitable", "CheckSpawnPoint", function(ply, spawnpointent, bMakeSuitable)
	if not GetGlobalBool("GM_DATATHEFT") or not GetGlobalBool("GM_DEATHMATCH") then return end

	local pos = spawnpointent:GetPos()

	-- Note that we're searching the default hull size here for a player in the way of our spawning.
	-- This seems pretty rough, seeing as our player's hull could be different.. but it should do the job.
	-- (HL2DM kills everything within a 128 unit radius)
	local ents = ents.FindInBox(pos + Vector(-16, -16, 0), pos + Vector(16, 16, 72))
	local Blockers = 0

	for _, v in ipairs(ents) do
		if v:IsPlayer() and v:Alive() then
			Blockers = Blockers + 1

			if bMakeSuitable then
				v:Kill()
			end
		end
	end

	if bMakeSuitable then return true end
	if Blockers > 0 then return false end

	return true
end)

hook.Add("SetupMove", "SpawnFreeze", function(ply, mv, cmd)
	if ply.SpawnFreezeTime and Course_Name ~= "" and Course_StartPos ~= vector_origin and Course_StartPos and ply.SpawnFreezeTime > CurTime() then
		mv:SetOrigin(Course_StartPos)
	end
end)

hook.Add("ShouldCollide", "NoPlayerCollisions", function(ent1, ent2)
	if ent1:IsPlayer() and (ent2:IsPlayer() or ent2.NoPlayerCollisions) then
		if ent2.BRCollisionFunc then
			return ent2:BRCollisionFunc(ent1)
		else
			if (ent1.br_Fired and ent2.br_FiredBy == ent1) or (ent2.br_Fired and ent1.br_FiredBy == ent2) then return true end

			return false
		end
	end

	if ent2:IsPlayer() and ent1:IsNPC() then return true end
end)

local function calc_fov(src, dst)
	local v_src = src:Forward()
	local v_dst = dst:Forward()
	local result = math.deg(math.acos(v_dst:Dot(v_src) / v_dst:Length()))

	if result ~= result or (result == math.huge or result == -math.huge) then
		result = 0
	end

	return result
end

-- i was forced
hook.Add("EntityFireBullets", "thisengineismadebyacrackhead", function(ent, data)
	if not IsValid(ent) or not isfunction(ent.GetShootPos) or not ent:IsPlayer() then return end

	for _, ply in ipairs(player.GetAll()) do
		if ply == ent then continue end

		local fov = calc_fov(data.Dir:Angle(), (ply:GetShootPos() - data.Src):Angle())
		if fov > 60 then continue end

		ply.br_FiredBy = ent

		timer.Simple(engine.TickInterval() * 3, function()
			if IsValid(ply) then
				ply.br_FiredBy = nil
			end
		end)
	end

	ent.br_Fired = true

	timer.Simple(engine.TickInterval() * 3, function()
		if IsValid(ent) then
			ent.br_Fired = false
		end
	end)
end)

hook.Add("PhysgunPickup", "AllowPlayerPickup", function(ply, ent)
	if ply:IsSuperAdmin() and ent:IsPlayer() then return true end
end)

function PLAYER:ShouldDrawLocal()
	if self.TauntCam:ShouldDrawLocalPlayer(self.Player, self.Player:IsPlayingTaunt()) then return true end
end

function PLAYER:CreateMove(cmd)
	if self.TauntCam:CreateMove(cmd, self.Player, self.Player:IsPlayingTaunt()) then return true end
end

function PLAYER:CalcView(view)
	local mult = (self.Player:InOverdrive() and 1.1) or 1
	local fov = GetConVar("Beatrun_FOV"):GetInt()

	view.fov = fov * mult

	if self.TauntCam:CalcView(view, self.Player, self.Player:IsPlayingTaunt()) then return true end
end

function PLAYER:GetHandsModel()
	local cl_playermodel = self.Player:GetInfo("cl_playermodel")

	return player_manager.TranslatePlayerHands(cl_playermodel)
end

function PLAYER:StartMove(move)
end

function PLAYER:FinishMove(move)
end

hook.Add("FinishMove", "BeatrunRHVelocity", function(ply, mv)
	local activewep = ply:GetActiveWeapon()

	if ply:UsingRH() and activewep.SetOwnerVelocity then
		activewep:SetOwnerVelocity(math.Round(mv:GetVelocity():Length()))
	end
end)

local meta = FindMetaTable("Player")

function meta:ResetParkourState()
	self:SetSliding(false)
	self:SetCrouchJump(false)
	self:SetQuickturn(false)
	self:SetGrappling(false)
	self:SetSwingbar(nil)
	self:SetZipline(nil)
	self:SetLadder(nil)
	self:SetMantle(0)
	self:SetWallrun(0)
	self:SetMEMoveLimit(0)
	self:SetMESprintDelay(0)
	self:SetMEAng(0)
	self:SetClimbing(0)
	self:SetClimbingTime(0)
	self:SetWallrunTime(0)
	self:SetWallrunSoundTime(0)
	self:SetSlidingTime(0)
	self:SetSlidingDelay(0)
	self:SetCrouchJumpTime(0)
	self:SetSafetyRollKeyTime(0)
	self:SetSafetyRollTime(0)
	self:SetQuickturnTime(0)
	self:SetMeleeTime(0)
	self:SetMeleeDelay(0)
	self:SetJumpTurn(false)
	self:SetDive(false)
	self:SetViewOffsetDucked(Vector(0, 0, 32))

	self.Swingrope = nil
	self.DiveSliding = false

	ParkourEvent("jump", self)

	self:StopSound("ZiplineLoop")
end

function meta:SaveParkourState()
	self.ParkourSave = {
		self:GetSliding(),
		self:GetCrouchJump(),
		self:GetQuickturn(),
		self:GetGrappling(),
		self:GetSwingbar(),
		self:GetZipline(),
		self:GetLadder(),
		self:GetMantle(),
		self:GetWallrun(),
		self:GetMEMoveLimit(),
		self:GetMESprintDelay(),
		self:GetMEAng(),
		self:GetClimbing(),
		self:GetClimbingTime(),
		self:GetWallrunTime(),
		self:GetWallrunSoundTime(),
		self:GetSlidingTime(),
		self:GetSlidingDelay(),
		self:GetCrouchJumpTime(),
		self:GetSafetyRollKeyTime(),
		self:GetSafetyRollTime(),
		self:GetQuickturnTime(),
		self:GetJumpTurn(),
		self:GetDive(),
	}
end

function meta:LoadParkourState()
	local save = self.ParkourSave
	if not save then return end

	self:SetSliding(save[1])
	self:SetCrouchJump(save[2])
	self:SetQuickturn(save[3])
	self:SetGrappling(save[4])
	self:SetSwingbar(save[5])
	self:SetZipline(save[6])
	self:SetLadder(save[7])
	self:SetMantle(save[8])
	self:SetWallrun(save[9])
	self:SetMEMoveLimit(save[10])
	self:SetMESprintDelay(save[11])
	self:SetMEAng(save[12])
	self:SetClimbing(save[13])
	self:SetClimbingTime(save[14])
	self:SetWallrunTime(save[15])
	self:SetWallrunSoundTime(save[16])
	self:SetSlidingTime(save[17])
	self:SetSlidingDelay(save[18])
	self:SetCrouchJumpTime(save[19])
	self:SetSafetyRollKeyTime(save[20])
	self:SetSafetyRollTime(save[21])
	self:SetQuickturnTime(save[22])
	self:SetJumpTurn(save[23])
	self:SetDive(save[24])
end

function meta:ResetParkourTimes()
	self:SetClimbingTime(0)
	self:SetWallrunTime(0)
	self:SetWallrunSoundTime(0)
	self:SetSlidingTime(0)
	self:SetSlidingDelay(0)
	self:SetCrouchJumpTime(0)
	self:SetSafetyRollKeyTime(0)
	self:SetSafetyRollTime(0)
	self:SetQuickturnTime(0)
end

function meta:InOverdrive()
	if not self.GetOverdriveMult then return false end

	return self:GetOverdriveMult() ~= 1
end

function meta:GetRolling()
	return self:GetSafetyRollTime() > CurTime()
end

hook.Add("PlayerSpawn", "ResetStateTransition", function(ply, transition)
	timer.Simple(0, function()
		if transition and IsValid(ply) then
			ply:ResetParkourTimes()
			ply:SetJumpPower(230)
			ply:SetFOV(ply:GetInfoNum("Beatrun_FOV", 100))
			ply:SetCanZoom(false)
			ply.ClimbingTrace = nil
		end
	end)
end)

hook.Add("PlayerSwitchWeapon", "BeatrunSwitchARC9FOVFix", function(ply)
	-- This ENTIRE hook is for dealing with ARC9's stupid FOV reset
	-- behavior after switching away from an ARC9 SWEP.
	ply:SetFOV(ply:GetInfoNum("Beatrun_FOV", 100))

	timer.Simple(0, function()
		ply:SetFOV(ply:GetInfoNum("Beatrun_FOV", 100))
	end)
end)

player_manager.RegisterClass("player_beatrun", PLAYER, "player_default")
