ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Swingbar"
ENT.Author = ""
ENT.Category = "Beatrun"
ENT.Information = ""

ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE

AddCSLuaFile()

ENT.Model = "models/hunter/plates/plate2.mdl"
ENT.NoWallrun = true
ENT.NoClimbing = true
local red = Color(255, 0, 0)

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetColor(red)
	self:SetModel(self.Model)

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
	end

	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetCustomCollisionCheck(true)
	self.NoPlayerCollisions = true
end

function ENT:CollisionFunc(ent)
end

function ENT:OnRemove()
end

function ENT:Think()
	return true
end

function ENT:Draw()
	self:DrawModel()
end