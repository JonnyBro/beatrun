ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Data Bank"
ENT.Author = ""
ENT.Category = "Beatrun"

ENT.Information = ""
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

AddCSLuaFile()

ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"
ENT.IsFinish = false

function ENT:SetupDataTables()
end

local minb, maxb = Vector(-75, -75, 0), Vector(75, 75, 100)

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

-- local screencolor = Color(64, 0, 0, 64)

function ENT:StartTouch(ent)
	if ent:IsPlayer() and ent:GetNW2Entity("DataBank") == self and ent:GetNW2Int("DataCubes", 0) > 0 then
		ent:SetNW2Int("DataBanked", ent:GetNW2Int("DataBanked", 0) + math.min(ent:GetNW2Int("DataCubes"), 5))
		ent:SetNW2Int("DataCubes", math.max(ent:GetNW2Int("DataCubes") - 5, 0))

		ent:DataTheft_Bank()

		self:EmitSound("mirrorsedge/ui/ME_UI_hud_select.wav", 60, 100 + math.random(-10, 5))
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
local red = Color(200, 200, 200, 200)
local circlepos = Vector()
local circleup = Vector(0, 0, 25)

function ENT:DrawTranslucent()
	local db = LocalPlayer():GetNW2Entity("DataBank")

	if IsValid(db) and db == self then
		self:SetRenderBounds(minb, maxb)

		render.SetColorMaterial()

		red.a = math.Clamp(LocalPlayer():GetPos():Distance(self:GetPos()) * 0.2, 25, 200)

		for i = 0, 16 do
			local angle = i * math.pi * 2 / 16 + self.offset

			circlepos:SetUnpacked(math.cos(angle) * radius, math.sin(angle) * radius, 0)

			local newpos = self:GetPos() + circlepos

			render.DrawBeam(newpos, newpos + circleup, 8, 0, 1, red, true)
		end

		-- local bmin, bmax = self:GetRenderBounds()
		-- render.DrawWireframeBox(self:GetPos(), angle_zero, bmin, bmax)
		self.offset = self.offset + 0.00075

		if self.offset >= 180 then
			self.offset = 0
		end
	end
end

function ENT:Draw()
end

local vecup = Vector(0, 0, 50)

hook.Add("HUDPaint", "DataBank", function()
	local db = LocalPlayer():GetNW2Entity("DataBank")

	if IsValid(db) then
		local pos = db:GetPos()
		pos:Add(vecup)
		local w2s = pos:ToScreen()

		if w2s.visible then
			surface.SetTextColor(200, 200, 200)
			surface.SetFont("BeatrunHUD")

			local tw, _ = surface.GetTextSize("Deposit")

			surface.SetTextPos(w2s.x - (tw * 0.5), w2s.y)
			surface.DrawText("Deposit")
		end
	end
end)

local meta = FindMetaTable("Player")

if SERVER then
	function meta:DataTheft_Bank()
		local dbtbl = ents.FindByClass("br_databank")
		local bank = dbtbl[math.random(#dbtbl)]

		if bank then
			self:SetNW2Entity("DataBank", bank)
		end
	end
end
