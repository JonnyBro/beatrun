ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Event Marker"
ENT.Author = ""
ENT.Category = "Beatrun"

ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

AddCSLuaFile()

local minb, maxb = Vector(-40, -40, 0), Vector(40, 40, 64)

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Score")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        self:DrawShadow(false)

        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_BBOX)
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:SetCollisionBounds(minb, maxb)

        self:SetTrigger(true)
    end

    function ENT:StartTouch(ent)
    	--on touch
    end
end