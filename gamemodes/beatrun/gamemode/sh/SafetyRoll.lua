if game.SinglePlayer() and SERVER then
	util.AddNetworkString("RollAnimSP")
end

local landang = Angle(0, 0, 0)
local lastGroundSpeed = 0
local rollspeedloss = CreateConVar("Beatrun_RollSpeedLoss", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "", 0, 1)

local roll = {
	followplayer = true,
	animmodelstring = "new_climbanim",
	showweapon = true,
	lockang = true,
	BodyAnimSpeed = 1.15,
	ignorez = true,
	deleteonend = true,
	AnimString = "rollanim"
}

local function RollAnimCrouch(land, evade)
	local ply = LocalPlayer()

	if land then
		if IsValid(ply) and PlayerCannotStand(ply) then
			roll.AnimString = ply:UsingRH() and "landcrouch" or "landguncrouch"
		else
			roll.AnimString = ply:UsingRH() and "land" or "landgun"
		end

		CacheBodyAnim()
		RemoveBodyAnim()
		StartBodyAnim(roll)
	elseif evade then
		timer.Simple(0.6, function()
			if IsValid(ply) and PlayerCannotStand(ply) then
				roll.AnimString = "evaderollcrouch"

				CacheBodyAnim()
				RemoveBodyAnim()
				StartBodyAnim(roll)
			end
		end)
	else
		timer.Simple(0.6, function()
			if IsValid(ply) and PlayerCannotStand(ply) then
				local crouchAnim = roll.AnimString == "merollgun" and "merollguncrouch" or "merollcrouch"
				roll.AnimString = crouchAnim

				CacheBodyAnim()
				RemoveBodyAnim()
				StartBodyAnim(roll)
			end
		end)
	end
end


hook.Add("SetupMove", "SafetyRoll", function(ply, mv, cmd)
	local speed = mv:GetVelocity().z

	if speed <= -350 and not ply:OnGround() and not ply:GetWasOnGround() and (mv:KeyPressed(IN_DUCK) or mv:KeyPressed(IN_SPEED) or mv:KeyPressed(IN_BULLRUSH)) then
		ply:SetSafetyRollKeyTime(CurTime() + 0.5)

		mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_DUCK)))
	end

	local isRolling = CurTime() < ply:GetSafetyRollKeyTime()

	if ply:OnGround() and not isRolling then
		lastGroundSpeed = mv:GetVelocity():Length()
	end

	if CurTime() < ply:GetSafetyRollTime() then
		ply.FootstepLand = false

		local ang = ply:GetSafetyRollAng()

		mv:SetSideSpeed(0)
		mv:SetForwardSpeed(0)

		mv:AddKey(IN_DUCK)

		if ang ~= landang then
			local vel = mv:GetVelocity()
			vel.x = 0
			vel.y = 0

			local speedloss = rollspeedloss:GetBool()
			local speedLimit = GetConVar("Beatrun_SpeedLimit"):GetInt()

			if speedloss then
				mv:SetVelocity(ang:Forward() * 250 + vel)
			else
				local max = math.max(250, math.Clamp(lastGroundSpeed, 200, speedLimit + 50))
				mv:SetVelocity(ang:Forward() * (max + 40))
			end

			ply:SetMEMoveLimit(450)
		else
			mv:SetVelocity(vector_origin)
		end
	end

	if ply:Alive() and IsValid(ply:GetActiveWeapon()) and CurTime() > ply:GetSafetyRollTime() and weapons.IsBasedOn(ply:GetActiveWeapon():GetClass(), "mg_base") then
		RunConsoleCommand("mgbase_debug_vmrender", "1")
	end
end)



net.Receive("RollAnimSP", function()
	local ply = LocalPlayer()
	local land = net.ReadBool()
	local evade = net.ReadBool()

	if land then
		roll.AnimString = ply:UsingRH() and "land" or "landgun"
		roll.animmodelstring = "new_climbanim"
		roll.BodyAnimSpeed = 1
	elseif evade then
		roll.AnimString = "evaderoll"
		roll.animmodelstring = "new_climbanim"
		roll.BodyAnimSpeed = 1.5
	else
		roll.AnimString = ply:UsingRH() and "meroll" or "merollgun"
		roll.animmodelstring = "new_climbanim"
		roll.BodyAnimSpeed = 1.15
	end

	-- Apply selected animation set
	if GetConVar("Beatrun_AnimSet"):GetInt() == 0 then
		roll.animmodelstring = "new_climbanim"
	else
		roll.animmodelstring = "old_climbanim"
	end

	-- Start animation
	CacheBodyAnim()
	RemoveBodyAnim()
	StartBodyAnim(roll)
	RollAnimCrouch(land, evade) --we play the crouching anims at the end
end)

