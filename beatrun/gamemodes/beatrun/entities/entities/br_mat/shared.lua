ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "Mat"
ENT.Author 				= ""
ENT.Information 		= ""

ENT.Spawnable 			= true

ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.Category			= "Beatrun"

AddCSLuaFile()

ENT.Model = "models/mechanics/robotics/stand.mdl"

function ENT:SetupDataTables()

end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:GetPhysicsObject():EnableMotion(false)
end

function ENT:Draw()
	self:DrawModel()
end