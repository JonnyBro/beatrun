ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Checkpoint"
ENT.Author = ""
ENT.Category = "Beatrun"

ENT.Information = ""
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

AddCSLuaFile()

ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"
ENT.IsFinish = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "CPNum")
end

local minb, maxb = Vector(-75, -75, 0), Vector(75, 75, 10000)

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

	self:SetPos(self:GetPos() + Vector(-0, -0, 0))
end

local screencolor = Color(64, 0, 0, 64)

function ENT:StartTouch(ent)
	if ent:IsPlayer() and Course_Name ~= "" and not ent.BuildMode and ent:GetNW2Int("CPNum", 1) == self:GetCPNum() then
		ent:SetNW2Int("CPNum", ent:GetNW2Int("CPNum", 1) + 1)

		if ent:GetNW2Int("CPNum", 1) > table.Count(Checkpoints) then
			ReplayStop(ent)
			FinishCourse(ent)
		else
			ent.CPSavePos = ent:GetPos()
			ent.CPSaveAng = ent:EyeAngles()
			ent.CPSaveVel = ent:GetVelocity()

			ent:SaveParkourState()

			net.Start("Checkpoint_Hit")
				net.WriteUInt(ent:GetNW2Int("CPNum", 1), 8)
			net.Send(ent)
		end

		ent:ScreenFade(SCREENFADE.IN, screencolor, 0.25, 0)
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Use(activator, caller, usetype)
end

function ENT:OnRemove()
end

local radius = 75
local red = Color(255, 0, 0, 200)
local circlepos = Vector()
local circleup = Vector(0, 0, 10000)

local checkheight = Vector(0, 0, 64) -- eyepos diff
local arrow = Material("medge/timetrial/checkpoint_arrow")
local asize = 32

function ENT:DrawTranslucent()
	self:SetRenderBounds(minb, maxb)

	if (not BuildMode and CheckpointNumber ~= self:GetCPNum()) and not LocalPlayer().InReplay then return end

	render.SetColorMaterial()

	red.a = math.Clamp(LocalPlayer():GetPos():Distance(self:GetPos()) * 0.2, 25, 200)

	for i = 0, 16 do
		local angle = i * math.pi * 2 / 16 + self.offset

		circlepos:SetUnpacked(math.cos(angle) * radius, math.sin(angle) * radius, 0)

		local newpos = self:GetPos() + circlepos

		render.DrawBeam(newpos, newpos + circleup, 8, 0, 1, red, true)
	end

	local nextCP = IsValid(Checkpoints[self:GetCPNum() + 1]) and Checkpoints[self:GetCPNum() + 1] or self

	local selfpos = self:GetPos() + checkheight
	local fwAng = (nextCP:GetPos() - selfpos):GetNormalized():Angle()

	for i = 0, 1, 0.1 do
		local prog = (SysTime() * .25) % 0.1 + i

		red.a = 255 * (prog > 0.5 and 0.5 - prog or prog) * 2

		local size = asize * (1 - prog)
		local pos = selfpos - fwAng:Forward() * asize + fwAng:Forward() * (asize * 2) * prog

		render.SetMaterial(arrow)
		render.DrawBeam(pos - fwAng:Forward() * size * .5, pos + fwAng:Forward() * size * .5, size, 1, 0, red)
	end

	-- local bmin, bmax = self:GetRenderBounds()
	-- render.DrawWireframeBox(self:GetPos(), angle_zero, bmin, bmax)
	self.offset = self.offset + 0.00075

	if self.offset >= 180 then
		self.offset = 0
	end
end

function ENT:Draw()
end

local circlesprite = Material("circle.png", "nocull")

function ENT:DrawLOC()
	if (not BuildMode and CheckpointNumber ~= self:GetCPNum()) and not LocalPlayer().InReplay then return end

	render.SetMaterial(circlesprite)

	red.a = math.Clamp(LocalPlayer():GetPos():Distance(self:GetPos()) * 0.2, 25, 200)

	local f = LocalPlayer():EyeAngles():Forward()

	for i = 0, 16 do
		local angle = i * math.pi * 2 / 16 + self.offset

		circlepos:SetUnpacked(math.cos(angle) * radius, math.sin(angle) * radius, 0)

		local newpos = self:GetPos() + circlepos
		-- render.DrawLine(newpos, newpos+VectorRand()*5, red)

		render.DrawQuadEasy(newpos, f, 6, 6, red)
	end

	-- local bmin, bmax = self:GetRenderBounds()
	-- render.DrawWireframeBox(self:GetPos(), angle_zero, bmin, bmax)
	self.offset = self.offset + 0.00075

	if self.offset >= 180 then
		self.offset = 0
	end
end