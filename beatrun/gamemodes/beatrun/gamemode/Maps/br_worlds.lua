local spawn = {
	{"br_swingbar", Vector(935.281250, 847.187500, 13185), Angle(0, 0, 0)},
	{"br_swingbar", Vector(935.281250, 813.875000, 13185), Angle(0, 0, 0)},
}

function PrintAllBars()
	for k, v in pairs(ents.FindByClass("br_swingbar")) do
		local pos, ang = v:GetPos(), v:GetAngles()
		local str = "{\"br_swingbar\", Vector(" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. "), Angle(" .. ang.x .. ", " .. ang.y .. ", " .. ang.z .. ")},"
		print(str)
	end
end

local function CreateSpawnEntities()
	for k, v in ipairs(spawn) do
		BRProtectedEntity(v[1], v[2], v[3])
	end
end

hook.Add("InitPostEntity", "CreateSpawnEntities", CreateSpawnEntities)
hook.Add("PostCleanupMap", "CreateSpawnEntities", CreateSpawnEntities)

print("Loaded worlds")

BlockWhitescaleSkypaint = true