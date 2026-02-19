-- ConVars
local databaseApiKey = CreateClientConVar("Beatrun_Apikey", "0", true, false, language.GetPhrase("beatrun.convars.apikey"))
local databaseDomain = CreateClientConVar("Beatrun_Domain", "courses.jbro.top", true, false, language.GetPhrase("beatrun.convars.domain"))
local uiTheme = CreateClientConVar("Beatrun_CoursesMenu_Theme", "dark", true, false, language.GetPhrase("beatrun.convars.theme"))

-- Database UI
local isCurrentMapOnly = false
local currentMap = game.GetMap()
local THEME = {
	dark = {
		accent = Color(255, 60, 60),
		bg = Color(40, 40, 40),
		cursor = color_white,
		header = Color(50, 50, 50),
		primary = Color(70, 70, 70),
		secondary = Color(80, 80, 80),
		search = Color(220, 60, 60), -- Color around active text box
		text = {
			primary = color_white,
			muted = Color(180, 180, 180),
			dark = Color(150, 150, 150),
		},
		buttons = {
			primary = {
				t = color_white, -- Text color
				n = Color(75, 75, 75), -- Normal state
				h = Color(95, 95, 95), -- Hovered state
				d = Color(110, 110, 110), -- Pressed state (isDown)
			},
			green = {
				t = color_white,
				n = Color(46, 125, 50),
				h = Color(56, 142, 60),
				d = Color(67, 160, 71),
			},
			red = {
				t = color_white,
				n = Color(183, 28, 28),
				h = Color(198, 40, 40),
				d = Color(211, 47, 47),
			}
		},
		panels = {
			primary = Color(58, 58, 58),
			secondary = Color(72, 72, 72)
		}
	},
	light = {
		accent = Color(33, 150, 243),
		bg = Color(245, 247, 250),
		cursor = color_black,
		header = Color(230, 233, 238),
		primary = Color(210, 214, 220),
		secondary = Color(225, 229, 235),
		search = Color(25, 118, 210),
		text = {
			primary = color_black,
			muted = Color(110, 110, 110),
			dark = Color(70, 70, 70),
		},
		buttons = {
			primary = {
				t = color_black,
				n = Color(215, 219, 225),
				h = Color(200, 210, 220),
				d = Color(185, 198, 212),
			},
			green = {
				t = color_white,
				n = Color(76, 175, 80),
				h = Color(67, 160, 71),
				d = Color(56, 142, 60),
			},
			red = {
				t = color_white,
				n = Color(229, 57, 53),
				h = Color(211, 47, 47),
				d = Color(198, 40, 40),
			}
		},
		panels = {
			primary = Color(255, 255, 255),
			secondary = Color(240, 243, 247)
		}
	}
}

-- Cache
Beatrun_MapImageCache = Beatrun_MapImageCache or {}
Beatrun_CoursesCache = Beatrun_CoursesCache or {
	all = nil,
	filtered = nil,
	at = 0,
	loading = false
}

local CACHE_LIFETIME = 60
local Frame, Header, Sheet, List, LocalPanel, BrowsePanel, ProfilePanel

-- Helpers
local function SanitizeString(str)
	str = string.lower(str)
	str = string.gsub(str, "[^%w_%-]", "_")

	return str
end

local function IsCoursesCacheValid()
	return Beatrun_CoursesCache.all and CurTime() - Beatrun_CoursesCache.at < CACHE_LIFETIME
end

local function CurrentTheme()
	return THEME[string.lower(uiTheme:GetString())] or THEME.dark
end

local function CacheMapPreview(course)
	if not course.workshopId then
		if file.Size("maps/thumb/" .. course.mapName .. ".png", "GAME") > 0 then
			Beatrun_MapImageCache[course.mapName] = Material("maps/thumb/" .. course.mapName .. ".png", "smooth")
		end

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

local function GetCurrentMapWorkshopID()
	for _, addon in ipairs(engine.GetAddons()) do
		if not addon.mounted or not addon.downloaded or not addon.wsid then continue end
		if file.Exists("maps/" .. currentMap .. ".bsp", addon.title) then return addon.wsid end
	end

	return nil
end

-- UI helpers
local function ApplyScrollTheme(panel)
	local bar = panel:GetVBar()

	bar.Paint = function() end
	bar.btnUp.Paint = function() end
	bar.btnDown.Paint = function() end

	bar.btnGrip.Paint = function(self, w, h)
		local col = self:IsHovered() and CurrentTheme().buttons.primary.h or CurrentTheme().buttons.primary.n

		draw.RoundedBox(4, 0, 0, w, h, col)
	end
end

local function ApplyButtonTheme(self, w, h, style)
	local bg = self:IsHovered() and CurrentTheme().buttons[style].h or CurrentTheme().buttons[style].n
	local isDown = self:IsDown() and CurrentTheme().buttons[style].d

	draw.RoundedBox(6, 0, 0, w, h, isDown or bg)
end

