include("shared.lua")

local TEXT_COLOR = Color(0, 255, 0)
local BG_COLOR = Color(0, 0, 0, 160)

function ENT:Initialize()
    self.offset = 0
    self:SetRenderBounds(
        Vector(-128, -128, -128),
        Vector(128, 128, 256)
    )
end

local radius = 50
local circleup = Vector(0, 0, 80)

function ENT:DrawTranslucent()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end

    local pos = self:GetPos() + Vector(0, 0, circleup.Z * 1.25)
    local ang = lp:EyeAngles()
    lp.distfromlocal = lp:GetPos():Distance(self:GetPos())
    local dist = lp.distfromlocal or 60000
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    cam.Start3D2D(pos, Angle(0, ang.y, ang.z), math.max(2.5 * dist / 2000, 0.75))
        render.DepthRange(0, 0)
        draw.SimpleText("OVER HERE", "BeatrunHUD", 0, 0, TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        render.DepthRange(0, 1)
    cam.End3D2D()

    render.SetColorMaterial()
    local count = 16
    for i = 0, count do
        local angle = i * math.pi * 2 / count + self.offset
        local circlepos = Vector(math.cos(angle) * radius, math.sin(angle) * radius, 0)
        local newpos = self:GetPos() + circlepos

        render.DepthRange(0, 0)
        TEXT_COLOR.a = 100
        render.DrawBeam(newpos, newpos + circleup, 4, 0, 1, TEXT_COLOR)
        TEXT_COLOR.a = 255
        render.DepthRange(0, 1)
    end

    self.offset = (self.offset + FrameTime() * 0.5) % (math.pi * 2)
end
