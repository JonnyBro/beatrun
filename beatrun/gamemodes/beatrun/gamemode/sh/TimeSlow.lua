if not game.SinglePlayer() then return end

local slow = false
local slowlerp = 1
local slowtarget = 0.35
local slowspeed = 2

if SERVER then
	util.AddNetworkString("SlowSounds")

	hook.Add("Think", "TimeSlow", function()
		if slow and slowlerp ~= slowtarget then
			slowlerp = math.Approach(slowlerp, slowtarget, slowspeed * FrameTime())

			game.SetTimeScale(slowlerp)
		elseif not slow and slowlerp ~= 1 then
			slowlerp = math.Approach(slowlerp, 1, slowspeed * 2 * FrameTime())

			game.SetTimeScale(slowlerp)
		end
	end)
end

local function TimeSlowSounds(t)
	local slow = slow

	if CLIENT then
		slow = game.GetTimeScale() <= slowtarget
	end

	if slow then
		t.Pitch = t.Pitch * 0.35

		return true
	end
end

net.Receive("SlowSounds", function()
	local slowed = net.ReadBool()

	if slowed then
		hook.Add("EntityEmitSound", "TimeSlow", TimeSlowSounds)
	else
		hook.Remove("EntityEmitSound", "TimeSlow")
	end
end)

concommand.Add("Beatrun_ToggleTimeSlow", function(ply)
	slow = not slow

	net.Start("SlowSounds")
		net.WriteBool(slow)
	net.Send(ply)

	if slow then
		hook.Add("EntityEmitSound", "TimeSlow", TimeSlowSounds)
	else
		hook.Remove("EntityEmitSound", "TimeSlow")
	end
end)