local function OpenCourseSaveMenu()
	local frameW = math.Clamp(ScrW() * 0.25, 320, 600)
	local frameH = math.Clamp(ScrH() * 0.18, 140, 260)

	local frame = vgui.Create("DFrame")
	frame:SetTitle("")
	frame:SetSize(frameW, frameH)
	frame:Center()
	frame:DockPadding(20, 40, 20, 20)
	frame:ShowCloseButton(false)
	frame:SetDeleteOnClose(true)
	frame:MakePopup()

	frame.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, CurrentTheme().bg)
		draw.RoundedBoxEx(8, 0, 0, w, 24, CurrentTheme().header, true, true, false, false)
		draw.SimpleText("#beatrun.coursesmenu.localpage.savecourse", "AEUIDefault", 10, 12, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local close = vgui.Create("DButton", frame)
	close:SetSize(24, 24)
	close:SetPos(frame:GetWide() - 24, 0)
	close:SetText("✕")
	close:SetFont("AEUIDefault")
	close:SetTextColor(CurrentTheme().buttons.red.t)

	close.Paint = function(self, w, h)
		local bg = self:IsHovered() and CurrentTheme().buttons.red.h or CurrentTheme().buttons.red.n
		local isDown = self:IsDown() and CurrentTheme().buttons.red.d

		draw.RoundedBoxEx(6, 0, 0, w, h, isDown or bg, false, true, false, false)
	end

	close.DoClick = function() if IsValid(frame) then frame:Close() end end

	local content = vgui.Create("DPanel", frame)
	content:Dock(FILL)
	content.Paint = nil

	local entry = vgui.Create("DTextEntry", content)
	entry:Dock(TOP)
	entry:SetTall(32)
	entry:SetFont("AEUIDefault")
	entry:SetPlaceholderText("#beatrun.coursesmenu.save.placeholder")
	entry:SetPaintBackground(false)

	entry.Paint = function(self, w, h)
		surface.SetDrawColor(CurrentTheme().text.muted)
		surface.DrawOutlinedRect(0, 0, w, h, 1)

		self:DrawTextEntryText(CurrentTheme().text.primary, CurrentTheme().text.muted, CurrentTheme().cursor)

		if self:GetValue() == "" then draw.SimpleText(self:GetPlaceholderText(), self:GetFont(), 5, h / 2, CurrentTheme().text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end

		if self:HasFocus() then
			surface.SetDrawColor(CurrentTheme().search:Unpack())
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end
	end

	local speedRow = vgui.Create("DPanel", content)
	speedRow:Dock(TOP)
	speedRow:DockMargin(0, 12, 0, 0)
	speedRow:SetTall(24)
	speedRow.Paint = nil

	local checkbox = vgui.Create("DCheckBox", speedRow)
	checkbox:Dock(LEFT)
	checkbox:SetWide(24)
	checkbox:SetValue(false)

	checkbox.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, CurrentTheme().panels.secondary)

		if self:GetChecked() then draw.RoundedBox(4, 4, 4, w - 8, h - 8, CurrentTheme().accent) end
	end

	local slider = vgui.Create("DNumSlider", speedRow)
	slider:Dock(FILL)
	slider:DockMargin(8, 0, 0, 0)
	slider:SetText("#beatrun.coursesmenu.save.maxspeedlock")
	slider:SetMin(325)
	slider:SetMax(1000)
	slider:SetDecimals(0)
	slider:SetValue(325)

	slider.Label:SetTextColor(CurrentTheme().text.primary)

	slider.TextArea:SetTextColor(CurrentTheme().text.primary)
	slider.TextArea:SetPaintBackground(false)

	slider.Slider.Paint = function(self, w, h) draw.RoundedBox(4, 0, h / 2 - 2, w, 4, CurrentTheme().panels.secondary) end
	slider.Slider.Knob.Paint = function(self, w, h) draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().accent) end

	local save = vgui.Create("DButton", content)
	save:Dock(BOTTOM)
	save:SetTall(32)
	save:SetText("#beatrun.coursesmenu.save")
	save:SetFont("AEUIDefault")
	save:SetTextColor(CurrentTheme().buttons.green.t)

	save.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

	save.DoClick = function()
		local name = string.Trim(entry:GetValue())
		if name == "" then return end

		local speed = checkbox:GetChecked() and math.floor(slider:GetValue()) or nil

		local saved = SaveCourse(name, speed)

		if saved then
			local text = language.GetPhrase("beatrun.coursesmenu.notification.save.success"):format("beatrun/" .. currentMap .. "/" .. saved .. ".txt")
			notification.AddLegacy(text, NOTIFY_GENERIC, 6)
		end

		if IsValid(frame) then frame:Close() end
	end
end

local function OpenConfirmPopup(title, message, onConfirm)
	local frameW = math.Clamp(ScrW() * 0.25, 320, 600)
	local frameH = math.Clamp(ScrH() * 0.18, 140, 260)

	local frame = vgui.Create("DFrame")
	frame:SetTitle("")
	frame:SetSize(frameW, frameH)
	frame:Center()
	frame:DockPadding(20, 40, 20, 20)
	frame:ShowCloseButton(false)
	frame:SetDeleteOnClose(true)
	frame:MakePopup()

	frame.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, CurrentTheme().bg)
		draw.RoundedBoxEx(8, 0, 0, w, 24, CurrentTheme().header, true, true, false, false)
		draw.SimpleText(title, "AEUIDefault", 10, 12, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local close = vgui.Create("DButton", frame)
	close:SetSize(24, 24)
	close:SetPos(frame:GetWide() - 24, 0)
	close:SetText("✕")
	close:SetFont("AEUIDefault")
	close:SetTextColor(CurrentTheme().buttons.red.t)

	close.Paint = function(self, w, h)
		local bg = self:IsHovered() and CurrentTheme().buttons.red.h or CurrentTheme().buttons.red.n
		local isDown = self:IsDown() and CurrentTheme().buttons.red.d

		draw.RoundedBoxEx(6, 0, 0, w, h, isDown or bg, false, true, false, false)
	end

	close.DoClick = function() if IsValid(frame) then frame:Close() end end

	local label = vgui.Create("DLabel", frame)
	label:SetText(message)
	label:SetFont("AEUIDefault")
	label:Dock(FILL)
	label:SetWrap(true)
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
	confirm:SetFont("AEUIDefault")
	confirm:SetTextColor(CurrentTheme().buttons.green.t)

	confirm.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

	confirm.DoClick = function()
		if onConfirm then onConfirm() end

		if IsValid(frame) then frame:Close() end
	end

	local cancel = vgui.Create("DButton", buttonRow)
	cancel:Dock(FILL)
	cancel:SetText("#beatrun.misc.cancel")
	cancel:SetFont("AEUIDefault")
	cancel:SetTextColor(CurrentTheme().buttons.red.t)

	cancel.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "red") end
	cancel.DoClick = function() if IsValid(frame) then frame:Close() end end
end

-- Save/load/upload functions
local function SaveCourseToFile(mapName, code, data)
	code = SanitizeString(code)

	file.CreateDir(string.format("beatrun/courses/%s", mapName))

	local path = string.format("beatrun/courses/%s/%s.txt", mapName, code)
	local success = file.Write(path, data)

	return success and path or nil
end

local function FetchAndSaveCourse(course)
	local headers = {
		code = course.code
	}

	http.Fetch("https://" .. databaseDomain:GetString() .. "/api/courses/download", function(body, _, _, code)
		if code ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

			print("> Code: " .. code or "null" .. "\n> Reply: " .. body or "null")

			return
		end

		body = util.JSONToTable(body)

		if body.code ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

			print("> Code: " .. body.code or code or "null" .. "\n> Reply: " .. body.message or "null" .. "\n> Data: " .. body.data or "null")

			return
		end

		local path = SaveCourseToFile(course.mapName, course.code, util.Base64Decode(body))

		if not path then
			notification.AddLegacy("#beatrun.coursesmenu.notification.save.failed", NOTIFY_ERROR, 4)
			return
		end

		notification.AddLegacy(language.GetPhrase("#beatrun.coursesmenu.notification.save.success"):format(path), NOTIFY_GENERIC, 4)
	end, function(err)
		notification.AddLegacy("#beatrun.coursesmenu.notification.openconsole", NOTIFY_ERROR, 4)
		print("> /api/courses/download\nError: ", err)
	end, headers)
end

local function FetchAndStartCourse(code)
	local headers = {
		code = code
	}

	http.Fetch("https://" .. databaseDomain:GetString() .. "/api/courses/download", function(body, _, _, code)
		if code ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

			print("> Code: " .. code or "null" .. "\n> Reply: " .. body or "null")

			return
		end

		local res = util.JSONToTable(body)

		if res and res.code and res.code ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

			print("> Code: " .. res.code or code or "null" .. "\n> Reply: " .. res.message or "null" .. "\n> Data: " .. res.data or "null")

			return
		end

		LoadCourseRaw(util.Base64Decode(body))

		notification.AddLegacy(language.GetPhrase("#beatrun.coursesmenu.notification.startingcourse"):format(code), NOTIFY_GENERIC, 4)
	end, function(err)
		notification.AddLegacy("#beatrun.coursesmenu.notification.openconsole", NOTIFY_ERROR, 4)
		print("> /api/courses/download\nError: ", err)
	end, headers)
