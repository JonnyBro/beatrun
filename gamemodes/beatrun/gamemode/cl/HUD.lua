local show_total_xp = CreateClientConVar("Beatrun_HUDXP", "1", true, false, language.GetPhrase("beatrun.convars.hudxp"), 0, 1)
local sway = CreateClientConVar("Beatrun_HUDSway", "1", true, false, language.GetPhrase("beatrun.convars.hudsway"), 0, 1)
local dynamic = CreateClientConVar("Beatrun_HUDDynamic", "0", true, false, language.GetPhrase("beatrun.convars.huddynamic"), 0, 1)
local hidden = CreateClientConVar("Beatrun_HUDHidden", "0", true, false, language.GetPhrase("beatrun.convars.hudhidden"), 0, 2)
local verificationstats = CreateClientConVar("Beatrun_HUDVerification", "0", true, false, "", 0, 1)
-- local reticle = CreateClientConVar("Beatrun_HUDReticle", "1", true, false, language.GetPhrase("beatrun.convars.hudreticle"), 0, 1)

CreateClientConVar("Beatrun_HUDTextColor", "255 255 255 255", true, true, language.GetPhrase("beatrun.convars.hudtextcolor"))
CreateClientConVar("Beatrun_HUDCornerColor", "20 20 20 100", true, true, language.GetPhrase("beatrun.convars.hudcornercolor"))
CreateClientConVar("Beatrun_HUDFloatingXPColor", "255 255 255 255", true, true, language.GetPhrase("beatrun.convars.hudfloatxpcolor"))

local packetloss = Material("vgui/packetloss.png")
local lastloss = 0
local MELogo = Material("vgui/MELogo.png", "mips smooth")

local hide = {
	CHudBattery = true,
	CHudHealth = true,
	CHudDamageIndicator = true
}

local inf = math.huge

hook.Add("HUDShouldDraw", "BeatrunHUDHide", function(name)
	if hide[name] then return false end
end)

local color = 1
local tab = {
	["$pp_colour_contrast"] = 1,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_addr"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_colour"] = color
}

hook.Add("RenderScreenspaceEffects", "BeatrunNoclipBW", function()
	if render.GetDXLevel() < 90 then return end

	local ply = LocalPlayer()
	local inp = color ~= 1
	local noclipping = ply:GetMoveType() == MOVETYPE_NOCLIP and not BuildMode and ply:GetMantle() == 0 and ply:GetClimbing() == 0 and not IsValid(ply:GetLadder()) and not ply:InVehicle()

	if noclipping or inp then
		tab["$pp_colour_colour"] = color
		DrawColorModify(tab)
	end

	if noclipping then
		color = math.Approach(color, 0.5, RealFrameTime())
	elseif inp then
		color = math.Approach(color, 1, RealFrameTime() * 2)
	end

	if ply:Health() < 100 then
		tab["$pp_colour_colour"] = math.max(ply:Health() / ply:GetMaxHealth(), 0)
		DrawColorModify(tab)
	end
end)

surface.CreateFont("BeatrunHUD", {
	shadow = true,
	blursize = 0,
	underline = false,
	rotary = false,
	strikeout = false,
	additive = false,
	antialias = false,
	extended = false,
	scanlines = 2,
	font = "x14y24pxHeadUpDaisy",
	italic = false,
	outline = false,
	symbol = false,
	weight = 500,
	size = ScreenScale(7)
})

surface.CreateFont("BeatrunHUDSmall", {
	shadow = true,
	blursize = 0,
	underline = false,
	rotary = false,
	strikeout = false,
	additive = false,
	antialias = false,
	extended = false,
	scanlines = 2,
	font = "x14y24pxHeadUpDaisy",
	italic = false,
	outline = false,
	symbol = false,
	weight = 500,
	size = ScreenScale(6)
})

local blur = Material("pp/blurscreen")

local function DrawBlurRect(x, y, w, h, a)
	if render.GetDXLevel() < 90 then return end

	local X = 0
	local Y = 0

	surface.SetDrawColor(255, 255, 255, a)
	surface.SetMaterial(blur)

	for i = 1, 2 do
		blur:SetFloat("$blur", i / 3 * 5)
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		render.SetScissorRect(x, y, x + w, y + h, true)

		surface.DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH())

		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

local hidealpha = 0

