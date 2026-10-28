local databaseApiKey = CreateClientConVar("Beatrun_Apikey", "0", true, false, language.GetPhrase("beatrun.convars.apikey"))
local databaseDomain = CreateClientConVar("Beatrun_Domain", "courses.jbro.top", true, false, language.GetPhrase("beatrun.convars.domain"))
local submitRecords = CreateClientConVar("Beatrun_SubmitRecords", "1", true, false, language.GetPhrase("beatrun.convars.submitrecords"), 0, 1)

local UI = BeatrunUI
local S, L = UI.S, UI.L
local THEME_ORDER = UI.THEME_ORDER
local uiTheme = UI.ThemeConVar
local PaintWindowBackground, PaintPanel = UI.PaintWindowBackground, UI.PaintPanel
local MakeWindow, MakeButton, MakeLabel, MakeTitle = UI.MakeWindow, UI.MakeButton, UI.MakeLabel, UI.MakeTitle
local MakeTextEntry, MakeScroll, StyleCheckBox = UI.MakeTextEntry, UI.MakeScroll, UI.StyleCheckBox

local isCurrentMapOnly = true
local currentMap = game.GetMap()

Beatrun_MapImageCache = Beatrun_MapImageCache or {}

local CACHE_LIFETIME = 120
local UploadCourseFile, OpenConfirmPopup
local databaseCourseCode, localCourseFile
local Frame, List, OnlinePager, LocalPanel, CodePanel, BrowsePanel, ProfilePanel, SettingsPanel, PopupFrame

local function SanitizeString(str)
	str = string.lower(str)
	str = string.gsub(str, "[^%w_%-]", "_")

	return str
end

local function LogApiError(endpoint, code, body, res)
	print(string.format("> %s\n> Code: %s\n> Reply: %s", endpoint, tostring(res and res.code or code), tostring(res and res.message or body)))

	if res and res.data ~= nil then print("> Data: " .. (istable(res.data) and util.TableToJSON(res.data) or tostring(res.data))) end
end

function IsCoursesMenuOpen()
	return IsValid(Frame) or IsValid(PopupFrame)
end

local previewQueue = {}
local previewRequested = {}
local previewBusy = false
local previewToken = nil
local PREVIEW_TIMEOUT = 10

local function ProcessPreviewQueue()
	if previewBusy then return end

	if not IsCoursesMenuOpen() then
		for _, course in ipairs(previewQueue) do
			previewRequested[course.mapName] = nil
		end

		table.Empty(previewQueue)
		return
	end

	local course = table.remove(previewQueue, 1)
	if not course then return end

	previewBusy = true

	local token = {}

	previewToken = token

	local function done()
		if previewToken ~= token then return end

		previewToken = nil
		previewBusy = false

		timer.Simple(0.1, ProcessPreviewQueue)
	end

	timer.Simple(PREVIEW_TIMEOUT, done)

	steamworks.FileInfo(course.workshopId, function(result)
		if previewToken ~= token then return end
		if not result or not result.previewid then return done() end

		steamworks.Download(result.previewid, true, function(name)
			if name then Beatrun_MapImageCache[course.mapName] = AddonMaterial(name) end

			done()
		end)
	end)
end

