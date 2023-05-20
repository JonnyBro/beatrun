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
	["item_ammo_smg1_large"] = true,
	["weapon_frag"] = true
}

local old = game.CleanUpMap

local CleanUpMapDetoured = function(dsc, efilters)
	if istable(efilters) then
		table.insert(efilters, "env_skypaint")
	end

	old(dsc, efilters)
end

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

	timer.Simple(0, function()
		if IsValid(ent) and (ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_respawnable") then
			local phys = ent:GetPhysicsObject()

			if IsValid(phys) then
				phys:EnableMotion(false)
			end
		end
	end)
end)

print("Loaded undercrane")