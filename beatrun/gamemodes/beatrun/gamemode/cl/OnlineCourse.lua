local apikey = CreateClientConVar("Beatrun_Apikey", "0", true, false, "Your API key")
local domain = CreateClientConVar("Beatrun_Domain", "courses.beatrun.ru", true, false, "Online courses domain")

function UploadCourse()
	if Course_Name == "" or Course_ID == "" then return print("Can't upload in Freeplay") end

	local data = file.Open("beatrun/courses/" .. game.GetMap() .. "/" .. Course_ID .. ".txt", "rb", "DATA")
	local filedata = util.Decompress(data:Read(data:Size()))

	local function h_success(code, body, headers)
		print("Response: " .. code)
		print(body)
	end

	local function h_failed(code, body)
		print("Response: " .. code)
		print(body)
	end

	local h_method = "POST"
	local h_url = "http://" .. domain:GetString() .. "/upload.php"
	local h_type = "text/plain"
	local h_body = filedata

	local h_headers = {
		Authorization = apikey:GetString(),
		["Content-Type"] = "text/plain",
		["Content-Length"] = filedata:len(),
		["User-Agent"] = "Valve/Steam HTTP Client 1.0 (4000)",
		["Accept-Encoding"] = "gzip",
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

function GetCourse(sharecode)
	http.Fetch("http://" .. domain:GetString() .. "/getcourse.php?sharecode=" .. sharecode .. "&map=" .. game.GetMap() .. "&key=" .. apikey:GetString(), function(body, length, headers, code)
		if code == 200 then
			print("Success! | Response: " .. code .. " | Length: " .. length)
			print("Loading course...")

			PrintTable(headers)

			local dir = "beatrun/courses/" .. game.GetMap() .. "/"

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
	end,
	function(message)
		print("An error occurred: ", message)

		return false
	end)
	-- end,
	-- {
	-- 	["User-Agent"] = "Valve/Steam HTTP Client 1.0 (4000)",
	-- 	["Accept-Encoding"] = "gzip"
	-- })
end

concommand.Add("Beatrun_LoadCode", function(ply, cmd, args, argstr)
	GetCourse(args[1])
end)
