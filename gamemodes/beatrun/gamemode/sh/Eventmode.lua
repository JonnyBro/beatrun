EPlayerStatus = {
    Member = {
        key = "Member",
        label_key = "#beatrun.eventmode.memberlabel",
        hud_key   = "#beatrun.eventmode.memberhud",
        color = Color(95, 245, 130)
    },
    Suspended = {
        key = "Suspended",
        label_key = "#beatrun.eventmode.suspendedlabel",
        hud_key   = "#beatrun.eventmode.suspendedhud",
        color = Color(255, 80, 80)
    },
    Manager = {
        key = "Manager",
        label_key = "#beatrun.eventmode.managerlabel",
        hud_key   = "#beatrun.eventmode.managerhud",
        color = Color(200, 200, 100)
    }
}

function GetStatusData(s)
    if not s then return EPlayerStatus.Member end

    if type(s) == "table" and s.key then return s end
    return EPlayerStatus[s] or EPlayerStatus.Member
end

if SERVER then
    util.AddNetworkString("Eventmode_Start")
    util.AddNetworkString("Eventmode_Sync")
    util.AddNetworkString("Eventmode_UpdatePlayerStatus")
    util.AddNetworkString("Eventmode_GlobalSettings")

    function SetPlayerEventStatus(ply, statusKey)
        if not IsValid(ply) then return end
        if not statusKey then statusKey = "Member" end

        ply:SetNW2String("EPlayerStatus", tostring(statusKey))

        net.Start("Eventmode_UpdatePlayerStatus")
            net.WriteEntity(ply)
            net.WriteString(tostring(statusKey))
        net.Broadcast()
    end

    local function FindPlayer(arg)
        if not arg then return nil end
        for _, p in ipairs(player.GetAll()) do
            if p:SteamID() == arg then return p end
        end
        local num = tonumber(arg)
        if num then
            for _, p in ipairs(player.GetAll()) do
                if p:UserID() == num or p:EntIndex() == num then return p end
            end
        end

        arg = string.lower(arg)
        for _, p in ipairs(player.GetAll()) do
            if string.find(string.lower(p:Nick()), arg, 1, true) then return p end
        end
        return nil
    end

    concommand.Add("Beatrun_Eventmode_Suspend", function(admin, cmd, args)
        if not IsValid(admin) or not admin:IsAdmin() then return end
        local tgt = FindPlayer(args[1])
        if not IsValid(tgt) then return end
        SetPlayerEventStatus(tgt, "Suspended")
    end)

    concommand.Add("Beatrun_Eventmode_Unsuspend", function(admin, cmd, args)
        if not IsValid(admin) or not admin:IsAdmin() then return end
        local tgt = FindPlayer(args[1])
        if not IsValid(tgt) then return end
        SetPlayerEventStatus(tgt, "Member")
    end)

    concommand.Add("Beatrun_Eventmode_SuspendAll", function(admin, cmd, args)
        if not IsValid(admin) or not admin:IsAdmin() then return end

        local count = 0
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:IsPlayer() then
                if not ply:IsAdmin() then
                    SetPlayerEventStatus(ply, "Suspended")
                    count = count + 1
                end
            end
        end
    end)

    concommand.Add("Beatrun_Eventmode_UnsuspendAll", function(admin, cmd, args)
        if not IsValid(admin) or not admin:IsAdmin() then return end

        local count = 0
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:IsPlayer() then
                if not ply:IsAdmin() then
                    SetPlayerEventStatus(ply, "Member")
                    count = count + 1
                end
            end
        end
    end)

    function Beatrun_StartEventmode()
        if GetGlobalBool("GM_EVENTMODE") then return end
        if Course_Name ~= "" then return end
        if player.GetCount() < 2 then return end
        
        SetGlobalBool("GM_EVENTMODE", true)

        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                SetPlayerEventStatus(ply, "Manager")
            else
                if GetGlobalBool("EM_NewPlayersSuspended") then
                    SetPlayerEventStatus(ply, "Suspended")
                else
                    SetPlayerEventStatus(ply, "Member")
                end
            end
        end

        net.Start("Eventmode_Start")
        net.Broadcast()
    end

    function Beatrun_StopEventmode()
        SetGlobalBool("GM_EVENTMODE", false)

        for _, ply in ipairs(player.GetAll()) do
            ply:SetNW2String("EPlayerStatus", "")
            net.Start("Eventmode_UpdatePlayerStatus")
                net.WriteEntity(ply)
                net.WriteString("")
            net.Broadcast()
        end
    end

    local function EventmodeSync(ply)
        if not GetGlobalBool("GM_EVENTMODE") then return end

        if ply:IsAdmin() then
            SetPlayerEventStatus(ply, "Manager")
        else
            local cur = ply:GetNW2String("EPlayerStatus", "")
            if cur == "" then
                if GetGlobalBool("EM_NewPlayersSuspended") then
                    SetPlayerEventStatus(ply, "Suspended")
                else
                    SetPlayerEventStatus(ply, "Member")
                end
            else
                net.Start("Eventmode_UpdatePlayerStatus")
                    net.WriteEntity(ply)
                    net.WriteString(cur)
                net.Send(ply)
            end
        end

        net.Start("Eventmode_Sync")
        net.Send(ply)
    end

    hook.Add("PlayerSpawn", "EventmodeSync", EventmodeSync)

    hook.Add("PlayerInitialSpawn", "EventMode_NewPlayerAssign", function(ply)
        if not GetGlobalBool("GM_EVENTMODE") then return end

        if ply:IsAdmin() then
            SetPlayerEventStatus(ply, "Manager")
        else
            if GetGlobalBool("EM_NewPlayersSuspended") then
                SetPlayerEventStatus(ply, "Suspended")
            else
                SetPlayerEventStatus(ply, "Member")
            end
        end
    end)

    hook.Add("PlayerDeath", "EventMode_AutoSuspend", function(victim)
        if not IsValid(victim) then return end
        if GetGlobalBool("GM_EVENTMODE") and GetGlobalBool("EM_SuspendOnDeath") then
            SetPlayerEventStatus(victim, "Suspended")
        end
    end)
