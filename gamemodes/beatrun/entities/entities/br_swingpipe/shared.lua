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

	self:SetMaterial("medge/redbrickvertex")
	self.NoPlayerCollisions = true
end

function ENT:OnRemove()
end

function ENT:Think()
end

function ENT:Draw()
	self:DrawModel()
end