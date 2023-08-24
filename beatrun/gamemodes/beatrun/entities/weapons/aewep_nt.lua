SWEP.ViewModel = "models/weapons/v_jinrai_srm_s.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.Primary.ClipSize = 45
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"

SWEP.UseHands = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Spawnable = false
SWEP.BobScale = 0
SWEP.SwayScale = 0
SWEP.ViewModelFOV = 70

SWEP.PrintName = "idk"
SWEP.Author = "datae"
SWEP.Instructions = ""
SWEP.Category = "Beatrun"

SWEP.BulletData = {}
SWEP.Damage = 15
SWEP.Force = 1
SWEP.Distance = 56756

SWEP.ReloadTime = 0

SWEP.VMPos = Vector()
SWEP.VMAng = Angle()
SWEP.VMPosOffset = Vector()
SWEP.VMAngOffset = Angle()

SWEP.VMPosOffset_Lerp = Vector()
SWEP.VMAngOffset_Lerp = Angle()

SWEP.VMLookLerp = Angle()

SWEP.StepBob = 0
SWEP.StepBobLerp = 0
SWEP.StepRandomX = 1
SWEP.StepRandomY = 1
SWEP.LastEyeAng = Angle()
SWEP.SmoothEyeAng = Angle()

SWEP.LastVelocity = Vector()
SWEP.Velocity_Lerp = Vector()
SWEP.VelocityLastDiff = 0

SWEP.Breath_Intensity = 1
SWEP.Breath_Rate = 1

SWEP.OffsetPos = Vector(10, -10, 0) --NT
-- SWEP.OffsetPos = Vector(0,0,-2)
SWEP.OffsetAng = Angle()

local coolswayCT = 0
local oldCT = 0

local function LerpC(t, a, b, powa)
	return a + (b - a) * math.pow(t, powa)
end

function SWEP:Move_Process(EyePos, EyeAng, velocity)
	local VMPos, VMAng = self.VMPos, self.VMAng
	local VMPosOffset, VMAngOffset = self.VMPosOffset, self.VMAngOffset
	local VMPosOffset_Lerp, VMAngOffset_Lerp = self.VMPosOffset_Lerp, self.VMAngOffset_Lerp
	local FT = FrameTime()
	local sightedmult = 1

	VMPos:Set(EyePos)
	VMAng:Set(EyeAng)

	VMPosOffset.x = self:GetOwner():GetVelocity().z * 0.0015 * sightedmult
	VMPosOffset.y = math.Clamp(velocity.y * -0.004, -1, 1) * sightedmult
	VMPosOffset_Lerp.x = Lerp(8 * FT, VMPosOffset_Lerp.x, VMPosOffset.x)
	VMPosOffset_Lerp.y = Lerp(8 * FT, VMPosOffset_Lerp.y, VMPosOffset.y)

	VMAngOffset.x = math.Clamp(VMPosOffset.x * 8, -4, 4)
	VMAngOffset.y = VMPosOffset.y * -1
	VMAngOffset.z = VMPosOffset.y * 0.5 + (VMPosOffset.x * -5)

	VMAngOffset_Lerp.x = LerpC(10 * FT, VMAngOffset_Lerp.x, VMAngOffset.x, 0.75)
	VMAngOffset_Lerp.y = LerpC(5 * FT, VMAngOffset_Lerp.y, VMAngOffset.y, 0.6)
	VMAngOffset_Lerp.z = Lerp(25 * FT, VMAngOffset_Lerp.z, VMAngOffset.z)

	VMPos:Add(VMAng:Up() * VMPosOffset_Lerp.x)
	VMPos:Add(VMAng:Right() * VMPosOffset_Lerp.y)
	VMAng:Add(VMAngOffset_Lerp)
end

local stepend = math.pi * 4

