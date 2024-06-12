local windsound

if CLIENT then
	windsound = CreateClientConVar("Beatrun_Wind", 1, true, false, "Wind noises", 0, 1)

	SWEP.PrintName = "Runner Hands"
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true

	hook.Add("VManipPrePlayAnim", "LOCNoVManip", function()
		if LocalPlayer():UsingRH() or blinded then return false end
	end)
end

SWEP.Author = "datae"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "LMB - Punch\nE + LMB - Overdrive (if enabled)\nRMB + A/D - Sidestep\nRMB while in air - Jump Turn"

SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.HoldType = "fist"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Category = "Beatrun"

-- Just don't draw the hands, we don't need 'em
SWEP.UseHands = false

SWEP.ViewModel = "models/runnerhands.mdl"
SWEP.WorldModel = ""

SWEP.ViewModelFOV = 75 --65 75

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.wepvelocity = 0

SWEP.lastpunch = 1 --1 right 2 left 3 both
SWEP.lastanimenum = 0
SWEP.spamcount = 0
SWEP.spamlast = 0
SWEP.punchanims = {ACT_DOD_PRIMARYATTACK_PRONE, ACT_DOD_SECONDARYATTACK_PRONE, ACT_DOD_PRIMARYATTACK_KNIFE}
SWEP.punchanimsfb = {"punchright", "punchleft", "punchmid"}
SWEP.punchangles = {Angle(2, 1, -2), Angle(2, -1, 2), Angle(2.5, 0, 0)}
SWEP.punchdelays = {0.165, 0.175, 0.5}
SWEP.lastpunchtimer = 0
SWEP.punching = false
SWEP.doublepunch = false

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "SideStep")
	self:NetworkVar("Bool", 1, "BlockAnims")
	self:NetworkVar("Bool", 2, "WasOnGround")
	self:NetworkVar("Bool", 3, "QuakeJumping")
	self:NetworkVar("Float", 0, "OwnerVelocity")
	self:NetworkVar("Float", 1, "WeaponVelocity")
	self:NetworkVar("Int", 0, "Punch")
	self:NetworkVar("Float", 2, "PunchReset")
end

-- local runseq = {
-- 	[6] = true,
-- 	[7] = true
-- }

local oddseq = {
	[8] = true,
	[9] = true,
	[10] = true,
	[19] = true,
}

function SWEP:GetViewModelPosition(pos, ang)
	if oddseq[self:GetSequence()] then return pos, ang end

	self.BobScale = 0
	ang.x = math.Clamp(ang.x, -10, 89)

	return pos, ang
end

function SWEP:Deploy()
	self:SetHoldType("normal")
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.RespawnDelay = 0
	self:SetWasOnGround(false)
	self:SetBlockAnims(false)
	self:SetPunch(1)
end

function SWEP:Initialize()
	self.RunWind1 = CreateSound(self, "clotheswind.wav")
	self.RunWind2 = CreateSound(self, "runwind.wav")
	self.RunWindVolume = 0
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.RespawnDelay = 0
	self:SetWasOnGround(false)
	self:SetBlockAnims(false)
end

local jumpseq = {ACT_VM_HAULBACK, ACT_VM_SWINGHARD}

-- local jumptr, jumptrout = {}, {}
-- local jumpvec = Vector(0, 0, -50)
local fallang = Angle()
local infall
local fallct = 0

