if game.SinglePlayer() then return end

local maxmsgcount = 100
-- local netIncoming_old = net.Incoming

local netIncoming_detour = function(length, ply)
	local tickcount = engine.TickCount()

	if tickcount > (ply.NetDelay or 0) then
		ply.NetDelayCount = 0
		ply.NetDelay = tickcount + 10
	end

	ply.NetDelayCount = ply.NetDelayCount + 1

	if ply.NetDelayCount > maxmsgcount then
		ply:Kick("Client sent too much data")

		return
	end

	local i = net.ReadHeader()
	local strName = util.NetworkIDToString(i)
	if not strName then return end

	local func = net.Receivers[strName:lower()]
	if not func then return end

	length = length - 16
	func(length, ply)
end

net.Incoming = netIncoming_detour