util.AddNetworkString("ToggleWhitescale")

local skypaint

local skypaintdata = {Vector(0, 0.34, 0.93), Vector(0.36, 0.76, 1), Vector(0.25, 0.1, 0), Vector(1, 1, 1), 0.44, 0.66, 0.79, 0.5, 7.44}

function WhitescaleOn()
	if BlockWhitescaleSkypaint then return end

	if not IsValid(skypaint) then
		skypaint = ents.FindByClass("env_skypaint")[1]
	end

	if IsValid(skypaint) then
		skypaint:SetTopColor(skypaintdata[1])
		skypaint:SetBottomColor(skypaintdata[2])
		skypaint:SetSunColor(skypaintdata[3])
		skypaint:SetDuskColor(skypaintdata[4])
		skypaint:SetFadeBias(skypaintdata[5])
		skypaint:SetHDRScale(skypaintdata[6])
		skypaint:SetDuskScale(skypaintdata[7])
		skypaint:SetDuskIntensity(skypaintdata[8])
		skypaint:SetSunSize(skypaintdata[9])
		skypaint:SetDrawStars(false)
	end
end

net.Receive("ToggleWhitescale", function(len, ply)
	local toggle = net.ReadBool()

	if toggle then
		WhitescaleOn()
	else return end
end)