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

local pickupmin, pickupmax = Vector(-20, -20, -15), Vector(20, 20, 30)

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetColor(Color(0, 255, 0))

	if CLIENT then return end

	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		local randvec = VectorRand() * 200
		randvec.z = math.abs(randvec.z)

		phys:SetVelocity(randvec)
	end
end

function ENT:Think()
	if CLIENT then return end

	local pos = self:GetPos()
	local zmin, zmax = pos + pickupmin, pos + pickupmax

	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end

		local pmin, pmax = ply:WorldSpaceAABB()

		if util.IsBoxIntersectingBox(pmin, pmax, zmin, zmax) then
			ply:SetNW2Int("DataCubes", ply:GetNW2Int("DataCubes", 0) + 1)

			self:EmitSound("a_tt_stars.ogg", 75, 100 + math.random(-10, 5))
			self:Remove()

			return
		end
	end

	self:NextThink(CurTime() + 0.1)

	return true
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
