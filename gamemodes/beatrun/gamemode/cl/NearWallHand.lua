local WallBrace = CreateClientConVar("Beatrun_WallBrace", "1", true, false, "", 0, 1)
local IsPlyInStandWall = false

local standWallAnims = {
    standhandwallright = true,
    standhandwallleft = true,
    standhandwallboth = true,
    standhandwallrightdown = true,
    standhandwallleftdown = true,
    standhandwallbothdown = true
}

local down = Vector(0, 0, -3)

local nextWallCheck = 0

hook.Add("Tick", "HandStandWall", function()
    if not WallBrace:GetBool() then return end

    if nextWallCheck > CurTime() then return end -- lets not spam checks
    nextWallCheck = CurTime() + 0.03 -- ~33 hz should be fast enough

    local ply = LocalPlayer()
    local bac = BodyAnimArmCopy
    local bac_seq = IsValid(bac) and bac:GetSequenceName(bac:GetSequence()) or ""
    if not IsValid(ply) or ply:GetMelee() ~= 0 or (ArmInterrupting(bac) and not standWallAnims[bac_seq]) or ply:GetSafetyRollTime() > CurTime() or (ply:GetDive() or ply:GetDiveSliding() or string.StartsWith(BodyAnimString, "diveslideend")) then IsPlyInStandWall = false return end

    local rh = ply:GetActiveWeapon()

    if not ply:OnGround() or not ply:UsingRH() or ply:GetWallrun() ~= 0 or ply:GetClimbing() ~= 0 or (rh.GetSideStep and rh:GetSideStep()) then
        IsPlyInStandWall = false

        if standWallAnims[bac_seq] then
            bac:SetCycle(1) -- no time to play the down animations
        end

        return
    end

    local traceDir = ply:EyeAngles()
    traceDir.z = 0
    traceDir.x = 0

    local lenght = 22.5 -- this is the shortest lenght that works well with corners

    local hand_offset =  traceDir:Right() * 5.5
    traceDir = traceDir:Forward()

    local leftHand_trace = util.QuickTrace(ply:GetShootPos() - hand_offset + down, traceDir * lenght, ply)
    local rightHand_trace = util.QuickTrace(ply:GetShootPos() + hand_offset + down, traceDir * lenght, ply)

    if (leftHand_trace.Hit or rightHand_trace.Hit) and not (ply:KeyDown(IN_BACK) and ply:GetVelocity():Length() > 10) and ply:WaterLevel() <= 1 then --TODO: figure out how to get if the player is moving backwards with only the velocity (dont rely on keydown)
        IsPlyInStandWall = true
        BodyLimitX = 10

        if leftHand_trace.Hit and rightHand_trace.Hit then
            ArmInterrupt("standhandwallboth")
        elseif rightHand_trace.Hit then
            ArmInterrupt("standhandwallright")
        else
            ArmInterrupt("standhandwallleft")
        end
    elseif IsPlyInStandWall then
        if standWallAnims[bac_seq] then
            ArmInterrupt(bac_seq .. "down")
        end
        IsPlyInStandWall = false
    end

    if standWallAnims[bac_seq] and not IsPlyInStandWall then
        BodyLimitX = 45
    end
end)

hook.Add("AdjustMouseSensitivity", "HandStandWallSense", function()
    if IsPlyInStandWall then
        return 0.65
    end
end)

hook.Add("CreateMove", "HandStandWallBlockAttack", function(cmd)
    if IsValid(BodyAnimArmCopy) and standWallAnims[BodyAnimArmCopy:GetSequenceName(BodyAnimArmCopy:GetSequence())] and not LocalPlayer():ShouldDrawLocalPlayer() then -- we check for shoulddrawlocalplayer because arminterrupts stop playing in thirdperson and become stuck :)
        cmd:RemoveKey(IN_ATTACK)
    end
end)