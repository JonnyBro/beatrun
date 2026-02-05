local apikey = CreateClientConVar("Beatrun_Apikey", "0", true, false, language.GetPhrase("beatrun.convars.apikey"))
local domain = CreateClientConVar("Beatrun_Domain", "courses.jbro.top", true, false, language.GetPhrase("beatrun.convars.domain"))

local QueuedArgs
local QueuedFunction
local currentMap = game.GetMap()

concommand.Add("Beatrun_Cancel", function()
	QueuedArgs = nil
	QueuedFunction = nil
end)

concommand.Add("Beatrun_Confirm", function()
	if QueuedArgs and QueuedFunction then
		QueuedFunction(QueuedArgs)

		QueuedArgs = nil
		QueuedFunction = nil

		return
	end

	if QueuedFunction then
		QueuedFunction()

		QueuedArgs = nil
		QueuedFunction = nil

		return
	end
end)

local function GetCurrentMapWorkshopID()
	for _, addon in pairs(engine.GetAddons()) do
		if not addon or not addon.title or not addon.wsid or not addon.mounted or not addon.downloaded then continue end

		_, addon_folders = file.Find("*", addon.title)

		if file.Exists("maps/" .. currentMap .. ".bsp", addon.title) then return addon.wsid end
	end

	return "no_map_id"
end

local function FetchCourse(url, headers)
	if not LocalPlayer():IsSuperAdmin() then
		print("You must be a Super Admin to load courses")
		return
	end

	http.Fetch(url, function(body, length, _, code)
		local response = util.JSONToTable(body)

		if BEATRUN_DEBUG then print(body) end

		if response and response.res == 200 then
			print("Success! | Length: " .. length .. "\nLoading course...")

			local dir = "beatrun/courses/" .. string.Replace(currentMap, " ", "-") .. "/"

			file.CreateDir(dir)

			local coursedata = util.Compress(response.file)

			file.Write(dir .. headers.code .. ".txt", coursedata)

			LoadCourseRaw(coursedata)

			return true
		elseif not response then
			print("Can't access the database! Please make sure that domain is correct.")

			return false
		else
			print(body)
			print("Error! | Response: " .. response.message)

			return false
		end
	end, function(e) print("An error occurred: " .. e) end, headers)
end

local function PostCourse(url, course, headers)
	http.Post(url, {
		data = course
	}, function(body, _, _, code)
		local response = util.JSONToTable(body)

		if BEATRUN_DEBUG then print(body) end

		if response and response.res == 200 then
			print("Success! | Code: " .. response.code)

			return true
		elseif not response then
			print("Can't access the database! Please make sure that domain is correct.")

			return false
		else
			print(body)
			print("An error occurred: " .. response.message)

			return false
		end
	end, function(e) print("Unexpected error: " .. e) end, headers)
end

function UploadCourse()
	if Course_Name == "" or Course_ID == "" then return print(language.GetPhrase("beatrun.coursesdatabase.cantuploadfreeplay")) end

	local fl = file.Open("beatrun/courses/" .. string.Replace(currentMap, " ", "-") .. "/" .. Course_ID .. ".txt", "rb", "DATA")
	local data = fl:Read()

	PostCourse("https://" .. domain:GetString() .. "/api/upload", util.Base64Encode(data, true), {
		authorization = apikey:GetString(),
		course = util.Base64Encode(data, true),
		map = string.Replace(currentMap, " ", "-"),
		mapid = GetCurrentMapWorkshopID()
	})
end

function UpdateCourse(course_code)
	if Course_Name == "" or Course_ID == "" then return print(language.GetPhrase("beatrun.coursesdatabase.cantuploadfreeplay")) end

	local fl = file.Open("beatrun/courses/" .. string.Replace(currentMap, " ", "-") .. "/" .. Course_ID .. ".txt", "rb", "DATA")
	local data = fl:Read()

	PostCourse("https://" .. domain:GetString() .. "/api/update", data, {
		authorization = apikey:GetString(),
		code = course_code,
		course = util.Base64Encode(data, true),
		map = string.Replace(currentMap, " ", "-")
	})
end

concommand.Add("Beatrun_LoadCode", function(ply, cmd, args, argstr)
	FetchCourse("https://" .. domain:GetString() .. "/api/download", {
		authorization = apikey:GetString(),
		code = args[1],
		map = string.Replace(currentMap, " ", "-")
	})
end)

concommand.Add("Beatrun_UploadCourse", function()
	QueuedFunction = UploadCourse

	print(language.GetPhrase("beatrun.coursesdatabase.upload1"):format(Course_Name, currentMap))
	print(language.GetPhrase("beatrun.coursesdatabase.upload2"))
end)

concommand.Add("Beatrun_UpdateCode", function(ply, cmd, args, argstr)
	QueuedFunction = UpdateCourse
	QueuedArgs = args[1]

	print(language.GetPhrase("beatrun.coursesdatabase.update1"):format(QueuedArgs, Course_Name, currentMap))
	print(language.GetPhrase("beatrun.coursesdatabase.upload2"))
end)

