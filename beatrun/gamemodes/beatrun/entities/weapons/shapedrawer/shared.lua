SWEP.PrintName = "ShapeDrawer"
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

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"

SWEP.ViewModelFOV = 75 --65 75

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:SetupDataTables()
end

function SWEP:Deploy()
	self:CallOnClient("Deploy")
	self:SetHoldType(self.HoldType)
	self:SendWeaponAnim(ACT_VM_DRAW)

	self.points = {}
	self.center = Vector()
end

function SWEP:Initialize()
end

function SWEP:Think()
end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
end

function SWEP:Reload()
	self:CallOnClient("Reload")

	table.Empty(self.points)
end

function SWEP:PrimaryAttack()
	self:CallOnClient("PrimaryAttack")
	local ply = self.Owner

	if not self.points[#self.points] or (ply:EyePos() + ply:EyeAngles():Forward() * 50):Distance(self.points[#self.points]) > 5 then
		table.insert(self.points, ply:EyePos() + ply:EyeAngles():Forward() * 50)
	end
end


function SWEP:SecondaryAttack()
	self:CallOnClient("SecondaryAttack")

	local ply = self.Owner

	self.center:Set(ply:GetEyeTrace().HitPos)
end

hook.Add("PostDrawTranslucentRenderables", "ShapeGun", function()
	local ply = Entity(1)
	local wep = ply:GetActiveWeapon() or nil

	if IsValid(wep) and wep:GetClass() == "shapedrawer" then
		for k, v in ipairs(wep.points) do
			render.DrawWireframeBox(v, angle_zero, Vector(-1, -1, -1), Vector(1, 1, 1))
		end

		render.DrawWireframeBox(wep.center, angle_zero, Vector(-2, -2, -2), Vector(2, 2, 2))
	end
end)