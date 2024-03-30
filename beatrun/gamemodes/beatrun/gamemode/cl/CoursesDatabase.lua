local apikey = CreateClientConVar("Beatrun_Apikey", "0", true, false, language.GetPhrase("beatrun.convars.apikey"))
local domain = CreateClientConVar("Beatrun_Domain", "courses.beatrun.ru", true, false, language.GetPhrase("beatrun.convars.domain"))

local QueuedArgs = NULL
local QueuedFunction = NULL
local currentMap = game.GetMap()

concommand.Add("Beatrun_Cancel", function()
	QueuedArgs = NULL
	QueuedFunction = NULL
end)

concommand.Add("Beatrun_Confirm", function()
	if QueuedArgs and QueuedFunction then
		QueuedFunction(QueuedArgs)

		return
	end

	if QueuedFunction then
		QueuedFunction()

		return
	end

	QueuedArgs = NULL
	QueuedFunction = NULL
end)

local function GetCurrentMapWorkshopID()
	for _, addon in pairs(engine.GetAddons()) do
		if not addon or not addon.title or not addon.wsid or not addon.mounted or not addon.downloaded then continue end

		_, addon_folders = file.Find("*", addon.title)

		if file.Exists("maps/" .. currentMap .. ".bsp", addon.title) then return addon.wsid end
	end

	return "no_map_id"
end

function GetCourse(sharecode)
	local url = domain:GetString() .. "/api/download"

	http.Fetch(url, function(body, length, headers, code)
		local response = util.JSONToTable(body)

		if response.res == 200 then
			print("Success! | Length: " .. length .. "\nLoading course...")

			local dir = "beatrun/courses/" .. currentMap .. "/"
			file.CreateDir(dir)
			local coursedata = util.Compress(response.file)

			file.Write(dir .. sharecode .. ".txt", coursedata)

			LoadCourseRaw(coursedata)

			return true
		else
			print("Error! | Response: " .. response.message)

			return false
		end
	end, function(message)
		print("An error occurred: " .. message)

		return false
	end, {
		authorization = apikey:GetString(),
		code = sharecode,
		map = string.Replace(currentMap, " ", "-")
	})
end

concommand.Add("Beatrun_LoadCode", function(ply, cmd, args, argstr)
	GetCourse(args[1])
end)

function UploadCourse()
	if Course_Name == "" or Course_ID == "" then return print(language.GetPhrase("beatrun.coursesdatabase.cantuploadfreeplay")) end

	local url = domain:GetString() .. "/api/upload"
	local data = file.Open("beatrun/courses/" .. currentMap .. "/" .. Course_ID .. ".txt", "rb", "DATA")
	local filedata = util.Decompress(data:Read(data:Size())) or data:Read(data:Size())

	http.Post(url, NULL, function(body, length, headers, code)
		local response = util.JSONToTable(body)

		if response.res == 200 then
			print("Success! | Code: " .. response.code)

			return true
		else
			print("An error occurred: " .. response.message)

			return false
		end
	end, function(message)
		print("Unexpected error: " .. message)
	end, {
		authorization = apikey:GetString(),
		course = util.Base64Encode(filedata, true),
		map = string.Replace(currentMap, " ", "-"),
		mapid = GetCurrentMapWorkshopID()
	})
end

concommand.Add("Beatrun_UploadCourse", function()
	QueuedFunction = UploadCourse

	print(language.GetPhrase("beatrun.coursesdatabase.upload1"):format(Course_Name, currentMap))
	print(language.GetPhrase("beatrun.coursesdatabase.upload2"))
end)

function UpdateCourse(course_code)
	if Course_Name == "" or Course_ID == "" then return print(language.GetPhrase("beatrun.coursesdatabase.cantuploadfreeplay")) end

	local url = domain:GetString() .. "/api/update"
	local data = file.Open("beatrun/courses/" .. currentMap .. "/" .. Course_ID .. ".txt", "rb", "DATA")
	local filedata = util.Decompress(data:Read(data:Size())) or data:Read(data:Size())

	http.Post(url, NULL, function(body, length, headers, code)
		local response = util.JSONToTable(body)

		if response.res == 200 then
			print("Success! | Code: " .. response.code)

			return true
		else
			print("An error occurred: " .. message)

			return false
		end
	end, function(message)
		print("Unexpected error: " .. message)
	end, {
		authorization = apikey:GetString(),
		code = course_code,
		course = util.Base64Encode(filedata, true),
		map = string.Replace(currentMap, " ", "-")
	})
end

concommand.Add("Beatrun_UpdateCode", function(ply, cmd, args, argstr)
	QueuedFunction = UpdateCourse
	QueuedArgs = args[1]

	print(language.GetPhrase("beatrun.coursesdatabase.update1"):format(QueuedArgs, Course_Name, currentMap))
	print(language.GetPhrase("beatrun.coursesdatabase.upload2"))
end)