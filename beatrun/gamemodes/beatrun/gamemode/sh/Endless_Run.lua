print("h")

local prefabs = {
	basic_floor = {
		{
			Vector(),
			Vector(300, 300, 50),
			0,
			0,
			0
		}
	}
}

function SpawnPrefab(pos, data)
	for k, v in ipairs(data) do
		local mins = v[1]
		local maxs = v[2]
		local offsetx = v[3] or 0
		local offsety = v[4] or 0
		local offsetz = v[5] or 0
		local offsetvec = Vector(offsetx, offsety, offsetz)

		offsetvec:Add(pos)
	end
end