local function BeatrunHUD()
	local ply = LocalPlayer()
	local scrw = ScrW()
	local scrh = ScrH()

	surface.SetFont("DebugFixedSmall")

	local version_text = "v" .. installedVersion
	local tw, _ = surface.GetTextSize(version_text)
	surface.SetTextColor(255, 255, 255, 20)
	surface.SetTextPos(scrw - tw, 0)
	surface.DrawText(version_text)
	surface.SetFont("BeatrunHUD")

	if installedVersion ~= latestVersion then
		local update_text = "Update available!"
		local notlatest_w, _ = surface.GetTextSize(update_text)
		surface.SetTextColor(255, 255, 255, 30)
		surface.SetTextPos(scrw - notlatest_w, 10)
		surface.DrawText(update_text)
		surface.SetFont("BeatrunHUD")
	end

	local pl = ply:GetNW2Int("PLoss")
	local CT = CurTime()

	if pl > 10 or CT < lastloss then
		local alpha = math.Clamp(math.abs(math.sin(CurTime() * 4) * 255), 25, 255)

		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetMaterial(packetloss)
		surface.DrawTexturedRect(5, 5, 58.75, 41.75)
		surface.SetTextPos(65, 20)
		surface.SetTextColor(255, 195, 90, alpha)
		surface.DrawText(pl)

		if pl > 10 then
			lastloss = CT + 4
		end
	end

	if BuildMode then return end
	if hidden:GetInt() > 1 then return end

	local shoulddraw = hook.Run("BeatrunDrawHUD")

	if shoulddraw == false then return end

	local vp = ply:GetViewPunchAngles()

	if not sway:GetBool() then
		vp.x = 0
		vp.z = 0
	end

	local coursename = nil
	local customname = hook.Run("BeatrunHUDCourse")
	coursename = customname and customname or Course_Name ~= "" and language.GetPhrase("beatrun.hud.course"):format(Course_Name) or "#beatrun.hud.freeplay"
	-- local lastxp = ply.LastXP or 0
	local nicktext = nil

	if show_total_xp:GetBool() then
		nicktext = ply:Nick() .. " | " .. ply:GetXP() .. "XP"
	else
		nicktext = ply:Nick()
	end

	surface.SetFont("BeatrunHUDSmall")

	local nickw, nickh = surface.GetTextSize(nicktext)

	surface.SetFont("BeatrunHUD")

	local coursew, _ = surface.GetTextSize(coursename)
	local bgpadw = nickw
	-- local bgpadh = nickh

	if bgpadw < coursew then
		bgpadw = coursew
	end

	local bgpadding = bgpadw > 200 and bgpadw + 40 or 200

	if not hidden:GetBool() then
		if dynamic:GetBool() then
			hidealpha = math.Approach(hidealpha, 150 * ply:GetVelocity():Length() / 250, 100 * RealFrameTime())
		else
			hidealpha = 0
		end

		local corner_color_c = string.ToColor(ply:GetInfo("Beatrun_HUDCornerColor"))
		corner_color_c.a = math.Clamp(corner_color_c.a + 50, 0, 255)
		corner_color_c.a = dynamic:GetBool() and math.max(150 - hidealpha, 50) or corner_color_c.a

		surface.SetDrawColor(corner_color_c)
		surface.DrawRect(-20 + vp.z, scrh * 0.895 + vp.x, 40, SScaleY(85))

		DrawBlurRect(20 + vp.z, scrh * 0.895 + vp.x, SScaleX(bgpadding), SScaleY(85), math.max(255 - hidealpha, 2))

		local corner_color = string.ToColor(ply:GetInfo("Beatrun_HUDCornerColor"))
		corner_color.a = dynamic:GetBool() and math.max(100 - hidealpha, 50) or corner_color.a

		local text_color = string.ToColor(ply:GetInfo("Beatrun_HUDTextColor"))
		text_color.a = dynamic:GetBool() and math.max(255 - hidealpha, 2) or text_color.a

		surface.SetDrawColor(corner_color)
		surface.DrawOutlinedRect(20 + vp.z, scrh * 0.895 + vp.x, SScaleX(bgpadding), SScaleY(85))
		surface.SetFont("BeatrunHUD")
		surface.SetTextColor(text_color)
		surface.SetTextPos(scrw * 0.015 + vp.z, scrh * 0.9 + vp.x)
		surface.DrawText(language.GetPhrase("beatrun.hud.lvl"):format(ply:GetLevel()))

		local kickGlitchText = ""
		if ply:GetInfo("Beatrun_KickGlitch") == "1" then
			kickGlitchText = "Off"
		elseif ply:GetInfo("Beatrun_KickGlitch") == "2" then
			kickGlitchText = "Old"
		elseif ply:GetInfo("Beatrun_KickGlitch") == "3" then
			kickGlitchText = "New"
		end

		if verificationstats:GetBool() then
			surface.SetTextPos(scrw * 0.015 + vp.z, scrh * 0.02 + vp.x)
			surface.DrawText("Purist: ")
			surface.DrawText(ply:GetInfo("Beatrun_PuristMode") == "1" and "true" or "false")
			surface.SetTextPos(scrw * 0.015 + vp.z, scrh * 0.04 + vp.x)
			surface.DrawText("Purist Wallrun: ")
			surface.DrawText(ply:GetInfo("Beatrun_PuristWallrun") == "1" and "true" or "false")
			surface.SetTextPos(scrw * 0.015 + vp.z, scrh * 0.06 + vp.x)
			surface.DrawText("Kick Glitch: ")
			surface.DrawText(kickGlitchText)
		end

		if tobool(ply:GetInfo("Beatrun_PuristMode")) then
			surface.SetDrawColor(230, 230, 230)
			surface.SetMaterial(MELogo)
			surface.DrawTexturedRect(scrw * 0.00125 + vp.z, scrh * 0.9 + vp.x + SScaleY(16) * 0.25, SScaleX(16), SScaleY(16))
		else
			surface.SetTextPos(scrw * 0.002 + vp.z, scrh * 0.9 + vp.x)
			surface.DrawText("★")
		end

		surface.SetFont("BeatrunHUDSmall")
		surface.SetTextPos(scrw * 0.015 + vp.z, scrh * 0.92 + vp.x)
		surface.DrawText(nicktext)
		surface.SetDrawColor(25, 25, 25, math.max(255 - hidealpha, 2))
		surface.DrawRect(scrw * 0.015 + vp.z, scrh * 0.94 + 1 + vp.x, SScaleX(150), SScaleY(4))
		surface.SetDrawColor(string.ToColor(ply:GetInfo("Beatrun_HUDTextColor")), math.max(255 - hidealpha, 2))
		surface.DrawRect(scrw * 0.015 + vp.z, scrh * 0.94 + vp.x, SScaleX(150 * math.min(ply:GetLevelRatio(), 1)), SScaleY(5))

		for k, v in pairs(XP_floatingxp) do
			local floating_color = string.ToColor(ply:GetInfo("Beatrun_HUDFloatingXPColor"))
			floating_color.a = math.Clamp(1000 * math.abs(CurTime() - k) / 5 - hidealpha, 0, 255)

			surface.SetFont("BeatrunHUD")
			surface.SetTextColor(floating_color)
			surface.SetTextPos(scrw * 0.015 + vp.z + nickw + 3, scrh * 0.92 + vp.x + nickh - 42 + 50 * math.abs(CurTime() - k) / 5)
			surface.DrawText(v)

			if k < CurTime() then
				XP_floatingxp[k] = nil
			end
		end
	end

	local text_color_c = string.ToColor(ply:GetInfo("Beatrun_HUDTextColor"))
	text_color_c.a = text_color_c.a - 55
	text_color_c.a = dynamic:GetBool() and math.max(200 - hidealpha, 2) or text_color_c.a

	surface.SetFont("BeatrunHUD")
	surface.SetTextColor(text_color_c)
	surface.SetTextPos(scrw * 0.015 + vp.z, scrh * 0.95 + vp.x)
	surface.DrawText(coursename)
