--Kicks people net spamming so the server doesn't eat shit
--Just a pasta of net.Incoming with an added check
if game.SinglePlayer() then return end

local maxmsgcount = 100
local netIncoming_old = net.Receive
local netIncoming_detour = function(length, ply)
	local tickcount = engine.TickCount()
	if tickcount > (ply.NetDelay or 0) then
		ply.NetDelayCount = 0
		ply.NetDelay = tickcount+ 10
	end
	ply.NetDelayCount = ply.NetDelayCount + 1
	
	if ply.NetDelayCount > maxmsgcount then
		ply:Kick("Client sent too much data")
		return
	end
	
	local i = net.ReadHeader()
	local strName = util.NetworkIDToString( i )
	
	if ( !strName ) then return end
	
	local func = net.Receivers[ strName:lower() ]
	if ( !func ) then return end

	length = length - 16
	func( length, ply )
end

net.Incoming = netIncoming_detour