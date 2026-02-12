--[[ TODO
	- Replace "http" with "https" for release
	- Localization
	- Rewrite all the functions for the new database backend
	- Make course commands (upload, load, etc) obsolete
	- Everything will be in the UI, no more commands (maybe there will be for automation or power users :shrug:)
	- Replace hardcoded colors with custom themes?
	- Validate api key with the server
--]]

-- ConVars
local databaseApiKey = CreateClientConVar("Beatrun_Apikey", "0", true, false, language.GetPhrase("beatrun.convars.apikey"))
local databaseDomain = CreateClientConVar("Beatrun_Domain", "courses.jbro.top", true, false, language.GetPhrase("beatrun.convars.domain"))

-- Database UI
local ScreenH, ScreenW = ScrH(), ScrW()
local isCurrentMapOnly = false
local currentMap = game.GetMap()

-- Global caches
Beatrun_MapImageCache = Beatrun_MapImageCache or {}
Beatrun_CoursesCache = Beatrun_CoursesCache or {
	all = nil,
	filtered = nil,
	at = 0,
	loading = false
}

local CACHE_LIFETIME = 5
local Frame, Header, Sheet, List, BrowsePanel, UploadPanel, ProfilePanel

-- Helpers
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

function GetCurrentMapWorkshopID()
	for _, addon in ipairs(engine.GetAddons()) do
		if not addon.mounted or not addon.downloaded or not addon.wsid then continue end

		if file.Exists("maps/" .. currentMap .. ".bsp", addon.title) then
			return addon.wsid
		end
	end

	return nil
end

local function SanitizeString(str)
	str = string.lower(str)
	str = string.gsub(str, "[^%w_%-]", "_")

	return str
end

local function SaveCourse(mapName, code, data)
	mapName = SanitizeString(mapName)
	code = SanitizeString(code)

	file.CreateDir("beatrun/courses/" .. mapName)

	local path = "beatrun/courses/" .. mapName .. "/" .. code .. ".txt"
	local success = file.Write(path, data)

	return success and path or nil
end

local function DownloadCourse(course)
	local headers = {
		code = course.code
	}

	http.Fetch("http://" .. databaseDomain:GetString() .. "/api/courses/download", function(body, _, _, code)
		if code ~= 200 or not body or body == "" then
			notification.AddLegacy("Failed to download course", NOTIFY_ERROR, 4)

			return
		end

		local path = SaveCourse(course.mapName, course.code, util.Base64Decode(body))

		if not path then
			notification.AddLegacy("Save failed", NOTIFY_ERROR, 4)

			return
		end

		notification.AddLegacy("Saved to data/" .. path, NOTIFY_GENERIC, 4)

		surface.PlaySound("ui/buttonclickrelease.wav")
	end, function(err)
		notification.AddLegacy("Check console", NOTIFY_ERROR, 4)
		print("HTTP error: " .. err)
	end, headers)
end

