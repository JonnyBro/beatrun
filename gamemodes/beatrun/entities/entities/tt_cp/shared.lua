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

function ENT:Reached(ply)
	if Course_Name == "" or ply.BuildMode or ply:GetNW2Int("CPNum", 1) ~= self:GetCPNum() then return end

	ply:SetNW2Int("CPNum", ply:GetNW2Int("CPNum", 1) + 1)

	if ply:GetNW2Int("CPNum", 1) > table.Count(Checkpoints) then
		FinishCourse(ply)
	else
		ply.CPSavePos = ply:GetPos()
		ply.CPSaveAng = ply:EyeAngles()
		ply.CPSaveVel = ply:GetVelocity()
		ply.CPSaveVehicle = nil

		local vehicle = ply:GetVehicle()

		if IsValid(vehicle) and not IsValid(vehicle:GetParent()) then
			ply.CPSaveVehicle = {
				ent = vehicle,
				id = BuildModeEntitySpawnable(vehicle) or (vehicle.VehicleName and "vehicle:" .. vehicle.VehicleName),
				pos = vehicle:GetPos(),
				ang = vehicle:GetAngles(),
				vel = vehicle:GetVelocity()
			}
		end

		ply:SaveParkourState()

		net.Start("Checkpoint_Hit")
			net.WriteUInt(ply:GetNW2Int("CPNum", 1), 8)
		net.Send(ply)
	end

	ply:ScreenFade(SCREENFADE.IN, screencolor, 0.25, 0)
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() then self:Reached(ent) end
end

-- Players in vehicles are parented to them and never touch triggers
function ENT:Think()
	if CLIENT then return end

	local pos = self:GetPos()
	local cpmins, cpmaxs = pos + minb, pos + maxb

	for _, ply in player.Iterator() do
		if not ply:InVehicle() or ply:GetNW2Int("CPNum", 1) ~= self:GetCPNum() then continue end

		local vehicle = ply:GetVehicle()
		local root = IsValid(vehicle:GetParent()) and vehicle:GetParent() or vehicle
		local mins, maxs = root:WorldSpaceAABB()

		if util.IsBoxIntersectingBox(mins, maxs, cpmins, cpmaxs) then self:Reached(ply) end
	end

	self:NextThink(CurTime() + 0.05)

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
local red = Color(255, 0, 0, 200)
local circlepos = Vector()
local circleup = Vector(0, 0, 10000)

local checkheight = Vector(0, 0, 64) -- eyepos diff
local arrow = Material("medge/timetrial/checkpoint_arrow")
local asize = 32

local drawingSkybox = false

-- if anyone knows a better way to stop the checkpoint from rendering in the skybox then pls fix
hook.Add("PreDrawTranslucentRenderables", "CheckForSkyboxRenderCheckPoint", function(_, IsDrawSkybox, IsDraw3DSkybox) drawingSkybox = IsDraw3DSkybox end)

function ENT:DrawTranslucent()
	if drawingSkybox then return end

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

		render.DrawQuadEasy(newpos, f, 6, 6, red)
	end

	self.offset = self.offset + 0.00075

	if self.offset >= 180 then
		self.offset = 0
	end
end
