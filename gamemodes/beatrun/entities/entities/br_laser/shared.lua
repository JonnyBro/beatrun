ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Laser Hazard"
ENT.Author = ""
ENT.Category = "Beatrun"

ENT.Information = ""
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

AddCSLuaFile()

ENT.Model = "models/maxofs2d/button_02.mdl"
ENT.NoClimbing = true
ENT.LaserLength = 100000

if CLIENT then
	language.Add("br_laser", "Laser Hazard")
end

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 1, "EndPos")
end

function ENT:Initialize()
	local entstable = player.GetAll()
	local ang = self:GetAngles()

	entstable[#entstable + 1] = self

	self:SetEndPos(util.QuickTrace(self:GetPos(), ang:Up() * self.LaserLength, entstable).HitPos)
	self:SetModel(self.Model)

	local mins, maxs = Vector(0, -1, -1), Vector(0, 1, self:GetPos():Distance(self:GetEndPos()))

	if SERVER then
		self:PhysicsInitBox(mins, maxs)
		self:SetSolid(SOLID_VPHYSICS)
		self:GetPhysicsObject():EnableMotion(false)
	end

	self.NoPlayerCollisions = true

	if CLIENT then
		self:SetRenderBounds(mins, maxs)
		self:SetCollisionBounds(mins, maxs)
	end
end

function ENT:OnRemove()
end

function ENT:Think()
	if CLIENT then return end

	local ang = self:GetAngles()

	local tr = util.QuickTrace(self:GetPos(), ang:Up() * self.LaserLength, self)

	self:SetEndPos(tr.HitPos)

	local hitEnt = tr.Entity

	if IsValid(hitEnt) and hitEnt:IsPlayer() then
		if hitEnt:Health() <= 0 or hitEnt:HasGodMode() or cvars.Bool("sbox_godmode", false) then return end

		local dmginfo = DamageInfo()
			dmginfo:SetAttacker(self)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamage(math.huge)
			dmginfo:SetDamageType(DMG_DISSOLVE)
		hitEnt:TakeDamageInfo(dmginfo)

		hitEnt:EmitSound("bigspark" .. math.random(1, 2) .. ".wav")
	end

	self:NextThink(CurTime())

	return true
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

local ropemat = Material("cable/physbeam")
local color_red = Color(255, 0, 0)

function ENT:Draw()
	local mins, maxs = self:GetCollisionBounds()

	self:SetRenderBounds(mins, maxs)
	self:DrawModel()
end

function ENT:DrawTranslucent()
	render.SetMaterial(ropemat)
	render.DrawBeam(self:GetPos(), self:GetEndPos(), 5, 0, 1, color_white)
end

function ENT:DrawLOC()
	local mins, maxs = self:GetCollisionBounds()

	self:SetRenderBounds(mins, maxs)

	render.SetMaterial(ropemat)
	render.DrawBeam(self:GetPos(), self:GetEndPos(), 5, 0, 1, color_red)
end