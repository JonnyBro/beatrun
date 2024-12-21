sound.Add({
	name = "FallStatic",
	channel = CHAN_STATIC,
	volume = 1,
	level = 80,
	pitch = 100,
	sound = "mirrorsedge/FallStatic.wav"
})

local zoom = Material("vgui/zoom.vtf")
local nextbeat = 0
local beatvol = 0.3
local blurpass = 0
local vignettealpha = 0

local function FallCheck()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local speed = ply:GetVelocity().z

	if not ply.FallStatic and speed <= -800 and ply:GetMoveType() ~= MOVETYPE_NOCLIP and ply:GetDive() == false and ply:Alive() then
		ply:EmitSound("FallStatic")
		ply.FallStatic = true

		nextbeat = CurTime() + 0.5
		beatvol = 0.3
		blurpass = 0
		vignettealpha = 0
		CamShake = true
		CamShakeMult = 0

		if not ply:GetJumpTurn() then
			ParkourEvent("falluncontrolled", ply, true)
		end
	elseif ply.FallStatic and speed > -800 then
		ply:SetFOV(ply:GetInfoNum("Beatrun_FOV", 100))
		ply:StopSound("FallStatic")

		ply.FallStatic = false
		CamShake = false

		ParkourEvent("fallrecover", ply, true)
	end
end

hook.Add("Tick", "FallCheck", FallCheck)

local function FallEffect()
	local ply = LocalPlayer()

	if ply.FallStatic then
		local vel = math.abs(ply:GetVelocity().z) / 1400
		local csm = CamShakeMult
		-- DrawMotionBlur( 0.4, 0.8, 0.015*vel )

		CamShakeMult = math.Approach(csm, 3, FrameTime() * 1.5)
		DrawMaterialOverlay("effects/fall_warp", CamShakeMult * 0.025)

		if blurpass >= 1 then return end -- DrawToyTown(math.Truncate(blurpass), ScrH()*blurpass)

		if CurTime() > nextbeat then
			nextbeat = CurTime() + math.Clamp(0.5 / vel, 0.3, 0.5)
			ply:EmitSound("heartbeat_beat_0" .. math.random(1, 8) .. ".wav", 80, 100, beatvol)
			beatvol = math.min(beatvol + 0.05, 1)
			blurpass = math.min(blurpass + 0.1, 10)
		end

		ply:SetFOV(ply:GetInfoNum("Beatrun_FOV", 100) + math.Rand(0, CamShakeMult * 2.5))
	end
end

hook.Add("RenderScreenspaceEffects", "FallEffect", FallEffect)

hook.Add("HUDPaint", "FallVignette", function()
	if not LocalPlayer().FallStatic then return end

	vignettealpha = math.min(255, vignettealpha + (FrameTime() * 100))

	surface.SetMaterial(zoom)
	surface.SetDrawColor(255, 255, 255, vignettealpha)
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	surface.DrawTexturedRectRotated(ScrW() * 0.5, ScrH() * 0.5, ScrW(), ScrH(), 180)
end)

hook.Add("InputMouseApply", "FallLock", function(cmd, x, y, ang)
	if LocalPlayer().FallStatic then
		cmd:SetMouseX(0)
		cmd:SetMouseY(0)

		return true
	end
end)