end

if CLIENT then
    local function EventmodeHUD()
        if not GetGlobalBool("GM_EVENTMODE") then return end

        surface.SetFont("BeatrunHUD")
        local text = language.GetPhrase("#beatrun.eventmode.name")
        local tw, _ = surface.GetTextSize(text)

        surface.SetTextPos(ScrW() * 0.5 - tw * 0.5, ScrH() * 0.25)
        surface.SetTextColor(95, 245, 130)
        surface.DrawText(text)
    end
    hook.Add("HUDPaint", "EventmodeHUD", EventmodeHUD)

    local function EventmodeHUDName()
        if not GetGlobalBool("GM_EVENTMODE") then return end

        local ply = LocalPlayer()
        local statusKey = ply:GetNW2String("EPlayerStatus", "Member")
        local sdata = GetStatusData(statusKey)
        return language.GetPhrase(sdata.hud_key or "")
    end

    net.Receive("Eventmode_Start", function()
        hook.Add("BeatrunHUDCourse", "EventmodeHUDName", EventmodeHUDName)

        LocalPlayer():EmitSound("mirrorsedge/ui/ME_UI_hud_select.wav")
        chat.AddText(Color(95, 245, 130), language.GetPhrase("#beatrun.eventmode.start"))
    end)

    net.Receive("Eventmode_Sync", function()
        hook.Add("BeatrunHUDCourse", "EventmodeHUDName", EventmodeHUDName)
    end)

    net.Receive("Eventmode_UpdatePlayerStatus", function()
        local ply = net.ReadEntity()
        local st  = net.ReadString()
        if IsValid(ply) then
            ply.EPlayerStatus = st
            ply:SetNW2String("EPlayerStatus", st)
        end
    end)
end
