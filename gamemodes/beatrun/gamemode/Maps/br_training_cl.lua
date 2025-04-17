local replaysdir = "beatrun/gamemode/Maps/TrainingData/"
TUTORIALMODE = true
local tutorialcount = 7

local endticks = {300, 300, 350, 500, 500, 230, 800}

tutorials = {}
curtutorial = 1

local tutorialtext = {
	"Move towards a wall while in the air to climb it", {"Press [%s] before landing to break your fall", "+speed"},
	"Jump towards an obstacle to vault over it", {"Hold Jump while holding [%s] and looking at a wall to wallrun\nYou can release either key during the wallrun, you won't fall off", "+forward"},
	"Press Jump during a wallrun to jump off\nYou can chain wallruns this way", "Hold Jump while moving towards a wall to wallclimb\nYou can release either key afterwards\nYou will automatically climb ledges", {"Press [%s] while moving left or right to sidestep\nSidestep lets you move at max speed immediately\nHold Crouch to slide under the gate", "+attack2"}
}

for i = 1, tutorialcount do
	tutorials[i] = util.JSONToTable(util.Decompress(file.Read(replaysdir .. "tut" .. i .. ".lua", "LUA")))
end

function PlayTutorialReplay(num)
	local data = tutorials[num]
	local ply = LocalPlayer()

	curtutorial = num
	ply.ReplayEndAtTick = endticks[num]

	ReplayPlay(ply, data[2], data[1])
end

function PTRD()
	PlayTutorialReplay(curtutorial)
end

function SGR()
	if curtutorial == 7 and LocalPlayer():GetPos()[1] < 6345 then
		PlayTutorialReplay(curtutorial)
	end
end

local curevent = {}
local eventcheck = {}

local eventwhitelist = {
	["step"] = true,
	["sidestep"] = true,
	["jump"] = true,
	["land"] = true,
	["jumpwallrun"] = true
}

local eventrequired = {
	{"climb"},
	{"roll"},
	{"vault", "vault"},
	{"wallrunh"},
	{"wallrunh", "wallrunh"},
	{"wallrunv", "climb"},
	{"slide"}
}

local eventnicenames = {
	["climb"] = "Climb",
	["roll"] = "Roll",
	["vault"] = "Vault",
	["wallrunh"] = "Wallrun (H)",
	["wallrunv"] = "Wallrun (V)",
	["slide"] = "Slide",
	["springboard"] = "Springboard",
	["coil"] = "Coil"
}

local eventhudtext = {}

local function DrawTutorialText()
	surface.SetFont("BeatrunHUD")

	local _, offsety = ScrW() * 0.33, ScrH() * 0.75
	local data = tutorialtext[curtutorial]
	local text

	if type(data) ~= "table" then
		text = tutorialtext[curtutorial]
	else
		text = string.format(tutorialtext[curtutorial][1], input.LookupBinding(tutorialtext[curtutorial][2]))
	end

	local textsplit = string.Split(text, "\n")
	-- local linecount = #textsplit
	local tw, th = surface.GetTextSize(text)
	local boxw = tw

	surface.SetTextColor(220, 220, 220, 255)
	surface.SetDrawColor(75, 75, 75, 45)
	surface.DrawRect(ScrW() / 2 - (tw * 0.5) - 15 - 1, offsety - 1, boxw + 30 + 1, 3)

	for k, v in ipairs(textsplit) do
		local tw, th = surface.GetTextSize(v)

		surface.SetTextPos(ScrW() / 2 - (tw * 0.5), offsety + 30 - (th * 0.5) + (th * (k - 1)))
		surface.DrawText(v)
	end

	table.Empty(eventhudtext)

	for k, v in ipairs(curevent) do
		if not eventwhitelist[v] and eventnicenames[v] then
			table.insert(eventhudtext, eventnicenames[v])
		end
	end

	offsety = ScrH() * 0.7
	text = table.concat(eventhudtext, " + ")
	tw, th = surface.GetTextSize(text)

	surface.SetTextPos(ScrW() / 2 - (tw * 0.5), offsety + 30 - (th * 0.5))
	surface.DrawText(text)
end

hook.Add("HUDPaint", "TutorialText", DrawTutorialText)
hook.Add("BeatrunHUDCourse", "TutorialHUD", function() return "Tutorial" end)