function SWEP:Think()
	local ply = self:GetOwner()
	local viewmodel = ply:GetViewModel()

	if not IsValid(viewmodel) then return end

	if self:GetHoldType() == "fist" and CurTime() > self:GetPunchReset() then
		self:SetHoldType("normal")
	end

	if self:GetBlockAnims() then
		ply:GetViewModel():SetPlaybackRate(1)

		return
	end

	local curseq = self:GetSequence()
	local onground = ply:OnGround()
	local vel = ply:GetVelocity()
	vel.z = 0

	local ismoving = vel:Length() > 100 and not ply:KeyDown(IN_BACK) and ply:IsSprinting() and not ply:Crouching() and not ply:KeyDown(IN_DUCK)
	local injump = curseq == 13 or curseq == 14 or curseq == 17 or curseq == -1 or curseq == 1
	infall = curseq == 19

	--[[ TODO: what a piece of shit, send help
	if vel:Length() == 0 and util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 30, ply).Hit and ply:GetMoveType() ~= MOVETYPE_NOCLIP and not ply:Crouching() and ply:WaterLevel() == 0 and ply:GetWallrun() == 0 then
		if (math.floor(ply:LocalEyeAngles().y) <= 35 and math.floor(ply:LocalEyeAngles().y) >= 5) or (math.floor(ply:LocalEyeAngles().y) <= 125 and math.floor(ply:LocalEyeAngles().y) >= 95) or (math.floor(ply:LocalEyeAngles().y) <= -55 and math.floor(ply:LocalEyeAngles().y) >= -85) or (math.floor(ply:LocalEyeAngles().y) <= -145 and math.floor(ply:LocalEyeAngles().y) >= -175) then
			if CLIENT then
				BodyLimitX = 20

				return ArmInterrupt("standhandwallright")
			elseif game.SinglePlayer() then
				return ply:SendLua("BodyLimitX = 20 ArmInterrupt('standhandwallright')")
			end
		elseif (math.floor(ply:LocalEyeAngles().y) <= 5 and math.floor(ply:LocalEyeAngles().y) >= -5) or (math.floor(ply:LocalEyeAngles().y) <= 95 and math.floor(ply:LocalEyeAngles().y) >= 85) or (math.floor(ply:LocalEyeAngles().y) <= -85 and math.floor(ply:LocalEyeAngles().y) >= -95) or (math.floor(ply:LocalEyeAngles().y) <= -175 or math.floor(ply:LocalEyeAngles().y) >= 175) then
			if CLIENT then
				BodyLimitX = 20

				return ArmInterrupt("standhandwallboth")
			elseif game.SinglePlayer() then
				return ply:SendLua("BodyLimitX = 20 ArmInterrupt('standhandwallboth')")
			end
		elseif (math.floor(ply:LocalEyeAngles().y) <= 5 and math.floor(ply:LocalEyeAngles().y) >= -35) or (math.floor(ply:LocalEyeAngles().y) <= 85 and math.floor(ply:LocalEyeAngles().y) >= 55) or (math.floor(ply:LocalEyeAngles().y) <= -95 and math.floor(ply:LocalEyeAngles().y) >= -125) or (math.floor(ply:LocalEyeAngles().y) <= 175 and math.floor(ply:LocalEyeAngles().y) >= 145) then
			if CLIENT then
				BodyLimitX = 20

				return ArmInterrupt("standhandwallleft")
			elseif game.SinglePlayer() then
				return ply:SendLua("BodyLimitX = 20 ArmInterrupt('standhandwallleft')")
			end
		end
	end
	--]]

	self:SetSideStep((curseq == 15 or curseq == 16) and GetConVar("Beatrun_SideStep"):GetBool())

	local insidestep = self:GetSideStep()
	local spvel = ply:GetVelocity()
	local ang = ply:EyeAngles()

	if spvel.z < -800 and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
		if not infall then
			-- if CLIENT then
			-- 	RemoveBodyAnim()
			-- elseif game.SinglePlayer() then
			-- 	self:GetOwner():SendLua("RemoveBodyAnim()")
			-- end
			self:SendWeaponAnim(ACT_RUN_ON_FIRE)
		end

		if CLIENT and fallct ~= CurTime() then
			local vel = math.min(math.abs(spvel.z) / 2500, 1)
			local mult = 20

			fallang:SetUnpacked(2 * vel * FrameTime() * mult, 1.25 * vel * FrameTime() * mult, 1.5 * vel * FrameTime() * mult)
			fallang:Add(ang)

			fallct = CurTime()
		end

		return
	elseif infall then
		self:SendWeaponAnim(ACT_VM_DRAW)

		ang.z = 0

		ply:SetEyeAngles(ang)
	end

	spvel.z = 0

	local velocity = self:GetOwnerVelocity()

	self.punching = curseq == 8 or curseq == 9 or curseq == 10 or curseq == 11

	if ply:KeyPressed(IN_JUMP) and self:GetWasOnGround() and not ply:GetJumpTurn() then
		ply:ViewPunch(Angle(-2, 0, 0))

		local eyeang = ply:EyeAngles()
		eyeang.x = 0

		if insidestep and viewmodel:GetCycle() <= 0.1 and GetConVar("Beatrun_QuakeJump"):GetBool() then
			if SERVER then
				ply:EmitSound("quakejump.mp3", 100, 100, 0.2)
			end

			ply.QuakeJumping = true

			self:SetQuakeJumping(true)
		end

		if not ismoving and not ply:Crouching() then
			ParkourEvent("jumpstill", ply)
		elseif not ply:Crouching() then
			if not util.QuickTrace(ply:GetPos() + eyeang:Forward() * 200, Vector(0, 0, -100), ply).Hit then
				self:SendWeaponAnim(jumpseq[1])

				ParkourEvent("jumpfar", ply)
			else
				self:SendWeaponAnim(jumpseq[2])

				ParkourEvent("jump", ply)
			end
		end

		return
	end

	if onground then
		self:SetQuakeJumping(false)
	end

	if ply:GetSliding() or ply:GetSlidingDelay() - 0.15 > CurTime() then
		self:SendWeaponAnim(ACT_VM_DRAW)

		return
	end

	if self.punching and viewmodel:GetCycle() >= 1 then
		self:SendWeaponAnim(ACT_VM_DRAW)
	end

	if injump and (viewmodel:GetCycle() >= 1 or (ply:GetMantle() ~= 0 and ply:KeyDown(IN_JUMP)) or ply:GetWallrun() > 1) then
		self:SendWeaponAnim(ACT_VM_DRAW)
	end

	self:SetWeaponVelocity(Lerp(5 * FrameTime(), self:GetWeaponVelocity(), velocity))

	if not ismoving then
		self:SetWeaponVelocity(velocity)
	end

	if not self.punching and not insidestep then
		if onground and ismoving and curseq ~= 6 and velocity <= 350 then
			self:SendWeaponAnim(ACT_RUN)
		elseif onground and ismoving and curseq ~= 7 and velocity > 350 then
			local cycle = self:GetCycle()

			self:SendWeaponAnim(ACT_RUN_PROTECTED)
			self:SetCycle(cycle)
		elseif (curseq == 6 or curseq == 7) and (velocity < 50 or not ismoving or not onground) and curseq ~= 13 then
			self:SendWeaponAnim(ACT_VM_DRAW)

			if not onground and ply:GetSafetyRollKeyTime() <= CurTime() and ply:GetSafetyRollTime() <= CurTime() then
				ParkourEvent("fall", self:GetOwner())
			end
		end
	end

	curseq = self:GetSequence()

	if (curseq == 6 or curseq == 7) and ismoving then
		local rate = (curseq == 7 and 1.2) or 0.75

		if rate ~= ply:GetViewModel():GetPlaybackRate() then
			ply:GetViewModel():SetPlaybackRate(rate)
		end
	else
		ply:GetViewModel():SetPlaybackRate(1)
	end

	if CLIENT then
		if not self.RunWind1 or not self.RunWind1.Play then
			self.RunWind1 = CreateSound(self, "clotheswind.wav")
			self.RunWind2 = CreateSound(self, "runwind.wav")
		end

		if velocity > 250 and windsound:GetBool() then
			self.RunWind1:Play()
			self.RunWind2:Play()

			self.RunWindVolume = math.Clamp(self.RunWindVolume + (0.5 * FrameTime()), 0, 1)

			self.RunWind1:ChangeVolume(self.RunWindVolume)
			self.RunWind2:ChangeVolume(self.RunWindVolume)
		else
			self.RunWindVolume = math.Clamp(self.RunWindVolume - (2.5 * FrameTime()), 0, 1)

			self.RunWind1:ChangeVolume(self.RunWindVolume)
			self.RunWind2:ChangeVolume(self.RunWindVolume)
		end
	end

	if blinded then
		self.RunWind1:ChangeVolume(0)
		self.RunWind2:ChangeVolume(0)
	end

	if insidestep and viewmodel:GetCycle() >= 1 then
		local mult = (ply:InOverdrive() and 1.25) or 1

		self:SendWeaponAnim(ACT_VM_DRAW)

		ply:SetMEMoveLimit(350 * mult)
		ply:SetMESprintDelay(CurTime())
	elseif insidestep then
		local mult = (ply:InOverdrive() and 1.25) or 1

		ply:SetMEMoveLimit(350 * mult)
		ply:SetMESprintDelay(CurTime())
	end

	self:SetWasOnGround(ply:OnGround())