end

local function UploadCourseFile(course)
	if not databaseApiKey:GetString() or databaseApiKey:GetString() == "0" or databaseApiKey:GetString() == "" then
		notification.AddLegacy("#beatrun.coursesmenu.notification.nokey", NOTIFY_ERROR, 4)

		return
	end

	local raw = file.Read(course, "DATA")
	if not raw then
		notification.AddLegacy("#beatrun.coursesmenu.notification.read.failed", NOTIFY_ERROR, 4)

		return
	end

	local encoded = util.Base64Encode(raw, true)

	local headers = {
		authorization = databaseApiKey:GetString(),
		mapName = currentMap,
		workshopId = GetCurrentMapWorkshopID()
	}

	http.Post("https://" .. databaseDomain:GetString() .. "/api/courses/upload", {
		data = encoded
	}, function(body, _, _, code)
		if code ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

			print("> Code: " .. code or "null" .. "\n> Reply: " .. body or "null")

			return
		end

		body = util.JSONToTable(body)

		if body.code ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

			print("> Code: " .. body.code or code or "null" .. "\n> Reply: " .. body.message or "null" .. "\n> Data: " .. body.data or "null")

			return
		end

		notification.AddLegacy("#beatrun.coursesmenu.notification.upload.success", NOTIFY_GENERIC, 4)

		print("> Code: " .. body.code .. "\n> Reply: " .. body.message)
	end, function(err)
		notification.AddLegacy("#beatrun.coursesmenu.notification.openconsole", NOTIFY_ERROR, 4)
		print("> /api/courses/upload\nError: ", err)
	end, headers)
end

-- Pages
local function BuildLocalPage()
	if not IsValid(LocalPanel) then return end

	LocalPanel:Clear()

	local top = vgui.Create("DPanel", LocalPanel)
	top:Dock(TOP)
	top:SetTall(60)
	top:DockPadding(20, 20, 20, 10)
	top.Paint = nil

	local saveBtn = vgui.Create("DButton", top)
	saveBtn:Dock(LEFT)
	saveBtn:DockMargin(0, 0, 15, 0)
	saveBtn:SetTall(28)
	saveBtn:SetText("#beatrun.coursesmenu.localpage.savecourse")
	saveBtn:SetFont("AEUISmall")
	saveBtn:SetTextColor(CurrentTheme().buttons.green.t)
	saveBtn:SizeToContentsX()

	saveBtn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end
	saveBtn.DoClick = function() OpenCourseSaveMenu() end

	local buildBtn = vgui.Create("DButton", top)
	buildBtn:Dock(LEFT)
	buildBtn:DockMargin(0, 0, 15, 0)
	buildBtn:SetText("#beatrun.coursesmenu.localpage.buildmode")
	buildBtn:SetFont("AEUISmall")
	buildBtn:SetTextColor(CurrentTheme().buttons.green.t)
	buildBtn:SizeToContentsX()
	buildBtn:SetEnabled(LocalPlayer():IsSuperAdmin())

	buildBtn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

	buildBtn.DoClick = function()
		LocalPlayer():ConCommand("Beatrun_BuildMode")

		if IsValid(Frame) then Frame:Close() end
	end

	local exitBtn = vgui.Create("DButton", top)
	exitBtn:Dock(LEFT)
	exitBtn:DockMargin(0, 0, 15, 0)
	exitBtn:SetText("#beatrun.coursesmenu.localpage.freeplay")
	exitBtn:SetFont("AEUISmall")
	exitBtn:SetTextColor(CurrentTheme().buttons.red.t)
	exitBtn:SizeToContentsX()
	exitBtn:SetEnabled(LocalPlayer():IsSuperAdmin())

	exitBtn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "red") end

	exitBtn.DoClick = function()
		if CourseGhost:GetBool() then StopGhostRecording(false, false) end

		net.Start("Course_Stop")
		net.SendToServer()
	end

	local divider = vgui.Create("DPanel", LocalPanel)
	divider:Dock(TOP)
	divider:SetTall(1)
	divider:DockMargin(0, 10, 0, 10)
	divider.Paint = function(self, w, h)
		surface.SetDrawColor(CurrentTheme().primary:Unpack())
		surface.DrawRect(0, 0, w, h)
	end

	local title = vgui.Create("DLabel", LocalPanel)
	title:SetText(language.GetPhrase("beatrun.coursesmenu.localpage.savedcourses"):format(currentMap))
	title:SetFont("AEUILarge")
	title:SetTextColor(CurrentTheme().text.primary)
	title:Dock(TOP)
	title:DockMargin(20, 0, 0, 10)
	title:SizeToContents()

	local scroll = vgui.Create("DScrollPanel", LocalPanel)
	scroll:Dock(FILL)
	scroll:DockMargin(20, 0, 20, 20)

	ApplyScrollTheme(scroll)

	local path = string.format("beatrun/courses/%s/", currentMap)
	local files = file.Find(path .. "*.txt", "DATA")

	if not files or #files == 0 then
		local empty = vgui.Create("DLabel", scroll)
		empty:SetText("#beatrun.coursesmenu.localpage.nosavedcourses")
		empty:SetFont("AEUIDefault")
		empty:SetTextColor(CurrentTheme().text.muted)
		empty:Dock(TOP)
		empty:DockMargin(0, 5, 0, 0)
		empty:SizeToContents()

		return
	end

	for _, filename in ipairs(files) do
		local raw = file.Read(path .. filename)
		local data = util.Decompress(raw) or raw
		local tbl = util.JSONToTable(data)
		local courseId = util.CRC(data)

		local entry = scroll:Add("DPanel")
		entry:SetTall(55)
		entry:Dock(TOP)
		entry:DockMargin(0, 0, 0, 8)

		entry.Paint = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().panels.primary)
			draw.SimpleText(string.format("%s (%s)", tbl[5], courseId), "AEUIDefault", 15, h / 2, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local loadBtn = vgui.Create("DButton", entry)
		loadBtn:Dock(RIGHT)
		loadBtn:SetWide(90)
		loadBtn:DockMargin(0, 10, 10, 10)
		loadBtn:SetText("#beatrun.coursesmenu.start")
		loadBtn:SetFont("AEUIDefault")
		loadBtn:SetTextColor(CurrentTheme().buttons.green.t)
		loadBtn:SetEnabled(LocalPlayer():IsSuperAdmin())

		loadBtn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

		loadBtn.DoClick = function()
			LoadCourse(filename)

			if IsValid(Frame) then Frame:Close() end
		end

		local uploadBtn = vgui.Create("DButton", entry)
		uploadBtn:Dock(RIGHT)
		uploadBtn:SetWide(90)
		uploadBtn:DockMargin(0, 10, 10, 10)
		uploadBtn:SetText("#beatrun.coursesmenu.upload")
		uploadBtn:SetFont("AEUIDefault")
		uploadBtn:SetTextColor(CurrentTheme().buttons.green.t)

		uploadBtn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

		uploadBtn.DoClick = function()
			OpenConfirmPopup("#beatrun.coursesmenu.upload", "#beatrun.coursesmenu.upload.confirm", function()
				UploadCourseFile(path .. filename)
			end)
		end

		local deleteBtn = vgui.Create("DButton", entry)
		deleteBtn:Dock(RIGHT)
		deleteBtn:SetWide(90)
		deleteBtn:DockMargin(0, 10, 10, 10)
		deleteBtn:SetText("#beatrun.coursesmenu.delete")
		deleteBtn:SetFont("AEUIDefault")
		deleteBtn:SetTextColor(CurrentTheme().buttons.red.t)

		deleteBtn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "red") end

		deleteBtn.DoClick = function()
			OpenConfirmPopup("#beatrun.coursesmenu.delete", "#beatrun.coursesmenu.delete.confirm", function()
				local deleted = file.Delete(path .. filename, "DATA")

				if deleted then BuildLocalPage() end
			end)
		end
	end
