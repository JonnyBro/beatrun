local function ParseArgs(str)
	local args = {}
	local inQuotes = false
	local current = ""

	for i = 1, #str do
		local c = str:sub(i, i)
		if c == '"' then
			inQuotes = not inQuotes
		elseif c == " " and not inQuotes then
			if current ~= "" then
				table.insert(args, current)
				current = ""
			end
		else
			current = current .. c
		end
	end

	if current ~= "" then table.insert(args, current) end

	return args
end

local function ParseFlags(args)
	local flags = {}
	local clean = {}

	for _, v in ipairs(args) do
		if v:sub(1, 1) == "-" then
			flags[v] = true
		else
			table.insert(clean, v)
		end
	end

	return clean, flags
end

local Commands = {}

local function AddCommand(cmd, func)
	Commands[string.lower(cmd)] = func
end

hook.Add("PlayerSay", "BeatrunChatCmd", function(ply, text)
	if text:sub(1, 1) ~= "!" then return end

	local raw = text:sub(2)
	local args = ParseArgs(raw)
	if not args[1] then return end

	local cmd = string.lower(args[1])

	table.remove(args, 1)

	local clean, flags = ParseFlags(args)

	if Commands[cmd] then
		Commands[cmd](ply, clean, flags)
		return ""
	end

	return ""
end)

AddCommand("em_goal", function(ply, args, flags)
	if not GetGlobalBool("GM_EVENTDATA") and ply:GetNW2String("EPlayerStatus", "Member") ~= "Manager" then return end

	local msg = table.concat(args, " ")
	msg = string.upper(msg)

	if msg ~= "" then msg = "[" .. msg .. "]" end

	net.Start("Eventmode_SetGoal")
		net.WriteString(msg)
	net.Broadcast()
end)