function SWEP:Step_Process(EyePos, EyeAng, velocity)
	local CT = CurTime()

	if CT > coolswayCT then
		coolswayCT = CT
	else
		return
	end

	local VMPos, VMAng = self.VMPos, self.VMAng
	local VMPosOffset, VMAngOffset = self.VMPosOffset, self.VMAngOffset
	local VMPosOffset_Lerp, _ = self.VMPosOffset_Lerp, self.VMAngOffset_Lerp

	velocity = math.min(velocity:Length(), 500)

	local delta = math.abs(self.StepBob * 2 / stepend - 1)
	local FT = FrameTime()
	local FTMult = 300 * FT
	local sightedmult = 1
	-- local sprintmult = 1
	local onground = self:GetOwner():OnGround()

	self.StepBob = self.StepBob + (velocity * 0.00015 + (math.pow(delta, 0.01) * 0.03)) * FTMult

	if self.StepBob >= stepend then
		self.StepBob = 0
		self.StepRandomX = math.Rand(1, 1.5)
		self.StepRandomY = math.Rand(1, 1.5)
	end

	if velocity == 0 then
		self.StepBob = 0
	end

	if onground then
		VMPosOffset.x = (math.sin(self.StepBob) * velocity * 0.000375 * sightedmult) * self.StepRandomX
		VMPosOffset.y = (math.sin(self.StepBob * 0.5) * velocity * 0.0005 * sightedmult) * self.StepRandomY
		VMPosOffset.z = math.sin(self.StepBob * 0.75) * velocity * 0.002 * sightedmult
	end

	VMPosOffset_Lerp.x = Lerp(16 * FT, VMPosOffset_Lerp.x, VMPosOffset.x)
	VMPosOffset_Lerp.y = Lerp(4 * FT, VMPosOffset_Lerp.y, VMPosOffset.y)
	VMPosOffset_Lerp.z = Lerp(2 * FT, VMPosOffset_Lerp.z, VMPosOffset.z)

	VMAngOffset.x = VMPosOffset_Lerp.x * 2
	VMAngOffset.y = VMPosOffset_Lerp.y * -7.5
	VMAngOffset.z = VMPosOffset_Lerp.y * 5

	VMPos:Add(VMAng:Up() * VMPosOffset_Lerp.x)
	VMPos:Add(VMAng:Right() * VMPosOffset_Lerp.y)
	VMPos:Add(VMAng:Forward() * VMPosOffset_Lerp.z)
	VMAng:Add(VMAngOffset)
end

function SWEP:Breath_Health()
	local owner = self:GetOwner()

	if not IsValid(owner) then return end

	local health = owner:Health()
	local maxhealth = owner:GetMaxHealth()

	self.Breath_Intensity = math.Clamp(maxhealth / health, 0, 2)
	self.Breath_Rate = math.Clamp((maxhealth * 0.5) / health, 1, 1.5)
end

function SWEP:Breath_StateMult()
	local owner = self:GetOwner()

	if not IsValid(owner) then return end

	local sightedmult = 1

	self.Breath_Intensity = self.Breath_Intensity * sightedmult
end

function SWEP:Breath_Process(EyePos, EyeAng)
	local VMPos, VMAng = self.VMPos, self.VMAng
	local VMPosOffset, VMAngOffset = self.VMPosOffset, self.VMAngOffset

	self:Breath_Health()
	self:Breath_StateMult()

	VMPosOffset.x = (math.sin(CurTime() * 2 * self.Breath_Rate) * 0.1) * self.Breath_Intensity
	VMPosOffset.y = (math.sin(CurTime() * 2.5 * self.Breath_Rate) * 0.025) * self.Breath_Intensity
	VMAngOffset.x = VMPosOffset.x * 1.5
	VMAngOffset.y = VMPosOffset.y * 2

	VMPos:Add(VMAng:Up() * VMPosOffset.x)
	VMPos:Add(VMAng:Right() * VMPosOffset.y)
	VMAng:Add(VMAngOffset)
end

