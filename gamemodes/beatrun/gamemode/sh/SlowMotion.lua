if not game.SinglePlayer() then return end

local slow = false
local slowlerp = 1
local slowtarget = 0.35
local slowspeed = 2

if SERVER then
	util.AddNetworkString("SlowMotionSounds")

	hook.Add("Think", "SlowMotion", function()
		if slow and slowlerp ~= slowtarget then
			slowlerp = math.Approach(slowlerp, slowtarget, slowspeed * FrameTime())

			game.SetTimeScale(slowlerp)
		elseif not slow and slowlerp ~= 1 then
			slowlerp = math.Approach(slowlerp, 1, slowspeed * 2 * FrameTime())

			game.SetTimeScale(slowlerp)
		end
	end)
end

local function SlowMotionSounds(t)
	local slow = slow

	if CLIENT then
		slow = game.GetTimeScale() <= slowtarget
	end

	if slow then
		t.Pitch = t.Pitch * 0.35

		return true
	end
end

net.Receive("SlowMotionSounds", function()
	local slowed = net.ReadBool()

	if slowed then
		hook.Add("EntityEmitSound", "SlowMotion", SlowMotionSounds)
	else
		hook.Remove("EntityEmitSound", "SlowMotion")
	end
end)

concommand.Add("beatrun_toggleslowmotion", function(ply)
	slow = not slow

	net.Start("SlowMotionSounds")
		net.WriteBool(slow)
	net.Send(ply)

	if slow then
		hook.Add("EntityEmitSound", "SlowMotion", SlowMotionSounds)
	else
		hook.Remove("EntityEmitSound", "SlowMotion")
	end
end)