local function CacheMapPreview(course)
	local mapName = course.mapName
	if not mapName or Beatrun_MapImageCache[mapName] or previewRequested[mapName] then return end

	previewRequested[mapName] = true

	if not course.workshopId then
		if file.Size("maps/thumb/" .. mapName .. ".png", "GAME") > 0 then Beatrun_MapImageCache[mapName] = Material("maps/thumb/" .. mapName .. ".png", "smooth") end

		return
	end

	previewQueue[#previewQueue + 1] = course

	ProcessPreviewQueue()
end

local function GetCurrentMapWorkshopID()
	for _, addon in ipairs(engine.GetAddons()) do
		if not addon.mounted or not addon.downloaded or not addon.wsid then continue end
		if file.Exists("maps/" .. currentMap .. ".bsp", addon.title) then return addon.wsid end
	end

	return nil
end

local function CreatePopup(title, w, h)
	if IsValid(PopupFrame) then PopupFrame:Remove() end

	PopupFrame = MakeWindow(title, S(w), S(h))

	return PopupFrame
end

local function MakePopupButtons(frame, buttons)
	local row = vgui.Create("DPanel", frame)
	row:SetTall(S(34))
	row:Dock(BOTTOM)
	row.Paint = nil

	local gap = S(10)

	row.PerformLayout = function(self, w, h)
		local count = #self:GetChildren()
		local bw = (w - gap * (count - 1)) / count

		for i, child in ipairs(self:GetChildren()) do
			child:SetPos((i - 1) * (bw + gap), 0)
			child:SetSize(bw, h)
		end
	end

	for _, data in ipairs(buttons) do
		local btn = MakeButton(row, data.text, data.style)
		btn.DoClick = data.onClick
	end

	return row
end

local function MakePopupMessage(frame, text)
	local label = MakeLabel(frame, text)
	label:Dock(FILL)
	label:SetWrap(true)
	label:SetContentAlignment(5)

	return label
end

local function ClosePopup()
	if IsValid(PopupFrame) then PopupFrame:Close() end
end

local function GetBanReason(body)
	local res = util.JSONToTable(body or "")
	if not istable(res) or not istable(res.data) or not res.data.banned then return end

	return tostring(res.data.reason or "?")
end

local function OpenDatabaseSite()
	gui.OpenURL("https://" .. databaseDomain:GetString() .. "/profile")
end

local function ShowBannedPopup(reason)
	local frame = CreatePopup("#beatrun.coursesmenu.banned.title", 520, 240)

	MakePopupButtons(frame, {
		{
			text = "#beatrun.coursesmenu.banned.opensite",
			style = "primary",
			onClick = function()
				OpenDatabaseSite()
				ClosePopup()
			end
		},
		{ text = "#beatrun.misc.ok", style = "secondary", onClick = ClosePopup }
	})

	MakePopupMessage(frame, L("beatrun.coursesmenu.banned.text"):format(reason))
end

local function WrapText(text, font, width)
	surface.SetFont(font)

	local lines, line = {}, ""

	for word in string.gmatch(text, "%S+") do
		local candidate = line == "" and word or line .. " " .. word

		if line ~= "" and surface.GetTextSize(candidate) > width then
			table.insert(lines, line)
			line = word
		else
			line = candidate
		end
	end

	if line ~= "" then table.insert(lines, line) end

	return lines
end

local function OpenCourseSaveMenu()
	local frame = CreatePopup("#beatrun.coursesmenu.localpage.savecourse", 460, 400)
	local data = CourseData()
	local hasKey = databaseApiKey:GetString() ~= "" and databaseApiKey:GetString() ~= "0"
	local padL, padT, padR, padB = frame:GetDockPadding()
	local width = frame:GetWide() - padL - padR
	local items = {}

	local function Add(panel, gap)
		table.insert(items, { panel = panel, gap = gap or 0 })

		return panel
	end

	local function Section(text, first)
		Add(MakeLabel(frame, "// " .. string.upper(L(text)), "BeatrunUISmall", CurrentTheme().text.muted), first and 0 or S(14))
	end

	local function Check(text)
		local check = vgui.Create("DCheckBoxLabel", frame)
		check:SetText(text)
		check:SetFont("BeatrunUISmall")
		check:SetTextColor(CurrentTheme().text.primary)
		check:SetTall(S(20))
		check.Button:SetSize(S(18), S(18))

		StyleCheckBox(check.Button)

		return Add(check, S(6))
	end

	local function Text(text, color, gap)
		local labels = {}

		for i, line in ipairs(WrapText(L(text), "BeatrunUISmall", width)) do
			table.insert(labels, Add(MakeLabel(frame, line, "BeatrunUISmall", color), i == 1 and gap or S(2)))
		end

		return labels
	end

	Section("#beatrun.coursesmenu.save.name", true)

	local entry = Add(MakeTextEntry(frame, "#beatrun.coursesmenu.save.placeholder"), S(6))
	entry:SetText(Course_Name or "")

	Section("#beatrun.coursesmenu.save.speed")

	local speedCheck = Check("#beatrun.coursesmenu.save.maxspeedlock")
	speedCheck:SetValue(Course_Speed and Course_Speed > 0)

	local slider = Add(UI.MakeSlider(frame), S(4))
	slider:SetMin(325)
	slider:SetMax(1000)
	slider:SetDecimals(0)
	slider:SetValue(Course_Speed and Course_Speed > 0 and Course_Speed or 325)

	local function UpdateSlider()
		local on = speedCheck:GetChecked()

		slider:SetMouseInputEnabled(on)
		slider:SetAlpha(on and 255 or 80)
	end

	speedCheck.OnChange = UpdateSlider
	UpdateSlider()

	local localDir = "beatrun/courses/" .. currentMap .. "/"
	local localNames = {}

	for _, filename in ipairs(file.Find(localDir .. "*.txt", "DATA") or {}) do
		local raw = file.Read(localDir .. filename, "DATA")
		local json = raw and (util.Decompress(raw) or raw)
		local tbl = json and util.JSONToTable(json)

		if istable(tbl) and isstring(tbl[5]) then localNames[filename] = string.lower(string.Trim(tbl[5])) end
	end

	local loadedFile = Course_Name ~= "" and localCourseFile and localNames[localCourseFile] and localCourseFile or nil

	local function FindOldFile()
		local name = string.lower(string.Trim(entry:GetValue()))
		local match

		if name ~= "" then
			for filename, courseName in SortedPairs(localNames) do
				if courseName == name and (not match or filename == loadedFile) then match = filename end
			end
		end

		if match then return match, true end

		return loadedFile, false
	end

	Section("#beatrun.coursesmenu.save.database")

	local uploadCheck = Check(hasKey and "#beatrun.coursesmenu.save.upload" or "#beatrun.coursesmenu.save.uploadnokey")
	local updateCheck = Check("#beatrun.coursesmenu.save.update")

	for _, check in ipairs({ uploadCheck, updateCheck }) do
		check:SetMouseInputEnabled(hasKey)
		check:SetAlpha(hasKey and 255 or 80)
	end

	local codeEntry = Add(MakeTextEntry(frame, "#beatrun.coursesmenu.save.updatecode"), S(6))
	codeEntry:SetText(Course_Name ~= "" and databaseCourseCode or "")

	local updateWarning = Text("#beatrun.coursesmenu.save.updatewarning", CurrentTheme().accent, S(6))
	local updateOnly = { codeEntry, unpack(updateWarning) }
	local Relayout

	Section("#beatrun.coursesmenu.save.summary")
	Text(L("beatrun.coursesmenu.save.counts"):format(#data[1], #data[6], #data[2], #data[8]), CurrentTheme().text.primary, 0)

	if #data[2] == 0 then Text("#beatrun.coursesmenu.save.nocheckpoints", CurrentTheme().accent, S(6)) end

	local function UpdateDatabaseOptions()
		local updating = hasKey and updateCheck:GetChecked()

		for _, panel in ipairs(updateOnly) do panel:SetVisible(updating) end

		Relayout()
	end

	uploadCheck.OnChange = function(_, value)
		if value then updateCheck:SetChecked(false) end

		UpdateDatabaseOptions()
	end

	updateCheck.OnChange = function(_, value)
		if value then uploadCheck:SetChecked(false) end

		UpdateDatabaseOptions()
	end

	local function Finish(name, speed, updateCode, upload, replaceFile)
		local saved = SaveCourse(name, speed)
		if not saved then return end

		local path = localDir .. saved .. ".txt"

		notification.AddLegacy(L("beatrun.coursesmenu.notification.save.success"):format(path), NOTIFY_GENERIC, 6)

		if replaceFile and replaceFile ~= saved .. ".txt" then file.Delete(localDir .. replaceFile, "DATA") end

		localCourseFile = saved .. ".txt"

		if IsValid(LocalPanel) then BuildLocalPage() end

		if updateCode then
			OpenConfirmPopup("#beatrun.coursesmenu.save.updateconfirm.title", L("beatrun.coursesmenu.save.updateconfirm"):format(updateCode), function() UploadCourseFile(path, updateCode) end, true, 220)
		elseif upload then
			UploadCourseFile(path)
		end
	end

	local function AskReplace(oldFile, sameName, onChoice)
		local ask = MakeWindow("#beatrun.coursesmenu.save.exists.title", S(520), S(230))

		local function Choose(replace)
			ask:Remove()
			onChoice(replace)
		end

		MakePopupButtons(ask, {
			{ text = "#beatrun.coursesmenu.save.exists.replace", style = "danger", onClick = function() Choose(true) end },
			{ text = "#beatrun.coursesmenu.save.exists.keep", style = "secondary", onClick = function() Choose(false) end },
			{ text = "#beatrun.misc.cancel", style = "secondary", onClick = function() ask:Remove() end }
		})

		local message = sameName and L("beatrun.coursesmenu.save.exists.samename"):format(string.Trim(entry:GetValue()), oldFile) or L("beatrun.coursesmenu.save.exists.loaded"):format(oldFile)

		MakePopupMessage(ask, message)
	end

	local function Save()
		local name = string.Trim(entry:GetValue())
		if name == "" then return entry:RequestFocus() end

		local updateCode = hasKey and updateCheck:GetChecked() and string.upper(string.Trim(codeEntry:GetValue())) or nil
		if updateCode == "" then return codeEntry:RequestFocus() end

		local speed = speedCheck:GetChecked() and math.floor(slider:GetValue()) or nil
		local upload = hasKey and uploadCheck:GetChecked()
		local oldFile, sameName = FindOldFile()

		if not oldFile then
			ClosePopup()

			return Finish(name, speed, updateCode, upload)
		end

		AskReplace(oldFile, sameName, function(replace)
			ClosePopup()
			Finish(name, speed, updateCode, upload, replace and oldFile)
		end)
	end

	entry.OnEnter = Save

	local buttons = MakePopupButtons(frame, {
		{ text = "#beatrun.coursesmenu.save", style = "primary", onClick = Save },
		{ text = "#beatrun.misc.cancel", style = "secondary", onClick = ClosePopup }
	})
	buttons:Dock(NODOCK)
	Add(buttons, S(18))

	Relayout = function()
		local y = padT

		for _, item in ipairs(items) do
			if item.panel:IsVisible() then
				y = y + item.gap

				item.panel:SetPos(padL, y)
				item.panel:SetWide(width)

				y = y + item.panel:GetTall()
			end
		end

		frame:SetTall(y + padB)
		frame:Center()
	end

	UpdateDatabaseOptions()

	entry:RequestFocus()
	entry:SetCaretPos(#entry:GetValue())
end

function OpenConfirmPopup(title, message, onConfirm, danger, height)
	local frame = CreatePopup(title, 520, height or 200)
	MakePopupButtons(frame, {
		{
			text = "#beatrun.misc.ok",
			style = danger and "danger" or "primary",
			onClick = function()
				ClosePopup()

				if onConfirm then onConfirm() end
			end
		},
		{
			text = "#beatrun.misc.cancel",
			style = "secondary",
			onClick = ClosePopup
		}
	})

	MakePopupMessage(frame, message)
end

local function OpenApiKeyPopup()
	local frame = CreatePopup("#beatrun.coursesmenu.profilepage.changekey", 480, 170)

	local entry = MakeTextEntry(frame, "#beatrun.coursesmenu.profilepage.changekey.placeholder")
	entry:Dock(TOP)

	local function save()
		local newKey = string.Trim(entry:GetValue())
		if newKey == "" then return entry:RequestFocus() end

		databaseApiKey:SetString(newKey)

		ClosePopup()

		timer.Simple(0, function() if IsValid(ProfilePanel) then BuildProfilePage() end end)
	end

	entry.OnEnter = save

	MakePopupButtons(frame, {
		{
			text = "#beatrun.coursesmenu.save",
			style = "primary",
			onClick = save
		}
	})

	entry:RequestFocus()
end

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
			LogApiError("/api/courses/download", code, body)

			return
		end

		local res = util.JSONToTable(body)
		if res and res.code and res.code ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)
			LogApiError("/api/courses/download", code, body, res)

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

	http.Fetch("https://" .. databaseDomain:GetString() .. "/api/courses/download", function(body, _, _, status)
		if status ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)
			LogApiError("/api/courses/download", status, body)

			return
		end

		local res = util.JSONToTable(body)
		if res and res.code and res.code ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)
			LogApiError("/api/courses/download", status, body, res)

			return
		end

		databaseCourseCode = code
		localCourseFile = nil

		LoadCourseRaw(util.Base64Decode(body))
		notification.AddLegacy(language.GetPhrase("#beatrun.coursesmenu.notification.startingcourse"):format(code), NOTIFY_GENERIC, 4)
	end, function(err)
		notification.AddLegacy("#beatrun.coursesmenu.notification.openconsole", NOTIFY_ERROR, 4)
		print("> /api/courses/download\nError: ", err)
	end, headers)
end

function UploadCourseFile(course, updateCode)
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
		workshopId = GetCurrentMapWorkshopID(),
		code = updateCode
	}

	local endpoint = updateCode and "/api/courses/update" or "/api/courses/upload"

	http.Post("https://" .. databaseDomain:GetString() .. endpoint, {
		data = encoded
	}, function(body, _, _, code)
		if code ~= 200 then
			local banReason = GetBanReason(body)

			if banReason then
				ShowBannedPopup(banReason)
			else
				notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)
			end

			LogApiError(endpoint, code, body)

			return
		end

		local res = util.JSONToTable(body)
		if res and res.code and res.code ~= 200 then
			notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)
			LogApiError(endpoint, code, body, res)

			return
		end

		if updateCode then
			local removed = res and istable(res.data) and res.data.removedRecords or 0

			notification.AddLegacy(L("beatrun.coursesmenu.notification.update.success"):format(updateCode, removed), NOTIFY_GENERIC, 6)
		else
			notification.AddLegacy("#beatrun.coursesmenu.notification.upload.success", NOTIFY_GENERIC, 4)
		end

		print("> " .. tostring(res and res.message or body))
	end, function(err)
		notification.AddLegacy("#beatrun.coursesmenu.notification.openconsole", NOTIFY_ERROR, 4)
		print("> " .. endpoint .. "\nError: ", err)
	end, headers)
