local totsugeki = CreateConVar("Beatrun_Totsugeki", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "", 0, 1)
local totsugekispam = CreateConVar("Beatrun_TotsugekiSpam", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "", 0, 1)
local totsugekiheading = CreateConVar("Beatrun_TotsugekiHeading", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "", 0, 1)
local totsugekidir = CreateConVar("Beatrun_TotsugekiDir", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "", 0, 1)

local totsugekiaudio = CreateConVar("Beatrun_TotsugekiAudio", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "", 0, 1)

local function Dive(ply, mv, cmd)
	if (not ply:GetDive() or ply:GetDive() and ply.QuakeJumping and totsugeki:GetBool() and totsugekispam:GetBool()) and ply:GetCrouchJump() and mv:KeyPressed(IN_ATTACK2) then
		local vel = mv:GetVelocity()
		local vel2 = Vector(vel)
		vel2.z = 0

		local vel2len = vel2:Length()
		local ang = cmd:GetViewAngles()
		ang.x = 0

		local velmul = 15 / (math.max(vel2len - 100, 40) * 0.003)

		vel:Add(ang:Forward() * velmul)
		vel:Add(Vector(0, 0, 70))

		mv:SetVelocity(vel)

		ply:SetCrouchJumpTime(CurTime() + 1.65)
		ply:SetDive(true)

		ply:ViewPunch(Angle(-10, 0, 0))

		ParkourEvent("divestart", ply)

		if ply:UsingRH() and ply:GetActiveWeapon():GetQuakeJumping() and totsugeki:GetBool() then
			if SERVER then
				if totsugekiaudio:GetBool() then
					ply:EmitSound("misc/totsugeki" .. math.random(1, 2) .. ".mp3", 60, 100, 1, CHAN_VOICE)
				end

				local vPoint = mv:GetOrigin()
				local effectdata = EffectData()

				effectdata:SetOrigin(vPoint)

				util.Effect("WaterSurfaceExplosion", effectdata)
			elseif CLIENT and IsFirstTimePredicted() then
				local vPoint = mv:GetOrigin()
				local effectdata = EffectData()

				effectdata:SetOrigin(vPoint)

				util.Effect("WaterSurfaceExplosion", effectdata)
			end

			local ang = cmd:GetViewAngles()

			if not totsugekiheading:GetBool() then
				ang.x = 0
			end

			vel:Set(ang:Forward() * 800)

			if not totsugekidir:GetBool() then
				vel:Set(vel2)
				vel:Add(ang:Forward() * 200)
			end

			vel:Add(Vector(0, 0, 70))
			mv:SetVelocity(vel)
		end
	end

	mv:AddKey(IN_BULLRUSH)

	if ply:GetDive() then
		if ply:GetMoveType() == MOVETYPE_NOCLIP or ply:WaterLevel() >= 3 or not ply:Alive() then
			ply:SetDive(false)
			ply:SetCrouchJump(false)
			ply.DiveSliding = false

			ParkourEvent("diveslideend", ply)

			return
		end

		if not cmd:KeyDown(IN_DUCK) then
			mv:AddKey(IN_BULLRUSH)
		end

		mv:AddKey(IN_DUCK)

		if ply:OnGround() and ply:GetSafetyRollKeyTime() <= CurTime() then
			ply.DiveSliding = true
			ply:SetDive(false)
		elseif ply:OnGround() and mv:KeyDown(IN_BULLRUSH) then
			mv:SetButtons(0)
		end
	end
end

hook.Add("SetupMove", "Dive", Dive)