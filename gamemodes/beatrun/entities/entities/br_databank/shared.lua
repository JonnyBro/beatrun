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
local handlemin, handlemax = Vector(-8, -8, 0), Vector(8, 8, 16)

function ENT:Initialize()
	self:SetModel(self.Model)
	self:DrawShadow(false)

	if SERVER then
		self:PhysicsInitBox(handlemin, handlemax)
		self:SetMoveType(MOVETYPE_NONE)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then phys:EnableMotion(false) end

		self.Inside = {}
	else
		self:SetRenderBounds(minb, maxb)
		self.offset = 0
	end

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
end

function ENT:Deposit(ply)
	if ply:GetNW2Entity("DataBank") ~= self or ply:GetNW2Int("DataCubes", 0) <= 0 then return end

	ply:SetNW2Int("DataBanked", ply:GetNW2Int("DataBanked", 0) + math.min(ply:GetNW2Int("DataCubes"), 5))
	ply:SetNW2Int("DataCubes", math.max(ply:GetNW2Int("DataCubes") - 5, 0))

	ply:DataTheft_Bank()

	self:EmitSound("mirrorsedge/ui/ME_UI_hud_select.ogg", 60, 100 + math.random(-10, 5))
end

function ENT:Think()
	if CLIENT then return end

	local pos = self:GetPos()
	local zmin, zmax = pos + minb, pos + maxb

	for _, ply in player.Iterator() do
		local inside = ply:Alive() and ply:GetPos():WithinAABox(zmin, zmax)

		if inside and not self.Inside[ply] then self:Deposit(ply) end

		self.Inside[ply] = inside or nil
	end

	self:NextThink(CurTime() + 0.1)

	return true
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

local toolweapons = {
	gmod_tool = true,
	weapon_physgun = true
}

function ENT:DrawTranslucent()
	local wep = LocalPlayer():GetActiveWeapon()

	if IsValid(wep) and toolweapons[wep:GetClass()] then render.DrawWireframeBox(self:GetPos(), self:GetAngles(), handlemin, handlemax, color_white, true) end

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