end

local allply = nil
local allplytimer = 0
local niltime = "--:--:--"
local placecolors = {
	Color(255, 215, 0),
	Color(192, 192, 192),
	Color(205, 127, 50)
}
local infectorcolor = Color(200, 25, 25)

local function sortleaderboard(a, b)
	local atime = a:GetNW2Float("PBTime")
	local btime = b:GetNW2Float("PBTime")

	if GetGlobalBool("GM_INFECTION") then
		if atime == 0 then
			atime = -1
		end

		if btime == 0 then
			btime = -1
		end

		return atime > btime
	elseif GetGlobalBool("GM_DATATHEFT") then
		atime = a:GetNW2Int("DataBanked", 0)
		btime = b:GetNW2Int("DataBanked", 0)

		if atime == 0 then
			atime = -1
		end

		if btime == 0 then
			btime = -1
		end

		return atime > btime
	elseif GetGlobalBool("GM_DEATHMATCH") then
		atime = a:GetNW2Int("DeathmatchKills", 0)
		btime = b:GetNW2Int("DeathmatchKills", 0)

		if atime == 0 then
			atime = -1
		end

		if btime == 0 then
			btime = -1
		end

		return atime > btime
	else
		if atime == 0 then
			atime = inf
		end

		if btime == 0 then
			btime = inf
		end

		return atime < btime
	end
