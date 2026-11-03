ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Balancing beam"
ENT.Author = ""
ENT.Category = "Beatrun"

ENT.Information = ""
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE

AddCSLuaFile()

ENT.Model = "models/parkoursource/pipe_standard.mdl"
ENT.NoClimbing = true
ENT.Balance = true

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "BalanceLength")
end

function ENT:BalanceLengthExact(length)
	self:SetBalanceLength(length)

	local mins, maxs = Vector(-15, -6, -0), Vector(6, 6, length)

	self:SetCollisionBounds(mins, maxs)
	self:PhysicsInitBox(mins, maxs)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
	self:GetPhysicsObject():EnableMotion(false)
end

function ENT:Initialize()
	local height = 250

	if SERVER then
		self:SetBalanceLength(height)
	end

	self:SetModel(self.Model)

	local ang = self:GetAngles()
	local mins, maxs = Vector(-15, -6, -0), Vector(6, 6, height)

	self:SetCollisionBounds(mins, maxs)
	self:SetAngles(ang)
	self:PhysicsInitBox(mins, maxs)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
	self:GetPhysicsObject():EnableMotion(false)

	if CLIENT then
		self:SetRenderBounds(mins, maxs)
		self.CLModel = ClientsideModel(self.Model)
		self.CLModel:SetPos(self:GetPos())
		self.CLModel:SetAngles(ang)
		self.CLModel:SetMaterial("medge/redbrickvertex")
	end

	self:SetPos(self:GetPos() - ang:Forward() * 10)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:OnRemove()
	if IsValid(self.CLModel) then
		self.CLModel:Remove()
	end
end

function ENT:DrawTranslucent()
end

function ENT:Think()
	if SERVER then
		local ang = self:GetAngles()

		if ang.x ~= 90 then
			ang.x = 90
			self:SetAngles(ang)
		end

		self:NextThink(CurTime() + 1)

		return true
	end

	if CLIENT then
		local physobj = self:GetPhysicsObject()

		if not IsValid(self.CLModel) then
			self.CLModel = ClientsideModel(self.Model)
			self.CLModel:SetPos(self:GetPos())
			self.CLModel:SetAngles(self:GetAngles())
			self.CLModel:SetMaterial("medge/redbrickvertex")
		end

		if IsValid(physobj) then
			physobj:SetPos(self:GetPos())
			physobj:SetAngles(self:GetAngles())

			self.CLModel:SetPos(self:GetPos())
			self.CLModel:SetAngles(self:GetAngles())

			local _, maxs = physobj:GetAABB()
			local cmins, cmaxs = self:GetCollisionBounds()

			if maxs.z ~= cmaxs.z then
				self:PhysicsInitBox(cmins, cmaxs)
				self:SetSolid(SOLID_VPHYSICS)
				self:SetCollisionGroup(SOLID_VPHYSICS)
				self:EnableCustomCollisions(true)
				self:GetPhysicsObject():EnableMotion(false)
			end
		else
			local cmins, cmaxs = self:GetCollisionBounds()
			self:PhysicsInitBox(cmins, cmaxs)
			self:SetSolid(SOLID_VPHYSICS)
			self:SetCollisionGroup(SOLID_VPHYSICS)
			self:EnableCustomCollisions(true)
			self:GetPhysicsObject():EnableMotion(false)
		end
	end
end

local piecelength = 250
local piecescale = Vector(1, 1, 1)

function ENT:Draw()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local mins, maxs = self:GetCollisionBounds()
	local length = self:GetBalanceLength()
	maxs.z = length

	if not IsValid(self.CLModel) then
		self.CLModel = ClientsideModel(self.Model)
		self.CLModel:SetMaterial("medge/redbrickvertex")
	end

	self:SetRenderBounds(mins, maxs)

	local model = self.CLModel
	local pieces = math.max(math.ceil(length / piecelength), 1)

	model:SetAngles(ang)

	piecescale.z = math.min(length / piecelength, 1)

	self.PieceMatrix = self.PieceMatrix or Matrix()
	self.PieceMatrix:SetScale(piecescale)
	model:EnableMatrix("RenderMultiply", self.PieceMatrix)

	for i = 0, pieces - 1 do
		local offset = math.min(piecelength * i, math.max(length - piecelength, 0))

		model:SetPos(pos + ang:Up() * offset)
		model:SetupBones()
		model:DrawModel()
	end
end
