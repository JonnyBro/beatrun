if CLIENT then
	hook.Add("InitPostEntity", "JoinSync", function()
		net.Start("JoinSync")
		net.SendToServer()
	end)
end

if SERVER then
	util.AddNetworkString("JoinSync")

	net.Receive("JoinSync", function(len, ply)
		if not ply.Synced then
			net.Start("BuildMode_Sync")
				net.WriteFloat(Course_StartPos.x)
				net.WriteFloat(Course_StartPos.y)
				net.WriteFloat(Course_StartPos.z)
				net.WriteFloat(Course_StartAng)
				net.WriteString(Course_Name)
				net.WriteString(Course_ID)
				net.WriteInt(Course_Speed, 11)
			net.Send(ply)

			ply.Synced = true
		end
	end)
end