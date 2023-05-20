ENT.Type 				= "anim"
ENT.Base 				= "base_entity"
ENT.PrintName 			= "Intel Marker"
ENT.Author 				= ""
ENT.Information 		= ""

ENT.Spawnable 			= true

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Category			= "Beatrun"

AddCSLuaFile()

ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"

function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "Score" )

end

local minb, maxb = Vector(-40, -40, 0), Vector(40, 40, 64)
function ENT:Initialize()
    self:SetModel(self.Model)
	self:DrawShadow(false)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetCollisionBounds(minb, maxb)
	if CLIENT then
		self:SetRenderBounds(minb, maxb)
		self.offset = 0
	else
		self:SetTrigger(true)
	end
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() then
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Use(activator, caller, usetype)

end

function ENT:OnRemove()

end

local radius = 35
local red = Color(100, 255, 0, 125)
local circlepos = Vector()
local circleup = Vector(0,0,40)
local msin = math.sin
local mabs = math.abs
function ENT:DrawTranslucent()
	self:SetRenderBounds(minb, maxb)
	render.SetColorMaterial()
	for i=0, 16 do
		local angle = i * math.pi*2 / 16 + self.offset
		circlepos:SetUnpacked(math.cos(angle)*radius, math.sin(angle)*radius, 0)
		local newpos = self:GetPos()+circlepos
		render.DrawBeam(newpos, newpos+circleup, 4, 0, 1, red, true)
	end
	local bmin, bmax = self:GetRenderBounds()
	self.offset = self.offset + (0.00075)
	if self.offset >= 180 then
		self.offset = 0
	end
	-- render.DrawWireframeBox(self:GetPos(), angle_zero, bmin, bmax)
end


function ENT:Draw()

end