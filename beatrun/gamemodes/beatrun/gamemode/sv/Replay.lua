util.AddNetworkString("ReplayRequest")
util.AddNetworkString("ReplayTutorialPos")

net.Receive("ReplayRequest", function(len, ply)
	local stopped = net.ReadBool()

	if not stopped and not ply.InReplay and ((Course_Name ~= "") or TUTORIALMODE) then
		ply.InReplay = true

		ply:ResetParkourState()
		ply:Spawn()
		ply:SetNW2Int("CPNum", -1)
		ply:SetLocalVelocity(vector_origin)
		ply:SetLaggedMovementValue(0)

		timer.Simple(0.1, function()
			ply:SetLaggedMovementValue(1)
		end)

		if not TUTORIALMODE then
			ply:SetPos(Course_StartPos)
		else
			ply:SetPos(net.ReadVector())
		end

		net.Start("ReplayRequest")
		net.Send(ply)
	elseif stopped then
		ply.InReplay = false
	end

	hook.Run("PostReplayRequest", ply, stopped)
end)

net.Receive("ReplayTutorialPos", function(len, ply)
	if not TUTORIALMODE then return end

	local pos = net.ReadVector()

	ply:SetPos(pos or ply:GetPos())
	ply:SetLocalVelocity(vector_origin)
end)