end

local function BuildProfilePage()
	if not IsValid(ProfilePanel) then return end

	ProfilePanel:Clear()

	local apiKey = databaseApiKey:GetString()
	local headers = {
		key = apiKey ~= "" and apiKey or "0"
	}

	http.Fetch("https://" .. databaseDomain:GetString() .. "/api/key/validate", function(body, _, _, code)
		if code ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

			print("> Code: " .. code or "null" .. "\n> Reply: " .. body or "null")

			return
		end

		body = util.JSONToTable(body)

		if body.code ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

			print("> Code: " .. body.code or code or "null" .. "\n> Reply: " .. body.message or "null" .. "\n> Data: " .. body.data or "null")

			return
		end

		local valid = body.data

		if not valid then
			local msg = vgui.Create("DLabel", ProfilePanel)
			msg:SetFont("AEUILarge")
			msg:SetText("#beatrun.coursesmenu.profilepage.message")
			msg:SetTextColor(CurrentTheme().text.primary)
			msg:SizeToContents()
			msg:Dock(TOP)
			msg:DockMargin(0, 60, 0, 20)
			msg:SetContentAlignment(5)

			local registerBtn = vgui.Create("DButton", ProfilePanel)
			registerBtn:SetText("#beatrun.coursesmenu.profilepage.register")
			registerBtn:SetFont("AEUIDefault")
			registerBtn:SetTall(40)
			registerBtn:Dock(TOP)
			registerBtn:DockMargin(200, 0, 200, 0)
			registerBtn:SetTextColor(CurrentTheme().buttons.green.t)

			registerBtn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

			registerBtn.DoClick = function()
				local headers = {
					steamid = LocalPlayer():SteamID64(),
					username = LocalPlayer():Nick()
				}

				http.Post("https://" .. databaseDomain:GetString() .. "/api/users/register", {}, function(body, _, _, code)
					if code ~= 200 then
						notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

						print("> Code: " .. code or "null" .. "\n> Reply: " .. body or "null")

						return
					end

					body = util.JSONToTable(body)

					if body.code ~= 200 then
						notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

						print("> Code: " .. body.code or code or "null" .. "\n> Reply: " .. body.message or "null" .. "\n> Data: " .. body.data or "null")

						return
					end

					print("Updated Beatrun API key to " .. body.data.key)

					databaseApiKey:SetString(body.data.key)

					BuildProfilePage()
				end, function(err)
					notification.AddLegacy("#beatrun.coursesmenu.notification.openconsole", NOTIFY_ERROR, 4)
					print("> /api/users/register\nError: ", err)
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
		name:SetTextColor(CurrentTheme().text.primary)
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
		keyLabel:SetText(language.GetPhrase("beatrun.coursesmenu.profilepage.key"):format(masked))
		keyLabel:SetTextColor(CurrentTheme().text.muted)
		keyLabel:Dock(LEFT)
		keyLabel:SizeToContents()

		local changeBtn = vgui.Create("DButton", keyRow)
		changeBtn:SetText("#beatrun.coursesmenu.profilepage.changekey")
		changeBtn:SetTextColor(CurrentTheme().buttons.green.t)
		changeBtn:SetFont("AEUIDefault")
		changeBtn:SetCursor("hand")
		changeBtn:Dock(LEFT)
		changeBtn:DockMargin(10, 0, 0, 0)
		changeBtn:SizeToContents()

		changeBtn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

		changeBtn.DoClick = function()
			local frame = vgui.Create("DFrame")
			frame:SetSize(360, 150)
			frame:Center()
			frame:SetTitle("")
			frame:ShowCloseButton(false)
			frame:MakePopup()

			frame.Paint = function(self, w, h)
				draw.RoundedBox(8, 0, 0, w, h, CurrentTheme().bg)
				draw.RoundedBox(8, 0, 0, w, 24, CurrentTheme().header)
				draw.SimpleText("#beatrun.coursesmenu.profilepage.changekey", "AEUIDefault", 10, 12, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			local close = vgui.Create("DButton", frame)
			close:SetSize(24, 24)
			close:SetPos(frame:GetWide() - 24, 0)
			close:SetText("✕")
			close:SetFont("AEUIDefault")
			close:SetTextColor(CurrentTheme().buttons.red.t)

			close.Paint = function(self, w, h)
				local bg = self:IsHovered() and CurrentTheme().buttons.red.h or CurrentTheme().buttons.red.n
				local isDown = self:IsDown() and CurrentTheme().buttons.red.d

				draw.RoundedBoxEx(6, 0, 0, w, h, isDown or bg, false, true, false, false)
			end

			close.DoClick = function() if IsValid(frame) then frame:Close() end end

			local entry = vgui.Create("DTextEntry", frame)
			entry:SetFont("AEUIDefault")
			entry:SetPlaceholderText("#beatrun.coursesmenu.profilepage.changekey.placeholder")
			entry:SetTall(32)
			entry:Dock(TOP)
			entry:DockMargin(0, 20, 0, 0)
			entry:SetPaintBackground(false)

			entry.Paint = function(self, w, h)
				surface.SetDrawColor(CurrentTheme().text.muted)
				surface.DrawOutlinedRect(0, 0, w, h, 1)

				self:DrawTextEntryText(CurrentTheme().text.primary, CurrentTheme().text.muted, CurrentTheme().cursor)

				if self:GetValue() == "" then draw.SimpleText(self:GetPlaceholderText(), self:GetFont(), 5, h / 2, CurrentTheme().text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end

				if self:HasFocus() then
					surface.SetDrawColor(CurrentTheme().search:Unpack())
					surface.DrawOutlinedRect(0, 0, w, h, 1)
				end
			end

			local save = vgui.Create("DButton", frame)
			save:Dock(BOTTOM)
			save:SetTall(32)
			save:SetText("#beatrun.coursesmenu.save")
			save:SetFont("AEUIDefault")
			save:SetTextColor(CurrentTheme().buttons.green.t)

			save.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

			save.DoClick = function()
				local newKey = string.Trim(entry:GetValue())
				if newKey == "" then return end

				databaseApiKey:SetString(newKey)

				if IsValid(frame) then frame:Close() end

				BuildProfilePage()
			end
		end

		local statsPanel = vgui.Create("DPanel", ProfilePanel)
		statsPanel:SetTall(60)
		statsPanel:Dock(TOP)
		statsPanel:DockMargin(0, 15, 0, 15)

		statsPanel.Paint = function(self, w, h) draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().panels.secondary) end

		local statsLabel = vgui.Create("DLabel", statsPanel)
		statsLabel:SetFont("AEUIDefault")
		statsLabel:SetTextColor(CurrentTheme().text.primary)
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

		statsLabel:SetText(language.GetPhrase("beatrun.coursesmenu.profilepage.stats"):format(#myCourses, totalDownloads))

		local myList = vgui.Create("DScrollPanel", ProfilePanel)
		myList:Dock(FILL)

		ApplyScrollTheme(myList)

		if #myCourses == 0 then
			local empty = vgui.Create("DLabel", myList)
			empty:SetText("#beatrun.coursesmenu.profilepage.nouploadedcourses")
			empty:SetFont("AEUIDefault")
			empty:SetTextColor(CurrentTheme().text.muted)
			empty:Dock(TOP)
			empty:DockMargin(0, 5, 0, 0)
			empty:SizeToContents()

			return
		end

		for _, v in ipairs(myCourses) do
			local entry = myList:Add("DPanel")
			entry:SetTall(60)
			entry:Dock(TOP)
			entry:DockMargin(0, 0, 0, 8)

			entry.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().panels.secondary)
				draw.SimpleText(v.name, "AEUIDefault", 10, 5, CurrentTheme().text.primary)
				draw.SimpleText(language.GetPhrase("beatrun.coursesmenu.downloads"):format(v.downloadCount), "AEUIDefault", 10, 22, CurrentTheme().text.muted)
				draw.SimpleText(language.GetPhrase("beatrun.coursesmenu.uploadedat"):format(v.uploadedAt), "AEUIDefault", 10, 38, CurrentTheme().text.muted)
			end

			local startBtn = vgui.Create("DButton", entry)
			startBtn:Dock(RIGHT)
			startBtn:SetWide(90)
			startBtn:DockMargin(0, 10, 10, 10)
			startBtn:SetText("Start")
			startBtn:SetFont("AEUIDefault")
			startBtn:SetTextColor(CurrentTheme().buttons.green.t)

			startBtn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end
			startBtn.DoClick = function() FetchAndStartCourse(v.code) end

			local deleteBtn = vgui.Create("DButton", entry)
			deleteBtn:Dock(RIGHT)
			deleteBtn:SetWide(90)
			deleteBtn:DockMargin(0, 10, 10, 10)
			deleteBtn:SetText("#beatrun.coursesmenu.delete")
			deleteBtn:SetFont("AEUIDefault")
			deleteBtn:SetTextColor(CurrentTheme().buttons.red.t)

			deleteBtn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "red") end

			deleteBtn.DoClick = function()
				OpenConfirmPopup("#beatrun.coursesmenu.delete", "#beatrun.coursesmenu.delete.confirm", function()
					HTTP({
						method = "DELETE",
						url = "https://" .. databaseDomain:GetString() .. "/api/courses/delete",
						headers = {
							authorization = databaseApiKey:GetString(),
							code = v.code,
						},
						success = function(code, body)
							if code ~= 200 then
								notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

								print("> Code: " .. code or "null" .. "\n> Reply: " .. body or "null")

								return
							end

							body = util.JSONToTable(body)

							if body.code ~= 200 then
								notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

								print("> Code: " .. body.code or code or "null" .. "\n> Reply: " .. body.message or "null" .. "\n> Data: " .. body.data or "null")

								return
							end
						end,
						failed = function(err) print("> /api/courses/delete\nError: ", err) end
					})

					BuildProfilePage()
				end)
			end
		end
	end, function(err)
		notification.AddLegacy("#beatrun.coursesmenu.notification.openconsole", NOTIFY_ERROR, 4)
		print("> /api/key/validate\nError: ", err)
	end, headers)
end

local function ApplyCourseFilter(newText)
	if not Beatrun_CoursesCache.all then return end

	local text = string.lower(newText or "")
	local filtered = {}

	for _, course in ipairs(Beatrun_CoursesCache.all) do
		if isCurrentMapOnly and course.mapName ~= currentMap then continue end

		local searchStr = string.lower(course.name .. course.mapName .. course.code .. course.uploadedBy.username)
		if text ~= "" and not string.find(searchStr, text) then continue end

		filtered[#filtered + 1] = course
	end

	Beatrun_CoursesCache.filtered = filtered
end

local function BuildOnlinePage()
	if not IsValid(List) then return end

	List:Clear()

	if not IsCoursesCacheValid() then
		if Beatrun_CoursesCache.loading then return end

		Beatrun_CoursesCache.loading = true

		local headers = {
			game = "yes"
		}

		http.Fetch("https://" .. databaseDomain:GetString() .. "/api/courses/list", function(body, _, _, code)
			Beatrun_CoursesCache.loading = false

			if code ~= 200 then
				notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

				print("> Code: " .. code or "null" .. "\n> Reply: " .. body or "null")

				return
			end

			body = util.JSONToTable(body)

			if body.code ~= 200 then
				notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)

				print("> Code: " .. body.code or code or "null" .. "\n> Reply: " .. body.message or "null" .. "\n> Data: " .. body.data or "null")

				return
			end

			local fetchedCourses = {}

			for _, course in ipairs(body.data) do
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
			BuildOnlinePage()

			if IsValid(ProfilePanel) then BuildProfilePage() end

			for _, v in ipairs(Beatrun_CoursesCache.all) do
				CacheMapPreview(v)
			end
		end, function(err)
			Beatrun_CoursesCache.loading = false

			notification.AddLegacy("#beatrun.coursesmenu.notification.openconsole", NOTIFY_ERROR, 4)
			print("> /api/courses/list\nError: ", err)
		end, headers)

		return
	end

	for _, v in ipairs(Beatrun_CoursesCache.filtered) do
		local entry = List:Add("DPanel")
		entry:SetTall(120)
		entry:Dock(TOP)
		entry:DockMargin(10, 10, 10, 0)

		entry.Paint = function(self, w, h)
			local col = self:IsHovered() and CurrentTheme().panels.secondary or CurrentTheme().panels.primary
			draw.RoundedBox(6, 0, 0, w, h, col)

			local mapMaterial = Beatrun_MapImageCache[v.mapName]

			if mapMaterial and not mapMaterial:IsError() then
				surface.SetMaterial(mapMaterial)
				surface.SetDrawColor(255, 255, 255)
				surface.DrawTexturedRect(10, 10, 160, 98)
			else
				draw.RoundedBox(4, 10, 10, 160, 98, CurrentTheme().panels.secondary)
				draw.SimpleText("No image", "AEUIDefault", 86, 59, CurrentTheme().text.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			draw.SimpleText(v.name, "AEUILarge", 180, 5, CurrentTheme().text.primary)
			draw.SimpleText(language.GetPhrase("beatrun.coursesmenu.uploadedat"):format(v.uploadedAt), "AEUIDefault", 184, 85, CurrentTheme().text.muted)
		end

		local mapBtn = vgui.Create("DButton", entry)
		mapBtn:SetText(v.mapName)
		mapBtn:SetFont("AEUIDefault")
		mapBtn:SetPos(180, 63)
		mapBtn:SizeToContents()
		mapBtn:SetCursor(v.workshopId and "hand" or "arrow")
		mapBtn:SetTextColor(CurrentTheme().text.muted)
		mapBtn:SetPaintBackground(false)

		mapBtn.DoClick = function() if v.workshopId then gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. v.workshopId) end end

		mapBtn.OnCursorEntered = function(self) if v.workshopId then self:SetTextColor(CurrentTheme().accent) end end
		mapBtn.OnCursorExited = function(self) if v.workshopId then self:SetTextColor(CurrentTheme().text.muted) end end

		local codeBtn = vgui.Create("DButton", entry)
		codeBtn:SetText(v.code)
		codeBtn:SetFont("AEUIDefault")
		codeBtn:SetPos(180, 35)
		codeBtn:SizeToContents()
		codeBtn:SetCursor("hand")
		codeBtn:SetTextColor(CurrentTheme().text.muted)
		codeBtn:SetPaintBackground(false)

		codeBtn.DoClick = function(self)
			SetClipboardText(v.code)

			if IsValid(self) then
				self:SetText("#beatrun.coursesmenu.copied")
				self:SizeToContents()
			end

			timer.Simple(2, function()
				if IsValid(self) then
					self:SetText(v.code)
					self:SizeToContents()
				end
			end)
		end

		codeBtn.OnCursorEntered = function(self) self:SetTextColor(CurrentTheme().accent) end
		codeBtn.OnCursorExited = function(self) self:SetTextColor(CurrentTheme().text.muted) end

		local rightPanel = vgui.Create("DPanel", entry)
		rightPanel:Dock(RIGHT)
		rightPanel:SetWide(170)
		rightPanel:DockMargin(0, 8, 10, 8)

		rightPanel.Paint = function(self, w, h)
			surface.SetDrawColor(CurrentTheme().secondary:Unpack())
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
		nameBtn:SetText(v.uploadedBy.username or "Unknown")
		nameBtn:SetFont("AEUIDefault")
		nameBtn:Dock(FILL)
		nameBtn:SetCursor("hand")
		nameBtn:SetContentAlignment(4)
		nameBtn:SetTextColor(CurrentTheme().text.primary)
		nameBtn:SetPaintBackground(false)

		nameBtn.DoClick = function() gui.OpenURL("https://steamcommunity.com/profiles/" .. v.uploadedBy.steamId) end

		nameBtn.OnCursorEntered = function(self) self:SetTextColor(CurrentTheme().accent) end
		nameBtn.OnCursorExited = function(self) self:SetTextColor(CurrentTheme().text.primary) end

		local loadPanel = vgui.Create("DPanel", rightPanel)
		loadPanel:SetTall(70)
		loadPanel:Dock(BOTTOM)
		loadPanel:DockMargin(10, 0, 0, 4)
		loadPanel.Paint = nil

		local loadBtn = vgui.Create("DButton", loadPanel)
		loadBtn:SetText("#beatrun.coursesmenu.onlinepage.start")
		loadBtn:SetFont("AEUIDefault")
		loadBtn:Dock(FILL)
		loadBtn:SetCursor("hand")
		loadBtn:SetTextColor(CurrentTheme().buttons.primary.t)

		loadBtn.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "primary") end

		loadBtn.DoClick = function()
			if v.workshopId and not steamworks.IsSubscribed(v.workshopId) then
				local loadWarn = vgui.Create("DFrame")
				loadWarn:SetTitle("")
				loadWarn:SetSize(360, 140)
				loadWarn:Center()
				loadWarn:SetDeleteOnClose(true)
				loadWarn:ShowCloseButton(false)
				loadWarn:MakePopup()

				loadWarn.Paint = function(self, w, h)
					draw.RoundedBox(8, 0, 0, w, h, CurrentTheme().bg)
					draw.RoundedBox(8, 0, 0, w, 24, CurrentTheme().header)
					draw.SimpleText("#beatrun.coursesmenu.onlinepage.start", "AEUIDefault", 10, 12, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end

				local close = vgui.Create("DButton", loadWarn)
				close:SetSize(24, 24)
				close:SetPos(loadWarn:GetWide() - 24, 0)
				close:SetText("✕")
				close:SetFont("AEUIDefault")
				close:SetTextColor(CurrentTheme().buttons.red.t)

				close.Paint = function(self, w, h)
					local bg = self:IsHovered() and CurrentTheme().buttons.red.h or CurrentTheme().buttons.red.n
					local isDown = self:IsDown() and CurrentTheme().buttons.red.d

					draw.RoundedBoxEx(6, 0, 0, w, h, isDown or bg, false, true, false, false)
				end

				close.DoClick = function() if IsValid(loadWarn) then loadWarn:Close() end end

				local label = vgui.Create("DLabel", loadWarn)
				label:SetText("#beatrun.coursesmenu.onlinepage.start.message")
				label:SetFont("AEUISmall")
				label:SetWrap(true)
				label:SetSize(330, 60)
				label:SetPos(15, 35)

				local workshop = vgui.Create("DButton", loadWarn)
				workshop:SetText("#beatrun.coursesmenu.onlinepage.openworkshop")
				workshop:SetFont("AEUIDefault")
				workshop:SetSize(150, 30)
				workshop:SetPos(20, 95)
				workshop:SetTextColor(CurrentTheme().buttons.green.t)
				workshop:SetEnabled(v.workshopId ~= nil)

				workshop.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "green") end

				workshop.DoClick = function()
					gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. v.workshopId)

					if IsValid(loadWarn) then loadWarn:Close() end
				end

				local iKnowWhatImDoing = vgui.Create("DButton", loadWarn)
				iKnowWhatImDoing:SetText("#beatrun.coursesmenu.onlinepage.iknowwhatimdoing")
				iKnowWhatImDoing:SetFont("AEUISmall")
				iKnowWhatImDoing:SetSize(150, 30)
				iKnowWhatImDoing:SetPos(190, 95)
				iKnowWhatImDoing:SetTextColor(CurrentTheme().buttons.red.t)

				iKnowWhatImDoing.Paint = function(self, w, h) ApplyButtonTheme(self, w, h, "red") end

				iKnowWhatImDoing.DoClick = function()
					FetchAndStartCourse(v.code)

					if IsValid(Frame) then Frame:Close() end
					if IsValid(loadWarn) then loadWarn:Close() end
				end

				return
			end

			FetchAndStartCourse(v.code)

			if IsValid(Frame) then Frame:Close() end
		end

		local downloadBtn = vgui.Create("DButton", loadPanel)
		downloadBtn:SetText("#beatrun.coursesmenu.onlinepage.download")
		downloadBtn:SetFont("AEUIDefault")
		downloadBtn:Dock(BOTTOM)
		downloadBtn:SetTall(28)
		downloadBtn:DockMargin(0, 6, 0, 0)
		downloadBtn:SetCursor("hand")
		downloadBtn:SetTextColor(CurrentTheme().buttons.green.t)

		local code = string.lower(v.code)
		local courseDoesExist = file.Exists(string.format("beatrun/courses/%s/%s.txt", v.mapName, code), "DATA")

		downloadBtn.Paint = function(self, w, h)
			local bg = self:IsHovered() and CurrentTheme().buttons.green.h or CurrentTheme().buttons.green.n
			local isDown = self:IsDown() and CurrentTheme().buttons.green.d

			if courseDoesExist then
				bg = self:IsHovered() and CurrentTheme().buttons.red.h or CurrentTheme().buttons.red.n
				isDown = self:IsDown() and CurrentTheme().buttons.red.d

				self:SetText("#beatrun.coursesmenu.onlinepage.overwrite")
				self:SetTextColor(CurrentTheme().buttons.red.t)
			end

			draw.RoundedBox(4, 0, 0, w, h, isDown or bg)
		end

		downloadBtn.DoClick = function()
			if courseDoesExist then
				OpenConfirmPopup("#beatrun.coursesmenu.onlinepage.overwrite", "#beatrun.coursesmenu.onlinepage.overwrite.confirm", function()
					FetchAndSaveCourse(v)
				end)

				return
			end

			FetchAndSaveCourse(v)
		end
	end