end

local function StartOnlineCourse(v)
	if v.workshopId and not steamworks.IsSubscribed(v.workshopId) then
		local frame = CreatePopup("#beatrun.coursesmenu.onlinepage.start", 560, 220)

		MakePopupButtons(frame, {
			{
				text = "#beatrun.coursesmenu.onlinepage.openworkshop",
				style = "primary",
				onClick = function()
					gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. v.workshopId)
					ClosePopup()
				end
			},
			{
				text = "#beatrun.coursesmenu.onlinepage.iknowwhatimdoing",
				style = "danger",
				onClick = function()
					FetchAndStartCourse(v.code)

					ClosePopup()

					if IsValid(Frame) then Frame:Close() end
				end
			}
		})

		MakePopupMessage(frame, "#beatrun.coursesmenu.onlinepage.start.message")

		return
	end

	FetchAndStartCourse(v.code)

	if IsValid(Frame) then Frame:Close() end
end

local function IsCourseDownloaded(v)
	return file.Exists(string.format("beatrun/courses/%s/%s.txt", v.mapName, string.lower(v.code)), "DATA")
end

local function DownloadOnlineCourse(v)
	if IsCourseDownloaded(v) then
		OpenConfirmPopup("#beatrun.coursesmenu.onlinepage.overwrite", "#beatrun.coursesmenu.onlinepage.overwrite.confirm", function() FetchAndSaveCourse(v) end, true)

		return
	end

	FetchAndSaveCourse(v)
end

local function ToMenuCourse(data)
	local author = data.author or {}

	return {
		code = data.code,
		name = data.name,
		mapName = data.mapName,
		workshopId = data.workshopId,
		downloadCount = data.downloadCount or 0,
		runsCount = data.runsCount or 0,
		elementsCount = data.elementsCount or 0,
		players = data.players or 0,
		checkpoints = data.checkpoints,
		bestTime = data.bestTime,
		uploadedAt = os.date("%Y-%m-%d %H:%M", (data.uploadedAt or 0) / 1000),
		uploadedBy = {
			steamId = author.steamId,
			username = author.username or author.steamId
		}
	}
end

local function UrlEncode(str)
	return string.gsub(str, "[^%w%-_%.~]", function(c) return string.format("%%%02X", string.byte(c)) end)
end

function Beatrun_SubmitCourseRecord(time)
	if not submitRecords:GetBool() then return end
	if Course_Name == "" or not Course_ID or Course_ID == "" then return end
	if not time or time <= 0 then return end

	local key = databaseApiKey:GetString()
	if not key or key == "" or key == "0" then return end

	if GetConVar("sv_cheats"):GetBool() then return end

	local headers = {
		authorization = key,
		hash = Course_ID
	}

	http.Post("https://" .. databaseDomain:GetString() .. "/api/courses/records", {
		time = tostring(time)
	}, function(body, _, _, code)
		if code == 404 then return end -- Course is not in the database

		local banReason = GetBanReason(body)

		if banReason then
			notification.AddLegacy("#beatrun.coursesmenu.notification.banned", NOTIFY_ERROR, 6)
			print("> /api/courses/records\n" .. L("beatrun.coursesmenu.banned.text"):format(banReason))

			return
		end

		local res = util.JSONToTable(body or "")

		if code ~= 200 or not res or not res.data then
			LogApiError("/api/courses/records", code, body, res)
			return
		end

		if res.data.personalBest then
			notification.AddLegacy(language.GetPhrase("#beatrun.coursesmenu.notification.record.pb"):format(res.data.position), NOTIFY_GENERIC, 5)
			surface.PlaySound("buttons/bell1.wav")
		else
			notification.AddLegacy(language.GetPhrase("#beatrun.coursesmenu.notification.record.saved"):format(res.data.position), NOTIFY_HINT, 4)
		end
	end, function(err) print("> /api/courses/records\nError: ", err) end, headers)
end

local codeLookup = {
	input = "",
	status = "idle", -- idle, invalid, loading, found, notfound, error
	code = nil,
	course = nil,
	lastRequest = {},
	cache = {}
}

local CODE_RETRY_DELAY = 2

local function NormalizeCourseCode(text)
	local code = string.upper(string.gsub(string.Trim(text or ""), "%s+", ""))
	if not string.match(code, "^%w+%-[%w%-]*%w$") then return nil end

	return code
end

local function LookupCourseByCode(text)
	codeLookup.input = text or ""

	local code = NormalizeCourseCode(text)
	if not code then
		codeLookup.status = "invalid"
		codeLookup.course = nil
		return BuildCodePage()
	end

	if codeLookup.code == code and (codeLookup.status == "loading" or codeLookup.status == "found") then return end

	local cached = codeLookup.cache[code]
	if cached and CurTime() - cached.at < CACHE_LIFETIME then
		codeLookup.code = code
		codeLookup.course = cached.course
		codeLookup.status = "found"

		return BuildCodePage()
	end

	if (codeLookup.lastRequest[code] or 0) + CODE_RETRY_DELAY > CurTime() then return end

	codeLookup.lastRequest[code] = CurTime()
	codeLookup.code = code
	codeLookup.course = nil
	codeLookup.status = "loading"

	BuildCodePage()

	http.Fetch("https://" .. databaseDomain:GetString() .. "/api/courses/info/" .. code, function(body, _, _, status)
		if codeLookup.code ~= code then return end

		local res = util.JSONToTable(body or "")

		if status == 404 then
			codeLookup.status = "notfound"
		elseif status ~= 200 or not res or not res.data then
			codeLookup.status = "error"

			LogApiError("/api/courses/info/" .. code, status, body, res)
		else
			local course = ToMenuCourse(res.data)
			codeLookup.course = course
			codeLookup.status = "found"
			codeLookup.cache[code] = {
				course = course,
				at = CurTime()
			}

			CacheMapPreview(course)
		end

		BuildCodePage()
	end, function(err)
		if codeLookup.code ~= code then return end

		codeLookup.status = "error"

		print("> /api/courses/info/" .. code .. "\nError: ", err)

		BuildCodePage()
	end)
end

-- Pages
local function MakeToolbar(parent)
	local bar = vgui.Create("DPanel", parent)
	bar:SetTall(S(54))
	bar:Dock(TOP)
	bar:DockPadding(S(20), S(10), S(20), S(10))
	bar.Paint = function(self, w, h)
		local theme = CurrentTheme()
		surface.SetDrawColor(theme.header)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(theme.border)
		surface.DrawLine(0, h - 1, w, h - 1)
	end

	return bar
end

local function MakeBody(parent)
	local body = vgui.Create("DPanel", parent)
	body:Dock(FILL)
	body:DockPadding(S(20), S(16), S(20), S(20))
	body.Paint = nil

	return body
end

