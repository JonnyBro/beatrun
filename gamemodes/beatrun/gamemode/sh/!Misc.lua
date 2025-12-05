local allowPropSpawn    = CreateConVar("Beatrun_AllowPropSpawn", "0", {FCVAR_ARCHIVE})
local allowWeaponSpawn  = CreateConVar("Beatrun_AllowWeaponSpawn", "0", {FCVAR_ARCHIVE})

if SERVER then
    util.AddNetworkString("SPParkourEvent")

    local weaponEvents = {
        "PlayerGiveSWEP",
        "PlayerSpawnSWEP"
    }

    local blockedNonPropEvents = {
        "PlayerSpawnEffect",
        "PlayerSpawnNPC",
        "PlayerSpawnObject",
        "PlayerSpawnRagdoll",
        "PlayerSpawnSENT",
        "PlayerSpawnVehicle"
    }

    local allowedPropEvent = "PlayerSpawnProp"

    local function CanPlayerSpawnProps(ply)
        if game.SinglePlayer() or (IsValid(ply) and ply:IsAdmin()) then return true end

        if GetGlobalBool("GM_EVENTMODE", false) and ply:GetNW2String("EPlayerStatus") ~= "Suspended" then
            return GetGlobalBool("EM_AllowProps", false)
        end

        return allowPropSpawn:GetBool()
    end

    local function CanPlayerSpawnWeapons(ply)
        if game.SinglePlayer() or (IsValid(ply) and ply:IsAdmin()) then return true end

        if GetGlobalBool("GM_EVENTMODE", false) and ply:GetNW2String("EPlayerStatus") ~= "Suspended" then
            return GetGlobalBool("EM_AllowWeapons", false)
        end

        return allowWeaponSpawn:GetBool()
    end

    local function BlockSpawnProp(ply, ...)
        if CanPlayerSpawnProps(ply) then return true end
        return false
    end

    local function BlockSpawnWeapon(ply, ...)
        if CanPlayerSpawnWeapons(ply) then return true end
        return false
    end

    local function BlockNonPropSpawn(ply, ...)
        if game.SinglePlayer() or (IsValid(ply) and ply:IsAdmin()) then return true end
        return false
    end

    for _, ev in ipairs(weaponEvents) do
        hook.Add(ev, "Beatrun_BlockSpawn_Weapon_" .. ev, BlockSpawnWeapon)
    end

    hook.Add(allowedPropEvent, "Beatrun_BlockSpawn_Prop_" .. allowedPropEvent, BlockSpawnProp)

    for _, ev in ipairs(blockedNonPropEvents) do
        hook.Add(ev, "Beatrun_BlockSpawn_NonProp_" .. ev, BlockNonPropSpawn)
    end

    hook.Add("IsSpawnpointSuitable", "Beatrun_NoSpawnFrag", function(ply) return true end)

    hook.Add("AllowPlayerPickup", "Beatrun_AllowAdminsPickUp", function(ply, ent)
        if IsValid(ply) and ply:IsAdmin() then return true end
    end)
end

if CLIENT then
	CreateClientConVar("Beatrun_FOV", 100, true, true, language.GetPhrase("beatrun.convars.fov"), 70, 120)
	CreateClientConVar("Beatrun_CPSave", 1, true, true, language.GetPhrase("beatrun.convars.cpsave"), 0, 1)
end

if ulx and ulx.noclip then
	local oldUlxNoclip = ulx.noclip

	function ulx.beatrun_noclip(calling_ply, target_plys)
		for i = 1, #target_plys do
			local ply = target_plys[i]
			if ply:IsValid() then
				if Course_Name ~= "" and ply:GetNW2Int("CPNum", 1) ~= -1 then
					ply:SetNW2Int("CPNum", -1)

					ULib.tsayError(ply, "Noclip Detected! Respawn to restart the course")
				end
			end
		end

		oldUlxNoclip(calling_ply, target_plys)
	end

	local noclip = ulx.command("Utility", "ulx noclip", ulx.beatrun_noclip, "!noclip")
	noclip:addParam{
		type = ULib.cmds.PlayersArg,
		ULib.cmds.optional
	}

	noclip:defaultAccess(ULib.ACCESS_ADMIN)
	noclip:help("Toggles noclip on target(s).")
end