local function UploadCourseFile(course)
	if not databaseApiKey:GetString() or databaseApiKey:GetString() == "0" then
		notification.AddLegacy("API key missing", NOTIFY_ERROR, 4)

		return
	end

	local raw = file.Read(course.path, "DATA")
	if not raw then
		notification.AddLegacy("Failed to read/open file", NOTIFY_ERROR, 4)

		return
	end

	local encoded = util.Base64Encode(raw, true)

	local headers = {
		authorization = databaseApiKey:GetString(),
		mapName = currentMap,
		workshopId = GetCurrentMapWorkshopID()
	}

	http.Post("http://" .. databaseDomain:GetString() .. "/api/courses/upload", {
		data = encoded
	}, function(body, size, headers, code)
		body = util.JSONToTable(body)

		if code ~= 200 then
			notification.AddLegacy("Upload failed, check console", NOTIFY_ERROR, 4)

			print("Code: " .. body.code)
			print("Reply: " .. body.message)

			return
		end

		notification.AddLegacy("Upload successful, check console for code", NOTIFY_GENERIC, 4)

		print("Code: " .. body.code)
		print("Reply: " .. body.message)

		surface.PlaySound("ui/buttonclickrelease.wav")
	end, function(err)
		print("Upload error:", err)
		notification.AddLegacy("Upload error (check console)", NOTIFY_ERROR, 4)
	end, headers)
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

			local mapMaterial = Beatrun_MapImageCache[v.mapName]

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
		mapBtn:SetCursor(v.workshopId and "hand" or "arrow")
		mapBtn:SetTextColor(Color(180, 180, 180))
		mapBtn:SetPaintBackground(false)

		mapBtn.DoClick = function() if v.workshopId then gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. v.workshopId) end end
		mapBtn.OnCursorEntered = function(self) if v.workshopId then self:SetTextColor(Color(255, 0, 0)) end end
		mapBtn.OnCursorExited = function(self) if v.workshopId then self:SetTextColor(Color(180, 180, 180)) end end

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
		nameBtn:SetTextColor(color_white)
		nameBtn:SetPaintBackground(false)

		nameBtn.DoClick = function() gui.OpenURL("https://steamcommunity.com/profiles/" .. v.uploadedBy.steamId) end
		nameBtn.OnCursorEntered = function(self) self:SetTextColor(Color(255, 0, 0)) end
		nameBtn.OnCursorExited = function(self) self:SetTextColor(color_white) end

		local loadPanel = vgui.Create("DPanel", rightPanel)
		loadPanel:SetTall(70)
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
			if v.workshopId and not steamworks.IsSubscribed(v.workshopId) then
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
				workshop:SetEnabled(v.workshopId ~= nil)
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

		local downloadBtn = vgui.Create("DButton", loadPanel)
		downloadBtn:SetText("Download")
		downloadBtn:SetFont("AEUIDefault")
		downloadBtn:Dock(BOTTOM)
		downloadBtn:SetTall(28)
		downloadBtn:DockMargin(0, 6, 0, 0)
		downloadBtn:SetCursor("hand")
		downloadBtn:SetTextColor(color_white)

		downloadBtn.Paint = function(self, w, h)
			local bg = self:IsHovered() and Color(60, 160, 60) or Color(60, 130, 50)
			local savedPath = "beatrun/courses/" .. SanitizeString(v.mapName) .. "/" .. SanitizeString(v.code) .. ".txt"

			if file.Exists(savedPath, "DATA") then
				bg = self:IsHovered() and Color(160, 60, 60) or Color(130, 50, 50)
				self:SetText("Overwrite?")

			end

			draw.RoundedBox(4, 0, 0, w, h, bg)
		end

		-- NOTE: I know that we have all the course data, but the database needs to update the download couter
		downloadBtn.DoClick = function() DownloadCourse(v) end
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

local function GetCoursesForCurrentMap()
	local map = SanitizeString(currentMap)
	local dir = "beatrun/courses/" .. map .. "/"
	if not file.Exists(dir, "DATA") then return {} end

	local files = file.Find(dir .. "*.txt", "DATA")
	local result = {}

	for _, v in ipairs(files or {}) do
		local data = file.Read(dir .. v, "DATA")
		local course = util.JSONToTable(util.Decompress(data) or data)
		local time = file.Time(dir .. v, "DATA")

		result[#result + 1] = {
			name = course[5],
			time,
			path = dir .. v
		}
	end

	return result
end