local function MakeRow(parent, height)
	local row = parent:Add("DPanel")
	row:SetTall(S(height))
	row:Dock(TOP)
	row:DockMargin(0, 0, S(10), S(8))
	row:DockPadding(S(14), S(10), S(12), S(10))
	row.Paint = function(self, w, h)
		local theme = CurrentTheme()
		PaintPanel(w, h, (self:IsHovered() or self:IsChildHovered()) and theme.panels.secondary or theme.panels.primary)
	end

	return row
end

local function MakeRowButton(row, text, style, onClick)
	local btn = MakeButton(row, text, style)
	btn:SetWide(math.max(btn:GetWide(), S(110)))
	btn:Dock(RIGHT)
	btn:DockMargin(S(8), 0, 0, 0)
	btn.DoClick = onClick

	return btn
end

local function MakeLink(parent, text, font, onClick, color)
	local link = vgui.Create("DButton", parent)
	link:SetText(text)
	link:SetFont(font or "BeatrunUI")
	link:SetContentAlignment(4)
	link:SetCursor(onClick and "hand" or "arrow")
	link:SizeToContents()
	link.Paint = function(self)
		local theme = CurrentTheme()
		self:SetTextColor(onClick and self:IsHovered() and theme.accent or color or theme.text.muted)
	end

	link.DoClick = function(self) if onClick then onClick(self) end end

	return link
end

local function MakeMessage(parent, text, color)
	local label = MakeLabel(parent, text, "AEUIDefault", color or CurrentTheme().text.muted)
	label:Dock(TOP)
	label:SetWrap(true)
	label:SetAutoStretchVertical(true)

	return label
end

local function DrawCoursePreview(course, x, y, w, h)
	local theme = CurrentTheme()

	CacheMapPreview(course)

	local mapMaterial = Beatrun_MapImageCache[course.mapName]
	if mapMaterial and not mapMaterial:IsError() then
		surface.SetMaterial(mapMaterial)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(x, y, w, h)
	else
		surface.SetDrawColor(theme.panels.secondary)
		surface.DrawRect(x, y, w, h)
		draw.SimpleText(course.mapName or "?", "BeatrunUISmall", x + w / 2, y + h / 2, theme.text.dark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	surface.SetDrawColor(theme.border)
	surface.DrawOutlinedRect(x, y, w, h, 1)
end

local function CopyCodeLink(parent, code, font)
	return MakeLink(parent, code, font or "BeatrunUI", function(self)
		SetClipboardText(code)

		self:SetText("#beatrun.coursesmenu.copied")
		self:SizeToContents()

		timer.Simple(2, function()
			if not IsValid(self) then return end
			self:SetText(code)
			self:SizeToContents()
		end)
	end, CurrentTheme().text.primary)
end

-- Local courses
function BuildLocalPage()
	if not IsValid(LocalPanel) then return end

	LocalPanel:Clear()

	local isSuperAdmin = LocalPlayer():IsSuperAdmin()
	local bar = MakeToolbar(LocalPanel)

	local saveBtn = MakeButton(bar, "#beatrun.coursesmenu.localpage.savecourse", "primary")
	saveBtn:Dock(LEFT)
	saveBtn:DockMargin(0, 0, S(8), 0)
	saveBtn.DoClick = function() OpenCourseSaveMenu() end

	local buildBtn = MakeButton(bar, "#beatrun.coursesmenu.localpage.buildmode", "secondary")
	buildBtn:Dock(LEFT)
	buildBtn:DockMargin(0, 0, S(8), 0)
	buildBtn:SetEnabled(isSuperAdmin)
	buildBtn.DoClick = function()
		LocalPlayer():ConCommand("beatrun_buildmode")
		if IsValid(Frame) then Frame:Close() end
	end

	local exitBtn = MakeButton(bar, "#beatrun.coursesmenu.localpage.freeplay", "secondary")
	exitBtn:Dock(LEFT)
	exitBtn:SetEnabled(isSuperAdmin)
	exitBtn.DoClick = function()
		if CourseGhost:GetBool() then StopGhostRecording(false, false) end
		net.Start("Course_Stop")
		net.SendToServer()
	end

	local body = MakeBody(LocalPanel)

	MakeTitle(body, L("beatrun.coursesmenu.localpage.savedcourses"):format(currentMap))

	local scroll = MakeScroll(body)
	local path = string.format("beatrun/courses/%s/", currentMap)

	local files = file.Find(path .. "*.txt", "DATA")
	if not files or #files == 0 then
		MakeMessage(scroll, "#beatrun.coursesmenu.localpage.nosavedcourses")

		return
	end

	for _, filename in ipairs(files) do
		local raw = file.Read(path .. filename, "DATA")
		local data = raw and (util.Decompress(raw) or raw)
		local tbl = data and util.JSONToTable(data)
		local isReadable = istable(tbl) and isstring(tbl[5])
		local row = MakeRow(scroll, 64)
		local loadBtn = MakeRowButton(row, "#beatrun.coursesmenu.start", "primary", function()
			databaseCourseCode = nil
			localCourseFile = filename

			LoadCourse(filename)

			if IsValid(Frame) then Frame:Close() end
		end)

		loadBtn:SetEnabled(isReadable and isSuperAdmin)

		local uploadBtn = MakeRowButton(row, "#beatrun.coursesmenu.upload", "secondary", function() OpenConfirmPopup("#beatrun.coursesmenu.upload", "#beatrun.coursesmenu.upload.confirm", function() UploadCourseFile(path .. filename) end) end)
		uploadBtn:SetEnabled(isReadable)

		MakeRowButton(row, "#beatrun.coursesmenu.delete", "danger", function() OpenConfirmPopup("#beatrun.coursesmenu.delete", "#beatrun.coursesmenu.delete.confirm", function() if file.Delete(path .. filename, "DATA") ~= false then BuildLocalPage() end end, true) end)

		local name = MakeLabel(row, isReadable and tbl[5] or "#beatrun.coursesmenu.localpage.broken", "BeatrunUI", isReadable and CurrentTheme().text.primary or CurrentTheme().text.muted)
		name:Dock(TOP)

		local id = MakeLabel(row, string.upper(string.StripExtension(filename)), "BeatrunUISmall", CurrentTheme().text.muted)
		id:Dock(TOP)
	end
end

-- Course by code
local function BuildCodeCourseCard(parent, v)
	local isOtherMap = v.mapName ~= currentMap
	local previewW, previewH = S(320), S(180)
	local pad = S(16)

	local textH = draw.GetFontHeight("BeatrunUILarge") + draw.GetFontHeight("BeatrunUI") * 2 + draw.GetFontHeight("BeatrunUISmall") * 2 + S(12) + S(34) + S(10)
	if isOtherMap then textH = textH + draw.GetFontHeight("BeatrunUI") + S(6) end

	local card = vgui.Create("DPanel", parent)
	card:Dock(TOP)
	card:SetTall(math.max(previewH, textH) + pad * 2)
	card:DockPadding(S(4) + pad + previewW + pad, pad, pad, pad)
	card.Paint = function(self, w, h)
		PaintPanel(w, h, nil, true)
		DrawCoursePreview(v, S(4) + pad, pad, previewW, h - pad * 2)
	end

	local buttons = vgui.Create("DPanel", card)
	buttons:SetTall(S(34))
	buttons:Dock(BOTTOM)
	buttons.Paint = nil

	local startBtn = MakeButton(buttons, "#beatrun.coursesmenu.onlinepage.start", "primary")
	startBtn:Dock(LEFT)
	startBtn:DockMargin(0, 0, S(8), 0)
	startBtn.DoClick = function()
		if isOtherMap then
			OpenConfirmPopup("#beatrun.coursesmenu.onlinepage.start", "#beatrun.coursesmenu.codepage.wrongmap.confirm", function() StartOnlineCourse(v) end)
			return
		end

		StartOnlineCourse(v)
	end

	local downloadBtn = MakeButton(buttons, "#beatrun.coursesmenu.onlinepage.download", "secondary")
	downloadBtn:Dock(LEFT)
	downloadBtn:DockMargin(0, 0, S(8), 0)
	downloadBtn.DoClick = function() DownloadOnlineCourse(v) end
	downloadBtn.Think = function(self)
		if (self.checkedAt or 0) > CurTime() then return end
		self.checkedAt = CurTime() + 1
		self:SetText(IsCourseDownloaded(v) and "#beatrun.coursesmenu.onlinepage.overwrite" or "#beatrun.coursesmenu.onlinepage.download")
	end

	local siteBtn = MakeButton(buttons, "#beatrun.coursesmenu.codepage.website", "secondary")
	siteBtn:Dock(LEFT)
	siteBtn.DoClick = function() gui.OpenURL("https://" .. databaseDomain:GetString() .. "/course/" .. v.code) end

	local name = MakeLabel(card, v.name or v.code, "BeatrunUILarge")
	name:Dock(TOP)

	local codeRow = vgui.Create("DPanel", card)
	codeRow:SetTall(draw.GetFontHeight("BeatrunUI"))
	codeRow:Dock(TOP)
	codeRow.Paint = nil

	CopyCodeLink(codeRow, v.code):Dock(LEFT)

	local mapLink = MakeLink(codeRow, "  |  " .. v.mapName, "BeatrunUI", v.workshopId and function() gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. v.workshopId) end)
	mapLink:Dock(LEFT)

	local author = MakeLink(card, L("beatrun.coursesmenu.codepage.author"):format(v.uploadedBy.username or "?") .. "  |  " .. L("beatrun.coursesmenu.uploadedat"):format(v.uploadedAt), "BeatrunUISmall", v.uploadedBy.steamId and function() gui.OpenURL("https://steamcommunity.com/profiles/" .. v.uploadedBy.steamId) end)
	author:Dock(TOP)

	local stats = MakeLabel(card, L("beatrun.coursesmenu.codepage.stats"):format(v.downloadCount, v.runsCount, v.players, v.checkpoints or "?"), "BeatrunUISmall", CurrentTheme().text.muted)
	stats:Dock(TOP)
	stats:DockMargin(0, S(8), 0, 0)

	local record = MakeLabel(card, v.bestTime and L("beatrun.coursesmenu.codepage.record"):format(string.FormattedTime(v.bestTime, "%02i:%02i:%02i")) or L("beatrun.coursesmenu.codepage.norecord"), "BeatrunUI")
	record:Dock(TOP)
	record:DockMargin(0, S(4), 0, 0)

	if isOtherMap then
		local warn = MakeLabel(card, L("beatrun.coursesmenu.codepage.wrongmap"):format(v.mapName, currentMap), "BeatrunUI", CurrentTheme().buttons.danger.t)
		warn:Dock(TOP)
		warn:DockMargin(0, S(6), 0, 0)
	end
