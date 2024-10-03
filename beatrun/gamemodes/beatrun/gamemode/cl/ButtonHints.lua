-- This file has lots of strings that needs to be localized.

local buttonhints = CreateClientConVar("Beatrun_HUDButtonHints", "1", true, false, "Show button hints on the bottom-right of your display when enabled.", 0, 1)

local function GetFormattedKey(bind)
	string = input.LookupBinding(bind)

	if string == "MOUSE1" then string = "LMB"      -- Don't localize LMB and RMB. Maybe.
	elseif string == "MOUSE2" then string = "RMB"
	elseif string == "MOUSE3" then string = "Wheel Click" end

	if string then
		return string.upper(string)
	else
		return "UNBOUND"
	end
end

surface.CreateFont("BeatrunButtons", {
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

surface.CreateFont("BeatrunButtonsSmall", {
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

hook.Add("HUDPaint", "BeatrunButtonPrompts", function()
	if !buttonhints:GetBool() then return end
	local ply = LocalPlayer()

	if ply.FallStatic then return end -- you're certainly dead by that point, can't even do anything

	local text_color = string.ToColor(ply:GetInfo("Beatrun_HUDTextColor"))
	local box_color = string.ToColor(ply:GetInfo("Beatrun_HUDCornerColor"))

	local RestartAtCheckpoint = GetConVar("Beatrun_CPSave"):GetBool()

	local QuickturnGround = GetConVar("Beatrun_QuickturnGround"):GetBool()
	local QuickturnHandsOnly = GetConVar("Beatrun_QuickturnHandsOnly"):GetBool()
	
	local QuickturnSpecialCase = ply:GetClimbing() != 0 or ply:GetMantle() >= 4 or ply:GetWallrun() != 0 or IsValid(ply:GetLadder()) or ply:GetGrappling() or ply:GetDive() or ply:GetSliding() or IsValid(ply:GetBalanceEntity()) or IsValid(ply:GetZipline())
	-- Case-catcher (?) for when quickturn/sidestep prompt shouldn't appear.

	local ButtonsTable = {} -- initialize/clear button table

	surface.SetFont("BeatrunButtons")
	fontheight = select(2, surface.GetTextSize("Placeholder, do not localize")) * 1.5

	if Course_Name != "" and RestartAtCheckpoint and ply:GetNW2Int("CPNum", -1) > 1 then
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.ttcheckpoint"), {GetFormattedKey("+reload")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.ttrestart"), {"HELDPRESS", GetFormattedKey("+reload")}}
	elseif Course_Name != "" then
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.ttrestart"), {GetFormattedKey("+reload")}}
	end

	if ply:OnGround() and ply:UsingRH() and !QuickturnSpecialCase then
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.sidestep"), {GetFormattedKey("+moveleft"), "OR", GetFormattedKey("+moveright"), "AND", GetFormattedKey("+attack2")}}
	end

	if (!ply:OnGround() or QuickturnGround) and (ply:UsingRH() or (ply:notUsingRH() and !QuickturnHandsOnly)) and not QuickturnSpecialCase then
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.quickturn"), {GetFormattedKey("+attack2")}}
	end

	if !ply:OnGround() and ply:UsingRH() and not QuickturnSpecialCase then
		if !ply:GetDive() then
			ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.dive"), {GetFormattedKey("+duck"), "AND", GetFormattedKey("+attack2")}}
		end

		if !ply:GetCrouchJump() then
			ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.crouchjump"), {GetFormattedKey("+duck")}}
		end
	end

	if !ply:OnGround() and !ply:GetCrouchJump() and !ply:GetDive() then
		if ply:GetVelocity():Length2D() > 220 and ply:GetVelocity().z <= -350 and !QuickturnSpecialCase then
			ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.fasthorfall"), {"TIMEDPRESS", GetFormattedKey("+duck")}}
		elseif ply:GetVelocity().z <= -350 and !QuickturnSpecialCase then
			ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.slowhorfall"), {"TIMEDPRESS", GetFormattedKey("+duck")}}
		end
	end

	if ply:GetMantle() == 2 then
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.vaultjump"), {"HELDPRESS", GetFormattedKey("+jump")}}
	end

	if ply:GetClimbing() != 0 then
		local ang = EyeAngles()
		ang = math.abs(math.AngleDifference(ang.y, ply.wallang.y))

		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.move"), {GetFormattedKey("+moveleft"), "OR", GetFormattedKey("+moveright")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.drop"), {GetFormattedKey("+duck")}}
		if ang <= 42 then
			ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.climb"), {GetFormattedKey("+forward")}}
		else
			ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.jump"), {GetFormattedKey("+forward"), "AND", GetFormattedKey("+jump")}}
		end
	end

	if ply:GetWallrun() == 1 then
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.quickturn"), {GetFormattedKey("+attack2")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.wallclimbcancel"), {GetFormattedKey("+duck")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.wallclimbsidejump"), {GetFormattedKey("+moveleft"), "OR", GetFormattedKey("+moveright"), "AND", GetFormattedKey("+jump")}}
	elseif ply:GetWallrun() != 0 then
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.quickturn"), {GetFormattedKey("+attack2")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.wallclimbcancel"), {GetFormattedKey("+duck")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.jump"), {GetFormattedKey("+jump")}}
	end

	if IsValid(ply:GetLadder()) then
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.climb"), {"HELDPRESS", GetFormattedKey("+forward")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.ladderdescend"), {"HELDPRESS", GetFormattedKey("+back")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.drop"), {GetFormattedKey("+duck")}}
	elseif IsValid(ply:GetBalanceEntity()) then
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.balance"), {GetFormattedKey("+moveleft"), "OR", GetFormattedKey("+moveright")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.balanceturn"), {GetFormattedKey("+attack2")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.balanceforward"), {GetFormattedKey("+forward")}}
	elseif IsValid(ply:GetZipline()) then
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.drop"), {GetFormattedKey("+duck")}}
	elseif ply:GetGrappling() then
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.jump"), {GetFormattedKey("+jump")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.grapplelonger"), {GetFormattedKey("+attack2")}}
		ButtonsTable[#ButtonsTable + 1] = {language.GetPhrase("beatrun.buttonhints.grappleshorter"), {GetFormattedKey("+attack")}}
	end

	for i=1,#ButtonsTable do
		local ButtonOrder = i
		local LineOffset = math.max(ButtonOrder - 1, 0)
		local ContainsSpecialText = false

		tw = 0
		for i=#ButtonsTable[ButtonOrder][2],1,-1 do
			if ButtonsTable[ButtonOrder][2][i] == "TIMEDPRESS" then
				draw.DrawText(language.GetPhrase("beatrun.buttonhints.timed"), "BeatrunButtonsSmall", ScrW() - ScreenScaleH(10) - tw - ScreenScaleH(2), ScrH() - ScreenScaleH(10) - fontheight * (1 + LineOffset), text_color, TEXT_ALIGN_RIGHT)
				tw = tw + surface.GetTextSize(language.GetPhrase("beatrun.buttonhints.timed"))
				ContainsSpecialText = true
			elseif ButtonsTable[ButtonOrder][2][i] == "HELDPRESS" then
				draw.DrawText(language.GetPhrase("beatrun.buttonhints.hold"), "BeatrunButtonsSmall", ScrW() - ScreenScaleH(10) - tw - ScreenScaleH(2), ScrH() - ScreenScaleH(10) - fontheight * (1 + LineOffset), text_color, TEXT_ALIGN_RIGHT)
				tw = tw + surface.GetTextSize(language.GetPhrase("beatrun.buttonhints.hold"))
				ContainsSpecialText = true
			elseif ButtonsTable[ButtonOrder][2][i] == "OR" then
				draw.DrawText("/", "BeatrunButtons", ScrW() - ScreenScaleH(10) - tw, ScrH() - ScreenScaleH(10) - fontheight * (1 + LineOffset), text_color, TEXT_ALIGN_RIGHT)
				tw = tw + surface.GetTextSize("/")
			elseif ButtonsTable[ButtonOrder][2][i] == "AND" then
				draw.DrawText("+", "BeatrunButtons", ScrW() - ScreenScaleH(10) - tw, ScrH() - ScreenScaleH(10) - fontheight * (1 + LineOffset), text_color, TEXT_ALIGN_RIGHT)
				tw = tw + surface.GetTextSize("+")
			elseif ContainsSpecialText then
				draw.WordBox(ScreenScaleH(2), ScrW() - ScreenScaleH(10) - tw, ScrH() - fontheight * (1 + LineOffset) - ScreenScaleH(10) - ScreenScaleH(1), ButtonsTable[ButtonOrder][2][i], "BeatrunButtons", box_color, text_color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
				tw = tw + surface.GetTextSize(ButtonsTable[ButtonOrder][2][i]) + ScreenScaleH(2) * 2
			else
				draw.WordBox(ScreenScaleH(2), ScrW() - ScreenScaleH(10) - tw, ScrH() - fontheight * (1 + LineOffset) - ScreenScaleH(10) - ScreenScaleH(2), ButtonsTable[ButtonOrder][2][i], "BeatrunButtons", box_color, text_color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
				tw = tw + surface.GetTextSize(ButtonsTable[ButtonOrder][2][i]) + ScreenScaleH(2) * 2
			end
		end

		draw.DrawText(ButtonsTable[ButtonOrder][1], "BeatrunButtons", ScrW() - ScreenScaleH(10) - tw - ScreenScaleH(4), ScrH() - ScreenScaleH(10) - fontheight * (1 + LineOffset), text_color, TEXT_ALIGN_RIGHT)
	end
end)