ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Ladder"
ENT.Author = ""
ENT.Category = "Beatrun"

ENT.Information = ""
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE

AddCSLuaFile()

ENT.Model = "models/props_c17/metalladder002.mdl"
ENT.ModelEnd = "models/props_c17/metalladder002b.mdl"
ENT.NoClimbing = true

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "LadderHeight")
end

function LadderSpawnDebug()
	local p = Entity(1):GetEyeTrace()

	a = ents.Create("br_ladder")

	a:SetAngles(p.HitNormal:Angle())
	a:SetPos(p.HitPos + p.HitNormal * 10)
	a:Spawn()

	sk = util.QuickTrace(p.HitPos, Vector(0, 0, 100000)).HitPos - p.HitNormal * 10

	a:LadderHeightExact(util.QuickTrace(sk, Vector(0, 0, -100000)).HitPos:Distance(a:GetPos()) - 62)
end

function ENT:LadderHeight(mul)
	local height = 125 * mul
	self:SetLadderHeight(height - 75)

	local mins, maxs = Vector(5, -14, 0), Vector(14, 14, height)

	self:SetCollisionBounds(mins, maxs)
	self:PhysicsInitBox(mins, maxs)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
	self:GetPhysicsObject():EnableMotion(false)
end

function ENT:LadderHeightExact(height)
	self:SetLadderHeight(height)
	height = height + 75

	local mins, maxs = Vector(5, -14, 0), Vector(14, 14, height)

	self:SetCollisionBounds(mins, maxs)
	self:PhysicsInitBox(mins, maxs)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
	self:GetPhysicsObject():EnableMotion(false)
end

function ENT:Initialize()
	local height = 125

	if SERVER then
		self:SetLadderHeight(height - 75)
	end

	self:SetModel(self.Model)

	local ang = self:GetAngles()
	local mins, maxs = Vector(5, -14, 0), Vector(14, 14, height)

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
		self.CLModel:SetAngles(self:GetAngles())
		self.CLModelEnd = ClientsideModel(self.ModelEnd)
		self.CLModelEnd:SetPos(self:GetPos())
		self.CLModelEnd:SetAngles(self:GetAngles())

		local scale = Vector(1, 0.85, 1)
		local mat = Matrix()

		mat:Scale(scale)

		self.CLModel:EnableMatrix("RenderMultiply", mat)
		self.CLModelEnd:EnableMatrix("RenderMultiply", mat)
		self.CLModel:SetMaterial("medge/redbrickvertex")
		self.CLModelEnd:SetMaterial("medge/redbrickvertex")
	end

	self:SetPos(self:GetPos() - self:GetAngles():Forward() * 10)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:OnRemove()
	if IsValid(self.CLModel) then
		self.CLModel:Remove()
	end

	if IsValid(self.CLModelEnd) then
		self.CLModelEnd:Remove()
	end
end

function ENT:DrawTranslucent()
end

function ENT:Think()
	if SERVER then
		local ang = self:GetAngles()

		if ang[1] ~= 0 or ang[3] ~= 0 then
			ang.x = 0
			ang.z = 0

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
		end

		if not IsValid(self.CLModelEnd) then
			self.CLModelEnd = ClientsideModel(self.ModelEnd)
			self.CLModelEnd:SetPos(self:GetPos())
			self.CLModelEnd:SetAngles(self:GetAngles())

			local scale = Vector(1, 0.85, 1)
			local mat = Matrix()

			mat:Scale(scale)

			self.CLModel:EnableMatrix("RenderMultiply", mat)
			self.CLModelEnd:EnableMatrix("RenderMultiply", mat)
			self.CLModel:SetMaterial("medge/redbrickvertex")
			self.CLModelEnd:SetMaterial("medge/redbrickvertex")
		end

		if IsValid(physobj) then
			physobj:SetPos(self:GetPos())
			physobj:SetAngles(self:GetAngles())

			self.CLModel:SetPos(self:GetPos())
			self.CLModel:SetAngles(self:GetAngles())
			self.CLModelEnd:SetPos(self:GetPos())
			self.CLModelEnd:SetAngles(self:GetAngles())

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

function ENT:Draw()
	local pos = self:GetPos()
	-- local ang = self:GetAngles()
	local oldz = pos.z
	local mins, maxs = self:GetCollisionBounds()
	maxs.z = self:GetLadderHeight() + 75

	local num = maxs.z / 125
	local numc = math.floor(num)
	local extra = num - numc

	if not IsValid(self.CLModel) then
		self:SetRenderBounds(mins, maxs)
		self.CLModel = ClientsideModel(self.Model)
		self.CLModel:SetPos(self:GetPos())
		self.CLModel:SetAngles(self:GetAngles())
	end

	if not IsValid(self.CLModelEnd) then
		self.CLModelEnd = ClientsideModel(self.ModelEnd)
		self.CLModelEnd:SetPos(self:GetPos())
		self.CLModelEnd:SetAngles(self:GetAngles())

		local scale = Vector(1, 0.85, 1)
		local mat = Matrix()

		mat:Scale(scale)

		self.CLModel:EnableMatrix("RenderMultiply", mat)
		self.CLModelEnd:EnableMatrix("RenderMultiply", mat)
		self.CLModel:SetMaterial("medge/redbrickvertex")
		self.CLModelEnd:SetMaterial("medge/redbrickvertex")
	end

	self:SetRenderBounds(mins, maxs)

	for i = 0, numc do
		if num == 1 then
			self.CLModel:DrawModel()
			break
		end

		if i == numc then
			if i > 0 then
				pos.z = pos.z + (125 * extra)
			end

			self.CLModel:SetPos(pos)
			self.CLModel:SetupBones()
			self.CLModel:DrawModel()
		else
			pos.z = oldz + (125 * i)
			self.CLModel:SetPos(pos)
			self.CLModel:SetupBones()
			self.CLModel:DrawModel()
		end
	end

	pos.z = pos.z + 112

	self.CLModelEnd:SetPos(pos)
	self.CLModelEnd:SetupBones()
	self.CLModelEnd:DrawModel()
end