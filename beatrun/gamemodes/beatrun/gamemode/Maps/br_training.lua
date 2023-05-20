local replaysdir = "beatrun/gamemode/Maps/TrainingData/"
TUTORIALMODE = true
local tutorialcount = 3

for i = 1, tutorialcount do
	AddCSLuaFile(replaysdir .. "tut" .. i .. ".lua")
end

hook.Add("PlayerDeath", "Ouch", function(ply)
	ply:Spawn()
	ply:SendLua("PTRD()")
end)

slidegate = slidegate or nil
local movegate = false
local sentreset = false

local function CreateSlideGate()
	slidegate = ents.Create("prop_physics")

	slidegate:SetModel("models/hunter/blocks/cube8x8x025.mdl")
	slidegate:SetPos(Vector(6332, 858, 895))
	slidegate:SetAngles(Angle(90, 0, 0))
	slidegate:Spawn()
	slidegate:PhysicsDestroy()
end

hook.Add("InitPostEntity", "TutorialSlideGate", CreateSlideGate)

local function ResetSlideGate()
	if not IsValid(slidegate) then return end

	slidegate:SetPos(Vector(6332, 858, 895))
	slidegate:SetAngles(Angle(90, 0, 0))

	movegate = false
	sentreset = false
end

hook.Add("PostReplayRequest", "ResetSlideGate", ResetSlideGate)

local function MoveSlideGate()
	if not IsValid(slidegate) or not IsValid(Entity(1)) then return end

	if not movegate then
		if Entity(1):GetVelocity():Length() > 25 then
			movegate = true
		else
			return
		end
	end

	local pos = slidegate:GetPos()

	if pos[3] > 350 then
		pos[3] = math.max(350, pos[3] - 2.75)

		slidegate:SetPos(pos)
	elseif not sentreset and not Entity(1).InReplay then
		Entity(1):SendLua("SGR()")
		sentreset = true
	end
end

hook.Add("Tick", "MoveSlideGate", MoveSlideGate)