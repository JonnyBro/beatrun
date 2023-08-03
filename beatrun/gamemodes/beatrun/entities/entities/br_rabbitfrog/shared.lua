ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Rabbitfrog"
ENT.Author = ""
ENT.Category = "Beatrun"

ENT.Information = ""
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE

AddCSLuaFile()

ENT.Model = "models/nt/props_vehicles/rabbitfrog_dynamic.mdl"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Passenger1")
	self:NetworkVar("Entity", 1, "Passenger2")
	self:NetworkVar("Entity", 2, "Passenger3")
	self:NetworkVar("Entity", 3, "Passenger4")
	self:NetworkVar("Vector", 0, "DestinationPos")
	self:NetworkVar("Angle", 1, "DestinationAngle")
end

-- local mins, maxs = Vector(-64, -64, 0), Vector(64, 64, 154)

function ENT:Initialize()
	self:SetModel(self.Model)
	-- self:SetMoveType(MOVETYPE_NONE)
	-- self:SetSolid(SOLID_BBOX)
	-- self:SetCollisionBounds(mins, maxs)

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
	end

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:ResetSequence(1)

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:OnRemove()
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Think()
	self:NextThink(CurTime())

	return true
end

local blur = Material("pp/blurscreen")

local function draw_blur(a, d)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)

	for i = 1, d do
		blur:SetFloat("$blur", (i / d) * a)
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end
end

local blurint = 4
-- local rabbitpos, rabbitang = Vector(), Angle()

local landseq = {
	[1] = true,
	[4] = true
}

-- local initseq = 1
-- local offset = Vector(-30, 5, 0)
-- local offsetdraw = Vector(0, 70, 0)
-- local angoffset = Angle(0, 90, 90)
-- local lastpos = Vector()
-- local lastang = Angle()
-- local endlerp = 0
-- local endlerppos = Vector()
-- local neweye = false
-- local fx = false
local diff = 1

local function IsLanding(ent)
	return landseq[ent:GetSequence()] or false
end

local introalpha = 255

local function LandingHUDPaint()
	introalpha = introalpha - (FrameTime() * 50)

	surface.SetDrawColor(0, 0, 0, introalpha)
	surface.DrawRect(0, 0, ScrW(), ScrH())

	if introalpha <= 0 then
		hook.Remove("HUDPaint", "LandingHUDPaint")
	end
end

local function LandingHUDIntro()
	introalpha = 255
	hook.Add("HUDPaint", "LandingHUDPaint", LandingHUDPaint)
end

local function LandingIntro()
	fx = false
	neweye = false
	endlerp = 0
	surface.PlaySound("hopperland.mp3")
	LandingHUDIntro()
end


function ENT:Draw()
	-- Reset everything to known good
	render.SetStencilWriteMask(0xFF)
	render.SetStencilTestMask(0xFF)
	render.SetStencilReferenceValue(0)
	-- render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation(STENCIL_KEEP)
	-- render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.ClearStencil()

	render.SetStencilEnable(true) -- Enable stencils
	render.SetStencilReferenceValue(1) -- Set the reference value to 1. This is what the compare function tests against
	render.SetStencilCompareFunction(STENCIL_NEVER) -- Force everything to fail
	render.SetStencilFailOperation(STENCIL_REPLACE) -- Save all the things we don't draw

	self:DrawModel() -- Fail to draw our entities.

	render.SetStencilCompareFunction(STENCIL_EQUAL) -- Render all pixels that don't have their stencil value as 1
	render.SetStencilFailOperation(STENCIL_KEEP) -- Don't modify the stencil buffer when things fail

	-- for _, ent in pairs( ents.FindByClass( "sent_stencil_test_big" ) ) do
	render.PushFilterMag(TEXFILTER.ANISOTROPIC) -- Draw our big entities. They will have holes in them wherever the smaller entities were
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	self:DrawModel()
	cam.Start2D(vector_origin, angle_zero)
	draw_blur(math.max(blurint * -diff, 0), 5)
	-- DrawBokehDOF(5,0.99,8)
	render.PopFilterMag()
	render.PopFilterMin()
	cam.End2D()
	-- end

	render.SetStencilEnable(false) -- Let everything render normally again
end


local function RabbitCalcView(ply, origin, ang)
	local rabbit = ply:GetRabbit()

	if IsValid(rabbit) and rabbit:GetCycle() < 1 and IsLanding(rabbit) then
		if rabbit:GetCycle() < 1 then
			util.ScreenShake(vector_origin, 1, 100, 0.5, 0)
		end

		local matrix = rabbit:GetBoneMatrix(0)
		local pos = matrix:GetTranslation()
		local angles = matrix:GetAngles()
		local npos, _ = LocalToWorld(offset, angles, pos, angles)
		angles:Sub(angoffset)
		angles.x = -angles.x
		angles.y = angles.y - 90
		angles.z = angles.x

		local oldangx = ang.x
		ang.x = 0

		diff = ang:Forward():Dot(angles:Right())

		local absdiff = math.abs(diff)
		ang.x = oldangx
		angles.z = angles.z * absdiff
		-- angles.x = angles.x * absdiff
		-- angles.x = angles.x*ang:Forward():Dot(ang:Forward())
		-- angles.z = angles.z*math.abs(ang:Forward():Dot(ang:Forward()))

		pos:Set(npos)
		origin:Set(pos)
		ang:Add(angles)
		lastpos:Set(origin)
		lastang:Set(ang)
	elseif endlerp < 1 then
		if not neweye then
			lastang.z = 0

			ang:Set(lastang)

			ply:SetEyeAngles(lastang)
			neweye = true

			ply:CLViewPunch(Angle(12, 0, 0))
			if VManip then
				VManip:PlayAnim("vault")
			end
		end

		origin:Set(LerpVector(endlerp, lastpos, origin))

		endlerp = endlerp + (FrameTime() * 4)

		endlerppos:Set(origin)
	end
end

local function RabbitVM(wep, vm, oldpos, oldang, pos, ang)
	local rabbit = LocalPlayer():GetRabbit()
	local diffpos = pos - oldpos
	local diffang = ang - oldang

	if IsValid(rabbit) and rabbit:GetCycle() < 1 and IsLanding(rabbit) then
		pos:Set(lastpos)
		ang:Set(lastang)
		pos:Sub(diffpos)
		ang:Sub(diffang)
	elseif endlerp < 1 then
		pos:Set(endlerppos)
	end
end

-- hook.Add("CalcViewModelView", "RabbitVM", RabbitVM)

-- hook.Add("BeatrunDrawHUD", "Rabbit", function()
-- 	if IsValid(rabbit) and rabbit:GetCycle() < 1 and IsLanding(rabbit) then return false end
-- end)

function ENT:Use(ply, caller, usetype, value)
	if not ply:IsPlayer() then return end

	print("hi")

	ply:SetRabbit(self)
	ply:SetRabbitSeat(1)
end

-- hook.Add("CalcViewModelView", "RabbitVM", RabbitVM)
-- hook.Add("CalcView", "RabbitCalcView", RabbitCalcView)


local function RabbitPlayerMove(ply, mv, cmd)
	local rabbit = ply:GetRabbit()

	if IsValid(rabbit) then
		local matrix = rabbit:GetBoneMatrix(0)
		local pos = matrix:GetTranslation() - ply:GetViewOffset()
		local angles = matrix:GetAngles()
		local npos, _ = LocalToWorld(offset, angles, pos, angles)
		ply:SetMoveType(MOVETYPE_NOCLIP)
		mv:SetOrigin(npos)
	end
end

-- hook.Add("SetupMove", "RabbitPlayerMove", RabbitPlayerMove)