--[[
concommand.Add("beatrun_testhtml", function()
	local frame = vgui.Create("DFrame")
	frame:SetSize(300, 200)
	frame:SetTitle("this is a derma frame with dhtml")
	frame:SetVisible(true)
	frame:SetDraggable(true)
	frame:MakePopup()
	frame:Center()

	--Fill the form with a html page
	local html = vgui.Create("DHTML", frame)
	html:Dock(FILL)
	html:SetHTML("<input type='submit' onclick='console.log(\"RUNLUA:RunConsoleCommand(\"Beatrun_LoadCode\", \"UBFU-NDDN-BLZP\")\")' />")
	-- Enable the webpage to call lua code.
	html:SetAllowLua(true)
end) --]]

-- UI

local coursesPanel = {
	w = 900,
	h = 650,
	bgcolor = Color(32, 32, 32),
	outlinecolor = Color(54, 55, 56),
	alpha = 0.9,
	elements = {}
}

coursesPanel.x = 950 - coursesPanel.w * 0.5
coursesPanel.y = 550 - coursesPanel.h * 0.5

local coursesList = {
	w = 800,
	h = 450,
	x = 1000 - coursesPanel.w * 0.5,
	y = 648 - coursesPanel.h * 0.5,
	bgcolor = Color(32, 32, 32),
	outlinecolor = Color(54, 55, 56),
	alpha = 0.9,
	elements = {}
}

local function closebutton()
	AEUI:RemovePanel(coursesList)
	AEUI:RemovePanel(coursesPanel)
end

AEUI:AddButton(coursesPanel, "  X  ", closebutton, "AEUILarge", coursesPanel.w - 47, 0)

-- UI Functions

function OpenDBMenu()
	AEUI:AddPanel(coursesPanel)
	AEUI:AddPanel(coursesList)

	local headers = {
		mapname = currentMap
	}

	http.Fetch("http://100.86.126.63:6547/game/courses/list", function(body, size, _, code)
		local response = util.JSONToTable(body)
		--[[
		["code"] = 200
		["data"]:
			[1]:
				["_id"] = 69843432d7ea1b166b2022bf
				["code"] = O3V-OJM
				["data"] = GxwBAKyKd4EkY3r+kRUbvpKPNmxcitRsqTGbsr1pFpr+cQKDbvP6dxvld0dIlPUUCfrVbmMwc4ulK3Vw+nRyoAcMNCCsJRJonmccaBhhJHkOPT45Namd+Y9ug1/gy7JXjnKaj9g7qIlyaKKMCZknexmRRIv3Q9oNrJ4/b+sS73epoYs/7jy4L06L3F57s7G7DXYLzUmTQzWJqUZ0oLTiP0WkX07dHKd8PjjyMaqaL0l2O1GhGCEZHg==
				["downloadCount"] = 2
				["elementsCount"] = 2
				["mapId"] = 0
				["mapImg"]	=
				["mapName"] = gm_construct
				["name"] = 123
				["uploadedAt"] = 1770271794860
				["uploadedBy"]:
					["_id"] = 69842e62d7ea1b166b2022be
					["createdAt"] = 1770270306023
					["steamId"] = 76561198198170143
					["username"] = Jonny_Bro
		--]]

		if response and response.code == 200 then
			local fetchedCourses = {}

			for _, course in ipairs(response.data) do
				table.insert(fetchedCourses, {
					code = course.code,
					data = course.data,
					downloadCount = course.downloadCount,
					elementsCount = course.elementsCount,
					mapId = course.mapId,
					mapImg = course.mapImg,
					mapName = course.mapName,
					name = course.name,
					uploadedAt = course.uploadedAt,
					uploadedBy = {
						createdAt = course.uploadedBy.createdAt,
						steamId = course.uploadedBy.steamId,
						username = course.uploadedBy.username
					}
				})
			end

			table.Empty(coursesList.elements)

			PrintTable(fetchedCourses)
			print("\n\n\n")

			for _, v in ipairs(fetchedCourses) do
				-- format: multiline
				local text = string.format(
					"Course: %s (%s)\nUploaded By: %s\nUpload Time: %s",
					v.name,
					v.code,
					v.uploadedBy.username,
					tostring(v.uploadedAt)
				)

				local courseentry = AEUI:Text(coursesList, text, "AEUILarge", 10, 120 * #coursesList.elements)

				function courseentry:onclick()
					LocalPlayer():EmitSound("buttonclick.wav")

					LoadCourseRaw(util.Base64Decode(v.data))

					AEUI:RemovePanel(coursesList)
					AEUI:RemovePanel(coursesPanel)
				end
			end
		elseif not response then
			print("Can't access the database! Please make sure that domain is correct.")
			return false
		else
			print(body)
			print("Error! | Response: " .. response.message)
			return false
		end
	end, function(e) print("An error occurred: " .. e) end, headers)
end

concommand.Add("Beatrun_CoursesDatabase", OpenDBMenu)