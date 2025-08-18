ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Swingpipe"
ENT.Author = ""
ENT.Category = "Beatrun"
ENT.Information = ""

ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE

AddCSLuaFile()

ENT.Model = "models/parkoursource/pipe_standard.mdl"

function ENT:SetupDataTables()
end

-- local spawntr = {}
-- local spawntrout = {}

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_NONE)

	local mins, maxs = Vector(-15, -15, 0), Vector(15, 15, 180)

	self:SetCollisionBounds(mins, maxs)
	self:PhysicsInitBox(mins, maxs)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:EnableCustomCollisions(true)

	if SERVER then
		self:GetPhysicsObject():EnableMotion(false)
	else
		return
	end

	-- self:SetRenderOrigin(self:GetPos() - self:GetAngles():Forward() * 15)
	self:SetMaterial("medge/redbrickvertex")
	self.NoPlayerCollisions = true
	-- local mins, maxs = self:GetCollisionBounds() * 4

	-- spawntr.start = self:GetPos()
	-- spawntr.endpos = spawntr.start
	-- spawntr.filter = self
	-- spawntr.output = spawntrout
	-- spawntr.mins, spawntr.maxs = mins, maxs

	-- util.TraceHull(spawntr)

	-- if spawntrout.Hit then
	-- 	local ang = spawntrout.HitNormal:Angle()
	-- 	ang.x = 0
	-- 	self:SetAngles(ang)
	-- end
end

function ENT:OnRemove()
end

function ENT:Think()
end

-- local matrix
-- local vecscale

function ENT:Draw()
	self:DrawModel()
	-- local mins, maxs = self:GetCollisionBounds()
	-- render.DrawWireframeBox(self:GetPos(), self:GetAngles(), mins, maxs)
end