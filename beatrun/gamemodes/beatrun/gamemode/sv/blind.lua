util.AddNetworkString("BlindPlayers")
util.AddNetworkString("BlindNPCKilled")

local function Echo()
	return false
end

blinded = false

concommand.Add("toggleblindness", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end

	blinded = not blinded

	net.Start("BlindPlayers")
		net.WriteBool(blinded)
	net.Broadcast()

	if blinded then
		for k, v in pairs(ents.FindByClass("env_soundscape")) do
			v:Remove()
		end

		hook.Add("EntityEmitSound", "Echo", Echo)
	else
		hook.Remove("EntityEmitSound", "Echo")
	end
end)

local red = Color(255, 90, 90)
local green = Color(90, 255, 90)

concommand.Add("blindplayer", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end

	local blinded = tobool(args[2])
	local blindedstr = (blinded and "is now blind.\n") or "is no longer blind.\n"
	local blindedcol = (blinded and red) or green
	local plysearch = args[1]

	if not plysearch then
		MsgC(red, "syntax: blindplayer (player name) (0/1)\n")

		return
	end

	local mply = nil
	local mname = ""
	local mcount = 0

	for k, v in ipairs(player.GetAll()) do
		local name = v:Nick()
		local smatch = string.match(name, plysearch)

		if smatch then
			local slen = smatch:len()

			if slen > mcount then
				mply = v
				mname = name
				mcount = slen
			end
		end
	end

	if IsValid(mply) then
		MsgC(blindedcol, mname, " ", blindedstr)
	else
		MsgC(red, "Player not found: ", plysearch)

		return
	end

	net.Start("BlindPlayers")
		net.WriteBool(blinded)
	net.Send(mply)
end)

hook.Add("OnNPCKilled", "BlindNPCKilled", function(npc, attacker, inflictor)
	if blinded and attacker:IsPlayer() then
		net.Start("BlindNPCKilled")
		net.Send(attacker)
	end
end)

hook.Add("InitPostEntity", "WtfTFA", function()
	hook.Remove("EntityEmitSound", "zzz_TFA_EntityEmitSound")
	hook.Remove("InitPostEntity", "WtfTFA")
end)