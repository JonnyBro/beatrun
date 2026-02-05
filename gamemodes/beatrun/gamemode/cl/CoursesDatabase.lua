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

-- Caching and pagination

local CachedCourses = nil
local CachedAt = 0
local CACHE_LIFETIME = 1 -- seconds

local PAGE_SIZE = 5
local CurrentPage = 1
local TotalPages = 1

local function IsCacheValid()
	return CachedCourses and (CurTime() - CachedAt) < CACHE_LIFETIME
end

local function PopulateCoursesList(courses)
	table.Empty(coursesList.elements)

	local startIndex = (CurrentPage - 1) * PAGE_SIZE + 1
	local endIndex = math.min(startIndex + PAGE_SIZE - 1, #courses)

	for i = startIndex, endIndex do
		local v = courses[i]
		if not v then continue end

		local text = string.format("Course: %s (%s)\nUploaded By: %s\nUploaded At: %s", v.name, v.code, v.uploadedBy.username, v.uploadedAt)
		local courseentry = AEUI:Text(coursesList, text, "AEUILarge", 10, 120 * #coursesList.elements)

		function courseentry:onclick()
			LocalPlayer():EmitSound("buttonclick.wav")

			LoadCourseRaw(util.Base64Decode(v.data))

			AEUI:RemovePanel(coursesList)
			AEUI:RemovePanel(coursesPanel)
		end
	end
end

-- UI Functions

function OpenDBMenu()
	CurrentPage = 1
	TotalPages = 1

	table.Empty(coursesList.elements)

	AEUI:AddPanel(coursesPanel)
	AEUI:AddPanel(coursesList)

	local pages = AEUI:Text(coursesPanel, CurrentPage .. " / " .. TotalPages, nil, coursesPanel.w / 2, coursesPanel.h - 40)

	AEUI:AddButton(coursesPanel, "< Prev", function()
		if CurrentPage > 1 then
			CurrentPage = CurrentPage - 1
			TotalPages = math.ceil(#CachedCourses / PAGE_SIZE)
			CurrentPage = math.Clamp(CurrentPage, 1, TotalPages)

			pages.string = CurrentPage .. " / " .. TotalPages

			PopulateCoursesList(CachedCourses)
		end
	end, nil, coursesPanel.w / 2 - 80, coursesPanel.h - 40)

	AEUI:AddButton(coursesPanel, "Next >", function()
		if CachedCourses and CurrentPage * PAGE_SIZE < #CachedCourses then
			CurrentPage = CurrentPage + 1
			TotalPages = math.ceil(#CachedCourses / PAGE_SIZE)
			CurrentPage = math.Clamp(CurrentPage, 1, TotalPages)

			pages.string = CurrentPage .. " / " .. TotalPages

			PopulateCoursesList(CachedCourses)
		end
	end, nil, coursesPanel.w / 2 + 60, coursesPanel.h - 40)

	if IsCacheValid() then
		TotalPages = math.ceil(#CachedCourses / PAGE_SIZE)
		CurrentPage = math.Clamp(CurrentPage, 1, TotalPages)

		pages.string = CurrentPage .. " / " .. TotalPages

		PopulateCoursesList(CachedCourses)

		return
	end

	http.Fetch("http://100.86.126.63:6547/game/courses/list", function(body, size, _, code)
		local response = util.JSONToTable(body)

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
					uploadedAt = os.date("%Y-%m-%d %H:%M", course.uploadedAt / 1000),
					uploadedBy = {
						createdAt = course.uploadedBy.createdAt,
						steamId = course.uploadedBy.steamId,
						username = course.uploadedBy.username
					}
				})
			end

			CachedCourses = fetchedCourses
			CachedAt = CurTime()

			TotalPages = math.ceil(#fetchedCourses / PAGE_SIZE)
			CurrentPage = math.Clamp(CurrentPage, 1, TotalPages)

			pages.string = CurrentPage .. " / " .. TotalPages

			PopulateCoursesList(fetchedCourses)
		elseif not response then
			print("Can't access the database! Please make sure that domain is correct.")
			return false
		else
			print(body)
			print("Error! | Response: " .. response.message)
			return false
		end
	end, function(e) print("An error occurred: " .. e) end, {
		mapname = currentMap
	})
end

concommand.Add("Beatrun_CoursesDatabase", OpenDBMenu)