function BRProtectedEntity(class, pos, ang)
	local a = ents.Create(class)

	a:SetPos(pos)
	a:SetAngles(ang)
	a:Spawn()
	a:SetNW2Bool("BRProtected", true)

	return a
end

if file.Exists("beatrun/gamemode/Maps/" .. game.GetMap() .. "_cl.lua", "LUA") then
	AddCSLuaFile("beatrun/gamemode/Maps/" .. game.GetMap() .. "_cl.lua")
end

if file.Exists("beatrun/gamemode/Maps/" .. game.GetMap() .. ".lua", "LUA") then
	include("beatrun/gamemode/Maps/" .. game.GetMap() .. ".lua")
end