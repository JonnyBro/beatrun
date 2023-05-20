ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "Swingrope"
ENT.Author 				= ""
ENT.Information 		= ""

ENT.Spawnable 			= true

ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.Category			= "Beatrun"

AddCSLuaFile()

ENT.Model = "models/parkoursource/pipe_standard.mdl"


ENT.NoClimbing = true
ENT.NoWallrun = true

function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "StartPos" )
	self:NetworkVar( "Vector", 1, "EndPos" )
end

local spawntr = {}
local spawntrout = {}
function ENT:Initialize()
	self:SetPos(self:GetStartPos())
    self:SetModel(self.Model)
	local ang = (self:GetEndPos()-self:GetStartPos()):Angle()
	local mins, maxs = Vector(-8,-8,0), Vector(self:GetStartPos():Distance(self:GetEndPos()), 0, 8)
	self:SetAngles(ang)
	self:PhysicsInitBox(mins,maxs)
    self:SetSolid(SOLID_VPHYSICS)
    self.NoPlayerCollisions=true
	self:EnableCustomCollisions(true)
	self:GetPhysicsObject():EnableMotion(false)
	
	if CLIENT then
		self:SetRenderBounds(mins,maxs)
	end
end

function ENT:OnRemove()

end


function ENT:Think()
	if self:GetPos() != self:GetStartPos() then
		self:SetStartPos(self:GetPos())
		local ang = (self:GetEndPos()-self:GetStartPos()):Angle()
		local mins, maxs = Vector(-8,-8,0), Vector(self:GetStartPos():Distance(self:GetEndPos()), 0, 8)
		self:SetAngles(ang)
		if CLIENT then
			self:SetRenderAngles(ang)
		end
		self:PhysicsInitBox(mins,maxs)
		self:SetSolid(SOLID_VPHYSICS)
		self.NoPlayerCollisions=true
		self:EnableCustomCollisions(true)
		self:GetPhysicsObject():EnableMotion(false)
	end
	self:NextThink(CurTime()+5)
	return true
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

local ropemat = Material("cable/cable2")
local color_red = Color(255,0,0)
function ENT:Draw()
	if LocalPlayer():GetGrappling() then
		local grapplepos = LocalPlayer():GetGrapplePos()
		if grapplepos == self:GetStartPos() or grapplepos == self:GetEndPos() then
			return
		end
	end
	local mins, maxs = self:GetCollisionBounds()
	self:SetRenderBounds(mins,maxs)
	render.SetMaterial(ropemat)
	render.DrawBeam(self:GetPos(), self:GetEndPos(), 5, 0, 1, color_white)
end

function ENT:DrawLOC()
	local mins, maxs = self:GetCollisionBounds()
	self:SetRenderBounds(mins,maxs)
	render.SetMaterial(ropemat)
	render.DrawBeam(self:GetPos(), self:GetEndPos(), 5, 0, 1, color_red)
end