local function BuildProfilePage()
	if not IsValid(ProfilePanel) then return end

	ProfilePanel:Clear()

	local apiKey = databaseApiKey:GetString()
	local hasKey = apiKey and apiKey ~= "0" and apiKey ~= ""

	if not hasKey then
		local msg = vgui.Create("DLabel", ProfilePanel)
		msg:SetFont("AEUILarge")
		msg:SetText("You need an API key to upload courses\nButton below will send your SteamID and Username to the database!\nWe do not collect any other info!")
		msg:SetTextColor(color_white)
		msg:SizeToContents()
		msg:Dock(TOP)
		msg:DockMargin(0, 60, 0, 20)
		msg:SetContentAlignment(5)

		local registerBtn = vgui.Create("DButton", ProfilePanel)
		registerBtn:SetText("Register/Get API Key")
		registerBtn:SetTall(40)
		registerBtn:Dock(TOP)
		registerBtn:DockMargin(200, 0, 200, 0)
		registerBtn:SetTextColor(color_white)
		registerBtn.Paint = function(self, w, h) draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(80, 120, 80) or Color(60, 100, 60)) end
		registerBtn.DoClick = function()
			local headers = {
				steamid = LocalPlayer():SteamID64(),
				username = LocalPlayer():Nick()
			}

			http.Post("http://" .. databaseDomain:GetString() .. "/api/users/register", {}, function(body, _, _, code)
				body = util.JSONToTable(body)

				if code ~= 200 then
					notification.AddLegacy("API key error (check console)", NOTIFY_ERROR, 4)

					print("Code: " .. body.code)
					print("Reply: " .. body.message)

					return
				end

				print("Updated Beatrun API key to " .. body.data.key)

				databaseApiKey:SetString(body.data.key)

				BuildProfilePage()

				surface.PlaySound("ui/buttonclickrelease.wav")
			end, function(err)
				print("API key error:", err)
				notification.AddLegacy("API key error (check console)", NOTIFY_ERROR, 4)
			end, headers)
		end

		return
	end

	local header = vgui.Create("DPanel", ProfilePanel)
	header:SetTall(90)
	header:Dock(TOP)
	header.Paint = nil

	local avatar = vgui.Create("AvatarImage", header)
	avatar:SetSize(64, 64)
	avatar:Dock(LEFT)
	avatar:DockMargin(0, 10, 15, 10)
	avatar:SetSteamID(LocalPlayer():SteamID64(), 64)

	local name = vgui.Create("DLabel", header)
	name:SetFont("AEUILarge")
	name:SetText(LocalPlayer():Nick())
	name:SetTextColor(color_white)
	name:Dock(TOP)
	name:SizeToContents()

	local keyRow = vgui.Create("DPanel", header)
	keyRow:Dock(TOP)
	keyRow:DockMargin(0, 6, 0, 0)
	keyRow:SetTall(26)
	keyRow.Paint = nil

	local masked = string.rep("*", math.max(#apiKey - 4, 0)) .. string.sub(apiKey, -4)

	local keyLabel = vgui.Create("DLabel", keyRow)
	keyLabel:SetFont("AEUIDefault")
	keyLabel:SetText("API Key: " .. masked)
	keyLabel:SetTextColor(Color(180, 180, 180))
	keyLabel:Dock(LEFT)
	keyLabel:SizeToContents()

	local changeBtn = vgui.Create("DButton", keyRow)
	changeBtn:SetText("Change")
	changeBtn:SetFont("AEUIDefault")
	changeBtn:Dock(LEFT)
	changeBtn:DockMargin(10, 0, 0, 0)
	changeBtn:SizeToContents()
	changeBtn:SetTextColor(color_white)
	changeBtn:SetCursor("hand")

	changeBtn.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(120, 80, 60) or Color(90, 60, 45))
	end

	changeBtn.DoClick = function()
		local frame = vgui.Create("DFrame")
		frame:SetSize(360, 150)
		frame:Center()
		frame:MakePopup()
		frame:SetTitle("Change API Key")

		local entry = vgui.Create("DTextEntry", frame)
		entry:Dock(TOP)
		entry:DockMargin(20, 40, 20, 0)
		entry:SetTall(28)
		entry:SetPlaceholderText("Enter new API key...")
		entry:SetText(databaseApiKey:GetString())

		local saveBtn = vgui.Create("DButton", frame)
		saveBtn:Dock(BOTTOM)
		saveBtn:DockMargin(20, 0, 20, 20)
		saveBtn:SetTall(32)
		saveBtn:SetText("Save")
		saveBtn:SetTextColor(color_white)

		saveBtn.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(70, 120, 70) or Color(60, 100, 60))
		end

		saveBtn.DoClick = function()
			local newKey = string.Trim(entry:GetValue())

			if newKey == "" then return end

			databaseApiKey:SetString(newKey)

			frame:Close()
			BuildProfilePage()
		end
	end

	-- Stats block
	local statsPanel = vgui.Create("DPanel", ProfilePanel)
	statsPanel:SetTall(60)
	statsPanel:Dock(TOP)
	statsPanel:DockMargin(0, 15, 0, 15)
	statsPanel.Paint = function(self, w, h) draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 60)) end

	local statsLabel = vgui.Create("DLabel", statsPanel)
	statsLabel:SetFont("AEUIDefault")
	statsLabel:SetTextColor(color_white)
	statsLabel:SetContentAlignment(5)
	statsLabel:Dock(FILL)

	local myCourses = {}

	local totalDownloads = 0

	if Beatrun_CoursesCache.all then
		local myId = LocalPlayer():SteamID64()

		for _, v in ipairs(Beatrun_CoursesCache.all) do
			if v.uploadedBy and v.uploadedBy.steamId == myId then
				myCourses[#myCourses + 1] = v
				totalDownloads = totalDownloads + (v.downloadCount or 0)
			end
		end
	end

	statsLabel:SetText("Uploads: " .. #myCourses .. "    |    Total Downloads: " .. totalDownloads)

	local myList = vgui.Create("DScrollPanel", ProfilePanel)
	myList:Dock(FILL)

	if #myCourses == 0 then
		local empty = vgui.Create("DLabel", myList)
		empty:SetText("You have not uploaded any courses yet.")
		empty:SetTextColor(Color(180, 180, 180))
		empty:Dock(TOP)
		empty:DockMargin(0, 5, 0, 0)
		empty:SizeToContents()

		return
	end

	for _, v in ipairs(Beatrun_CoursesCache.all or {}) do
		if not (v.uploadedBy and v.uploadedBy.steamId == LocalPlayer():SteamID64()) then continue end

		local entry = myList:Add("DPanel")
		entry:SetTall(60)
		entry:Dock(TOP)
		entry:DockMargin(0, 0, 0, 8)

		entry.Paint = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, Color(55, 55, 55))
			draw.SimpleText(v.name, "AEUIDefault", 10, 8, color_white)
			draw.SimpleText("Downloads: " .. v.downloadCount, "AEUIDefault", 10, 26, Color(180, 180, 180))
			draw.SimpleText("Uploaded: " .. v.uploadedAt, "AEUIDefault", 10, 42, Color(140, 140, 140))
		end
	end
end

function OpenDBMenu()
	if IsValid(Frame) then Frame:Remove() end

	Frame = vgui.Create("DFrame")
	Frame:SetSize(ScreenW / 1.1, ScreenH / 1.1)
	Frame:Center()
	Frame:SetTitle(string.format("Online Courses Database (%s)", databaseDomain:GetString()))
	Frame:MakePopup()

	Sheet = vgui.Create("DPropertySheet", Frame)
	Sheet:Dock(FILL)

	-- Browse page
	BrowsePanel = vgui.Create("DPanel", Sheet)
	BrowsePanel:Dock(FILL)
	BrowsePanel:DockPadding(0, 0, 0, 0)
	BrowsePanel:SetBackgroundColor(Color(45, 45, 45))

	Sheet:AddSheet("Browse", BrowsePanel, "icon16/folder.png")

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

	-- Upload page
	UploadPanel = vgui.Create("DPanel", Sheet)
	UploadPanel:Dock(FILL)
	UploadPanel:DockPadding(20, 20, 20, 20)
	UploadPanel:SetBackgroundColor(Color(45, 45, 45))

	local title = vgui.Create("DLabel", UploadPanel)
	title:SetText("Upload Course (Current Map: " .. currentMap .. ")")
	title:SetFont("AEUILarge")
	title:Dock(TOP)
	title:DockMargin(0, 0, 0, 12)
	title:SetTextColor(color_white)
	title:SizeToContents()

	local refreshBtn = vgui.Create("DButton", UploadPanel)
	refreshBtn:SetText("Refresh")
	refreshBtn:Dock(TOP)
	refreshBtn:SetTall(28)
	refreshBtn:DockMargin(0, 0, 0, 10)

	local courseList = vgui.Create("DScrollPanel", UploadPanel)
	courseList:Dock(FILL)

	local selectedCourse = nil

	local function PopulateLocalCourses()
		courseList:Clear()
		selectedCourse = nil

		local courses = GetCoursesForCurrentMap()

		if #courses == 0 then
			local empty = vgui.Create("DLabel", courseList)
			empty:SetText("No saved courses found for this map")
			empty:SetTextColor(Color(180, 180, 180))
			empty:Dock(TOP)
			empty:DockMargin(0, 4, 0, 0)
			empty:SizeToContents()

			return
		end

		for _, course in ipairs(courses) do
			local btn = vgui.Create("DButton", courseList)
			btn:SetText(course.name .. " (Created: " .. os.date("%Y-%m-%d %H:%M", course.time) .. ")")
			btn:SetTall(32)
			btn:Dock(TOP)
			btn:DockMargin(0, 0, 0, 6)
			btn:SetTextColor(color_white)

			btn.Paint = function(self, w, h)
				local col

				if selectedCourse == course then
					col = Color(70, 120, 70)
				elseif self:IsHovered() then
					col = Color(80, 80, 80)
				else
					col = Color(60, 60, 60)
				end

				draw.RoundedBox(6, 0, 0, w, h, col)
			end

			btn.DoClick = function()
				selectedCourse = course
			end
		end
	end

	refreshBtn.DoClick = PopulateLocalCourses

	local uploadBtn = vgui.Create("DButton", UploadPanel)
	uploadBtn:SetText("Upload Selected")
	uploadBtn:Dock(BOTTOM)
	uploadBtn:SetTall(36)
	uploadBtn:SetTextColor(color_white)

	uploadBtn.Paint = function(self, w, h)
		local col = self:IsHovered() and Color(100, 100, 100) or Color(80, 80, 80)
		draw.RoundedBox(6, 0, 0, w, h, col)
	end

	uploadBtn.DoClick = function()
		if not selectedCourse then
			notification.AddLegacy("No course selected", NOTIFY_ERROR, 3)

			return
		end

		OpenConfirmPopup("Upload Course", "Upload course '" .. selectedCourse.name .. "' to database?", function() UploadCourseFile(selectedCourse) end)
	end

	PopulateLocalCourses()

	Sheet:AddSheet("Upload", UploadPanel, "icon16/arrow_up.png")

	-- Profile page
	ProfilePanel = vgui.Create("DPanel", Sheet)
	ProfilePanel:Dock(FILL)
	ProfilePanel:DockPadding(20, 20, 20, 20)
	ProfilePanel:SetBackgroundColor(Color(45, 45, 45))

	Sheet.OnActiveTabChanged = function(self, old, new)
		if new:GetText() == "Profile" then
			BuildProfilePage()
		end
	end

	Sheet:AddSheet("Profile", ProfilePanel, "icon16/user.png")

	-- Fetch courses
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

	http.Fetch("http://" .. databaseDomain:GetString() .. "/api/courses/list", function(body)
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

		if IsValid(ProfilePanel) then
			BuildProfilePage()
		end

		for _, v in ipairs(Beatrun_CoursesCache.all) do
			CacheMapPreview(v)
		end
	end, function(err)
		Beatrun_CoursesCache.loading = false

		print("Courses fetch error:", err)
	end, headers)
end

concommand.Add("Beatrun_CoursesDatabase", OpenDBMenu)

function OpenConfirmPopup(title, message, onConfirm)
	local frameW = math.Clamp(ScreenW * 0.25, 320, 600)
	local frameH = math.Clamp(ScreenH * 0.18, 140, 260)

	local frame = vgui.Create("DFrame")
	frame:SetTitle(title)
	frame:SetSize(frameW, frameH)
	frame:Center()
	frame:MakePopup()
	frame:SetDeleteOnClose(true)
	frame:DockPadding(20, 40, 20, 20)

	frame.Paint = function(self, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(45, 45, 45)) end

	local label = vgui.Create("DLabel", frame)
	label:Dock(FILL)
	label:SetWrap(true)
	label:SetText(message)
	label:SetContentAlignment(5)
	label:SetAutoStretchVertical(true)

	local buttonRow = vgui.Create("DPanel", frame)
	buttonRow:Dock(BOTTOM)
	buttonRow:SetTall(frameH * 0.28)
	buttonRow.Paint = nil

	local confirm = vgui.Create("DButton", buttonRow)
	confirm:Dock(LEFT)
	confirm:DockMargin(0, 0, 10, 0)
	confirm:SetWide(frameW * 0.5 - 25)
	confirm:SetText("#beatrun.misc.ok")

	confirm.DoClick = function()
		if onConfirm then onConfirm() end
		frame:Close()
	end

	local cancel = vgui.Create("DButton", buttonRow)
	cancel:Dock(FILL)
	cancel:SetText("#beatrun.misc.cancel")

	cancel.DoClick = function()
		frame:Close()
	end
end