end

function BuildCodePage()
	if not IsValid(CodePanel) then return end

	CodePanel:Clear()

	local bar = MakeToolbar(CodePanel)

	local findBtn = MakeButton(bar, "#beatrun.coursesmenu.codepage.find", "primary")
	findBtn:SetWide(math.max(findBtn:GetWide(), S(110)))
	findBtn:Dock(RIGHT)
	findBtn:DockMargin(S(8), 0, 0, 0)
	findBtn:SetEnabled(codeLookup.status ~= "loading")

	local entry = MakeTextEntry(bar, "#beatrun.coursesmenu.codepage.placeholder")
	entry:Dock(FILL)
	entry:SetText(codeLookup.input)
	entry:SetUpdateOnType(false)
	entry.OnChange = function(self) codeLookup.input = self:GetValue() end
	entry.OnEnter = function(self, value) LookupCourseByCode(value) end

	findBtn.DoClick = function() LookupCourseByCode(entry:GetValue()) end

	local body = MakeBody(CodePanel)
	local status = codeLookup.status
	local danger = CurrentTheme().buttons.danger.t

	if status == "idle" then
		MakeMessage(body, "#beatrun.coursesmenu.codepage.hint")
		entry:RequestFocus()
	elseif status == "invalid" then
		MakeMessage(body, "#beatrun.coursesmenu.codepage.invalid", danger)
		entry:RequestFocus()
	elseif status == "loading" then
		MakeMessage(body, "#beatrun.coursesmenu.codepage.loading")
	elseif status == "notfound" then
		MakeMessage(body, L("beatrun.coursesmenu.codepage.notfound"):format(codeLookup.code), danger)
		entry:RequestFocus()
	elseif status == "error" then
		MakeMessage(body, "#beatrun.coursesmenu.codepage.error", danger)
	elseif status == "found" and codeLookup.course then
		BuildCodeCourseCard(body, codeLookup.course)
	end
end

-- Online
local ONLINE_PAGE_SIZE = 20
local SEARCH_DELAY = 0.4
local onlineState = {
	page = 1,
	pages = 1,
	total = 0,
	query = "",
	items = nil,
	status = "idle", -- idle, loading, done, error
	request = 0,
	at = 0
}