function SWEP:Look_Process(EyePos, EyeAng)
	local VMPos, VMAng = self.VMPos, self.VMAng
	local VMPosOffset, VMAngOffset = self.VMPosOffset, self.VMAngOffset
	local FT = FrameTime()
	local sightedmult = 1

	self.SmoothEyeAng = LerpAngle(FT * 5, self.SmoothEyeAng, EyeAng - self.LastEyeAng)

	VMPosOffset.x = -self.SmoothEyeAng.x * -1 * sightedmult
	VMPosOffset.y = self.SmoothEyeAng.y * 0.5 * sightedmult
	VMAngOffset.x = VMPosOffset.x * 2.5
	VMAngOffset.y = VMPosOffset.y * 1.25
	VMAngOffset.z = VMPosOffset.y * 2

	self.VMLookLerp.y = Lerp(FT * 10, self.VMLookLerp.y, VMAngOffset.y * 1.5 + self.SmoothEyeAng.y)

	VMAng.y = VMAng.y - self.VMLookLerp.y

	VMPos:Add(VMAng:Up() * VMPosOffset.x)
	VMPos:Add(VMAng:Right() * VMPosOffset.y)
	VMAng:Add(VMAngOffset)
end

function SWEP:GetVMPosition(EyePos, EyeAng)
	if CurTime() == oldCT then return self.VMPos, self.VMAng end

	local velocity = self:GetOwner():GetVelocity()

	velocity = WorldToLocal(velocity, angle_zero, vector_origin, EyeAng)

	self:Move_Process(EyePos, EyeAng, velocity)
	self:Step_Process(EyePos, EyeAng, velocity)
	self:Breath_Process(EyePos, EyeAng)
	self:Look_Process(EyePos, EyeAng)
	self.LastEyeAng = EyeAng
	self.LastEyePos = EyePos
	self.LastVelocity = velocity

	local offsetpos, _ = LocalToWorld(self.OffsetPos, self.OffsetAng, self.VMPos, self.VMAng)

	self.VMPos:Set(offsetpos)
	-- self.VMAng:Add(offsetang)
	oldCT = CurTime()

	return self.VMPos, self.VMAng
end

function SWEP:CalcViewModelView(vm, oldeyepos, oldeyeang, eyepos, eyeang)
	return self:GetVMPosition(eyepos, eyeang)
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:GenerateBullet()
	local tbl = self.BulletData
	tbl.Attacker = self:GetOwner()
	tbl.Damage = self.Damage
	tbl.Force = self.Force
	tbl.Distance = self.Distance
	tbl.Num = 1
	tbl.Spread = Vector(0.05, 0.05, 0)
	tbl.Src = self:GetOwner():GetShootPos()
	tbl.Dir = self:GetOwner():GetEyeTrace().Normal

	return tbl
end

function SWEP:MuzzleFlash()
	local vPoint = self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Forward() * 10
	local ed = EffectData()

	ed:SetOrigin(vPoint)
	ed:SetScale(1)
	ed:SetEntity(self)

	util.Effect("arccw_shelleffect", ed)
end

function SWEP:DryFire()
	self:EmitSound("weapons/pistol/pistol_empty.wav")
end

function SWEP:Reload()
	if self:Clip1() >= self:GetMaxClip1() or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	if self.ReloadTime and CurTime() <= self.ReloadTime then return end

	self:DefaultReload(ACT_VM_RELOAD)

	local AnimationTime = self:GetOwner():GetViewModel():SequenceDuration()

	self.ReloadTime = CurTime() + AnimationTime
	self:SetNextPrimaryFire(CurTime() + AnimationTime)
	self:SetNextSecondaryFire(CurTime() + AnimationTime)
	self:EmitSound("weapons/smg1/smg1_reload.wav")
end

function SWEP:PrimaryAttack()
	if self:Clip1() < 1 then
		self:DryFire()
		self:SetNextPrimaryFire(CurTime() + 0.5)

		return
	end

	self:SetClip1(self:Clip1() - 1)
	self:GetOwner():MuzzleFlash()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SetNextPrimaryFire(CurTime() + 0.065)
	self:EmitSound("weapons/smg1/smg1_fire1.wav")
	self:FireBullets(self:GenerateBullet())
	self:GetOwner():ViewPunch(Angle(-0.1, 0, 0))

	if IsFirstTimePredicted() then
		self:MuzzleFlash()
	end

	return true
end

function SWEP:SecondaryAttack()
	return true
end