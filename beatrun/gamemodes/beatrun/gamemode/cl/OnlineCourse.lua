local apikey = CreateClientConVar("Beatrun_Apikey", "0", true, {FCVAR_ARCHIVE, FCVAR_UNLOGGED})
local domain = CreateClientConVar("Beatrun_Domain", "localhost", true, {FCVAR_ARCHIVE, FCVAR_UNLOGGED})

function UploadCourse()
	if Course_Name == "" or Course_ID == "" then return print("Can't upload in Freeplay") end

	local file = file.Open("beatrun/courses/" .. game.GetMap() .. "/" .. Course_ID .. ".txt", "rb", "DATA")
	local filedata = util.Decompress(file:Read(file:Size()))

	local function h_success(code, body, headers)
		print("Response: ", code)
		print("Your Share Code: ", body)
	end

	local function h_failed(reason)
		print("HTTP failed: ", reason)
	end

	local h_method = "POST"
	local h_url = "http://" .. domain:GetString() .. "/upload.php"
	local h_type = "text/plain"
	local h_body = filedata

	local h_headers = {
		["Content-Type"] = "text/plain",
		["Content-Length"] = filedata:len(),
		["User-Agent"] = "Valve/Steam HTTP Client 1.0 (4000)",
		["Accept-Encoding"] = "gzip, deflate",
		Authorization = apikey:GetString(),
		["Game-Map"] = game.GetMap()
	}

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
	["Not valid map"] = "Error: You are not playing on the map this course was intended for.",
	["Not valid share code"] = "Error: The share code provided is invalid.",
	["Not valid key"] = "Plese message @Jonny_Bro#4226 for a key.",
	["Ratelimited"] = "You are ratelimited, please try again later!"
}

function GetCourse(sharecode)
	http.Fetch("http://" .. domain:GetString() .. "/getcourse.php?sharecode=" .. sharecode .. "&map=" .. game.GetMap() .. "&key=" .. apikey:GetString(), function(body, length, headers, code)
		local errorcode = GetCourse_Errors[body]

		if not errorcode then
			print("Success! | Response:", code, "Length:", length)
			print("Loading course...")
			-- PrintTable(headers)
			LoadCourseRaw(util.Compress(body))

			return true
		else
			print(errorcode)

			return false
		end
	end,
	function(message)
		print("An error occurred: ", message)

		return false
	end,
	{
		["accept-encoding"] = "gzip, deflate"
	})
end

concommand.Add("Beatrun_LoadCode", function(ply, cmd, args, argstr)
	GetCourse(args[1])
end)