end

function BuildSettingsPage()
	if not IsValid(SettingsPanel) then return end

	SettingsPanel:Clear()

	local title = vgui.Create("DLabel", SettingsPanel)
	title:Dock(TOP)
	title:SetText("#beatrun.coursesmenu.settings")
	title:SetFont("AEUILarge")
	title:SetTextColor(CurrentTheme().text.primary)
	title:DockMargin(0, 0, 0, 15)
	title:SizeToContents()

	local themeLabel = vgui.Create("DLabel", SettingsPanel)
	themeLabel:Dock(TOP)
	themeLabel:SetText("#beatrun.coursesmenu.settings.theme")
	themeLabel:SetFont("AEUIDefault")
	themeLabel:SetTextColor(CurrentTheme().text.primary)
	themeLabel:DockMargin(0, 0, 0, 5)
	themeLabel:SizeToContents()

	local themeSelect = vgui.Create("DComboBox", SettingsPanel)
	themeSelect:Dock(TOP)
	themeSelect:SetTall(30)
	themeSelect:DockMargin(0, 0, Frame:GetWide() - 500, 20)
	themeSelect:SetFont("AEUIDefault")
	themeSelect:SetTextColor(CurrentTheme().text.primary)
	themeSelect:SetValue(language.GetPhrase("beatrun.coursesmenu.themes." .. string.lower(uiTheme:GetString())))
	themeSelect:SetPaintBackground(false)
	themeSelect:SetTextInset(8, 0)
	themeSelect:SizeToContents()

	themeSelect.DropButton:SetVisible(false)

	themeSelect.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().panels.secondary)

		if self:IsHovered() or self:IsMenuOpen() then
			surface.SetDrawColor(CurrentTheme().accent)
		else
			surface.SetDrawColor(CurrentTheme().text.muted)
		end

		surface.DrawOutlinedRect(0, 0, w, h, 1)

		local arrow = self:IsMenuOpen() and "◂" or "▾"
		local selected = themeSelect:GetValue()

		surface.SetFont("AEUISmall")
		draw.SimpleText(selected, "AEUISmall", surface.GetTextSize(selected), h / 2, CurrentTheme().text.primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(arrow, "AEUISmall", w - 18, h / 2, CurrentTheme().text.primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		return true
	end

	function themeSelect:OpenMenu()
		DComboBox.OpenMenu(self)

		if not IsValid(self.Menu) then return end

		self.Menu.Paint = function(s, w, h)
			draw.RoundedBox(6, 0, 0, w, h, CurrentTheme().bg)
			surface.SetDrawColor(CurrentTheme().text.muted)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end

		for _, option in pairs(self.Menu:GetCanvas():GetChildren()) do
			option:SetTextColor(CurrentTheme().text.primary)

			option.Paint = function(s, w, h) if s:IsHovered() then draw.RoundedBox(0, 0, 0, w, h, CurrentTheme().panels.secondary) end end
		end
	end

	for _, v in pairs(table.GetKeys(THEME)) do
		themeSelect:AddChoice(language.GetPhrase("beatrun.coursesmenu.themes." .. v), v)
	end

	function themeSelect:OnSelect(_, _, data)
		if uiTheme:GetString() == data then return end

		uiTheme:SetString(data)

		if IsValid(Frame) then Frame:Close() end

		timer.Simple(.1, function()
			RunConsoleCommand("Beatrun_CoursesMenu")
		end)
	end

	local domainLabel = vgui.Create("DLabel", SettingsPanel)
	domainLabel:Dock(TOP)
	domainLabel:SetText("#beatrun.coursesmenu.settings.domain")
	domainLabel:SetFont("AEUIDefault")
	domainLabel:SetTextColor(CurrentTheme().text.primary)
	domainLabel:DockMargin(0, 0, 0, 5)
	domainLabel:SizeToContents()

	local domainEntry = vgui.Create("DTextEntry", SettingsPanel)
	domainEntry:Dock(TOP)
	domainEntry:SetTall(30)
	domainEntry:SetPlaceholderText(databaseDomain:GetString())
	domainEntry:DockMargin(0, 0, Frame:GetWide() - 500, 15)
	domainEntry:SetPaintBackground(false)
	domainEntry:SizeToContents()

	domainEntry.Paint = function(self, w, h)
		surface.SetDrawColor(CurrentTheme().text.muted)
		surface.DrawOutlinedRect(0, 0, w, h, 1)

		self:DrawTextEntryText(CurrentTheme().text.primary, CurrentTheme().text.muted, CurrentTheme().cursor)

		if self:GetValue() == "" then draw.SimpleText(self:GetPlaceholderText(), self:GetFont(), 5, h / 2, CurrentTheme().text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end

		if self:HasFocus() then
			surface.SetDrawColor(CurrentTheme().search:Unpack())
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end
	end

	function domainEntry:OnLoseFocus()
		local val = string.Trim(self:GetValue())

		if not val or val == "" then
			val = databaseDomain:GetDefault()
		end

		val = string.gsub(val, "^https?://", "")
		val = string.gsub(val, "/+$", "")

		databaseDomain:SetString(val)

		self:SetText(val)
	end

	function domainEntry:OnEnter(value)
		local val = string.Trim(value)
		val = string.gsub(val, "^https?://", "")
		val = string.gsub(val, "/+$", "")

		databaseDomain:SetString(val)

		self:SetText(val)
	end
end

function OpenDBMenu()
	if IsValid(Frame) then Frame:Remove() end

	Frame = vgui.Create("DFrame")
	Frame:SetSize(ScrW() / 1.1, ScrH() / 1.1)
	Frame:Center()
	Frame:SetTitle("")
	Frame:ShowCloseButton(false)
	Frame:MakePopup()

	Frame.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, CurrentTheme().bg)
		draw.RoundedBoxEx(8, 0, 0, w, 24, CurrentTheme().header, true, true, false, false)
		draw.SimpleText(string.format("Epic Courses Menu (%s)", databaseDomain:GetString()), "AEUIDefault", 10, 12, CurrentTheme().text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local close = vgui.Create("DButton", Frame)
	close:SetText("✕")
	close:SetFont("AEUIDefault")
	close:SetSize(24, 24)
	close:SetPos(Frame:GetWide() - 24, 0)
	close:SetTextColor(CurrentTheme().buttons.red.t)

	close.Paint = function(self, w, h)
		local bg = self:IsHovered() and CurrentTheme().buttons.red.h or CurrentTheme().buttons.red.n
		local isDown = self:IsDown() and CurrentTheme().buttons.red.d

		draw.RoundedBoxEx(6, 0, 0, w, h, isDown or bg, false, true, false, false)
	end

	close.DoClick = function() if IsValid(Frame) then Frame:Close() end end

	Sheet = vgui.Create("DPropertySheet", Frame)
	Sheet:Dock(FILL)

	Sheet.OnActiveTabChanged = function(self, old, new)
		local img = new.Image:GetImage()

		if string.match(img, "/folder_user") then
			BuildLocalPage()
		elseif string.match(img, "/folder_database") then
			ApplyCourseFilter()
			BuildOnlinePage()
		elseif string.match(img, "/user") then
			BuildProfilePage()
		elseif string.match(img, "/cog") then
			BuildSettingsPage()
		end
	end

	-- Local page
	LocalPanel = vgui.Create("DPanel", Sheet)
	LocalPanel:Dock(FILL)
	LocalPanel:DockPadding(0, 0, 0, 0)
	LocalPanel:SetBackgroundColor(CurrentTheme().bg)

	Sheet:AddSheet("#beatrun.coursesmenu.localpage", LocalPanel, "icon16/folder_user.png")

	-- Browse page
	BrowsePanel = vgui.Create("DPanel", Sheet)
	BrowsePanel:Dock(FILL)
	BrowsePanel:DockPadding(0, 0, 0, 0)
	BrowsePanel:SetBackgroundColor(CurrentTheme().bg)

	Sheet:AddSheet("#beatrun.coursesmenu.onlinepage", BrowsePanel, "icon16/folder_database.png")

	Header = vgui.Create("DPanel", BrowsePanel)
	Header:Dock(TOP)
	Header:SetTall(40)
	Header:DockPadding(10, 8, 10, 8)

	Header.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, CurrentTheme().header)
	end

	local CurrentMapBtn = vgui.Create("DButton", Header)
	CurrentMapBtn:SetText("placeholder")
	CurrentMapBtn:SetFont("AEUISmall")
	CurrentMapBtn:SetTextColor(CurrentTheme().buttons.primary.t)
	CurrentMapBtn:SizeToContentsX()
	CurrentMapBtn:Dock(LEFT)
	CurrentMapBtn:DockMargin(0, 0, 8, 0)

	CurrentMapBtn.Paint = function(self, w, h)
		local text = isCurrentMapOnly and "#beatrun.coursesmenu.onlinepage.currentmap" or "#beatrun.coursesmenu.onlinepage.notcurrentmap"

		ApplyButtonTheme(self, w, h, "primary")

		self:SetText(text)
		self:SizeToContentsX()
	end

	CurrentMapBtn.DoClick = function()
		isCurrentMapOnly = not isCurrentMapOnly

		ApplyCourseFilter()
		BuildOnlinePage()
	end

	local Search = vgui.Create("DTextEntry", Header)
	Search:Dock(FILL)
	Search:SetPlaceholderText("#beatrun.coursesmenu.onlinepage.search.placeholder")
	Search:SetUpdateOnType(true)
	Search:SetFont("AEUIDefault")
	Search:SetPaintBackground(false)

	Search.Paint = function(self, w, h)
		surface.SetDrawColor(CurrentTheme().text.muted)
		surface.DrawOutlinedRect(0, 0, w, h, 1)

		self:DrawTextEntryText(CurrentTheme().text.primary, CurrentTheme().text.muted, CurrentTheme().cursor)

		if self:GetValue() == "" then draw.SimpleText(self:GetPlaceholderText(), self:GetFont(), 5, h / 2, CurrentTheme().text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end

		if self:HasFocus() then
			surface.SetDrawColor(CurrentTheme().search:Unpack())
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end
	end

	local searchTimer = "Beatrun_CourseSearchDebounce"
	function Search:OnValueChange(text)
		if timer.Exists(searchTimer) then timer.Remove(searchTimer) end

		timer.Create(searchTimer, .25, 1, function()
			ApplyCourseFilter(text)
			BuildOnlinePage()
		end)
	end

	List = vgui.Create("DScrollPanel", BrowsePanel)
	List:Dock(FILL)

	ApplyScrollTheme(List)

	-- Profile page
	ProfilePanel = vgui.Create("DPanel", Sheet)
	ProfilePanel:Dock(FILL)
	ProfilePanel:DockPadding(20, 20, 20, 20)
	ProfilePanel:SetBackgroundColor(CurrentTheme().bg)

	Sheet:AddSheet("#beatrun.coursesmenu.profilepage", ProfilePanel, "icon16/user.png")

	-- Settings page
	SettingsPanel = vgui.Create("DPanel", Sheet)
	SettingsPanel:Dock(FILL)
	SettingsPanel:DockPadding(20, 20, 20, 20)
	SettingsPanel:SetBackgroundColor(CurrentTheme().bg)

	Sheet:AddSheet("#beatrun.coursesmenu.settings", SettingsPanel, "icon16/cog.png")

	-- NOTE: Add sheets (pages) before this (or they will not be themed!)
	Sheet.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, CurrentTheme().bg) end

	for _, tab in pairs(Sheet.Items) do
		tab.Tab.Paint = function(self, w, h)
			local active = self:IsActive()
			local col

			if active then
				col = CurrentTheme().bg
			elseif self:IsHovered() then
				col = CurrentTheme().panels.secondary
			else
				col = CurrentTheme().header
			end

			draw.RoundedBoxEx(6, 0, 0, w, h, col, true, true, false, false)

			if not active then
				surface.SetDrawColor(CurrentTheme().header:Unpack())
				surface.DrawLine(0, h - 1, w, h - 1)
			end
		end

		tab.Tab:SetTextColor(CurrentTheme().buttons.primary.t)
	end

	BuildLocalPage()
end

concommand.Add("Beatrun_CoursesMenu", OpenDBMenu)