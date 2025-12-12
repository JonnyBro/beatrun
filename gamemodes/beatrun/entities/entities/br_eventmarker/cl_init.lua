include("shared.lua")

local TEXT_COLOR = Color(0, 255, 0, 255)
local BEAM_COLOR = Color(0, 255, 0, 100)
local radius = 50
local circleup = Vector(0, 0, 80)

local ENT_CLASS = "br_eventmarker"

local function ShouldDrawMarker(ent)
	local lp = LocalPlayer()
	if not IsValid(lp) or not IsValid(ent) then return false end
	if not GetGlobalBool("GM_EVENTMODE") or lp:GetNW2String("EPlayerStatus", "Member") == "Suspended" then return false end
	return true
end

local function DrawMarkerText()
	local markers = ents.FindByClass(ENT_CLASS)

	for _, ent in ipairs(markers) do
		if not ShouldDrawMarker(ent) then continue end

		local dist = LocalPlayer():GetPos():Distance(ent:GetPos())
		local pos = ent:GetPos() + Vector(0, 0, circleup.Z * 1.15)

		local ang = LocalPlayer():EyeAngles()
		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), 90)

		local scale = math.Clamp(2.5 * dist / 2000, 0.75, 5)

		cam.Start3D2D(pos, Angle(0, ang.y, ang.z), scale)
			cam.IgnoreZ(true)
			render.DepthRange(0, 0)
			draw.SimpleText("OVER HERE", "BeatrunHUD", 0, 0, TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			render.DepthRange(0, 1)
			cam.IgnoreZ(false)
		cam.End3D2D()
	end
end

hook.Add("PostDrawOpaqueRenderables", "BeatrunEventMarkers_Text", DrawMarkerText)

local function DrawMarkerBeams()
	local markers = ents.FindByClass(ENT_CLASS)

	for _, ent in ipairs(markers) do
		if not ShouldDrawMarker(ent) then continue end

		render.SetColorMaterial()

		local count = 16
		local offset = CurTime() * 0.5 % (math.pi * 2)

		for i = 0, count do
			local angle = i * math.pi * 2 / count + offset
			local circlepos = Vector(math.cos(angle) * radius, math.sin(angle) * radius, -7)
			local newpos = ent:GetPos() + circlepos

			render.DrawBeam(newpos, newpos + circleup, 4, 0, 1, BEAM_COLOR)
		end
	end
end

hook.Add("PostDrawTranslucentRenderables", "BeatrunEventMarkers_Beams", DrawMarkerBeams)

function ENT:Initialize()
	self:SetRenderBounds(Vector(-128, -128, -128), Vector(128, 128, 256))
end