local START_Z = -15800
local CURRENT_Z = 0

local ROTATION = {Vector(-325.8125, 573.90625, START_Z), Vector(-66.3125, 573.90625, START_Z), Vector(189.15625, 573.90625, START_Z), Vector(412.5625, 573.90625, START_Z), Vector(568.09375, 316.59375, START_Z), Vector(568.09375, 69.03125, START_Z), Vector(568.09375, -189.28125, START_Z), Vector(568.09375, -408.125, START_Z), Vector(412.5625, -569.375, START_Z), Vector(189.15625, -569.375, START_Z), Vector(-66.3125, -569.375, START_Z), Vector(-325.8125, -569.375, START_Z), Vector(-568.65625, -408.125, START_Z), Vector(-568.65625, -189.28125, START_Z), Vector(-568.65625, 69.03125, START_Z), Vector(-568.65625, 316.59375, START_Z),}

local ANGLES = {Angle(0, 0, 0), Angle(0, 0, 0), Angle(0, 0, 0), Angle(0, 0, 0), Angle(0, -90, 0), Angle(0, -90, 0), Angle(0, -90, 0), Angle(0, -90, 0), Angle(0, 0, 0), Angle(0, 0, 0), Angle(0, 0, 0), Angle(0, 0, 0), Angle(0, -90, 0), Angle(0, -90, 0), Angle(0, -90, 0), Angle(0, -90, 0),}

local CURRENT_ROTATION = 1
local MAX_ROTATION = #ROTATION

for i = 0, 100 do
	local mdl = "models/hunter/blocks/cube2x3x025.mdl"
	local plat = ents.Create("prop_physics")

	plat:SetModel(mdl)
	plat:SetPos(ROTATION[CURRENT_ROTATION] + Vector(0, 0, CURRENT_Z))
	plat:SetAngles(ANGLES[CURRENT_ROTATION])
	plat:Spawn()
	plat:PhysicsDestroy()

	CURRENT_Z = CURRENT_Z + math.random(20, 70)
	CURRENT_ROTATION = CURRENT_ROTATION + 1

	if CURRENT_ROTATION > MAX_ROTATION then
		CURRENT_ROTATION = 1
	end
end