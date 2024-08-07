if SERVER then
	util.AddNetworkString("ReplaySendToClient")
end

function ReplayCmd(ply, cmd)
	if not ply.ReplayRecording then return end
	if cmd:TickCount() == 0 then return end

	if not ply.ReplayFirstTick and cmd:TickCount() ~= 0 then
		ply.ReplayFirstTick = cmd:TickCount()
	end

	local ang = cmd:GetViewAngles()

	if ply.ReplayLastAng == ang then
		ang = 0
	else
		ply.ReplayLastAng = ang
	end

	local curtick = cmd:TickCount() - ply.ReplayFirstTick + 1

	if ang == 0 then
		ply.ReplayTicks[curtick] = {cmd:GetButtons(), cmd:GetForwardMove(), cmd:GetSideMove()}
	else
		ply.ReplayTicks[curtick] = {cmd:GetButtons(), ang.x, ang.y, cmd:GetForwardMove(), cmd:GetSideMove()}
	end

	if curtick > 23760 then
		ErrorNoHalt("Replay recording stopped (too long). Your course might be too long.")

		ply.ReplayRecording = false
	end
end

hook.Add("StartCommand", "ReplayStart", ReplayCmd)

function ReplayStart(ply)
	--if not game.SinglePlayer() then return end
	if ply.InReplay then return end

	print("Starting Replay")

	ply.ReplayRecording = true
	ply.ReplayTicks = {}
	ply.ReplayFirstTick = false
	ply.ReplayStartPos = ply:GetPos()
	ply.ReplayLastAng = nil
end

function ReplayStop(ply, debugdump)
	--if not game.SinglePlayer() then return end
	if not ply.ReplayTicks then return end
	if ply.InReplay then return end

	print("Ending Replay (" .. #ply.ReplayTicks .. "ticks)")

	ply.InReplay = false
	ply.ReplayRecording = false

	local debugdata = {ply.ReplayStartPos, ply.ReplayTicks}

	local replay = util.Compress(util.TableToJSON(debugdata))
	local dir = "beatrun/replays/" .. game.GetMap() .. "/"

	file.CreateDir(dir)
	file.Write(dir .. "replaydump.txt", replay)
end

local RFF = true

function ReplayPlayback(ply, cmd)
	if not ply.InReplay or not ply.ReplayTicks then return end

	local cmdtc = cmd:TickCount()

	if cmdtc == 0 then return end

	if not ply.ReplayFirstTick then
		ply.ReplayFirstTick = cmdtc

		if SERVER then
			ply:SetNWInt("ReplayFirstTick", cmdtc)
		end
	end

	local firsttick = ply:GetNWInt("ReplayFirstTick")

	if ply.ReplayTicks[cmdtc - firsttick + 1] then
		tickcount = cmdtc - firsttick + 1

		if ply.ReplayEndAtTick and ply.ReplayEndAtTick <= tickcount then
			ply.ReplayTicks = {}

			return
		end

		local tickdata = ply.ReplayTicks[tickcount]
		local shortdata = #tickdata == 3
		local ang = shortdata and 0 or Angle(tickdata[2], tickdata[3], cmd:GetViewAngles().z)

		if not shortdata then
			ply.ReplayLastAng = ang
		end

		cmd:SetButtons(tickdata[1])
		cmd:SetViewAngles(ply.ReplayLastAng)

		if shortdata then
			cmd:SetForwardMove(tickdata[2])
			cmd:SetSideMove(tickdata[3])
		else
			cmd:SetForwardMove(tickdata[4])
			cmd:SetSideMove(tickdata[5])
		end

		cmd:RemoveKey(IN_RELOAD)
	elseif SERVER and cmdtc - firsttick + 1 > 0 or CLIENT and not ply:GetNWBool("InReplay") and RFF < CurTime() then
		print("Replay cancelled: nil tick at " .. cmdtc - firsttick + 1, firsttick)

		if SERVER then
			ply:SetNWBool("InReplay", false)
		end

		hook.Remove("StartCommand", "ReplayPlay")
		hook.Remove("RenderScreenspaceEffects", "BeatrunReplayVision")
		hook.Remove("HUDPaint", "BeatrunReplayHUD")

		ply.InReplay = false
		ply.ReplayFirstTick = false

		if TUTORIALMODE then
			net.Start("ReplayTutorialPos")
				net.WriteVector(ply.ReplayStartPos)
			net.SendToServer()

			TutorialClearEvents()
		end
	end
end

function ReplaySendToClient(ply)
	if not game.SinglePlayer() then return end

	local replaydata = util.JSONToTable(util.Decompress(file.Read("beatrun/replays/" .. game.GetMap() .. "/replaydump.txt", "DATA")))

	ply.ReplayFirstTick = false
	ply.ReplayStartPos = replaydata[1]
	ply.ReplayTicks = replaydata[2]
	ply:SetNWBool("InReplay", true)

	net.Start("ReplaySendToClient")
	net.Send(ply)

	ply.InReplay = true
	ply:SetPos(ply.ReplayStartPos)
	ply:SetVelocity(vector_origin)

	hook.Add("StartCommand", "ReplayPlay", ReplayPlayback)
end

if CLIENT then
	local tab = {
		["$pp_colour_contrast"] = 0.9,
		["$pp_colour_addg"] = 0.5799,
		["$pp_colour_addb"] = 1.12,
		["$pp_colour_addr"] = 0,
		["$pp_colour_colour"] = 0.14,
		["$pp_colour_brightness"] = -0.57,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0,
		["$pp_colour_mulr"] = 0
	}

	local function BeatrunReplayVision()
		if LocalPlayer().ReplayFirstTick then
			DrawColorModify(tab)
		end
	end

	local rcol = Color(200, 200, 200)

	local function BeatrunReplayHUD()
		if LocalPlayer().ReplayTicks and not LocalPlayer().ReplayTicks.reliable then
			surface.SetFont("BeatrunHUD")
			surface.SetTextColor(rcol)
			surface.SetTextPos(5, ScrH() * 0.975)

			local text = TUTORIALMODE and "" or "*Clientside replay: may not be accurate "
			surface.DrawText(text .. tickcount .. "/" .. #LocalPlayer().ReplayTicks)
		end
	end

	function ReplayBegin()
		LocalPlayer().InReplay = true

		RFF = CurTime() + 1

		hook.Add("StartCommand", "ReplayPlay", ReplayPlayback)
		hook.Add("RenderScreenspaceEffects", "BeatrunReplayVision", BeatrunReplayVision)
		hook.Add("HUDPaint", "BeatrunReplayHUD", BeatrunReplayHUD)

		surface.PlaySound("friends/friend_join.wav")
	end

	net.Receive("ReplayRequest", ReplayBegin)

	net.Receive("ReplaySendToClient", function(length)
		if length < 100 then
			LocalPlayer().ReplayTicks = util.JSONToTable(util.Decompress(file.Read("beatrun/replays/" .. game.GetMap() .. "/replaydump.txt", "DATA")))[2]
		else
			LocalPlayer().ReplayTicks = util.JSONToTable(util.Decompress(net.ReadData(length)))
		end

		LocalPlayer().ReplayFirstTick = false
		ReplayBegin()
	end)
end

function ReplayCancel(ply)
	hook.Remove("StartCommand", "ReplayPlay")
	hook.Remove("RenderScreenspaceEffects", "BeatrunReplayVision")
	hook.Remove("HUDPaint", "BeatrunReplayHUD")

	ply.InReplay = false
	ply.ReplayFirstTick = false

	net.Start("ReplayRequest")
		net.WriteBool(true)
	net.SendToServer()
end