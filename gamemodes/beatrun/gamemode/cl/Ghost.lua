--[[
	A ghost that shows your best course time - globalsl
	ghost data file is saved to data/beatrun/ghost
--]]

CourseGhost = CreateClientConVar("Beatrun_CourseGhost", "1", true, false, "", 0, 1)

local Ghost_data = {}
local Ghost_dataBuffer = {}

local WroteRecordingInfo = false

local playerGhost

local Record_tickcount = 0
local Record_lastTick = 0

local Ghost_tickcount = 0
local Ghost_lastTick = 0

-- for the concommands
local con_RecordingBool = false
local con_PlayingBool = false


cvars.AddChangeCallback("Beatrun_CourseGhost", function(convar_name, value_old, value_new)
	if value_new == "0" then
		StopGhostRecording(false, false)
		StopGhostReplay()
	end
end)

local function GhostRecording()
	local ply = LocalPlayer()

	if engine.TickCount() > Record_lastTick then -- might be a better way to do this idk
		Record_tickcount = Record_tickcount + 1
		Record_lastTick = engine.TickCount()
	else
		return
	end

	if not WroteRecordingInfo then -- we just need to write once, no need to constantly write it ¯\_(ツ)_/¯
		if Course_ID then Ghost_dataBuffer["Cid"] = Course_ID end
		WroteRecordingInfo = true
	end

	-- print(Record_tickcount)
	Ghost_dataBuffer[Record_tickcount] = {ply:EyeAngles(), ply:GetPos(), ply:GetSequenceName(ply:GetSequence()), ply:GetCycle(), (ply:GetPoseParameter("move_x") * 2) -1, (ply:GetPoseParameter("move_y") * 2) -1}
end

function StopGhostRecording(FirstPB, PBhit)
	Record_tickcount = 0
	Record_lastTick = 0
	WroteRecordingInfo = false

	if PBhit or FirstPB or Course_Name == "" then -- let through freeplay recording
		Ghost_data = {}

		for k, v in pairs(Ghost_dataBuffer) do
			Ghost_data[k] = v
		end

		if Course_Name ~= "" then -- dont write freeplay recordings
			local tab = util.TableToJSON(Ghost_data)

			tab = util.Compress(tab)

			file.CreateDir("beatrun/ghost")
			file.Write("beatrun/ghost/" .. Ghost_data["Cid"] .. ".txt", tab)
		end
	end

	hook.Remove("CreateMove", "GhostRecording")
end

function StartGhostRecording()
	Ghost_dataBuffer = {}
	hook.Add("CreateMove", "GhostRecording", GhostRecording)
end

local function GhostEntInit()
	local ply = LocalPlayer()
	playerGhost = ClientsideModel(ply:GetModel())

	playerGhost:SetRenderMode(RENDERMODE_TRANSALPHA)
	playerGhost:SetSequence("idle_all_01") -- avoid tpose on spawn

	playerGhost.GetPlayerColor = function()
		-- creating this function changes the models clothes color, yeah ¯\_(ツ)_/¯
		return ply:GetPlayerColor()
	end

	for i = 0, ply:GetNumBodyGroups() - 1 do
		playerGhost:SetBodygroup(i, ply:GetBodygroup(i))
	end

	playerGhost:SetupBones() -- we gotta call it to disable the jigglebones

	for i = 0, playerGhost:GetBoneCount() - 1 do
		playerGhost:ManipulateBoneJiggle(i, 2) -- disable jigglebones. Why? jigglebones flicker because of the setblend thing
	end

	playerGhost.RenderOverride = function(self)
		render.OverrideColorWriteEnable(true, false)

		self:DrawModel()

		render.OverrideColorWriteEnable(false, false)
		render.SetBlend(0.50)

		self:DrawModel()

		render.SetBlend(1)
	end
end

local function GhostReplay()
	if not IsValid(playerGhost) then GhostEntInit() end

	if engine.TickCount() > Ghost_lastTick then -- might be a better way to do this idk
		Ghost_tickcount = Ghost_tickcount + 1
		Ghost_lastTick = engine.TickCount()
	else
		return -- optimization: Since we dont change the tickcount then we dont need to set new values to our ghost
	end

	if not Ghost_data[Ghost_tickcount] or Ghost_data["Cid"] ~= Course_ID then -- the added course check makes it so that if we stop the course the ghost dissapears
		StopGhostReplay() -- self destruct
		-- print("Ghost killed(It finished playing or detected a course change)")
		return
	end

	local ang_ghost = Ghost_data[Ghost_tickcount][1]
	ang_ghost.z = 0
	ang_ghost.x = 0

	playerGhost:SetPos(Ghost_data[Ghost_tickcount][2])
	playerGhost:SetAngles(ang_ghost)
	playerGhost:SetSequence(Ghost_data[Ghost_tickcount][3])
	playerGhost:SetCycle(Ghost_data[Ghost_tickcount][4])
	playerGhost:SetPoseParameter("move_x", Ghost_data[Ghost_tickcount][5] or 1)
	playerGhost:SetPoseParameter("move_y", Ghost_data[Ghost_tickcount][6] or 0)

	if playerGhost:GetPos():Distance(LocalPlayer():GetPos()) < 40 then
		playerGhost:SetNoDraw(true)
	else
		playerGhost:SetNoDraw(false)
	end
end

function StopGhostReplay()
	hook.Remove("CreateMove", "GhostReplay")

	Ghost_tickcount = 0
	Ghost_lastTick = 0
	con_PlayingBool = false

	if IsValid(playerGhost) then playerGhost:Remove() end
end

function StartGhostReplay()
	if Ghost_data["Cid"] ~= Course_ID then
		local ghostFile = "data/beatrun/ghost/" .. Course_ID .. ".txt"

		if file.Exists(ghostFile, "GAME") then
			local jsonData = file.Read(ghostFile, "GAME")
			jsonData = util.Decompress(jsonData)
			Ghost_data = util.JSONToTable(jsonData, true)
		elseif Course_ID ~= "" then
			return
		end
	end

	hook.Add("CreateMove", "GhostReplay", GhostReplay)
end

concommand.Add("Beatrun_ToggleGhostRecord", function()
	if Course_Name ~= "" then
		print("This command is only available in Freeplay")
		return
	end

	con_RecordingBool = not con_RecordingBool

	if con_RecordingBool then
		print("Recording started.")
		StartGhostRecording()
	else
		print("Recording stopped.")
		StopGhostRecording()
	end
end)

concommand.Add("Beatrun_ToggleGhostPlay", function()
	if Course_Name ~= "" then
		print("This command is only available in Freeplay")
		return
	end

	con_PlayingBool = not con_PlayingBool

	if con_PlayingBool then
		print("Starting Ghost replay")
		StartGhostReplay()
	else
		print("Stopping Ghost replay")
		StopGhostReplay()
	end
end)