end

function BeatrunLeaderboard(forced)
	if not forced and Course_Name == "" and not GetGlobalBool("GM_INFECTION") and not GetGlobalBool("GM_DATATHEFT") and not GetGlobalBool("GM_DEATHMATCH") then return end

	local isinfection = GetGlobalBool("GM_INFECTION")
	local isdatatheft = GetGlobalBool("GM_DATATHEFT")
	local isdeathmatch = GetGlobalBool("GM_DEATHMATCH")
	local ply = LocalPlayer()
	local vp = ply:GetViewPunchAngles()
	local scrh = ScrH()

	if not sway:GetBool() then
		vp.x = 0
		vp.z = 0
	end

	allply = allply or player.GetAll()

	if allplytimer < CurTime() then
		allply = player.GetAll()
		allplytimer = CurTime() + 5
		table.sort(allply, sortleaderboard)
	end

	local allplycount = #allply + 1

	surface.SetDrawColor(20, 20, 20, math.max(150 - hidealpha, 50))
	surface.DrawRect(-20 + vp.z, scrh * 0.2 + vp.x, 40, SScaleY(30 * allplycount))

	DrawBlurRect(20 + vp.z, scrh * 0.2 + vp.x, SScaleX(400), SScaleY(30 * allplycount), math.max(255 - hidealpha, 2))

	surface.SetDrawColor(20, 20, 20, math.max(100 - hidealpha, 50))
	surface.DrawOutlinedRect(20 + vp.z, scrh * 0.2 + vp.x, SScaleX(400), SScaleY(30 * allplycount))
	surface.SetFont("BeatrunHUD")
	surface.SetTextColor(255, 255, 255, math.max(255 - hidealpha, 2))

	local i = 0

	for k, v in ipairs(allply) do
		if IsValid(v) then
			i = i + 1

			local pbtimenum = v:GetNW2Float("PBTime")
			local pbtime = niltime

			if isdatatheft then
				pbtimenum = v:GetNW2Int("DataBanked", 0)
				pbtime = pbtimenum
				surface.SetTextColor(pbtimenum ~= 0 and placecolors[k] or color_white)
			elseif isdeathmatch then
				pbtimenum = v:GetNW2Int("DeathmatchKills", 0)
				pbtime = pbtimenum
				surface.SetTextColor(pbtimenum ~= 0 and placecolors[k] or color_white)
			else
				surface.SetTextColor(pbtimenum ~= 0 and placecolors[k] or color_white)

				if pbtimenum ~= 0 then
					pbtime = string.FormattedTime(v:GetNW2Float("PBTime"), "%02i:%02i:%02i")
				end
			end

			surface.SetTextPos(30 + vp.z, scrh * 0.2 + vp.x + 25 * k)
			surface.DrawText(k .. ". " .. v:Nick():Left(14))
			surface.SetTextPos(SScaleX(220 + vp.z), scrh * 0.2 + vp.x + 25 * k)

			if isinfection and pbtimenum == 0 and v:GetNW2Bool("Infected") then
				surface.SetTextColor(infectorcolor)
				surface.DrawText(" | " .. language.GetPhrase("beatrun.hud.infector"))
			else
				surface.DrawText(" | " .. pbtime)
			end

			if k < 4 and pbtimenum ~= 0 then
				surface.SetTextPos(SScaleX(380 + vp.z), scrh * 0.2 + vp.x + 25 * k)
				surface.DrawText("★")
			end
		end
	end
end

hook.Add("HUDPaint", "BeatrunHUD", BeatrunHUD)
hook.Add("HUDPaint", "BeatrunLeaderboard", BeatrunLeaderboard)

local lastchatply = nil

hook.Add("OnPlayerChat", "BeatrunChatSound", function(ply, text, teamChat, isDead)
	if lastchatply ~= ply then
		LocalPlayer():EmitSound("friends/message.wav")
		lastchatply = ply
	end
end)

