ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Block"
ENT.Author = ""
ENT.Category = "Beatrun"

ENT.Information = ""
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE

AddCSLuaFile()

ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"
local mat

if CLIENT then
	mat = CreateMaterial("blockmeasure", "VertexLitGeneric", {
		["$basetexture"] = "dev/dev_measuregeneric01b",
		["$basetexturetransform"] = "scale 0.5 0.5"
	})
end

function ENT:SetupDataTables()
end

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBounds(Vector(-75, -75, 0), Vector(75, 75, 100))
	self:AddSolidFlags(FSOLID_CUSTOMRAYTEST)
end

function ENT:OnRemove()
end

function ENT:DrawTranslucent()
end

function ENT:Think()
	if SERVER then
		local mins, maxs = self:GetCollisionBounds()

		mins:Rotate(self:GetAngles())
		maxs:Rotate(self:GetAngles())

		self:SetCollisionBounds(mins, maxs)
		self:NextThink(CurTime() + 1)

		return true
	end
end

local matrix
local vecscale

function ENT:Draw()
	local mins, maxs = self:GetCollisionBounds()
	matrix = matrix or Matrix()
	vecscale = vecscale or Vector()

	vecscale:SetUnpacked(maxs.x * 0.025, maxs.y * 0.025, 0)
	matrix:SetScale(vecscale)

	mat:SetMatrix("$basetexturetransform", matrix)

	self:SetRenderBounds(mins, maxs)

	render.SetColorModulation(1, 1, 1)
	render.SetMaterial(mat)
	render.DrawBox(self:GetPos(), self:GetAngles(), mins, maxs, color_white)
end