hook.Add("SetupMove", "EvadeRoll", function(ply, mv, cmd)
	if ply:GetJumpTurn() and ply:OnGround() and mv:KeyPressed(IN_BACK) then
		if ply:Alive() and IsValid(ply:GetActiveWeapon()) and CurTime() > ply:GetSafetyRollTime() and weapons.IsBasedOn(ply:GetActiveWeapon():GetClass(), "mg_base") then
			RunConsoleCommand("mgbase_debug_vmrender", "0")
		end

		local ang = cmd:GetViewAngles()

		ply:SetViewOffset(Vector(0, 0, 64))

		ang.x = 0
		ang.z = 0

		ang:RotateAroundAxis(Vector(0, 0, 1), 180)
		ply:SetJumpTurn(false)
		ply:SetSafetyRollAng(ang)
		ply:SetSafetyRollTime(CurTime() + 0.9)

		roll.AnimString = "evaderoll"
		roll.animmodelstring = "new_climbanim"
		roll.usefullbody = false

		if SERVER and not land then
			ply:EmitSound("Cloth.FallShortMediumLong")
			ply:EmitSound("Cloth.RollCloth")
		elseif CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
			ply:EmitSound("Handsteps.ConcreteHard")
			ply:EmitSound("Land.Concrete")
		end

		if CLIENT and IsFirstTimePredicted() then
			if GetConVar("Beatrun_AnimSet"):GetInt() == 0 then
				roll.animmodelstring = "new_climbanim"
			else
				roll.animmodelstring = "old_climbanim"
			end

			CacheBodyAnim()
			RemoveBodyAnim()
			StartBodyAnim(roll)
			RollAnimCrouch(false, true) --we play the crouching anims at the end
		elseif game.SinglePlayer() then
			net.Start("RollAnimSP")
				net.WriteBool(false)
				net.WriteBool(true)
			net.Send(ply)
		end
	end
end)

hook.Add("OnPlayerHitGround", "SafetyRoll", function(ply, water, floater, speed)
	local tr = {
		filter = ply,
		start = ply:GetPos()
	}
	tr.endpos = tr.start - Vector(0, 0, 150)

	local out = util.TraceLine(tr)
	local normal = out.HitNormal
	local sang = normal:Angle()

	if sang.x <= 314 and not ply:InOverdrive() and (speed >= 350 or ply:GetDive()) and speed < 800 and (CurTime() < ply:GetSafetyRollKeyTime() and not ply:GetDive() or ply:GetDive() and not ply:KeyDown(IN_DUCK)) and not ply:GetJumpTurn() and (not ply:Crouching() or ply:GetDive()) then
		if ply:Alive() and IsValid(ply:GetActiveWeapon()) and CurTime() > ply:GetSafetyRollTime() and weapons.IsBasedOn(ply:GetActiveWeapon():GetClass(), "mg_base") then
			RunConsoleCommand("mgbase_debug_vmrender", "0")
		end

		ply:SetCrouchJump(false)
		ply:SetDive(false)

		ParkourEvent("roll", ply)

		local ang = ply:EyeAngles()
		local land = ply:GetVelocity()
		ang.x = 0
		ang.z = 0
		land.z = 0

		if land:Length() < 200 or ply:KeyDown(IN_BACK) then
			land = true

			ply:SetSafetyRollAng(landang)
			ply:SetSafetyRollTime(CurTime() + 0.6)

			roll.AnimString = ply:UsingRH() and "land" or "landgun"
			roll.animmodelstring = "new_climbanim"
			roll.usefullbody = true
		else
			land = false

			ply:SetSafetyRollAng(ang)
			ply:SetSafetyRollTime(CurTime() + 1.05)

			roll.AnimString = ply:UsingRH() and "meroll" or "merollgun"
			roll.animmodelstring = "new_climbanim"
			roll.usefullbody = false
		end

		if SERVER and not land then
			timer.Simple(0.2, function()
				ply:EmitSound("Cloth.Roll")
				ply:EmitSound("Cloth.BodyRollSwish")
			end)

			ply:EmitSound("Cloth.RollLand")
		elseif CLIENT and IsFirstTimePredicted() or game.SinglePlayer() then
			ply:EmitSound("Handsteps.ConcreteHard")
			ply:EmitSound("Land.Concrete")
		end

		if CLIENT and IsFirstTimePredicted() then
			if GetConVar("Beatrun_AnimSet"):GetInt() == 0 then
				roll.animmodelstring = "new_climbanim"
			else
				roll.animmodelstring = "old_climbanim"
			end

			CacheBodyAnim()
			RemoveBodyAnim()
			StartBodyAnim(roll)
			RollAnimCrouch(land, false)
		elseif game.SinglePlayer() then
			net.Start("RollAnimSP")
				net.WriteBool(land)
				net.WriteBool(false)
			net.Send(ply)
		end
	end
end)

if SERVER then
	local safelandents = {
		br_mat = true
	}

	hook.Add("GetFallDamage", "SafetyRoll", function(ply, speed)
		local groundent = ply:GetGroundEntity()

		if IsValid(groundent) and safelandents[groundent:GetClass()] then
			groundent:EmitSound("mirrorsedge/GameplayObjects/Landing_01.ogg", 80, 100 + math.random(-30, 10))

			return 0
		end

		if speed >= 800 and not ply:InOverdrive() and not ply:HasGodMode() then
			if speed < 800 and CurTime() < ply:GetSafetyRollKeyTime() and not ply:GetCrouchJump() and not ply:Crouching() then
				return 0
			else
				return math.huge
			end
		end

		return 0
	end)
end