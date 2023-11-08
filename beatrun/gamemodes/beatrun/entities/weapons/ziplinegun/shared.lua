SWEP.PrintName = "Zipline Gun"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Author = "datae"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""

SWEP.BounceWeaponIcon = false
SWEP.DrawWeaponInfoBox = false

SWEP.HoldType = "crossbow"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Category = "Beatrun"

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"

SWEP.ViewModelFOV = 55 -- 75

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:SetupDataTables()
end

function SWEP:Deploy()
	self:SetHoldType(self.HoldType)
	self:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:Initialize()
	self.ziplines = {}
end

function SWEP:Think()
end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
end

function SWEP:Reload()
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()

	if SERVER then
		local zip = CreateZipline(ply:EyePos(), ply:GetEyeTrace().HitPos)

		zip:SetTwoWay(true)

		table.insert(self.ziplines, zip)
	end
end

function SWEP:SecondaryAttack()
	for _, v in pairs(self.ziplines) do
		v:Remove()
	end

	table.Empty(self.ziplines)
end