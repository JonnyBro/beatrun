local apikey = CreateClientConVar("Beatrun_Apikey", "0", true, false, language.GetPhrase("beatrun.convars.apikey"))
local domain = CreateClientConVar("Beatrun_Domain", "courses.jbro.top", true, false, language.GetPhrase("beatrun.convars.domain"))
local currentMap = game.GetMap()

function OpenConfirmPopup(title, message, onConfirm)
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

function OpenUpdatePopup()
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

function GetCurrentMapWorkshopID()
	for _, addon in pairs(engine.GetAddons()) do
		if not addon or not addon.title or not addon.wsid or not addon.mounted or not addon.downloaded then continue end

		_, addon_folders = file.Find("*", addon.title)

		if file.Exists("maps/" .. currentMap .. ".bsp", addon.title) then return addon.wsid end
	end

	return "0"
end

function FetchCourse(url, headers)
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

function PostCourse(url, course, headers)
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
	if Course_Name == "" or Course_ID == "" then return print(language.GetPhrase("beatrun.coursesdatabase.cantdoinfreeplay")) end

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
	if Course_Name == "" or Course_ID == "" then return print(language.GetPhrase("beatrun.coursesdatabase.cantdoinfreeplay")) end

	local fl = file.Open("beatrun/courses/" .. string.Replace(currentMap, " ", "-") .. "/" .. Course_ID .. ".txt", "rb", "DATA")
	local data = fl:Read()

	PostCourse("https://" .. domain:GetString() .. "/api/update", data, {
		authorization = apikey:GetString(),
		code = course_code,
		course = util.Base64Encode(data, true),
		map = string.Replace(currentMap, " ", "-")
	})
end

-- Database UI
local ScreenH, ScreenW = ScrH(), ScrW()
local isCurrentMapOnly = false

-- Global caches
Beatrun_MapImageCache = Beatrun_MapImageCache or {}
Beatrun_CoursesCache = Beatrun_CoursesCache or {
	all = nil,
	filtered = nil,
	at = 0,
	loading = false
}

local CACHE_LIFETIME = 5
local Frame, Header, List

local function IsCoursesCacheValid()
	return Beatrun_CoursesCache.all and CurTime() - Beatrun_CoursesCache.at < CACHE_LIFETIME
end

local function CacheMapPreview(course)
	if file.Size("maps/thumb/" .. course.mapName .. ".png", "GAME") > 0 then
		Beatrun_MapImageCache[course.mapName] = Material("maps/thumb/" .. course.mapName .. ".png", "smooth")

		return
	end

	steamworks.FileInfo(course.workshopId, function(result)
		if not result then return end

		steamworks.Download(result.previewid, true, function(name)
			if not name then return end

			Beatrun_MapImageCache[course.mapName] = AddonMaterial(name)

			return
		end)
	end)
end

local function GetMapPreview(course)
	return Beatrun_MapImageCache[course.mapName]
end

