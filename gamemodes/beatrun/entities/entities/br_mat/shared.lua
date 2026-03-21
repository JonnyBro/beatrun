ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Mat"
ENT.Author = ""
ENT.Category = "Beatrun"

ENT.Information = ""
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE

AddCSLuaFile()

ENT.Model = "models/crashpad.mdl"

local start_dist = 150
local end_dist = 600

local greycolor = Vector(0.55, 0.55, 0.55)
local redcolor = Vector(1, 0.15, 0.15)

function ENT:SetupDataTables()
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	if CLIENT then self:_EnsureTintMaterial() end
end

function ENT:Draw()
	self:DrawModel()
end

if CLIENT then
	function ENT:OnRemove()
		if self._mainwarpSubMatIndex then self:SetSubMaterial(self._mainwarpSubMatIndex, "") end
	end

	function ENT:_FindMainwarpSubMaterialIndex()
		local mats = self:GetMaterials()
		if not istable(mats) then return nil end

		for i = 1, #mats do
			local name = mats[i]
			if isstring(name) and string.find(string.lower(name), "mainwarp", 1, true) then return i - 1 end
		end

		return nil
	end

	function ENT:_EnsureTintMaterial()
		if self._mainwarpTintMatName and self._mainwarpSubMatIndex ~= nil then return end

		self._mainwarpSubMatIndex = self:_FindMainwarpSubMaterialIndex()

		if self._mainwarpSubMatIndex == nil then
			timer.Simple(0, function() if IsValid(self) then self:_EnsureTintMaterial() end end)
			return
		end

		local matName = ("br_mat_mainwarp_%d"):format(self:EntIndex())

		self._mainwarpTintMatName = matName

		local base = Material("models/crashpad/mainwarp")
		local baseTex = base and base:GetTexture("$basetexture")
		local params = {
			["$model"] = 1,
			["$surfaceprop"] = "fabric",
			["$phong"] = 1,
			["$phongexponent"] = 20,
			["$color2"] = "[1 1 1]",
		}

		if baseTex then
			params["$basetexture"] = baseTex:GetName()
		else
			params["$basetexture"] = "models/crashpad/mainwarp"
		end

		self._mainwarpTintMat = CreateMaterial(matName, "VertexLitGeneric", params)
		self:SetSubMaterial(self._mainwarpSubMatIndex, "!" .. matName)
	end

	function ENT:Think()
		self:_EnsureTintMaterial()

		if not self._mainwarpTintMat then return end

		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local dist = ply:GetPos():Distance(self:GetPos())
		local t = math.Clamp((dist - start_dist) / (end_dist - start_dist), 0, 1)
		local col = LerpVector(t, greycolor, redcolor)

		self._mainwarpTintMat:SetVector("$color2", col)
		self._mainwarpTintMat:SetVector("$color", col)

		self:NextThink(CurTime() + 0.1)

		return true
	end
end