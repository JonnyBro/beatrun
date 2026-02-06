local apikey = CreateClientConVar("Beatrun_Apikey", "0", true, false, language.GetPhrase("beatrun.convars.apikey"))
local domain = CreateClientConVar("Beatrun_Domain", "courses.jbro.top", true, false, language.GetPhrase("beatrun.convars.domain"))
local currentMap = game.GetMap()

local function OpenConfirmPopup(title, message, onConfirm)
	local frame = vgui.Create("DFrame")
	frame:SetTitle(title)
	frame:SetSize(360, 140)
	frame:Center()
	frame:MakePopup()
	frame:SetDeleteOnClose(true)

	local label = vgui.Create("DLabel", frame)
	label:SetText(message)
	label:SetWrap(true)
	label:SetSize(330, 60)
	label:SetPos(15, 35)

	local confirm = vgui.Create("DButton", frame)
	confirm:SetText("#beatrun.misc.ok")
	confirm:SetSize(150, 30)
	confirm:SetPos(20, 95)

	confirm.DoClick = function()
		if onConfirm then onConfirm() end
		frame:Close()
	end

	local cancel = vgui.Create("DButton", frame)
	cancel:SetText("#beatrun.misc.cancel")
	cancel:SetSize(150, 30)
	cancel:SetPos(190, 95)
	cancel.DoClick = function() frame:Close() end
end

local function OpenUpdatePopup()
	local frame = vgui.Create("DFrame")
	frame:SetTitle("#beatrun.toolsmenu.courses.updatecourse")
	frame:SetSize(360, 160)
	frame:Center()
	frame:MakePopup()
	frame:SetDeleteOnClose(true)

	local label = vgui.Create("DLabel", frame)
	label:SetText("#beatrun.toolsmenu.courses.enterloadcourse")
	label:SetPos(15, 35)
	label:SizeToContents()

	local entry = vgui.Create("DTextEntry", frame)
	entry:SetPos(15, 55)
	entry:SetSize(330, 22)
	entry:SetPlaceholderText("XXXX-XXXX-XXXX")

	local confirm = vgui.Create("DButton", frame)
	confirm:SetText("#beatrun.misc.ok")
	confirm:SetSize(150, 30)
	confirm:SetPos(20, 115)
	confirm.DoClick = function()
		local code = string.Trim(entry:GetValue())
		if code == "" then return end

		OpenConfirmPopup("#beatrun.toolsmenu.courses.updatecourse", string.format(language.GetPhrase("beatrun.coursesdatabase.update1"), code, Course_Name, currentMap), function()
			UpdateCourse(code)

			notification.AddLegacy("#beatrun.misc.checkconsole", NOTIFY_HINT, 5)
		end)

		frame:Close()
	end

	local cancel = vgui.Create("DButton", frame)
	cancel:SetText("#beatrun.misc.cancel")
	cancel:SetSize(150, 30)
	cancel:SetPos(190, 115)
	cancel.DoClick = function()
		frame:Close()
	end
end

local function GetCurrentMapWorkshopID()
	for _, addon in pairs(engine.GetAddons()) do
		if not addon or not addon.title or not addon.wsid or not addon.mounted or not addon.downloaded then continue end

		_, addon_folders = file.Find("*", addon.title)

		if file.Exists("maps/" .. currentMap .. ".bsp", addon.title) then return addon.wsid end
	end

	return "0"
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
		workshopid = GetCurrentMapWorkshopID()
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
	local msg = string.format(language.GetPhrase("beatrun.coursesdatabase.upload1"), Course_Name, currentMap)

	OpenConfirmPopup("#beatrun.toolsmenu.courses.uploadcourse", msg, function()
		UploadCourse()

		notification.AddLegacy("#beatrun.misc.checkconsole", NOTIFY_HINT, 5)
	end)
end)

concommand.Add("Beatrun_UpdateCode", function(ply, cmd, args, argstr)
	OpenUpdatePopup()
end)

-- Database UI
local ScreenH, ScreenW = ScrH(), ScrW()
local PAGE_SIZE = 5
local CurrentPage, TotalPages = 1, 1

