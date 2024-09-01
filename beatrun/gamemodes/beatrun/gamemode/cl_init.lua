include("shared.lua")

for _, v in ipairs(file.Find("gamemodes/beatrun/gamemode/cl/*.lua", "GAME")) do
	include("cl/" .. v)
end

http.Fetch("https://raw.githubusercontent.com/JonnyBro/beatrun/main/version.txt", function(body, size, headers, code)
	if code == 200 then
		if body == VERSIONGLOBAL then
			VERSIONLATEST = true
		else
			VERSIONLATEST = false
		end
	else
		print("Error while checking version:\n" .. body)
	end
end, function(e)
	print("Error while checking version:\n" .. e)
end)