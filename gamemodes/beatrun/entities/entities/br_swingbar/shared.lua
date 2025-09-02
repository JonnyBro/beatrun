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
-- local spawntr = {}
-- local spawntrout = {}

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetColor(red)
	self:SetModel(self.Model)
	-- self:SetMoveType(MOVETYPE_NONE)

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
	end

	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetCustomCollisionCheck(true)
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

function ENT:CollisionFunc(ent)
end

-- if ent:GetPos().z + 64 > self:GetPos().z then
-- 	print("huh")

-- 	return true
-- else
-- 	return false
-- end

function ENT:OnRemove()
end

function ENT:Think()
	return true
end

-- local matrix
-- local vecscale

function ENT:Draw()
	self:DrawModel()
end