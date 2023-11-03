local apikey = CreateClientConVar("Beatrun_Apikey", "0", true, false, language.GetPhrase("beatrun.convars.apikey"))
local domain = CreateClientConVar("Beatrun_Domain", "courses.beatrun.ru", true, false, language.GetPhrase("beatrun.convars.domain"))

local QueuedArgs = NULL
local QueuedFunction = NULL
local currentMap = game.GetMap()

concommand.Add("Beatrun_Confirm", function()
	if QueuedArgs and QueuedFunction then
		QueuedFunction(QueuedArgs)

		return
	end

	if QueuedFunction then
		QueuedFunction()

		return
	end
end)

concommand.Add("Beatrun_Cancel", function()
	QueuedArgs = NULL
	QueuedFunction = NULL
end)

local function GetCurrentMapWorkshopID()
	for _, addon in pairs(engine.GetAddons()) do
		if not addon or not addon.title or not addon.wsid or not addon.mounted or not addon.downloaded then continue end

		_, addon_folders = file.Find("*", addon.title)

		if file.Exists("maps/" .. currentMap .. ".bsp", addon.title) then return addon.wsid end
	end

	return 0
end

function UploadCourse()
	if Course_Name == "" or Course_ID == "" then return print(language.GetPhrase("beatrun.coursesdatabase.cantuploadfreeplay")) end

	local url = domain:GetString() .. "/upload.php"
	local data = file.Open("beatrun/courses/" .. currentMap .. "/" .. Course_ID .. ".txt", "rb", "DATA")
	local filedata = util.Decompress(data:Read(data:Size()))

	http.Post(url, {
		key = apikey:GetString(),
		map = string.Replace(currentMap, " ", "-"),
		course_data = util.Base64Encode(filedata, true),
		mapid = GetCurrentMapWorkshopID()
	}, function(body, length, headers, code) -- onSuccess function
		if code == 200 then
			print("Response: " .. body)
		else
			print("Error (" .. code .. "): " .. body)
		end
	end, function(message) -- onFailure function
		print("Unexpected error: " .. message)
	end)
end

concommand.Add("Beatrun_UploadCourse", function()
	QueuedFunction = UploadCourse

	print(language.GetPhrase("beatrun.coursesdatabase.upload1"):format(Course_Name, currentMap))
	print(language.GetPhrase("beatrun.coursesdatabase.upload2"))
end)

function GetCourse(sharecode)
	local url = domain:GetString() .. "/getcourse.php"
		.. "?sharecode=" .. sharecode
		.. "&map=" .. string.Replace(currentMap, " ", "-")
		.. "&key=" .. apikey:GetString()

	http.Fetch(url, function(body, length, headers, code)
		if code == 200 then
			print("Success! | Response: " .. code .. " | Length: " .. length .. "\nLoading course...")

			PrintTable(headers)

			local dir = "beatrun/courses/" .. currentMap .. "/"
			file.CreateDir(dir)
			local coursedata = util.Compress(body)

			if not file.Exists(dir .. sharecode .. ".txt", "DATA") then
				file.Write(dir .. sharecode .. ".txt", coursedata)
			end

			LoadCourseRaw(coursedata)

			return true
		else
			print("Error! | Response: " .. code)
			print(body)

			return false
		end
	end, function(message)
		print("An error occurred: ", message)

		return false
	end, {
		["User-Agent"] = "Valve/Steam HTTP Client 1.0 (4000)",
		["Accept-Encoding"] = "gzip"
	})
end

concommand.Add("Beatrun_LoadCode", function(ply, cmd, args, argstr)
	GetCourse(args[1])
end)

function UpdateCourse(course_code)
	if Course_Name == "" or Course_ID == "" then return print(language.GetPhrase("beatrun.coursesdatabase.cantuploadfreeplay")) end

	local url = domain:GetString() .. "/updatecourse.php"
	local data = file.Open("beatrun/courses/" .. currentMap .. "/" .. Course_ID .. ".txt", "rb", "DATA")
	local filedata = util.Decompress(data:Read(data:Size()))

	http.Post(url, {
		key = apikey:GetString(),
		map = string.Replace(currentMap, " ", "-"),
		course_data = util.Base64Encode(filedata, true),
		code = course_code
	}, function(body, length, headers, code) -- onSuccess function
		if code == 200 then
			print("Response: " .. body)
		else
			print("Error (" .. code .. "): " .. body)
		end
	end, function(message) -- onFailure function
		print("Unexpected error: " .. message)
	end)
end

concommand.Add("Beatrun_UpdateCode", function(ply, cmd, args, argstr)
	QueuedFunction = UpdateCourse
	QueuedArgs = args[1]

	print(language.GetPhrase("beatrun.coursesdatabase.update1"):format(QueuedArgs, Course_Name, currentMap))
	print(language.GetPhrase("beatrun.coursesdatabase.upload2"))
end)