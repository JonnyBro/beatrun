local spawn = {
	{"br_databank", Vector(46.673126220703, 957.37548828125, 256.03125)},
	{"br_databank", Vector(-3.3380174636841, -939.83837890625, 256.03125)},
	{"br_databank", Vector(946.02209472656, 269.16903686523, 522.03125)},
	{"br_databank", Vector(-802.15405273438, 343.96166992188, 272.03125)},
	{"br_databank", Vector(-694.69586181641, -590.50836181641, 272.03125)},
	{"br_databank", Vector(-46.449630737305, -1083.9945068359, 256.03125)},
	{"br_databank", Vector(651.01989746094, -464.4665222168, 458.03125)},
}

local function CreateSpawnEntities()
	for k, v in ipairs(spawn) do
		BRProtectedEntity(v[1], v[2], angle_zero)
	end
end

hook.Add("InitPostEntity", "CreateSpawnEntities", CreateSpawnEntities)
hook.Add("PostCleanupMap", "CreateSpawnEntities", CreateSpawnEntities)