local function PopulateCoursesList()
	if not IsValid(List) then return end
	if not Beatrun_CoursesCache.filtered then return end

	List:Clear()

	for _, v in ipairs(Beatrun_CoursesCache.filtered) do
		local entry = List:Add("DPanel")
		entry:SetTall(120)
		entry:Dock(TOP)
		entry:DockMargin(10, 10, 10, 0)

		entry.Paint = function(self, w, h)
			local col = self:IsHovered() and Color(70, 70, 70) or Color(60, 60, 60)
			draw.RoundedBox(6, 0, 0, w, h, col)

			local mapMaterial = GetMapPreview(v)

			if mapMaterial and not mapMaterial:IsError() then
				surface.SetMaterial(mapMaterial)
				surface.SetDrawColor(255, 255, 255)
				surface.DrawTexturedRect(10, 10, 160, 98)
			else
				draw.RoundedBox(4, 10, 10, 160, 98, Color(40, 40, 40))
				draw.SimpleText("No image", "AEUIDefault", 86, 59, Color(120, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			draw.SimpleText(v.name, "AEUILarge", 180, 5, color_white)
			draw.SimpleText("Uploaded: " .. v.uploadedAt, "AEUIDefault", 184, 85, Color(180, 180, 180))
		end

		local mapBtn = vgui.Create("DButton", entry)
		mapBtn:SetText(v.mapName)
		mapBtn:SetFont("AEUIDefault")
		mapBtn:SetPos(180, 63)
		mapBtn:SizeToContents()
		mapBtn:SetCursor(v.workshopId == "0" and "arrow" or "hand")
		mapBtn:SetTextColor(Color(180, 180, 180))
		mapBtn:SetPaintBackground(false)

		mapBtn.DoClick = function() if v.workshopId ~= "0" then gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. v.workshopId) end end
		mapBtn.OnCursorEntered = function(self) if v.workshopId ~= "0" then self:SetTextColor(Color(255, 0, 0)) end end
		mapBtn.OnCursorExited = function(self) if v.workshopId ~= "0" then self:SetTextColor(Color(180, 180, 180)) end end

		local codeBtn = vgui.Create("DButton", entry)
		codeBtn:SetText(v.code)
		codeBtn:SetFont("AEUIDefault")
		codeBtn:SetPos(180, 35)
		codeBtn:SizeToContents()
		codeBtn:SetCursor("hand")
		codeBtn:SetTextColor(Color(150, 150, 150))
		codeBtn:SetPaintBackground(false)

		codeBtn.DoClick = function(self)
			SetClipboardText(v.code)

			if IsValid(self) then self:SetText("Copied code to clipboard") end
			if IsValid(self) then self:SizeToContents() end

			timer.Simple(2, function()
				if IsValid(self) then self:SetText(v.code) end
				if IsValid(self) then self:SizeToContents() end
			end)
		end
		codeBtn.OnCursorEntered = function(self) self:SetTextColor(Color(255, 0, 0)) end
		codeBtn.OnCursorExited = function(self) self:SetTextColor(Color(180, 180, 180)) end

		local rightPanel = vgui.Create("DPanel", entry)
		rightPanel:Dock(RIGHT)
		rightPanel:SetWide(170)
		rightPanel:DockMargin(0, 8, 10, 8)
		rightPanel.Paint = function(self, w, h)
			surface.SetDrawColor(80, 80, 80)
			surface.DrawLine(0, 0, 0, h)
		end

		local authorPanel = vgui.Create("DPanel", rightPanel)
		authorPanel:Dock(TOP)
		authorPanel:SetTall(28)
		authorPanel.Paint = nil

		local avatar = vgui.Create("AvatarImage", authorPanel)
		avatar:SetSize(24, 24)
		avatar:Dock(LEFT)
		avatar:DockMargin(10, 2, 6, 2)
		avatar:SetSteamID(v.uploadedBy.steamId, 32)

		local nameBtn = vgui.Create("DButton", authorPanel)
		nameBtn:SetText(v.uploadedBy.username)
		nameBtn:SetFont("AEUIDefault")
		nameBtn:Dock(FILL)
		nameBtn:SetCursor("hand")
		nameBtn:SetContentAlignment(4)
		nameBtn:SetTextColor(Color(180, 180, 180))
		nameBtn:SetPaintBackground(false)

		nameBtn.DoClick = function() gui.OpenURL("https://steamcommunity.com/profiles/" .. v.uploadedBy.steamId) end
		nameBtn.OnCursorEntered = function(self) self:SetTextColor(Color(255, 0, 0)) end
		nameBtn.OnCursorExited = function(self) self:SetTextColor(Color(180, 180, 180)) end

		local loadPanel = vgui.Create("DPanel", rightPanel)
		loadPanel:SetTall(36)
		loadPanel:Dock(BOTTOM)
		loadPanel:DockMargin(10, 0, 0, 4)
		loadPanel.Paint = nil

		local loadBtn = vgui.Create("DButton", loadPanel)
		loadBtn:SetText("Load Course")
		loadBtn:SetFont("AEUIDefault")
		loadBtn:Dock(FILL)
		loadBtn:SetCursor("hand")
		loadBtn:SetTextColor(Color(255, 255, 255))

		loadBtn.Paint = function(self, w, h)
			local bgColor = self:IsHovered() and Color(100, 100, 100) or Color(80, 80, 80)

			draw.RoundedBox(4, 0, 0, w, h, bgColor)
		end

		loadBtn.DoClick = function()
			if not steamworks.IsSubscribed(v.workshopId) then
				local loadWarn = vgui.Create("DFrame")
				loadWarn:SetTitle("")
				loadWarn:SetSize(360, 140)
				loadWarn:Center()
				loadWarn:MakePopup()
				loadWarn:SetDeleteOnClose(true)

				local label = vgui.Create("DLabel", loadWarn)
				label:SetText("You're not subscribed to this map. If you start the course you may become stuck. Would you like to subscribe?")
				label:SetWrap(true)
				label:SetSize(330, 60)
				label:SetPos(15, 35)

				local workshop = vgui.Create("DButton", loadWarn)
				workshop:SetText("Open Workshop")
				workshop:SetSize(150, 30)
				workshop:SetPos(20, 95)
				workshop:SetEnabled(v.workshopId ~= "0")
				workshop.DoClick = function()
					gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. v.workshopId)

					if IsValid(loadWarn) then loadWarn:Close() end
				end

				local iKnowWhatImDoing = vgui.Create("DButton", loadWarn)
				iKnowWhatImDoing:SetText("I know, start anyway")
				iKnowWhatImDoing:SetSize(150, 30)
				iKnowWhatImDoing:SetPos(190, 95)
				iKnowWhatImDoing.DoClick = function()
					LocalPlayer():EmitSound("ui/buttonclickrelease.wav")

					LoadCourseRaw(util.Base64Decode(v.data))

					if IsValid(Frame) then Frame:Close() end
					if IsValid(loadWarn) then loadWarn:Close() end
				end

				return
			end

			LocalPlayer():EmitSound("ui/buttonclickrelease.wav")

			LoadCourseRaw(util.Base64Decode(v.data))

			if IsValid(Frame) then Frame:Close() end
		end
	end