local function FetchOnlinePage()
	onlineState.request = onlineState.request + 1
	onlineState.status = "loading"

	local request = onlineState.request
	local params = { "limit=" .. ONLINE_PAGE_SIZE, "page=" .. onlineState.page, "sort=newest" }

	if isCurrentMapOnly then params[#params + 1] = "map=" .. UrlEncode(currentMap) end
	if onlineState.query ~= "" then params[#params + 1] = "q=" .. UrlEncode(onlineState.query) end

	BuildOnlinePage()

	http.Fetch("https://" .. databaseDomain:GetString() .. "/api/courses/search?" .. table.concat(params, "&"), function(body, _, _, code)
		if request ~= onlineState.request then return end

		local res = util.JSONToTable(body or "")
		local data = res and res.data

		if code ~= 200 or not data or not data.items then
			LogApiError("/api/courses/search", code, body, res)
			onlineState.status = "error"
			return BuildOnlinePage()
		end

		local items = {}
		for _, course in ipairs(data.items) do
			items[#items + 1] = ToMenuCourse(course)
		end

		onlineState.items = items
		onlineState.at = CurTime()
		onlineState.total = data.total or #items
		onlineState.pages = math.max(1, data.pages or 1)
		onlineState.status = "done"

		BuildOnlinePage()
	end, function(err)
		if request ~= onlineState.request then return end

		onlineState.status = "error"

		print("> /api/courses/search\nError: ", err)

		BuildOnlinePage()
	end)
end

local function SetOnlinePage(page)
	onlineState.page = math.Clamp(page, 1, onlineState.pages)
	FetchOnlinePage()
end

local function BuildOnlineEntry(v)
	local isOtherMap = v.mapName ~= currentMap
	local previewW, _previewH = S(178), S(100)

	local row = MakeRow(List, 120)
	row:DockPadding(S(10) + previewW + S(14), S(10), S(12), S(10))

	local rowPaint = row.Paint

	row.Paint = function(self, w, h)
		rowPaint(self, w, h)
		DrawCoursePreview(v, S(10), S(10), previewW, h - S(20))
	end

	local side = vgui.Create("DPanel", row)
	side:SetWide(S(220))
	side:Dock(RIGHT)
	side.Paint = nil

	local authorRow = vgui.Create("DPanel", side)
	authorRow:SetTall(S(26))
	authorRow:Dock(TOP)
	authorRow.Paint = nil

	if v.uploadedBy.steamId then
		local avatar = vgui.Create("AvatarImage", authorRow)
		avatar:SetSteamID(v.uploadedBy.steamId, 32)
		avatar:SetWide(S(26))
		avatar:Dock(LEFT)
		avatar:DockMargin(0, 0, S(8), 0)
	end

	local authorLink = MakeLink(authorRow, v.uploadedBy.username or "?", "BeatrunUISmall", v.uploadedBy.steamId and function() gui.OpenURL("https://steamcommunity.com/profiles/" .. v.uploadedBy.steamId) end, CurrentTheme().text.primary)
	authorLink:Dock(FILL)

	local downloadBtn = MakeButton(side, "#beatrun.coursesmenu.onlinepage.download", "secondary")
	downloadBtn:Dock(BOTTOM)
	downloadBtn:DockMargin(0, S(6), 0, 0)
	downloadBtn.DoClick = function() DownloadOnlineCourse(v) end

	if IsCourseDownloaded(v) then downloadBtn:SetText("#beatrun.coursesmenu.onlinepage.overwrite") end

	local startBtn = MakeButton(side, "#beatrun.coursesmenu.onlinepage.start", "primary")
	startBtn:Dock(BOTTOM)
	startBtn.DoClick = function()
		if isOtherMap then
			OpenConfirmPopup("#beatrun.coursesmenu.onlinepage.start", "#beatrun.coursesmenu.codepage.wrongmap.confirm", function() StartOnlineCourse(v) end)
			return
		end

		StartOnlineCourse(v)
	end

	local name = MakeLabel(row, v.name, "BeatrunUILarge")
	name:Dock(TOP)

	local codeRow = vgui.Create("DPanel", row)
	codeRow:SetTall(draw.GetFontHeight("BeatrunUI"))
	codeRow:Dock(TOP)
	codeRow.Paint = nil

	CopyCodeLink(codeRow, v.code):Dock(LEFT)

	local mapLink = MakeLink(codeRow, "  |  " .. v.mapName, "BeatrunUI", v.workshopId and function() gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. v.workshopId) end)
	mapLink:Dock(LEFT)

	local info = MakeLabel(row, L("beatrun.coursesmenu.uploadedat"):format(v.uploadedAt) .. "  |  " .. L("beatrun.coursesmenu.downloads"):format(v.downloadCount), "BeatrunUISmall", CurrentTheme().text.muted)
	info:Dock(BOTTOM)
end

function BuildOnlinePage()
	if not IsValid(List) then return end

	List:Clear()

	if onlineState.status == "idle" or onlineState.status == "done" and CurTime() - (onlineState.at or 0) > CACHE_LIFETIME then return FetchOnlinePage() end
	if IsValid(OnlinePager) then OnlinePager:Update() end

	if onlineState.status == "loading" and not onlineState.items then
		MakeMessage(List, "#beatrun.coursesmenu.loading")

		return
	end

	if onlineState.status == "error" then
		MakeMessage(List, "#beatrun.coursesmenu.notification.fetch.failed", CurrentTheme().buttons.danger.t)

		return
	end

	if not onlineState.items or #onlineState.items == 0 then
		MakeMessage(List, "#beatrun.coursesmenu.onlinepage.empty")

		return
	end

	for _, v in ipairs(onlineState.items) do
		BuildOnlineEntry(v)
	end
end

-- Profile
local function BuildProfileCourses(scroll, myCourses)
	if not IsValid(scroll) then return end

	scroll:Clear()

	if #myCourses == 0 then
		MakeMessage(scroll, "#beatrun.coursesmenu.profilepage.nouploadedcourses")

		return
	end

	for _, v in ipairs(myCourses) do
		local isOtherMap = v.mapName ~= currentMap
		local row = MakeRow(scroll, 64)

		MakeRowButton(row, "#beatrun.coursesmenu.start", "primary", function()
			if isOtherMap then
				OpenConfirmPopup("#beatrun.coursesmenu.onlinepage.start", "#beatrun.coursesmenu.codepage.wrongmap.confirm", function() StartOnlineCourse(v) end)
				return
			end

			StartOnlineCourse(v)
		end)

		MakeRowButton(row, "#beatrun.coursesmenu.delete", "danger", function()
			OpenConfirmPopup("#beatrun.coursesmenu.delete", "#beatrun.coursesmenu.delete.confirm", function()
				HTTP({
					method = "DELETE",
					url = "https://" .. databaseDomain:GetString() .. "/api/courses/delete",
					headers = {
						authorization = databaseApiKey:GetString(),
						code = v.code,
					},
					success = function(code, body)
						local res = util.JSONToTable(body or "")
						if code ~= 200 or res and res.code and res.code ~= 200 then
							notification.AddLegacy("#beatrun.coursesmenu.notification.fetch.failed", NOTIFY_ERROR, 4)
							LogApiError("/api/courses/delete", code, body, res)
							return
						end

						onlineState.status = "idle"
						BuildProfilePage()
					end,
					failed = function(err) print("> /api/courses/delete\nError: ", err) end
				})
			end, true)
		end)

		local name = MakeLabel(row, v.name, "BeatrunUI")
		name:Dock(TOP)

		local info = MakeLabel(row, v.code .. "  |  " .. v.mapName .. "  |  " .. L("beatrun.coursesmenu.downloads"):format(v.downloadCount), "BeatrunUISmall", CurrentTheme().text.muted)
		info:Dock(TOP)
	end
end

local function BuildProfileCard(body, apiKey)
	local steamId = LocalPlayer():SteamID64()
	local pad = S(16)
	local avatarSize = S(84)
	local textH = draw.GetFontHeight("BeatrunUILarge") + draw.GetFontHeight("BeatrunUI") + draw.GetFontHeight("BeatrunUISmall") + S(30) + S(8)

	local card = vgui.Create("DPanel", body)
	card:Dock(TOP)
	card:SetTall(math.max(avatarSize, textH) + pad * 2)
	card:DockMargin(0, 0, 0, S(20))
	card:DockPadding(S(4) + pad, pad, pad, pad)
	card.Paint = function(self, w, h) PaintPanel(w, h, nil, true) end

	local avatarHolder = vgui.Create("DPanel", card)
	avatarHolder:SetWide(avatarSize)
	avatarHolder:Dock(LEFT)
	avatarHolder:DockMargin(0, 0, pad, 0)
	avatarHolder.Paint = nil

	local avatar = vgui.Create("AvatarImage", avatarHolder)
	avatar:SetSteamID(steamId, 184)
	avatar:SetSize(avatarSize, avatarSize)

	avatarHolder.PerformLayout = function(self, w, h) avatar:SetPos(0, math.floor((h - avatarSize) / 2)) end

	local rank = MakeLabel(card, "★ ...", "BeatrunUILarge")
	rank:Dock(TOP)

	local nameRow = MakeLabel(card, LocalPlayer():Nick(), "BeatrunUI")
	nameRow:Dock(TOP)

	local stats = MakeLabel(card, "#beatrun.coursesmenu.profilepage.loading", "BeatrunUISmall", CurrentTheme().text.muted)
	stats:Dock(TOP)

	local keyRow = vgui.Create("DPanel", card)
	keyRow:SetTall(S(30))
	keyRow:Dock(BOTTOM)
	keyRow.Paint = nil

	local masked = string.rep("*", math.max(#apiKey - 4, 0)) .. string.sub(apiKey, -4)
	local keyLabel = MakeLabel(keyRow, L("beatrun.coursesmenu.profilepage.key"):format(masked), "BeatrunUISmall", CurrentTheme().text.muted)
	keyLabel:Dock(LEFT)
	keyLabel:DockMargin(0, 0, S(12), 0)

	local changeBtn = MakeButton(keyRow, "#beatrun.coursesmenu.profilepage.changekey", "secondary")
	changeBtn:Dock(LEFT)
	changeBtn:DockMargin(0, 0, S(8), 0)
	changeBtn.DoClick = function() OpenApiKeyPopup() end

	local siteBtn = MakeButton(keyRow, "#beatrun.coursesmenu.profilepage.website", "secondary")
	siteBtn:Dock(LEFT)
	siteBtn.DoClick = function() gui.OpenURL("https://" .. databaseDomain:GetString() .. "/user/" .. steamId) end

	http.Fetch("https://" .. databaseDomain:GetString() .. "/api/users/profile/" .. steamId, function(statsBody, _, _, statsCode)
		if not IsValid(card) then return end

		local statsRes = util.JSONToTable(statsBody or "")
		local data = statsRes and statsRes.data
		local s = data and data.stats

		if statsCode ~= 200 or not s then
			LogApiError("/api/users/profile/" .. steamId, statsCode, statsBody, statsRes)

			rank:SetText("★ " .. L("beatrun.coursesmenu.profilepage.unranked"))
			stats:SetText("#beatrun.coursesmenu.profilepage.statsfailed")

			return
		end

		rank:SetText("★ " .. (s.rank and L("beatrun.coursesmenu.profilepage.rank"):format(s.rank) or L("beatrun.coursesmenu.profilepage.unranked")))
		nameRow:SetText((data.user and data.user.username or LocalPlayer():Nick()) .. " | " .. L("beatrun.coursesmenu.profilepage.points"):format(s.points or 0))
		stats:SetText(L("beatrun.coursesmenu.profilepage.stats.short"):format(s.worldRecords or 0, s.completed or 0, s.courses or 0, s.downloads or 0))
	end, function(err)
		if IsValid(stats) then stats:SetText("#beatrun.coursesmenu.profilepage.statsfailed") end
		print("> /api/users/profile\nError: ", err)
	end)
end

local function BuildProfileSignIn(body)
	local authUrl = string.format("https://%s/auth?redirect=/profile", databaseDomain:GetString())
	local pad = S(20)

	local card = vgui.Create("DPanel", body)
	card:Dock(TOP)
	card:DockPadding(S(4) + pad, pad, pad, pad)
	card.Paint = function(self, w, h) PaintPanel(w, h, nil, true) end

	local title = MakeLabel(card, "★ " .. string.upper(L("beatrun.coursesmenu.profilepage.signin")), "BeatrunUILarge")
	title:Dock(TOP)
	title:DockMargin(0, 0, 0, S(10))

	local msg = MakeLabel(card, "#beatrun.coursesmenu.profilepage.message", "AEUIDefault", CurrentTheme().text.muted)
	msg:Dock(TOP)
	msg:SetWrap(true)
	msg:SetAutoStretchVertical(true)

	local buttons = vgui.Create("DPanel", card)
	buttons:SetTall(S(34))
	buttons:Dock(TOP)
	buttons:DockMargin(0, S(16), 0, 0)
	buttons.Paint = nil

	local registerBtn = MakeButton(buttons, "#beatrun.coursesmenu.profilepage.register", "primary")
	registerBtn:Dock(LEFT)
	registerBtn:DockMargin(0, 0, S(8), 0)
	registerBtn.DoClick = function()
		gui.OpenURL(authUrl)
		timer.Simple(.5, OpenApiKeyPopup)
	end

	local copyBtn = MakeButton(buttons, "#beatrun.coursesmenu.profilepage.copylink", "secondary")
	copyBtn:Dock(LEFT)
	copyBtn:DockMargin(0, 0, S(8), 0)
	copyBtn.DoClick = function(self)
		SetClipboardText(authUrl)
		self:SetText("#beatrun.coursesmenu.copied")
		timer.Simple(2, function() if IsValid(self) then self:SetText("#beatrun.coursesmenu.profilepage.copylink") end end)
	end

	local keyBtn = MakeButton(buttons, "#beatrun.coursesmenu.profilepage.changekey", "secondary")
	keyBtn:Dock(LEFT)
	keyBtn.DoClick = function() OpenApiKeyPopup() end

	card.PerformLayout = function(self)
		self:SizeToChildren(false, true)
		self:SetTall(self:GetTall() + pad)
	end
end

function BuildProfilePage()
	if not IsValid(ProfilePanel) then return end

	ProfilePanel:Clear()

	local body = MakeBody(ProfilePanel)
	local loading = MakeMessage(body, "#beatrun.coursesmenu.loading")
	local apiKey = databaseApiKey:GetString()
	local headers = {
		key = apiKey ~= "" and apiKey or "0"
	}

	http.Fetch("https://" .. databaseDomain:GetString() .. "/api/key/validate", function(validateBody, _, _, code)
		if not IsValid(body) then return end

		loading:Remove()

		local res = util.JSONToTable(validateBody or "")
		if code ~= 200 or not res or res.code and res.code ~= 200 then
			LogApiError("/api/key/validate", code, validateBody, res)
			MakeMessage(body, "#beatrun.coursesmenu.notification.fetch.failed", CurrentTheme().buttons.danger.t)
			return
		end

		if not res.data then return BuildProfileSignIn(body) end

		BuildProfileCard(body, apiKey)

		if istable(res.ban) then
			local banned = MakeMessage(body, L("beatrun.coursesmenu.banned.text"):format(tostring(res.ban.reason or "?")), CurrentTheme().buttons.danger.t)
			banned:DockMargin(0, 0, 0, S(6))

			local openSite = MakeButton(body, "#beatrun.coursesmenu.banned.opensite", "primary")
			openSite:Dock(TOP)
			openSite:DockMargin(0, 0, 0, S(14))
			openSite.DoClick = OpenDatabaseSite
		end

		MakeTitle(body, "#beatrun.coursesmenu.profilepage.mycourses")

		local scroll = MakeScroll(body)

		MakeMessage(scroll, "#beatrun.coursesmenu.loading")

		local steamId = LocalPlayer():SteamID64()

		http.Fetch("https://" .. databaseDomain:GetString() .. "/api/courses/search?limit=100&author=" .. steamId, function(listBody, _, _, listCode)
			if not IsValid(scroll) then return end

			local listRes = util.JSONToTable(listBody or "")
			local items = listRes and listRes.data and listRes.data.items

			if listCode ~= 200 or not items then
				LogApiError("/api/courses/search", listCode, listBody, listRes)

				scroll:Clear()

				MakeMessage(scroll, "#beatrun.coursesmenu.notification.fetch.failed", CurrentTheme().buttons.danger.t)

				return
			end

			local myCourses = {}
			for _, course in ipairs(items) do
				myCourses[#myCourses + 1] = ToMenuCourse(course)
			end

			BuildProfileCourses(scroll, myCourses)
		end, function(err) print("> /api/courses/search\nError: ", err) end)
	end, function(err)
		if IsValid(loading) then loading:SetText("#beatrun.coursesmenu.notification.openconsole") end
		print("> /api/key/validate\nError: ", err)
	end, headers)
end

-- Settings
local OpenCoursesMenu

local function MakeSettingLabel(parent, text)
	local label = MakeLabel(parent, text, "BeatrunUISmall", CurrentTheme().text.muted)
	label:Dock(TOP)
	label:DockMargin(0, 0, 0, S(6))

	return label
end

local function MakeSettingCheck(parent, text, description, convar)
	local check = vgui.Create("DCheckBoxLabel", parent)
	check:SetText(text)
	check:SetFont("BeatrunUI")
	check:SetTextColor(CurrentTheme().text.primary)
	check:SetConVar(convar)
	check:Dock(TOP)
	check.Button:SetSize(S(20), S(20))

	StyleCheckBox(check.Button)

	local hint = MakeLabel(parent, description, "AEUIDefault", CurrentTheme().text.muted)
	hint:Dock(TOP)
	hint:DockMargin(S(28), S(2), 0, S(14))
	hint:SetWrap(true)
	hint:SetAutoStretchVertical(true)

	return check
end

function BuildSettingsPage()
	if not IsValid(SettingsPanel) then return end

	SettingsPanel:Clear()

	local scroll = MakeScroll(SettingsPanel)
	local body = scroll:GetCanvas()
	body:DockPadding(S(20), S(20), math.max(S(20), SettingsPanel:GetParent():GetWide() - S(580)), S(20))

	-- Appearance
	MakeTitle(body, "#beatrun.coursesmenu.settings")

	local allSettings = MakeButton(body, "#beatrun.settings.open", "secondary", "BeatrunUI")
	allSettings:Dock(TOP)
	allSettings:DockMargin(0, 0, 0, S(20))
	allSettings.DoClick = function()
		if IsValid(Frame) then Frame:Close() end

		OpenSettingsMenu()
	end

	MakeSettingLabel(body, "#beatrun.coursesmenu.settings.theme")

	local themeSelect = UI.MakeComboBox(body)
	themeSelect:Dock(TOP)
	themeSelect:DockMargin(0, 0, 0, S(20))

	for _, key in ipairs(THEME_ORDER) do
		themeSelect:AddChoice(L("beatrun.coursesmenu.themes." .. key), key, key == string.lower(uiTheme:GetString()))
	end

	function themeSelect:OnSelect(_, _, data)
		if uiTheme:GetString() == data then return end

		uiTheme:SetString(data)

		if IsValid(Frame) then Frame:Remove() end

		timer.Simple(0, function() OpenCoursesMenu("settings") end)
	end

	-- Courses
	MakeTitle(body, "#beatrun.toolsmenu.courses.name"):DockMargin(0, S(10), 0, S(10))

	MakeSettingCheck(body, "#beatrun.toolsmenu.courses.raceyourghost", "#beatrun.toolsmenu.courses.raceyourghostdesc", "Beatrun_CourseGhost")
	MakeSettingCheck(body, "#beatrun.toolsmenu.courses.faststart", "#beatrun.toolsmenu.courses.faststartdesc", "Beatrun_FastStart")
	MakeSettingCheck(body, "#beatrun.toolsmenu.courses.checkpointsave", "#beatrun.toolsmenu.courses.checkpointsavedesc", "Beatrun_CPSave")
	MakeSettingCheck(body, "#beatrun.coursesmenu.settings.submitrecords", "#beatrun.coursesmenu.settings.submitrecordsdesc", "Beatrun_SubmitRecords")

	-- Database
	MakeTitle(body, "#beatrun.coursesmenu.settings.database"):DockMargin(0, S(10), 0, S(10))

	MakeSettingLabel(body, "#beatrun.coursesmenu.settings.domain")

	local domainEntry = MakeTextEntry(body, databaseDomain:GetString())
	domainEntry:Dock(TOP)

	local function saveDomain(value)
		local val = string.Trim(value or "")
		if val == "" then val = databaseDomain:GetDefault() end

		val = string.gsub(val, "^https?://", "")
		val = string.gsub(val, "/+$", "")

		databaseDomain:SetString(val)
		domainEntry:SetText(val)

		onlineState.status = "idle"
		onlineState.items = nil
	end

	domainEntry.OnLoseFocus = function(self) saveDomain(self:GetValue()) end
	domainEntry.OnEnter = function(self, value) saveDomain(value) end
end

local function BuildOnlineChrome(panel)
	local bar = MakeToolbar(panel)

	local mapBtn = MakeButton(bar, "", "secondary")
	mapBtn:Dock(LEFT)
	mapBtn:DockMargin(0, 0, S(8), 0)

	surface.SetFont("BeatrunUISmall")

	local w1 = surface.GetTextSize(L("beatrun.coursesmenu.onlinepage.currentmap"))
	local w2 = surface.GetTextSize(L("beatrun.coursesmenu.onlinepage.notcurrentmap"))

	mapBtn:SetWide(math.max(w1, w2) + S(32))

	local function updateMapBtn()
		mapBtn:SetText(isCurrentMapOnly and "#beatrun.coursesmenu.onlinepage.currentmap" or "#beatrun.coursesmenu.onlinepage.notcurrentmap")
	end

	updateMapBtn()

	mapBtn.DoClick = function()
		isCurrentMapOnly = not isCurrentMapOnly
		updateMapBtn()
		SetOnlinePage(1)
	end

	local search = MakeTextEntry(bar, "#beatrun.coursesmenu.onlinepage.search.placeholder")
	search:Dock(FILL)
	search:SetText(onlineState.query)
	search:SetUpdateOnType(true)

	local searchTimer = "Beatrun_CourseSearchDebounce"

	function search:OnValueChange(text)
		timer.Create(searchTimer, SEARCH_DELAY, 1, function()
			local query = string.Trim(text or "")
			if query == onlineState.query then return end

			onlineState.query = query

			SetOnlinePage(1)
		end)
	end

	OnlinePager = vgui.Create("DPanel", panel)
	OnlinePager:SetTall(S(54))
	OnlinePager:Dock(BOTTOM)
	OnlinePager:DockPadding(S(20), S(10), S(20), S(10))
	OnlinePager.Paint = function(self, w, h)
		local theme = CurrentTheme()
		surface.SetDrawColor(theme.border)
		surface.DrawLine(0, 0, w, 0)
	end

	local prevBtn = MakeButton(OnlinePager, "#beatrun.coursesmenu.onlinepage.prev", "secondary")
	prevBtn:Dock(LEFT)
	prevBtn.DoClick = function() SetOnlinePage(onlineState.page - 1) end

	local nextBtn = MakeButton(OnlinePager, "#beatrun.coursesmenu.onlinepage.next", "secondary")
	nextBtn:Dock(RIGHT)
	nextBtn.DoClick = function() SetOnlinePage(onlineState.page + 1) end

	local pageLabel = MakeLabel(OnlinePager, "", "BeatrunUISmall", CurrentTheme().text.muted)
	pageLabel:Dock(FILL)
	pageLabel:SetContentAlignment(5)

	function OnlinePager:Update()
		local loading = onlineState.status == "loading"

		pageLabel:SetText(loading and L("beatrun.coursesmenu.loading") or L("beatrun.coursesmenu.onlinepage.page"):format(onlineState.page, onlineState.pages, onlineState.total))
		prevBtn:SetEnabled(not loading and onlineState.page > 1)
		nextBtn:SetEnabled(not loading and onlineState.page < onlineState.pages)
	end

	List = MakeScroll(panel)
	List:DockMargin(S(20), S(16), S(10), 0)
end

function OpenCoursesMenu(startPage)
	if IsValid(Frame) then Frame:Remove() end

	local headerH = S(36)

	Frame = vgui.Create("DFrame")
	Frame:SetTitle("")
	Frame:SetSize(math.min(ScrW() * 0.9, S(1600)), math.min(ScrH() * 0.9, S(960)))
	Frame:Center()
	Frame:DockPadding(1, headerH, 1, 1)
	Frame:ShowCloseButton(false)
	Frame:MakePopup()
	Frame.Paint = function(self, w, h)
		local theme = CurrentTheme()
		local radius = S(theme.radius)

		PaintWindowBackground(self, w, h)
		draw.RoundedBoxEx(radius, 0, 0, w, headerH, theme.header, true, true, false, false)

		if theme.outline then
			surface.SetDrawColor(theme.border)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end

		draw.SimpleText("★ BEATRUN / " .. string.upper(L("beatrun.coursesmenu.title")), "BeatrunUI", S(14), headerH / 2, theme.text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		local ply = LocalPlayer()

		if IsValid(ply) and ply.GetLevel then
			local right = w - headerH - S(14)
			local barW = S(120)
			draw.SimpleText(L("beatrun.hud.lvl"):format(ply:GetLevel()) .. " | " .. ply:Nick(), "BeatrunUISmall", right - barW - S(12), headerH / 2, theme.text.primary, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			surface.SetDrawColor(theme.panels.secondary)
			surface.DrawRect(right - barW, headerH / 2 - S(2), barW, S(4))
			surface.SetDrawColor(theme.text.primary)
			surface.DrawRect(right - barW, headerH / 2 - S(2), barW * math.Clamp(ply:GetLevelRatio(), 0, 1), S(4))
		end
	end

	local close = MakeButton(Frame, "✕", "close")
	close:SetSize(headerH, headerH)
	close:SetPos(Frame:GetWide() - headerH, 0)
	close.DoClick = function() if IsValid(Frame) then Frame:Close() end end

	local tabBar = vgui.Create("DPanel", Frame)
	tabBar:SetTall(S(40))
	tabBar:Dock(TOP)
	tabBar:DockPadding(S(12), 0, S(12), 0)
	tabBar.Paint = function(self, w, h)
		local theme = CurrentTheme()
		surface.SetDrawColor(theme.border)
		surface.DrawLine(0, h - 1, w, h - 1)
	end

	local content = vgui.Create("DPanel", Frame)
	content:Dock(FILL)
	content.Paint = nil

	local pages = {}
	local activePage

	local function SelectPage(key)
		local page = pages[key] or pages["local"]
		activePage = page
		for _, p in pairs(pages) do
			p.panel:SetVisible(p == page)
		end

		page.builder()
	end

	local function AddPage(key, label, builder)
		local panel = vgui.Create("DPanel", content)
		panel:Dock(FILL)
		panel:SetPaintBackground(false)
		panel:SetVisible(false)

		local tab = vgui.Create("DButton", tabBar)
		tab:SetText(string.upper(L(label)))
		tab:SetFont("BeatrunUISmall")
		tab:SetCursor("hand")
		tab:Dock(LEFT)
		tab:SizeToContentsX(S(28))

		local page = {
			panel = panel,
			builder = builder
		}

		tab.Paint = function(self, w, h)
			local theme = CurrentTheme()
			local active = activePage == page

			self:SetTextColor(active and theme.text.primary or self:IsHovered() and theme.accent or theme.text.muted)

			if active then
				surface.SetDrawColor(theme.accent)
				surface.DrawRect(0, h - S(3), w, S(3))
			end
		end

		tab.DoClick = function() if activePage ~= page then SelectPage(key) end end
		pages[key] = page

		return panel
	end

	LocalPanel = AddPage("local", "#beatrun.coursesmenu.localpage", BuildLocalPage)
	CodePanel = AddPage("code", "#beatrun.coursesmenu.codepage", BuildCodePage)
	BrowsePanel = AddPage("online", "#beatrun.coursesmenu.onlinepage", BuildOnlinePage)
	ProfilePanel = AddPage("profile", "#beatrun.coursesmenu.profilepage", BuildProfilePage)
	SettingsPanel = AddPage("settings", "#beatrun.coursesmenu.settings", BuildSettingsPage)
	BuildOnlineChrome(BrowsePanel)
	timer.Simple(0, function() if IsValid(Frame) then SelectPage(startPage or "local") end end)
end

BeatrunUI.OpenCourseSave = OpenCourseSaveMenu

function OpenDBMenu()
	OpenCoursesMenu()
end

concommand.Add("beatrun_coursesmenu", OpenDBMenu)