local tutorialendpos = {tutorials[2][1], tutorials[3][1], tutorials[4][1], tutorials[5][1], tutorials[6][1], tutorials[7][1], Vector()}

local function TutorialLogic()
	local ply = LocalPlayer()

	if not IsValid(ply) then return end
	if ply.InReplay then return end

	local endpos = tutorialendpos[curtutorial]

	if not endpos then return end

	if ply:GetPos():Distance(endpos) < 20 then
		table.Empty(eventcheck)

		for k, v in ipairs(curevent) do
			if not eventwhitelist[v] then
				table.insert(eventcheck, v)
			end
		end

		if table.concat(eventcheck) == table.concat(eventrequired[curtutorial]) then
			table.Empty(curevent)
			table.Empty(eventcheck)

			curtutorial = curtutorial + 1

			PlayTutorialReplay(curtutorial)
		else
			table.Empty(curevent)
			table.Empty(eventcheck)

			PlayTutorialReplay(curtutorial)
		end
	end
end

hook.Add("Tick", "TutorialLogic", TutorialLogic)

local function TutorialEvents(event, ply)
	if not eventnicenames[event] then return end
	table.insert(curevent, event)

	if #curevent > 10 then
		table.remove(curevent, 1)
	end
end

hook.Add("OnParkour", "TutorialEvents", TutorialEvents)

function TutorialClearEvents()
	table.Empty(curevent)
end

local markerup = Vector()
local markercol = Color(255, 25, 25)

local function TutorialMarker()
	local markerpos = tutorialendpos[curtutorial]

	if markerpos then
		markerup:Set(markerpos)
		markerup[3] = markerup[3] + 50

		render.DrawLine(markerpos, markerup, markercol, true)

		local ang = EyeAngles()
		ang.x = -90

		markerup[3] = markerup[3] + 50 + math.sin(CurTime() * 4) * 5

		cam.Start3D2D(markerup - ang:Right() * 13, ang, 1)
			surface.SetFont("BeatrunHUD")
			surface.SetTextPos(0, 0)
			surface.SetTextColor(markercol)
			surface.DrawText("←")
		cam.End3D2D()
	end
end

hook.Add("PostDrawTranslucentRenderables", "TutorialMarker", TutorialMarker)

local creditslist = {
	{3.25, "Beatrun"},
	{3.25, "Authored by datae"},
	{3.25, "Ideas stolen from Mirror's Edge"},
	{3.75, "Sounds stolen from Mirror's Edge"},
	{3.25, "Infection music stolen from Dying Light"},
	{1.75, "Maybe I forgot more?"},
	{3.25, "Anyways..."},
	{8.75, "Thanks for playing, %s!"},
	{7.5, ""},
}

local creditstime = 0
local curcredit = 1

local function CreditsThink()
	if gui.IsGameUIVisible() then return end

	cam.Start2D()
		local data = creditslist[curcredit]

		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		surface.SetFont("BeatrunHUD")

		local text = data[2]
		text = string.format(text, LocalPlayer():Nick())

		local tw, th = surface.GetTextSize(text)

		surface.SetTextColor(220, 220, 220, 255)
		surface.SetTextPos(ScrW() / 2 - (tw * 0.5), ScrH() / 2 - (th * 0.5))
		surface.DrawText(text)

		if CurTime() > creditstime + data[1] then
			creditstime = CurTime()
			curcredit = curcredit + 1

			if not creditslist[curcredit] then
				hook.Remove("PreRender", "Credits")
				RunConsoleCommand("disconnect")
			end
		end
	cam.End2D()

	return true
end

local function CreditsStart()
	creditstime = CurTime()
	curcredit = 1

	hook.Add("PreRender", "Credits", CreditsThink)
	RunConsoleCommand("stopsound")

	timer.Simple(0, function()
		EmitSound("music/credits.mp3", vector_origin, -2, CHAN_AUTO, 1, 75, SND_SHOULDPAUSE)
	end)
end

local creditscheck = 0

hook.Add("PlayerBindPress", "CreditsCheck", function(ply, bind, pressed)
	if creditstime == 0 and bind == "+use" then
		creditscheck = creditscheck + 1

		if creditscheck > (30 - ply:GetLevel()) then
			CreditsStart()
		end
	end
end)