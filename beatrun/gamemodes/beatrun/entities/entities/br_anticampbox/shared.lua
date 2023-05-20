ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Anti Camp Box"
ENT.Author = ""
ENT.Category = "Beatrun"

ENT.Information = ""
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

AddCSLuaFile()

ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"
ENT.IsFinish = false

function ENT:Initialize()
	self:SetModel(self.Model)
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetCollisionBounds(Vector(-150, -150, 0), Vector(150, 150, 150))

	if SERVER then
		self:SetTrigger(true)
	end

	self:SetPos(self:GetPos() + Vector(-0, -0, 0))
end

-- local screencolor = Color(64, 0, 0, 64)

function ENT:StartTouch(ent)
	if ent:IsPlayer() then
		ent.MemeTime = CurTime() + 10
	end
end

function ENT:Touch(ent)
	if ent:IsPlayer() then
		if CurTime() > ent.MemeTime then
			if not ent.MemeMessage then
				ent:ChatPrint("Are you having fun standing still in a parkour game? Let's spice things up a bit!")
				ent.MemeMessage = true
			end

			if CurTime() - 4 > ent.MemeTime then
				ent:SetVelocity(VectorRand() * 1000)
			end
		end
	end
end

function ENT:EndTouch(ent)
	if ent:IsPlayer() then
		ent.MemeMessage = false
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_NEVER
end

function ENT:Use(activator, caller, usetype)
end

function ENT:OnRemove()
end

function ENT:DrawTranslucent()
end

function ENT:Draw()
end