end

if CLIENT then
	local didfallang = false
	local mouseang = Angle()

	hook.Add("InputMouseApply", "FallView", function(cmd, x, y, ang)
		local ply = LocalPlayer()

		if infall and not BodyAnimArmCopy and ply:Alive() and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
			mouseang.x, mouseang.y = y * 0.01, x * -0.01

			fallang:Add(mouseang)

			cmd:SetViewAngles(fallang)

			didfallang = true

			util.ScreenShake(vector_origin, 5 * (math.abs(ply:GetVelocity().z) / 1000), 5, 0.05, 5000)

			return true
		elseif didfallang then
			fallang.z = 0
			fallang.x = math.Clamp(fallang.x, -89, 89)

			if ply:Alive() then
				cmd:SetViewAngles(fallang)
			end

			didfallang = false
		end
	end)
end

function SWEP:Holster()
	if self.RunWind1 then
		self.RunWind1:Stop()
		self.RunWind2:Stop()
	end

	return true
end

function SWEP:OnRemove()
	if self.RunWind1 then
		self.RunWind1:Stop()
		self.RunWind2:Stop()
	end
end

function SWEP:Reload()
	if GetGlobalBool("GM_DATATHEFT") or GetGlobalBool("GM_DEATHMATCH") or GetGlobalBool("GM_INFECTION") then return end

	if not TUTORIALMODE and CurTime() > self.RespawnDelay and self:GetOwner():GetClimbing() == 0 and not IsValid(self:GetOwner():GetSwingbar()) and not self:GetOwner().BuildMode then
		self:GetOwner():Spawn()

		-- if self:GetOwner():KeyDown(IN_USE) then
		-- 	if game.SinglePlayer() then
		-- 		RunConsoleCommand("toggleblindness")
		-- 	elseif CLIENT then
		-- 		ToggleBlindness(not blinded)
		-- 	end
		-- end

		self.RespawnDelay = CurTime() + 0.5
	end