hook.Add("PlayerNoClip", "BlockNoClip", function(ply, enabled)
	if enabled and Course_Name ~= "" and ply:GetNW2Int("CPNum", 1) ~= -1 then
		ply:SetNW2Int("CPNum", -1)

		if CLIENT and IsFirstTimePredicted() then
			notification.AddLegacy(language.GetPhrase("beatrun.misc.noclipdetected"), NOTIFY_ERROR, 4)
		elseif SERVER and game.SinglePlayer() then
			ply:SendLua("notification.AddLegacy(\"#beatrun.misc.noclipdetected\", NOTIFY_ERROR, 4)")
		end
	end

	if enabled and (GetGlobalBool("GM_INFECTION") or GetGlobalBool("GM_DATATHEFT") or GetGlobalBool("GM_DEATHMATCH")) then return false end
end)

function ParkourEvent(event, ply, ignorepred)
	if IsFirstTimePredicted() or ignorepred then
		hook.Run("OnParkour", event, ply or CLIENT and LocalPlayer())

		if game.SinglePlayer() and SERVER then
			net.Start("SPParkourEvent")
				net.WriteString(event)
			net.Broadcast()
		end
	end
end

hook.Add("SetupMove", "JumpDetect", function(ply, mv, cmd)
	if ply:OnGround() and not ply:GetWasOnGround() and mv:GetVelocity():Length() > 50 and ply:GetMEMoveLimit() < 375 then
		local vel = mv:GetVelocity()
		vel.z = 0

		ply:SetMEMoveLimit(math.max(vel:Length(), 150))

		if ply:GetMESprintDelay() < 0 then
			ply:SetMEMoveLimit(350)
			ply:SetMESprintDelay(0)
		end

		ply.QuakeJumping = false

		if game.SinglePlayer() then
			ply:SendLua("LocalPlayer().QuakeJumping = false")
		end
	end

	if ply:UsingRH() then
		ply:SetWasOnGround(ply:OnGround())

		return
	end

	local ismoving = mv:GetVelocity():Length() > 100 and not mv:KeyDown(IN_BACK) and not ply:Crouching() and not mv:KeyDown(IN_DUCK)
	local eyeang = cmd:GetViewAngles()
	local eyeangx = eyeang.x
	eyeang.x = 0
	eyeang.z = 0

	if not ply:OnGround() and ply:GetWasOnGround() and not ply:GetJumpTurn() then
		if ismoving and mv:GetVelocity().z > 50 then
			ply:ViewPunch(Angle(-2, 0, 0))

			if not util.QuickTrace(mv:GetOrigin() + eyeang:Forward() * 200, Vector(0, 0, -100), ply).Hit then
				ParkourEvent("jumpfar", ply)
			else
				ParkourEvent("jump", ply)
			end
		elseif ply:GetSafetyRollKeyTime() <= CurTime() and ply:GetSafetyRollTime() <= CurTime() then
			ParkourEvent("fall", ply)
		end
	end

	if not ply:GetSliding() and not ply:GetJumpTurn() and not ply:Crouching() then
		ply:SetCurrentViewOffset(Vector(0, 0, 64) + eyeang:Forward() * math.Clamp(eyeangx * 0.177, 0, 90))
	end

	ply:SetWasOnGround(ply:OnGround())
end)

hook.Add("CanProperty", "BlockProperty", function(ply)
	if not ply:IsAdmin() then return false end
end)

hook.Add("CanDrive", "BlockDrive", function(ply)
	if not ply:IsAdmin() then return false end
end)

if CLIENT and game.SinglePlayer() then
	net.Receive("SPParkourEvent", function()
		local event = net.ReadString()

		hook.Run("OnParkour", event, LocalPlayer())
	end)
end

if CLIENT then
	local blur = Material("pp/blurscreen")

	function draw_blur(a, d)
		if render.GetDXLevel() < 90 then return end

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(blur)

		for i = 1, d do
			blur:SetFloat("$blur", i / d * a)
			blur:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end
	end

	local draw_blur = draw_blur
	local impactblurlerp = 0
	-- local lastintensity = 0

	hook.Add("HUDPaint", "DrawImpactBlur", function()
		if impactblurlerp > 0 then
			impactblurlerp = math.Approach(impactblurlerp, 0, 25 * FrameTime())
			draw_blur(math.min(impactblurlerp, 10), 4)
		end
	end)

	function DoImpactBlur(intensity)
		impactblurlerp = intensity
		lastintensity = intensity
	end
end
