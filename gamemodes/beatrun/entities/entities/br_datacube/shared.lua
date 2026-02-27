ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Data Cube"
ENT.Author = ""

ENT.Category = "Beatrun"
ENT.Information = ""
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

AddCSLuaFile()

ENT.Model = "models/hunter/blocks/cube05x05x05.mdl"
ENT.DataCube = true

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetCollisionBounds(Vector(-20, -20, -15), Vector(20, 20, 30))

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)

		local randvec = VectorRand() * 200
		randvec.z = math.abs(randvec.z)

		self:SetTrigger(true)
		self:GetPhysicsObject():SetVelocity(randvec)
	end

	self:SetColor(Color(0, 255, 0))
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() then
		ent:SetNW2Int("DataCubes", ent:GetNW2Int("DataCubes", 0) + 1)

		self:EmitSound("A_TT_Stars.wav", 75, 100 + math.random(-10, 5))
		self:Remove()
	end
end

function ENT:Touch(ent)
	if ent:IsPlayer() then return end
end

function ENT:Think()
	return true
end

function ENT:Use(activator, caller, usetype)
end

function ENT:OnRemove()
end

local spinang = Angle(0, 1, 0)

function ENT:DrawTranslucent()
	local curang = self:GetRenderAngles() or Angle()
	curang:Add(spinang)

	self:SetRenderAngles(curang)
	self:DrawModel()
end

function ENT:Draw()
end