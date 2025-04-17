local updatetime = 0

hook.Add("PlayerPostThink", "PacketLossNet", function(ply)
	if CurTime() > updatetime then
		ply:SetNW2Int("PLoss", ply:PacketLoss())

		updatetime = CurTime() + 4
	end
end)