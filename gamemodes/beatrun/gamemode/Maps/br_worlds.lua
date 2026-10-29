local spawn = {
	{ "br_swingbar", Vector(935.281250, 847.187500, 13185), Angle(0, 0, 0) },
	{ "br_swingbar", Vector(935.281250, 813.875000, 13185), Angle(0, 0, 0) },
}

local function CreateSpawnEntities()
	for _, v in ipairs(spawn) do
		BRProtectedEntity(v[1], v[2], v[3])
	end
end

hook.Add("InitPostEntity", "CreateSpawnEntities", CreateSpawnEntities)
hook.Add("PostCleanupMap", "CreateSpawnEntities", CreateSpawnEntities)
