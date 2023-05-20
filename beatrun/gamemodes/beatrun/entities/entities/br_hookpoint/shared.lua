ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "Hook Point"
ENT.Author 				= ""
ENT.Information 		= ""

ENT.Spawnable 			= true

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Category			= "Beatrun"

AddCSLuaFile()

ENT.Model = "models/Roller.mdl"
ENT.HookPoint = true

local color_green = Color(0,255,0)
function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local mins, maxs = self:GetCollisionBounds()

	self:PhysicsInitBox(mins, maxs)

	-- Set up solidity and movetype
	self:SetMoveType( MOVETYPE_NONE )
	self:GetPhysicsObject():EnableMotion(false)
end


function ENT:Think()
	if SERVER then
		self:NextThink(CurTime()+1)
		return true
	end
	
	if ( CLIENT ) then
		local physobj = self:GetPhysicsObject()

		if ( IsValid( physobj ) ) then
			physobj:SetPos( self:GetPos() )
			physobj:SetAngles( self:GetAngles() )
		end
	end
end

function ENT:Use(activator, caller, usetype)

end

function ENT:OnRemove()

end

function ENT:DrawTranslucent()
	self:DrawModel()
end


function ENT:Draw()
end