-- Global caches
Beatrun_MapImageCache = Beatrun_MapImageCache or {}
Beatrun_CoursesCache = Beatrun_CoursesCache or { data = nil, at = 0, loading = false }

local CACHE_LIFETIME = 5
local Frame, List, PageLabel

local function GetPreviewImage(id)

end

local function IsCoursesCacheValid()
	return Beatrun_CoursesCache.data and CurTime() - Beatrun_CoursesCache.at < CACHE_LIFETIME
end

local function PopulateCoursesList()
	if not IsValid(List) then return end

	List:Clear()

	local startIndex = (CurrentPage - 1) * PAGE_SIZE + 1
	local endIndex = math.min(startIndex + PAGE_SIZE - 1, #Beatrun_CoursesCache.data)

	for i = startIndex, endIndex do
		local v = Beatrun_CoursesCache.data[i]
		if not v then continue end

		local entry = List:Add("DPanel")
		entry:SetTall(120)
		entry:Dock(TOP)
		entry:DockMargin(0, 0, 0, 5)

		entry.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 60))

			local mapId = v.workshopId ~= "0" and v.workshopId or currentMap
			local MapMaterial

			if tonumber(MapId) == nil or steamworks.IsSubscribed(mapId) then
				MapMaterial = Material("maps/thumb/" .. mapId .. ".png", "smooth")
			else
				MapMaterial = Beatrun_MapImageCache[mapId]
			end

			if MapMaterial and not MapMaterial:IsError() then
				surface.SetMaterial(MapMaterial)
				surface.SetDrawColor(255, 255, 255)
				surface.DrawTexturedRect(5, 10, 160, 98)
			else
				draw.RoundedBox(4, 5, 10, 160, 98, Color(40, 40, 40))
				draw.SimpleText("No image", "AEUIDefault", 86, 59, Color(120, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			draw.SimpleText(v.name .. " (" .. v.code .. ")", "AEUILarge", 180, 10, color_white)
			draw.SimpleText("Uploaded At: " .. v.uploadedAt, "AEUIDefault", 180, 92, Color(180, 180, 180))
		end

		local avatar = vgui.Create("AvatarImage", entry)
		avatar:SetSize(24, 24)
		avatar:SetPos(182, 46)
		avatar:SetSteamID(v.uploadedBy.steamId, 32)

		local nameBtn = vgui.Create("DButton", entry)
		nameBtn:SetText(v.uploadedBy.username)
		nameBtn:SetFont("AEUIDefault")
		nameBtn:SetPos(210, 46)
		nameBtn:SizeToContents()
		nameBtn:SetCursor("hand")
		nameBtn:SetTextColor(Color(180, 180, 180))
		nameBtn:SetPaintBackground(false)

		nameBtn.DoClick = function() gui.OpenURL("https://steamcommunity.com/profiles/" .. v.uploadedBy.steamId) end
		nameBtn.OnCursorEntered = function(self) self:SetTextColor(Color(255, 0, 0)) end
		nameBtn.OnCursorExited = function(self) self:SetTextColor(Color(180, 180, 180)) end

		local mapBtn = vgui.Create("DButton", entry)
		mapBtn:SetText("Map: " .. v.mapName)
		mapBtn:SetFont("AEUIDefault")
		mapBtn:SetPos(176, 68)
		mapBtn:SizeToContents()
		mapBtn:SetCursor(v.workshopId == "0" and "arrow" or "hand")
		mapBtn:SetTextColor(Color(180, 180, 180))
		mapBtn:SetPaintBackground(false)

		mapBtn.DoClick = function() if v.workshopId ~= "0" then gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. v.workshopId) end end
		mapBtn.OnCursorEntered = function(self) if v.workshopId ~= "0" then self:SetTextColor(Color(255, 0, 0)) end end
		mapBtn.OnCursorExited = function(self) if v.workshopId ~= "0" then self:SetTextColor(Color(180, 180, 180)) end end

		local loadBtn = vgui.Create("DButton", entry)
		loadBtn:SetText("Load Course")
		loadBtn:SetFont("AEUIDefault")
		loadBtn:SetSize(120, 26)
		loadBtn:SetPos(400, 56)
		loadBtn:SetCursor("hand")
		loadBtn:SetTextColor(Color(255, 255, 255))

		loadBtn.Paint = function(self, w, h)
			local bgColor = self:IsHovered() and Color(100, 100, 100) or Color(80, 80, 80)

			draw.RoundedBox(4, 0, 0, w, h, bgColor)
			draw.SimpleText(self:GetText(), "AEUIDefault", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		loadBtn.DoClick = function()
			LocalPlayer():EmitSound("ui/buttonclickrelease.wav")

			LoadCourseRaw(util.Base64Decode(v.data))

			if IsValid(Frame) then Frame:Close() end
		end
	end
end

local function UpdatePagination()
	if not Beatrun_CoursesCache.data then return end

	TotalPages = math.max(1, math.ceil(#Beatrun_CoursesCache.data / PAGE_SIZE))
	CurrentPage = math.Clamp(CurrentPage, 1, TotalPages)

	if IsValid(PageLabel) then PageLabel:SetText("Page: " .. CurrentPage .. "/" .. TotalPages) end

	PopulateCoursesList()
end

function OpenDBMenu()
	CurrentPage, TotalPages = 1, 1

	if IsValid(Frame) then Frame:Remove() end

	Frame = vgui.Create("DFrame")
	Frame:SetSize(ScreenW / 1.1, ScreenH / 1.1)
	Frame:Center()
	Frame:SetTitle(string.format("Beatrun Courses Database (%s)", domain:GetString()))
	Frame:MakePopup()

	List = vgui.Create("DScrollPanel", Frame)
	List:SetPos(20, 40)
	List:Dock(FILL)

	local Prev = vgui.Create("DButton", Frame)
	Prev:SetText("< Prev")
	Prev:SetSize(80, 30)
	Prev:SetPos(math.Round(Frame:GetWide()) / 2 - 80, ScreenH / 1.15)
	Prev.DoClick = function()
		if CurrentPage > 1 then
			CurrentPage = CurrentPage - 1

			UpdatePagination()
		end
	end

	PageLabel = vgui.Create("DLabel", Frame)
	PageLabel:SetText("Page: 1/1")
	PageLabel:SetPos(math.Round(Frame:GetWide()) / 2 + 15, ScreenH / 1.143)
	PageLabel:SizeToContents()

	local Next = vgui.Create("DButton", Frame)
	Next:SetText("Next >")
	Next:SetSize(80, 30)
	Next:SetPos(math.Round(Frame:GetWide()) / 2 + 80, ScreenH / 1.15)
	Next.DoClick = function()
		if Beatrun_CoursesCache.data and CurrentPage < TotalPages then
			CurrentPage = CurrentPage + 1

			UpdatePagination()
		end
	end

	if IsCoursesCacheValid() then
		UpdatePagination()

		return
	end

	-- Prevent duplicate fetch
	if Beatrun_CoursesCache.loading then return end
	Beatrun_CoursesCache.loading = true

	-- Fetch courses
	http.Fetch("http://100.86.126.63:6547/courses/list", function(body)
		Beatrun_CoursesCache.loading = false

		local response = util.JSONToTable(body)
		if not response or response.code ~= 200 then return end

		local fetchedCourses = {}

		for _, course in ipairs(response.data) do
			fetchedCourses[#fetchedCourses + 1] = {
				code = course.code,
				data = course.data,
				downloadCount = course.downloadCount,
				elementsCount = course.elementsCount,
				workshopId = course.workshopId,
				mapName = course.mapName,
				name = course.name,
				uploadedAt = os.date("%Y-%m-%d %H:%M", course.uploadedAt / 1000),
				uploadedBy = {
					steamId = course.uploadedBy.steamId,
					username = course.uploadedBy.username
				}
			}
		end

		Beatrun_CoursesCache.data = fetchedCourses
		Beatrun_CoursesCache.at = CurTime()

		for _, course in ipairs(Beatrun_CoursesCache.data) do
			print("Loading map preview: " .. course.workshopId)

			GetPreviewImage(course.workshopId)
		end

		UpdatePagination()
	end, function(err)
		Beatrun_CoursesCache.loading = false

		print("Courses fetch error:", err)
	end, {
		mapname = currentMap,
		game = "yes"
	})
end

concommand.Add("Beatrun_CoursesDatabase", OpenDBMenu)