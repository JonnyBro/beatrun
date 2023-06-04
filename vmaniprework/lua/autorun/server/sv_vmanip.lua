util.AddNetworkString("VManip_SimplePlay")
util.AddNetworkString("VManip_StopHold")

--VManip_SimplePlay: WriteString of anim to play on client (not guaranteed to play)
--VManip_StopHold: WriteString of anim to stop holding on client

local function VManip_FindAndImport()

local path="vmanip/anims/"
local anims=file.Find(path.."*.lua","lsv")

for k,v in pairs(anims) do
		AddCSLuaFile(path..v)
end

end

VManip_FindAndImport()