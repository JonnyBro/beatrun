ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Cube"
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
		["$basetexture"] = "dev/reflectivity_50b",
		["$color2"] = Vector(0, 1, 0)
	})
end

-- local reflec = Material("dev/reflectivity_50b")

function ENT:SetupDataTables()
end

function ENT:Initialize()
	-- if ( CLIENT ) then return end -- We only want to run this code serverside
	if CLIENT then
		if tcmat and not tcmat["blockmeasure"] then
			tcmat["blockmeasure"] = mat
			tcmatshaders["blockmeasure"] = 1
		end
	end

	self:PhysicsInitBox(Vector(0, 0, 0), Vector(100, 100, 1000))
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
	self:GetPhysicsObject():EnableMotion(false)
end

function ENT:OnRemove()
end

function ENT:DrawTranslucent()
end

function ENT:Think()
	if SERVER then
		self:NextThink(CurTime() + 1)

		return true
	end

	if CLIENT then
		local physobj = self:GetPhysicsObject()

		if IsValid(physobj) then
			physobj:SetPos(self:GetPos())
			physobj:SetAngles(self:GetAngles())
		end
	end
end

-- local matrix
-- local vecscale

function ENT:Draw()
	local mins, maxs = self:GetCollisionBounds()

	self:SetRenderBounds(mins, maxs)

	render.SetMaterial(mat)
	render.DrawBox(self:GetPos(), self:GetAngles(), mins, maxs, color_white)
end