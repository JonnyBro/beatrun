EPlayerStatus = {
	Member = {
		key = "Member",
		label_key = "#beatrun.eventmode.memberlabel",
		hud_key = "#beatrun.eventmode.memberhud",
		color = Color(95, 245, 130)
	},
	Suspended = {
		key = "Suspended",
		label_key = "#beatrun.eventmode.suspendedlabel",
		hud_key = "#beatrun.eventmode.suspendedhud",
		color = Color(255, 80, 80)
	},
	Manager = {
		key = "Manager",
		label_key = "#beatrun.eventmode.managerlabel",
		hud_key = "#beatrun.eventmode.managerhud",
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
	util.AddNetworkString("Eventmode_SetGoal")

	util.AddNetworkString("Eventmode_Suspend")
	util.AddNetworkString("Eventmode_Manager")
	util.AddNetworkString("Eventmode_Unsuspend")
	util.AddNetworkString("Eventmode_SuspendAll")
	util.AddNetworkString("Eventmode_UnsuspendAll")

	if ULib and ulx then
		local BLOCKED_IN_EVENTMODE = {
			["ulx votemap"] = true,
			["ulx votemap2"] = true,
			["ulx votekick"] = true,
			["ulx voteban"] = true
		}

		hook.Add("ULibCommandCalled", "Eventmode_BlockULXCommands", function(ply, cmd, args)
			if not GetGlobalBool("GM_EVENTMODE") then return end
			if BLOCKED_IN_EVENTMODE[cmd] then
				if IsValid(ply) then
					ply:ChatPrint("[Eventmode] '" .. cmd .. "' IS DISABLED.")
				end
				return false
			end
		end)
	end

	function SetPlayerEventStatus(ply, statusKey)
		if not IsValid(ply) then return end
		if not statusKey then statusKey = "Member" end

		ply:SetNW2String("EPlayerStatus", tostring(statusKey))

		net.Start("Eventmode_UpdatePlayerStatus")
			net.WriteEntity(ply)
			net.WriteString(tostring(statusKey))
		net.Broadcast()
	end

	net.Receive("Eventmode_Suspend", function(_, admin)
		if not IsValid(admin) or not admin:IsAdmin() then return end
		local ply = net.ReadEntity()
		if IsValid(ply) then SetPlayerEventStatus(ply, "Suspended") end
	end)

	net.Receive("Eventmode_Unsuspend", function(_, admin)
		if not IsValid(admin) or not admin:IsAdmin() then return end
		local ply = net.ReadEntity()
		if IsValid(ply) then SetPlayerEventStatus(ply, "Member") end
	end)

	net.Receive("Eventmode_Manager", function(_, admin)
		if not IsValid(admin) or not admin:IsAdmin() then return end
		local ply = net.ReadEntity()
		if IsValid(ply) and ply:IsAdmin() then SetPlayerEventStatus(ply, "Manager") end
	end)

	net.Receive("Eventmode_SuspendAll", function(_, admin)
		if not IsValid(admin) or not admin:IsAdmin() then return end
		for _, ply in ipairs(player.GetAll()) do
			if ply:GetNW2String("EPlayerStatus") ~= "Manager" then
				SetPlayerEventStatus(ply, "Suspended")
			end
		end
	end)

	net.Receive("Eventmode_UnsuspendAll", function(_, admin)
		if not IsValid(admin) or not admin:IsAdmin() then return end
		for _, ply in ipairs(player.GetAll()) do
			if ply:GetNW2String("EPlayerStatus") ~= "Manager" then
				SetPlayerEventStatus(ply, "Member")
			end
		end
	end)

	function Beatrun_StartEventmode(manager)
		if GetGlobalBool("GM_EVENTMODE") then return end
		if Course_Name ~= "" then return end
		if player.GetCount() < 2 then return end

		SetGlobalBool("GM_EVENTMODE", true)

		local specificManager = IsValid(manager) and manager:IsPlayer() and manager or nil

		for _, ply in ipairs(player.GetAll()) do
			if specificManager then
				if ply == specificManager then
					SetPlayerEventStatus(ply, "Manager")
				else
					if GetGlobalBool("EM_NewPlayersSuspended") then
						SetPlayerEventStatus(ply, "Suspended")
					else
						SetPlayerEventStatus(ply, "Member")
					end
				end
			else
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
		end

		net.Start("Eventmode_Start")
		net.Broadcast()
	end

	function Beatrun_StopEventmode()
		SetGlobalBool("GM_EVENTMODE", false)
		SetGlobalBool("EM_SuspendOnDeath", false)
		SetGlobalBool("EM_NewPlayersSuspended", false)
		SetGlobalBool("EM_AllowProps", false)
		SetGlobalBool("EM_AllowWeapons", false)
		SetGlobalBool("EM_HideNametags", false)
		SetGlobalBool("EM_NoMeleeDamage", false)

		game.CleanUpMap()

		net.Start("Eventmode_SetGoal")
			net.WriteString("")
		net.Broadcast()

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

		if ply:GetNW2String("EPlayerStatus", "Member") == "Manager" then return end

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

		net.Start("Eventmode_Sync")
		net.Send(ply)
	end

	hook.Add("PlayerSpawn", "EventmodeSync", EventmodeSync)

	hook.Add("PlayerInitialSpawn", "EventMode_NewPlayerAssign", function(ply)
		if not GetGlobalBool("GM_EVENTMODE") then return end

		if ply:GetNW2String("EPlayerStatus", "Member") == "Manager" then return end

		if GetGlobalBool("EM_NewPlayersSuspended") then
			SetPlayerEventStatus(ply, "Suspended")
		else
			SetPlayerEventStatus(ply, "Member")
		end
	end)

	hook.Add("CanPlayerSuicide", "EventMode_AllowSuicide", function(ply)
		if GetGlobalBool("GM_EVENTMODE") then
			return false
		end
	end)

	hook.Add("PlayerDeath", "EventMode_AutoSuspend", function(victim)
		if not IsValid(victim) then return end
		if victim:GetNW2String("EPlayerStatus", "Member") == "Manager" then return end
		if GetGlobalBool("GM_EVENTMODE") and GetGlobalBool("EM_SuspendOnDeath") then
			SetPlayerEventStatus(victim, "Suspended")
		end
	end)
end

if CLIENT then
	local goal = nil

	local function EventmodeHUD()
		if not GetGlobalBool("GM_EVENTMODE") then return end

		surface.SetFont("BeatrunHUD")

		local text = goal or language.GetPhrase("beatrun.eventmode.name")
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

		chat.AddText(Color(95, 245, 130), language.GetPhrase("beatrun.eventmode.start"))
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

		if allply then
			allply = player.GetAll()
			table.sort(allply, sortleaderboard)
			allplytimer = 0
		end
	end)

	net.Receive("Eventmode_SetGoal", function()
		local st = net.ReadString()
		local lp = LocalPlayer()

		if st ~= "" then
			lp:EmitSound("mirrorsedge/ui/ME_UI_hud_select.wav")
			goal = st
		else
			goal = nil
		end
	end)
end
