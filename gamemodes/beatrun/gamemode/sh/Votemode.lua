local voteDuration = 5
local cooldownDuration = 3

local validGamemodesMap = {
	["freeplay"] = "Freeplay",
	["fp"] = "Freeplay",
	["infection"] = "Infection",
	["infect"] = "Infection",
	["deathmatch"] = "Deathmatch",
	["dm"] = "Deathmatch",
	["data theft"] = "Data Theft",
	["dt"] = "Data Theft"
}

if CLIENT then
	local voteActive = false
	local voteText = ""
	local voteEndTime = 0
	local slide = 0
	local blur = Material("pp/blurscreen")
	local hoveredButton = nil
	local clickerActive = false
	local hasVoted = false
	local animProgress = 0

	local function DrawBlurRect(x, y, w, h, a)
		if render.GetDXLevel() < 90 then return end
		surface.SetDrawColor(255, 255, 255, a)
		surface.SetMaterial(blur)
		for i = 1, 2 do
			blur:SetFloat("$blur", i / 3 * 5)
			blur:Recompute()
			render.UpdateScreenEffectTexture()
			render.SetScissorRect(x, y, x + w, y + h, true)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			render.SetScissorRect(0, 0, 0, 0, false)
		end
	end

	local function pointInRect(mx, my, x, y, w, h)
		return mx >= x and mx <= x + w and my >= y and my <= y + h
	end

	local function VoteMenu_GetLayout()
		local sw, sh = ScrW(), ScrH()
		local w = sw * 0.15
		local h = sh * 0.09
		local x = sw - w * slide
		local y = sh * 0.5 - h * 0.5
		local titleH = 20
		local barH = 16
		local barW = w - 75.5
		local barX = x + 37.5
		local btnH = 34
		local btnMargin = 10
		local btnGap = 50
		local btnW = (w - 75 - btnGap) / 2
		local btnY = y + h - btnH - btnMargin

		local origTitleY = y + 10.5
		local origTitleBottom = origTitleY + titleH
		local origCenter = (origTitleBottom + btnY) / 2
		local origBarY = origCenter - barH / 2

		local menuCenterY = y + h / 2
		local spacing = 30
		local targetTitleY = menuCenterY - (titleH + spacing + barH) / 2
		local targetBarY = targetTitleY + titleH + spacing

		local titleY = Lerp(animProgress, origTitleY, targetTitleY)
		local barY = Lerp(animProgress, origBarY, targetBarY)

		local buttonTotalW = 2 * btnW + btnGap
		local yesX = x + (w - buttonTotalW) / 2
		local noX = yesX + btnW + btnGap
		return {
			x = x, y = y, w = w, h = h,
			titleY = titleY,
			barX = barX, barY = barY, barW = barW, barH = barH,
			btnY = btnY, btnW = btnW, btnH = btnH,
			yesX = yesX, noX = noX
		}
	end

	hook.Add("HUDPaint", "VoteMenu_Draw", function()
		if not voteActive then
			slide = Lerp(FrameTime() * 7, slide, 0)
			animProgress = Lerp(FrameTime() * 7, animProgress, 0)
			if slide < 0.5 then slide = 0 end
			if slide == 0 and clickerActive then
				gui.EnableScreenClicker(false)
				clickerActive = false
			end
			return
		end

		slide = Lerp(FrameTime() * 8, slide, 1)
		if hasVoted then
			animProgress = Lerp(FrameTime() * 5, animProgress, 1)
			if clickerActive then
				gui.EnableScreenClicker(false)
				clickerActive = false
			end
		end
		local L = VoteMenu_GetLayout()
		local x, y, w, h, titleY, barX, barY, barW, barH, btnY, btnW, btnH, yesX, noX = L.x, L.y, L.w, L.h, L.titleY, L.barX, L.barY, L.barW, L.barH, L.btnY, L.btnW, L.btnH, L.yesX, L.noX

		DrawBlurRect(x, y, w, h, 255)

		surface.SetDrawColor(0, 0, 0, 50)
		surface.DrawRect(x, y, w, h)
		surface.SetDrawColor(20, 20, 20, 100)
		surface.DrawOutlinedRect(x, y, w, h)
		surface.SetFont("BeatrunHUD")
		surface.SetTextColor(255, 255, 255)

		local ttW, ttH = surface.GetTextSize(voteText)

		surface.SetTextPos(x + w / 2 - ttW / 2, titleY)
		surface.DrawText(voteText)

		local timeLeft = math.max(0, voteEndTime - CurTime())
		local prog = math.Clamp(timeLeft / voteDuration, 0, 1)

		DrawBlurRect(barX, barY, barW, barH, 180)

		surface.SetDrawColor(20, 20, 20, 120)
		surface.DrawRect(barX, barY, barW, barH)
		surface.SetDrawColor(255, 255, 255, 200)
		surface.DrawRect(barX, barY, barW * prog, barH)

		if not hasVoted then
			local mx, my = gui.MousePos()

			if pointInRect(mx, my, yesX, btnY, btnW, btnH) then
				hoveredButton = "yes"
			elseif pointInRect(mx, my, noX, btnY, btnW, btnH) then
				hoveredButton = "no"
			else
				hoveredButton = nil
			end

			local function DrawButton(label, bx, id, colorHover)
				DrawBlurRect(bx, btnY, btnW, btnH, 200)
				surface.SetDrawColor(30, 30, 30, 130)
				surface.DrawRect(bx, btnY, btnW, btnH)
				if hoveredButton == id then
					surface.SetDrawColor(colorHover)
				else
					surface.SetDrawColor(255, 255, 255, 40)
				end
				surface.DrawOutlinedRect(bx, btnY, btnW, btnH)
				surface.SetFont("BeatrunHUDSmall")
				local tw, th = surface.GetTextSize(label)
				surface.SetTextPos(bx + btnW / 2 - tw / 2, btnY + btnH / 2 - th / 2)
				surface.DrawText(label)
			end

			DrawButton("YES", yesX, "yes", Color(70, 220, 90, 220))
			DrawButton("NO", noX, "no", Color(255, 70, 70, 220))
		end

		if timeLeft <= 0 then
			voteActive = false
			hasVoted = false
			animProgress = 0
		end
	end)

	hook.Add("GUIMousePressed", "VoteMenu_Mouse", function(mc)
		if mc ~= MOUSE_LEFT then return end
		if not voteActive then return end
		if hasVoted then return end

		local L = VoteMenu_GetLayout()
		local yesX, noX, btnY, btnW, btnH = L.yesX, L.noX, L.btnY, L.btnW, L.btnH
		local mx, my = gui.MousePos()

		if pointInRect(mx, my, yesX, btnY, btnW, btnH) then
			net.Start("VoteMenu_Response") net.WriteBool(true) net.SendToServer()
			hasVoted = true
			return
		end

		if pointInRect(mx, my, noX, btnY, btnW, btnH) then
			net.Start("VoteMenu_Response") net.WriteBool(false) net.SendToServer()
			hasVoted = true
			return
		end
	end)

	net.Receive("VoteMenu_Start", function()
		voteText = net.ReadString()
		voteEndTime = CurTime() + voteDuration
		voteActive = true
		hasVoted = false
		animProgress = 0
		clickerActive = true
		slide = 0
		gui.EnableScreenClicker(true)
	end)

	net.Receive("VoteMenu_Stop", function()
		voteActive = false
		hasVoted = false
		animProgress = 0
	end)

	net.Receive("VoteMenu_Sync", function()
		voteText = net.ReadString()
	end)
