local blacklistedents = {
	["weapon_pistol"] = true,
	["weapon_357"] = true,
	["weapon_crossbow"] = true,
	["weapon_crowbar"] = true,
	["weapon_ar2"] = true,
	["weapon_rpg"] = true,
	["weapon_shotgun"] = true,
	["weapon_smg1"] = true,
	["item_ammo_357"] = true,
	["item_ammo_ar2"] = true,
	["item_ammo_ar2_altfire"] = true,
	["item_healthkit"] = true,
	["item_healthvial"] = true,
	["item_ammo_smg1"] = true,
	["item_box_buckshot"] = true,
	["item_battery"] = true,
	["item_ammo_smg1_grenade"] = true,
	["item_ammo_pistol"] = true,
	["item_ammo_crossbow"] = true,
	["item_rpg_round"] = true,
	["item_ammo_smg1_large"] = true
}

local old = game.CleanUpMap

local CleanUpMapDetoured = function(dsc, efilters)
	if istable(efilters) then
		table.insert(efilters, "env_skypaint")
	end

	old(dsc, efilters)
end

local spawn = {
	{"br_swingbar", Vector(-473.625, 2578.53125, 219.5625), Angle(0, 90, 0)},
	{"br_swingbar", Vector(-303.8125, 2578.53125, 219.5625), Angle(0, 90, 0)},
	{"br_swingbar", Vector(-398.15625, 2578.53125, 219.5625), Angle(0, 90, 0)},
	{"br_swingbar", Vector(3387.78125, 2381.0625, 235.1875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(3387.78125, 2286.84375, 235.1875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1222.21875, 1197.59375, 561.15625), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1566.3125, 1181.9375, 465.78125), Angle(0, -45, 0)},
	{"br_swingbar", Vector(1792.15625, 1228.65625, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1792.15625, 1062.25, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1792.15625, 1156.25, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2309.21875, 1417.1875, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2309.21875, 1323.1875, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2309.21875, 1489.59375, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2309.21875, 1417.1875, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2309.21875, 1323.1875, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2309.21875, 1489.59375, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2076.34375, 1417.1875, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2076.34375, 1323.1875, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2076.375, 1489.59375, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1792.15625, 1417.1875, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1792.15625, 1323.1875, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1792.15625, 1489.59375, 228.59375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2014.34375, 2145.6875, 670.9375), Angle(0, 45, 0)},
	{"br_swingbar", Vector(2014.34375, 2145.6875, 355.125), Angle(0, 45, 0)},
	{"br_swingbar", Vector(1967.34375, 1558.59375, 582.5625), Angle(0, 90, 0)},
	{"br_swingbar", Vector(2014.34375, 2145.6875, 454.21875), Angle(0, 45, 0)},
	{"br_swingbar", Vector(-302.65625, 5230.15625, 461.625), Angle(0, 90, 0)},
	{"br_swingbar", Vector(-445.125, 5230.15625, 461.59375), Angle(0, 90, 0)},
	{"br_swingbar", Vector(-350.5, 5230.15625, 461.59375), Angle(0, 90, 0)},
	{"br_swingbar", Vector(-350.5, 5692.8125, 381.84375), Angle(0, 90, 0)},
	{"br_swingbar", Vector(-302.65625, 5692.8125, 381.84375), Angle(0, 90, 0)},
	{"br_swingbar", Vector(-445.125, 5692.8125, 381.84375), Angle(0, 90, 0)},
	{"br_swingbar", Vector(-350.5, 5489.90625, 420.3125), Angle(0, 90, 0)},
	{"br_swingbar", Vector(-302.65625, 5489.90625, 420.34375), Angle(0, 90, 0)},
	{"br_swingbar", Vector(-445.125, 5489.90625, 420.3125), Angle(0, 90, 0)},
	{"br_swingbar", Vector(446.40625, 4603.78125, 370.9375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(446.40625, 4698.09375, 370.9375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(446.40625, 4509.8125, 370.9375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(446.40625, 4415.53125, 370.9375), Angle(0, 0, 0)},
	{"br_swingbar", Vector(748.8125, 4341.1875, 374), Angle(0, 90, 0)},
	{"br_swingbar", Vector(654.09375, 4341.1875, 374), Angle(0, 90, 0)},
	{"br_swingbar", Vector(558.34375, 4341.1875, 374), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1261.25, 4447.3125, 229.40625), Angle(0, -90, 0)},
	{"br_swingbar", Vector(1425.46875, 4447.3125, 229.40625), Angle(0, -90, 0)},
	{"br_swingbar", Vector(1331.21875, 4447.3125, 229.40625), Angle(0, -90, 0)},
	{"br_swingbar", Vector(1261.25, 4259.6875, 165.875), Angle(0, -90, 0)},
	{"br_swingbar", Vector(1425.46875, 4259.6875, 165.875), Angle(0, -90, 0)},
	{"br_swingbar", Vector(1331.21875, 4259.6875, 165.875), Angle(0, -90, 0)},
	{"br_swingbar", Vector(377.3125, 4595.125, -248.8125), Angle(-15, 0, 0)},
	{"br_swingbar", Vector(377.3125, 4689.65625, -248.8125), Angle(-15, 0, 0)},
	{"br_swingbar", Vector(1504.59375, 4527.5625, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1504.59375, 4811.40625, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1504.59375, 4622.09375, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1504.59375, 4716.84375, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1166.28125, 4527.5625, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1166.28125, 4811.40625, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1166.28125, 4622.09375, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1166.28125, 4716.84375, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1718, 4527.5625, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(967.34375, 4811.40625, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1718, 4622.09375, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1718, 4716.84375, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(538.03125, 4595.125, -248.78125), Angle(-14.96875, 0, 0)},
	{"br_swingbar", Vector(538.03125, 4689.65625, -248.78125), Angle(-14.96875, 0, 0)},
	{"br_swingbar", Vector(967.3125, 4622.09375, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(967.3125, 4527.5625, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(967.3125, 4716.84375, 216.03125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(967.3125, 4622.09375, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(967.3125, 4527.5625, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(967.3125, 4716.84375, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1202.625, 4622.09375, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1202.625, 4527.5625, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1202.625, 4716.84375, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1481.375, 4622.09375, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1481.375, 4527.5625, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1481.375, 4716.84375, -37.53125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1773.0625, 4249.3125, -0.875), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1774.59375, 4251.5, -0.1875), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1938, 4251.5, -0.1875), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1866.53125, 4249.3125, -0.875), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1868.0625, 4251.5, -0.1875), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1936.46875, 4249.3125, -0.875), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1773.0625, 4399.96875, -91.1875), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1938, 4402.15625, -90.5), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1866.53125, 4399.96875, -91.1875), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1868.0625, 4402.15625, -90.5), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1936.46875, 4399.96875, -91.1875), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1774.59375, 4402.15625, -90.5), Angle(0, 90, 0)},
	{"br_swingbar", Vector(538.03125, 4689.65625, -5.46875), Angle(-15, 0, 0)},
	{"br_swingbar", Vector(538.03125, 4595.125, -5.46875), Angle(-15, 0, 0)},
	{"br_swingbar", Vector(377.3125, 4595.125, -5.46875), Angle(-15, 0, 0)},
	{"br_swingbar", Vector(377.3125, 4689.65625, -5.46875), Angle(-15, 0, 0)},
	{"br_swingbar", Vector(-740.78125, 2292.65625, 638.25), Angle(0, 0, 0)},
	{"br_swingbar", Vector(-740.75, 2385.21875, 638.25), Angle(0, 0, 0)},
	{"br_swingbar", Vector(-519.09375, 2385.21875, 638.25), Angle(0, 0, 0)},
	{"br_swingbar", Vector(-519.09375, 2292.65625, 638.25), Angle(0, 0, 0)},
	{"br_swingbar", Vector(-238.9375, 2385.21875, 638.25), Angle(0, 0, 0)},
	{"br_swingbar", Vector(-17.28125, 2292.65625, 638.25), Angle(0, 0, 0)},
	{"br_swingbar", Vector(-238.9375, 2292.65625, 638.25), Angle(0, 0, 0)},
	{"br_swingbar", Vector(-17.28125, 2385.21875, 638.25), Angle(0, 0, 0)},
	{"br_swingbar", Vector(927.21875, 2399.8125, 115.3125), Angle(0, 135, 0)},
	{"br_swingbar", Vector(913.59375, 2681.71875, 114.09375), Angle(0, 90, 0)},
	{"br_swingbar", Vector(1309.09375, 2333.59375, 19), Angle(0, -45, 0)},
	{"br_swingbar", Vector(1360.53125, 2053.5625, -3.59375), Angle(0, -90, 0)},
	{"br_swingbar", Vector(1360.90625, 1734.5625, -65.09375), Angle(0, -90, 0)},
	{"br_swingbar", Vector(1316.84375, 1415.65625, -84.125), Angle(0, -60, 0)},
	{"br_swingbar", Vector(1765.78125, 1377.84375, -99.6875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1765.78125, 1284.0625, -99.6875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1529.1875, 1197.1875, -99.6875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(1529.1875, 1290.96875, -99.6875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2635.4375, 1493.15625, 8.46875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2635.4375, 1330.03125, 8.5), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2713.09375, 1418.4375, 99.78125), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2055, 1418.4375, -183.6875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2055, 1488.59375, -183.6875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2055, 1325.46875, -183.6875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2237, 1418.4375, -140.96875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2237, 1488.59375, -141), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2237, 1325.46875, -140.96875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2463.84375, 1418.4375, -85.6875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2463.84375, 1488.59375, -85.71875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2463.84375, 1325.46875, -85.6875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(2635.4375, 1423, 8.46875), Angle(0, 0, 0)},
	{"br_swingbar", Vector(-2400.0625, 95.59375, 307.90625), Angle(0, 45, 0)},
	{"br_swingbar", Vector(2274.5, 2412.0625, 136.46875), Angle(0, -90, 0)},
	{"br_swingbar", Vector(2274.5, 2650.0625, 123.46875), Angle(0, -90, 0)},
	{"br_swingbar", Vector(2606.75, 1556, 594.78125), Angle(0, -90, 0)},
	{"br_swingbar", Vector(2600.21875, 1798.09375, 611.125), Angle(0, -90, 0)},
	{"br_swingbar", Vector(2582.125, 2146.9375, 531.6875), Angle(0, -45, 0)},
	{"br_swingbar", Vector(2437.125, 2715.25, 377.5), Angle(0, 90, 0)},
	{"br_swingbar", Vector(2345.5, 2715.25, 377.5), Angle(0, 90, 0)},
	{"br_swingbar", Vector(2376.90625, 2456.28125, 377.5), Angle(0, 90, 0)},
	{"br_swingbar", Vector(2285.28125, 2456.28125, 377.5), Angle(0, 90, 0)},
	{"br_anticampbox", Vector(-778.63702392578, -1732.625, 1833.2685546875), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(-1413.6267089844, -889.77520751953, 1408.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(-2296.6579589844, -766.48419189453, 1152.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(-1411.6685791016, 7568.8515625, 1024.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(653.60040283203, 7546.6235351563, 1024.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(1083.7712402344, 3445.6235351563, 896.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(1605.3482666016, 3456.8474121094, 896.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(2105.6247558594, 3471.8090820313, 896.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(4092.0490722656, 4081.3520507813, 1280.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(4089.609375, 2811.6884765625, 1280.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(3846.6906738281, 2050.796875, 1216.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(3843.7377929688, 1138.6533203125, 1216.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(2306.8647460938, 1014.7623291016, 1474.8770751953), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(501.71005249023, 63.838512420654, 1280.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(-74.375015258789, 125.63264465332, 1408.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(-136.48791503906, -894.35400390625, 1408.03125), Angle(0, 0, 0)},
	{"br_anticampbox", Vector(-380.66781616211, 1725.1768798828, 2131.5939941406), Angle(0, 0, 0)},
}

function PrintAllBars()
	for _, v in pairs(ents.FindByClass("br_swingbar")) do
		local pos, ang = v:GetPos(), v:GetAngles()
		local str = "{\"br_swingbar\", Vector(" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. "), Angle(" .. ang.x .. ", " .. ang.y .. ", " .. ang.z .. ")},"
		print(str)
	end
end

function PrintAllCampBoxes()
	for _, v in pairs(ents.FindByClass("br_anticampbox")) do
		local pos, ang = v:GetPos(), v:GetAngles()
		local str = "{\"br_anticampbox\", Vector(" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. "), Angle(" .. ang.x .. ", " .. ang.y .. ", " .. ang.z .. ")},"
		print(str)
	end
end

local function CreateSpawnEntities()
	for _, v in ipairs(spawn) do
		BRProtectedEntity(v[1], v[2], v[3])
	end
end

hook.Add("InitPostEntity", "CreateSpawnEntities", CreateSpawnEntities)
hook.Add("PostCleanupMap", "CreateSpawnEntities", CreateSpawnEntities)

game.CleanUpMap = CleanUpMapDetoured

local skypaint

hook.Add("PlayerSpawn", "CubixInit", function()
	RunConsoleCommand("sv_skyname", "painted")

	if not skypaint then
		skypaint = ents.Create("env_skypaint")
		WhitescaleOn()
	end
end)

hook.Add("OnEntityCreated", "BlacklistedEnts", function(ent)
	if IsValid(ent) and blacklistedents[ent:GetClass()] then
		ent:Remove()

		return
	end

	if IsValid(ent) and ent:GetClass() == "func_button" and ent:GetName() == "device_ctrl" then
		ent:Remove()

		return
	end

	timer.Simple(0, function()
		if IsValid(ent) and (ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_respawnable") then
			local phys = ent:GetPhysicsObject()

			if IsValid(phys) then
				phys:EnableMotion(false)
			end
		end
	end)
end)

hook.Add("PlayerUse", "button", function(ply, ent)
	if ent:GetName() == "device_ctrl" then return false end
end)

print("Loaded cubix")