end

local function ApplyCourseFilter(newText)
	if not Beatrun_CoursesCache.all then return end

	local text = string.lower(newText or "")
	local filtered = {}

	for _, course in ipairs(Beatrun_CoursesCache.all) do
		if isCurrentMapOnly and course.mapName ~= currentMap then continue end
		if text ~= "" and not string.find(string.lower(course.name), text, 1, true) then continue end

		filtered[#filtered + 1] = course
	end

	Beatrun_CoursesCache.filtered = filtered
	PopulateCoursesList()
end

function OpenDBMenu()
	if IsValid(Frame) then Frame:Remove() end

	Frame = vgui.Create("DFrame")
	Frame:SetSize(ScreenW / 1.1, ScreenH / 1.1)
	Frame:Center()
	Frame:SetTitle(string.format("Beatrun Courses Database (%s)", domain:GetString()))
	Frame:MakePopup()

	local Sheet = vgui.Create("DPropertySheet", Frame)
	Sheet:Dock(FILL)

	-- Browse page
	local BrowsePanel = vgui.Create("DPanel", Sheet)
	BrowsePanel:Dock(FILL)
	BrowsePanel:DockPadding(0, 0, 0, 0)
	BrowsePanel:SetBackgroundColor(Color(45, 45, 45))

	Sheet:AddSheet("Browse Courses", BrowsePanel, "icon16/folder.png")

	Header = vgui.Create("DPanel", BrowsePanel)
	Header:Dock(TOP)
	Header:SetTall(40)
	Header:DockPadding(10, 8, 10, 8)
	Header.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(55, 55, 55))
	end

	local CurrentMapBtn = vgui.Create("DButton", Header)
	CurrentMapBtn:SetText("placeholder")
	CurrentMapBtn:SetTextColor(color_white)
	CurrentMapBtn:SetSize(120, 24)
	CurrentMapBtn:Dock(LEFT)
	CurrentMapBtn:DockMargin(0, 0, 8, 0)

	CurrentMapBtn.Paint = function(self, w, h)
		local text = isCurrentMapOnly and "Current Map Only" or "All Courses"
		local col = self:IsHovered() and Color(95, 95, 95) or Color(80, 80, 80)

		draw.RoundedBox(6, 0, 0, w, h, col)

		self:SetText(text)
	end

	CurrentMapBtn.DoClick = function()
		isCurrentMapOnly = not isCurrentMapOnly
		ApplyCourseFilter()
	end

	local Search = vgui.Create("DTextEntry", Header)
	Search:Dock(FILL)
	Search:SetPlaceholderText("Search courses...")
	Search:SetUpdateOnType(true)
	function Search:OnValueChange(text)
		ApplyCourseFilter(text)
	end

	List = vgui.Create("DScrollPanel", BrowsePanel)
	List:Dock(FILL)
	-- List:DockMargin(10, 10, 10, 10)

	-- Upload page
	local UploadPanel = vgui.Create("DPanel", Sheet)
	UploadPanel:Dock(FILL)
	UploadPanel:DockPadding(20, 20, 20, 20)

	UploadPanel.Paint = function(self, w, h)
		draw.SimpleText("there will be ui...", "AEUILarge", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	Sheet:AddSheet("Upload Course", UploadPanel, "icon16/arrow_up.png")

	-- Download page
	local DownloadPanel = vgui.Create("DPanel", Sheet)
	DownloadPanel:Dock(FILL)
	DownloadPanel:DockPadding(20, 20, 20, 20)

	DownloadPanel.Paint = function(self, w, h)
		draw.SimpleText("there will be ui...", "AEUILarge", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	Sheet:AddSheet("Download Courses", DownloadPanel, "icon16/arrow_down.png")

	if IsCoursesCacheValid() then
		PopulateCoursesList()

		return
	end

	if Beatrun_CoursesCache.loading then return end

	Beatrun_CoursesCache.loading = true

	local headers = {
		-- mapname = "",
		game = "yes"
	}

	http.Fetch("http://" .. domain:GetString() .. "/courses/list", function(body)
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

		Beatrun_CoursesCache.all = fetchedCourses
		Beatrun_CoursesCache.filtered = fetchedCourses
		Beatrun_CoursesCache.at = CurTime()

		ApplyCourseFilter()
		PopulateCoursesList()

		for _, v in ipairs(Beatrun_CoursesCache.all) do
			CacheMapPreview(v)
		end
	end, function(err)
		Beatrun_CoursesCache.loading = false

		print("Courses fetch error:", err)
	end, headers)
end

concommand.Add("Beatrun_CoursesDatabase", OpenDBMenu)