end

if SERVER then
	local gamemode = nil
	voteStarted = false

	local yesCount = 0
	nextVoteTime = 0
	local playersNeeded = 0
	local initiator = nil

	local voted = {}

	util.AddNetworkString("VoteMenu_Start")
	util.AddNetworkString("VoteMenu_Stop")
	util.AddNetworkString("VoteMenu_Sync")

	util.AddNetworkString("VoteMenu_Response")

	beatrunGamemodes = {
		"Freeplay",
		"fp",

		"Infection",
		"infect",

		"Deathmatch",
		"dm",

		"Data Theft",
		"dt"
	}

	function isValidGamemode(mode)
		mode = string.lower(mode)

		for _, v in ipairs(beatrunGamemodes) do
			if string.lower(v) == mode then return true end
		end

		return false
	end

	local function EndVote()
		if not voteStarted then return end

		voteStarted = false
		net.Start("VoteMenu_Stop")
		net.Broadcast()

		nextVoteTime = CurTime() + cooldownDuration
		local success = (yesCount >= playersNeeded)

		local str
		if success then
			str = "Vote successful! (" .. yesCount .. "/" .. playersNeeded .. ")\nStarting \"" .. gamemode .. "\"..."
			if GetGlobalBool("GM_DATATHEFT") then
				Beatrun_StopDataTheft()
			elseif GetGlobalBool("GM_INFECTION") then
				Beatrun_StopInfection()
			elseif GetGlobalBool("GM_DEATHMATCH") then
				Beatrun_StopDeathmatch()
			elseif GetGlobalBool("GM_EVENTMODE") then
				Beatrun_StopEventmode()
			end

			local lower = string.lower(gamemode)
			if lower == "infection" or lower == "infect" then
				if not GetGlobalBool("GM_INFECTION") then
					Beatrun_StartInfection()
				else
					Beatrun_StopInfection()
				end
			elseif lower == "deathmatch" or lower == "dm" then
				if not GetGlobalBool("GM_DEATHMATCH") then
					Beatrun_StartDeathmatch()
				else
					Beatrun_StopDeathmatch()
				end
			elseif lower == "data theft" or lower == "dt" then
				if not GetGlobalBool("GM_DATATHEFT") then
					Beatrun_StartDataTheft()
				else
					Beatrun_StopDataTheft()
				end
			end
		else
			str = "Vote failed! No one voted or not enough votes."
		end

		PrintMessage(HUD_PRINTTALK, str)
		print("[VoteMenu] " .. str)

		voted = {}
		yesCount = 0
		playersNeeded = 0
		gamemode = nil
		initiator = nil
	end

	function StartVote(gm, init_ply)
		if GetGlobalBool("GM_EVENTMODE") then return end
		if voteStarted then return end
		if CurTime() < nextVoteTime then return end
		if not isstring(gm) or gm == "" then return end

		local lower = string.lower(gm)
		if not validGamemodesMap[lower] then return end

		gamemode = validGamemodesMap[lower]
		initiator = init_ply

		voted = {}
		yesCount = 0
		playersNeeded = math.ceil(#player.GetAll() / 2)

		if playersNeeded < 1 then playersNeeded = 1 end

		net.Start("VoteMenu_Start")
			net.WriteString(gamemode .. " (" .. yesCount .. "/" .. playersNeeded ..")")
		net.Broadcast()

		voteStarted = true

		timer.Simple(voteDuration, function()
			if voteStarted then
				EndVote()
			end
		end)
	end

	net.Receive("VoteMenu_Response", function(len, ply)
		if not voteStarted then return end
		if not IsValid(ply) then return end
		local steamID = ply:SteamID()
		if voted[steamID] then return end
		voted[steamID] = true
		local yes = net.ReadBool()
		if yes then
			yesCount = yesCount + 1
			net.Start("VoteMenu_Sync")
				net.WriteString(gamemode .. " (" .. yesCount .. "/" .. playersNeeded ..")")
			net.Broadcast()
		end
	end)

	hook.Add("PlayerDisconnected", "VoteMenu_HandleDisconnect", function(ply)
		if not voteStarted then return end
		local steamID = ply:SteamID()
		if voted[steamID] then
			voted[steamID] = nil
		end
	end)
end