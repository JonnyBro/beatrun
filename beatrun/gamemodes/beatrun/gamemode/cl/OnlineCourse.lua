local apikey = CreateConVar("beatrun_apikey", "0", true, {
	FCVAR_ARCHIVE,
	FCVAR_UNLOGGED
})

function UploadCourse()
	if Course_Name == "" or Course_ID == "" then
		print("Can't upload in Freeplay")

		return
	end

	local file = file.Open("beatrun/courses/" .. game.GetMap() .. "/" .. Course_ID .. ".txt", "rb", "DATA")
	local filedata = util.Decompress(file:Read(file:Size()))

	local function h_failed(reason)
		print("HTTP failed: ", reason)
	end

	local function h_success(code, body, headers)
		print(body)
	end

	local h_method = "POST"
	local h_url = "https://datae.org/beatrun/upload.php"
	local h_headers = {
		["Content-Type"] = "text/plain",
		["Content-Length"] = filedata:len(),
		["User-Agent"] = "Beatrun/1.0.0",
		["Accept-Encoding"] = "gzip, deflate",
		Authorization = apikey:GetString(),
		["Game-Map"] = game.GetMap()
	}
	local h_type = "text/plain"
	local h_body = filedata

	HTTP({
		failed = h_failed,
		success = h_success,
		method = h_method,
		url = h_url,
		headers = h_headers,
		type = h_type,
		body = h_body
	})
end

concommand.Add("Beatrun_UploadCourse", UploadCourse)

local GetCourse_Errors = {
	["Bad map"] = "Error: You are not playing on the map this course was intended for.",
	["Not member"] = "Membership error. For more info, login at datae.org/beatrun",
	["Bad code"] = "Error: The share code provided is invalid.",
	["Not valid key"] = "Error: The API key used is not valid."
}

function GetCourse(sharecode)
	http.Fetch("https://datae.org/beatrun/getcourse.php?sharecode=" .. sharecode .. "&map=" .. game.GetMap() .. "&key=" .. apikey:GetString(), function (body, length, headers, code)
		local errorcode = GetCourse_Errors[body]

		if not errorcode then
			print("Success | Code:", code, "Length:", length)
			PrintTable(headers)
			LoadCourseRaw(util.Compress(body))

			return true
		else
			print(errorcode)

			return false
		end
	end, function (message)
		print("An error occurred.", message)

		return false
	end, {
		["accept-encoding"] = "gzip, deflate"
	})
end

concommand.Add("Beatrun_LoadCode", function (ply, cmd, args, argstr)
	GetCourse(args[1])
end)