local pp = {
	["$pp_colour_contrast"] = 1.05,
	["$pp_colour_addg"] = -0.015,
	["$pp_colour_addb"] = 0.0025,
	["$pp_colour_addr"] = -0.015,
	["$pp_colour_colour"] = 0.8,
	["$pp_colour_brightness"] = -0.02,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
	["$pp_colour_mulr"] = 0
}

hook.Add("RenderScreenspaceEffects", "FilterPP", function()
	if render.GetDXLevel() < 90 then return end

	if not blinded or not blindinverted then
		DrawColorModify(pp)
	end
end)

local maxentries = SScaleX(375)
speedrecord = {}
-- local lastx = 0
-- local lasty = 0
local sgoffsetx = 0.75
local sgoffsety = 0.75

local function DrawSpeedGraph()
	if not speedrecord or not LocalPlayer().InReplay then return end

	local offsetx = ScrW() * sgoffsetx
	local offsety = ScrH() * sgoffsety
	local boxscaledx = SScaleX(400)
	local boxscaledy = SScaleY(200)

	render.SetScissorRect(offsetx, offsety, offsetx + boxscaledx, offsety + boxscaledy, true)

	surface.SetDrawColor(25, 25, 25, 100)
	surface.DrawRect(offsetx, offsety, boxscaledx, boxscaledy)
	surface.SetFont("DebugFixedSmall")

	render.PushFilterMag(TEXFILTER.POINT)
	render.PushFilterMin(TEXFILTER.POINT)

	for i = 1, #speedrecord do
		local speed = speedrecord[i]
		speedcol = speed * 2

		surface.SetDrawColor(speedcol * 0.1, speedcol * 0.5, speedcol * 0.25, speedcol * 2)
		surface.DrawLine(offsetx + i - 1, offsety + boxscaledy, offsetx + i, offsety + boxscaledy - speed)

		lasty = speed
	end

	local entrycount = #speedrecord
	local lastrecord = speedrecord[entrycount]

	if lastrecord then
		surface.SetTextColor(255, 255, 255)
		surface.SetTextPos(offsetx + entrycount, offsety + boxscaledy - lastrecord)
		surface.DrawText(math.Round(lastrecord))
	end

	render.SetScissorRect(0, 0, 0, 0, false)
	render.PopFilterMag()
	render.PopFilterMin()
	surface.SetDrawColor(45, 45, 45, 145)
	surface.DrawOutlinedRect(offsetx - 1, offsety - 1, boxscaledx + 1, boxscaledy + 1)
end

hook.Add("HUDPaint", "SpeedGraph", DrawSpeedGraph)

local smoothvel = true
local lastvel = 0

local function RecordSpeedGraph()
	if not LocalPlayer().InReplay then return end

	local lenrecord = #speedrecord
	local vel = LocalPlayer():GetVelocity()
	local oldrecord = false

	if LocalPlayer():GetClimbing() ~= 0 then
		oldrecord = speedrecord[lenrecord] or 0
	end

	if maxentries <= lenrecord then
		table.remove(speedrecord, 1)
	end

	if not oldrecord then
		vel.z = math.max(vel.z, 0)
		local power = nil

		if smoothvel then
			power = math.pow(Lerp(0, lastvel, vel:Length()), 2)
		else
			power = math.pow(vel:Length(), 2)
		end

		table.insert(speedrecord, SScaleY(power * 0.001 * power * 5e-06))
	else
		table.insert(speedrecord, oldrecord)
	end

	lastvel = Lerp(0.1, lastvel, vel:Length())
end

hook.Add("Tick", "SpeedGraph", RecordSpeedGraph)

--[[
local crosshair_unarmed = Material("vgui/hud/crosshair_unarmed")
local crosshair_standard = Material("vgui/hud/crosshair_standard")

local function BeatrunReticle()
	if not reticle:GetBool() then return end

	local wep = LocalPlayer():GetActiveWeapon()

	if not IsValid(wep) or not LocalPlayer():UsingRH() then return end

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(crosshair_standard)
	surface.DrawTexturedRect(ScrW() * 0.5 - 4, ScrH() * 0.5 - 4, 8, 8)
	surface.SetMaterial(crosshair_unarmed)
	surface.DrawTexturedRect(ScrW() * 0.5 - 4, ScrH() * 0.5 - 4, 8, 8)
end

hook.Add("HUDPaint", "BeatrunReticle", BeatrunReticle)
--]]