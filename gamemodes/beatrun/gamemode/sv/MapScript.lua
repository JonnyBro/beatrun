function BRProtectedEntity(class, pos, ang)
	local a = ents.Create(class)

	a:SetPos(pos)
	a:SetAngles(ang)
	a:Spawn()
	a:SetNW2Bool("BRProtected", true)

	return a
end

function BRSetSkypaint(skypaint)
	if not IsValid(skypaint) then return end

	skypaint:SetTopColor(Vector(0, 0.34, 0.93))
	skypaint:SetBottomColor(Vector(0.36, 0.76, 1))
	skypaint:SetSunColor(Vector(0.25, 0.1, 0))
	skypaint:SetDuskColor(Vector(1, 1, 1))
	skypaint:SetFadeBias(0.44)
	skypaint:SetHDRScale(0.66)
	skypaint:SetDuskScale(0.79)
	skypaint:SetDuskIntensity(0.5)
	skypaint:SetSunSize(7.44)
	skypaint:SetDrawStars(false)
end

if file.Exists("beatrun/gamemode/Maps/" .. game.GetMap() .. "_cl.lua", "LUA") then
	AddCSLuaFile("beatrun/gamemode/Maps/" .. game.GetMap() .. "_cl.lua")
end

if file.Exists("beatrun/gamemode/Maps/" .. game.GetMap() .. ".lua", "LUA") then
	include("beatrun/gamemode/Maps/" .. game.GetMap() .. ".lua")
end
