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

AddCommand("votemode", function(ply, args, flags)
	if GetGlobalBool("GM_EVENTMODE") then return end
	
	if voteStarted then
		ply:ChatPrint("There is already a vote in progress. Please wait for the current one to end.")
		return
	end

	if CurTime() < nextVoteTime then
		ply:ChatPrint("Vote is on cooldown. Please wait.")
		return
	end

	local mode = args[1] or ""
	if not isValidGamemode(mode) then
		ply:ChatPrint("Invalid gamemode \"" .. mode .. "\".\nAvailable modes (alias):\n- Freeplay (fp)\n- Deathmatch (dm)\n- Infection (infect)\n- Data Theft (dt)")
		return
	end

	StartVote(mode, ply)
	ply:ChatPrint("Started vote for gamemode: " .. mode)
end)