end

local tr = {}
local tr_result = {}

local allow_overdrive = CreateConVar("Beatrun_AllowOverdriveInMultiplayer", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()

	if ply:GetJumpTurn() and not ply:OnGround() then
		if CLIENT then
			return ArmInterrupt("jumpturnflypiecesign")
		elseif game.SinglePlayer() then
			return ply:SendLua("ArmInterrupt('jumpturnflypiecesign')")
		end
	end

	if ply:KeyDown(IN_USE) and (game.SinglePlayer() or allow_overdrive:GetBool()) then
		local mult = (ply:InOverdrive() and 1) or 1.25
		local fovmult = (mult == 1 and 1) or 1.1

		ply:SetMEMoveLimit(ply:GetMEMoveLimit() * 0.75)
		ply:SetOverdriveMult(mult)
		ply:SetFOV(ply:GetInfoNum("Beatrun_FOV", 100) * fovmult, 0.125)

		return
	end

	if not ply:OnGround() or ply:GetSliding() or ply:GetGrappling() or ply:GetWallrun() ~= 0 or ply:GetJumpTurn() then return end

	local curseq = self:GetSequence()
	local infall = curseq == 19
	if infall then return end

	if CurTime() > self:GetPunchReset() then
		self:SetPunch(1)
	end

	local punch = self:GetPunch()
	self:SendWeaponAnim(self.punchanims[punch])

	if CLIENT and IsFirstTimePredicted() then
		ArmInterrupt(self.punchanimsfb[punch])
	elseif game.SinglePlayer() then
		ply:SendLua("ArmInterrupt('" .. self.punchanimsfb[punch] .. "')")
	end

	ply:ViewPunch(self.punchangles[punch])

	self:SetNextPrimaryFire(CurTime() + self.punchdelays[punch])
	self:SetPunchReset(CurTime() + 0.5)

	tr.start = ply:GetShootPos()
	tr.endpos = ply:GetShootPos() + ply:GetAimVector() * 50
	tr.filter = ply
	tr.mins = Vector(-8, -8, -8)
	tr.maxs = Vector(8, 8, 8)
	tr.output = tr_result

	if ply:IsPlayer() then
		ply:LagCompensation(true)

		self:SetHoldType("fist")

		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
	end

	util.TraceHull(tr)

	self:EmitSound("mirrorsedge/Melee/armswoosh" .. math.random(1, 6) .. ".wav")

	if ply:IsPlayer() then
		ply:LagCompensation(false)
	end

	if tr_result.Hit then
		self:EmitSound("mirrorsedge/Melee/fist" .. math.random(1, 5) .. ".wav")

		local ent = tr_result.Entity

		if SERVER and IsValid(ent) then
			if not ply:IsPlayer() or (Course_Name == "" and not GetGlobalBool("GM_INFECTION")) then
				local d = DamageInfo()
				d:SetDamage((punch ~= 3 and 10) or 20)
				d:SetAttacker(ply)
				d:SetInflictor(self)
				d:SetDamageType(DMG_CLUB)
				d:SetDamagePosition(tr.start)
				d:SetDamageForce(ply:EyeAngles():Forward() * 7000)

				ent:TakeDamageInfo(d)

				if ent:IsNPC() then
					ent:SetActivity(ACT_FLINCH_HEAD)
				end
			end
		end

		if game.SinglePlayer() or (CLIENT and IsFirstTimePredicted()) then
			util.ScreenShake(Vector(0, 0, 0), 2.5, 10, 0.25, 0)
		end
	end

	self:SetPunch(punch + 1)

	if punch + 1 > 3 then
		self:SetPunch(1)
	end
end

function SWEP:SecondaryAttack()
end
