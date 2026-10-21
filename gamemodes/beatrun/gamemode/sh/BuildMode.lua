local mousex = 0
local mousey = 0
local inf = math.huge

buildmode_props = {}

local propmatsblacklist = {}
local blocksdir = "models/hunter/blocks/"
local blocksdir_s = blocksdir .. "*.mdl"

for _, v in ipairs(file.Find(blocksdir_s, "GAME")) do
	table.insert(buildmode_props, blocksdir .. v:lower())
end

local blocksdir = "models/hunter/triangles/"
local blocksdir_s = blocksdir .. "*.mdl"

for _, v in ipairs(file.Find(blocksdir_s, "GAME")) do
	table.insert(buildmode_props, blocksdir .. v:lower())
end

local blocksdir = "models/props_phx/construct/glass/"
local blocksdir_s = blocksdir .. "*.mdl"

for _, v in ipairs(file.Find(blocksdir_s, "GAME")) do
	local key = table.insert(buildmode_props, blocksdir .. v:lower())
	propmatsblacklist[key] = true
end

buildmode_entmodels = {
	br_swingpipe = "models/parkoursource/pipe_standard.mdl",
	br_ladder = "models/maxofs2d/lamp_projector.mdl",
	br_balance = "models/maxofs2d/lamp_projector.mdl",
	br_mat = "models/crashpad.mdl",
	br_swingrope = "models/hunter/blocks/cube025x025x025.mdl",
	br_laser = "models/maxofs2d/button_02.mdl",
	br_zipline = "models/hunter/blocks/cube025x025x025.mdl",
	tt_cp = "models/props_phx/construct/windows/window_angle360.mdl",
	br_swingbar = "models/hunter/plates/plate2.mdl",
	br_hookpoint = "models/Roller.mdl"
}

local misc = { "models/hunter/misc/lift2x2.mdl", "models/hunter/misc/stair1x1.mdl", "models/hunter/misc/stair1x1inside.mdl", "models/hunter/misc/stair1x1outside.mdl", "models/props_combine/combine_barricade_short02a.mdl", "models/props_combine/combine_bridge_b.mdl", "models/props_docks/channelmarker_gib02.mdl", "models/props_docks/channelmarker_gib04.mdl", "models/props_docks/channelmarker_gib03.mdl", "models/props_lab/blastdoor001a.mdl", "models/props_lab/blastdoor001c.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_wasteland/cargo_container01b.mdl", "models/props_wasteland/cargo_container01c.mdl", "models/props_wasteland/horizontalcoolingtank04.mdl", "models/props_wasteland/laundry_washer001a.mdl", "models/props_wasteland/laundry_washer003.mdl", "models/props_junk/TrashDumpster01a.mdl", "models/props_junk/TrashDumpster02.mdl", "models/props_junk/wood_crate001a.mdl", "models/props_junk/wood_crate002a.mdl", "models/props_junk/wood_pallet001a.mdl", "models/props_c17/fence01a.mdl", "models/props_c17/fence01b.mdl", "models/props_c17/fence02a.mdl", "models/props_c17/fence03a.mdl", "models/props_c17/fence04a.mdl", "models/props_wasteland/interior_fence001g.mdl", "models/props_wasteland/interior_fence002d.mdl", "models/props_wasteland/interior_fence002e.mdl", "models/props_building_details/Storefront_Template001a_Bars.mdl", "models/props_wasteland/wood_fence01a.mdl", "models/props_wasteland/wood_fence02a.mdl", "models/props_c17/concrete_barrier001a.mdl", "models/props_wasteland/medbridge_base01.mdl", "models/props_wasteland/medbridge_post01.mdl", "models/props_wasteland/medbridge_strut01.mdl", "models/props_c17/column02a.mdl", "models/props_junk/iBeam01a_cluster01.mdl", "models/props_junk/iBeam01a.mdl", "models/props_canal/canal_cap001.mdl", "models/props_canal/canal_bridge04.mdl", "models/Mechanics/gears2/pinion_80t3.mdl", "models/props_phx/gears/rack36.mdl", "models/props_phx/gears/rack70.mdl", "models/cranes/crane_frame.mdl", "models/cranes/crane_docks.mdl", "models/props_wasteland/cranemagnet01a.mdl" }

for _, v in ipairs(misc) do
	local key = table.insert(buildmode_props, v:lower())
	propmatsblacklist[key] = true
end

misc = nil

buildmode_ents = {
	br_swingpipe = true,
	br_swingrope = true,
	br_ladder = true,
	br_balance = true,
	br_mat = true,
	br_laser = true,
	br_zipline = true,
	tt_cp = true,
	br_swingbar = true,
	br_hookpoint = true
}

PlaceStartPos = nil
PlaceEndPos = nil
local PlaceMaxs = Vector()
local PlaceMins = Vector()
PlaceAxisLock = 0

entplacefunc_prespawn = {
	br_zipline = true,
	br_swingrope = true
}

entplacefunc = {
	br_ladder = function(self, vecextra)
		self:SetPos(self:GetPos() + self:GetAngles():Forward() * 10)
		vecextra:Set(vecextra + self:GetAngles():Forward() * 10)
		self:LadderHeightExact(vecextra:Distance(self:GetPos()) - 75)
	end,
	br_balance = function(self, vecextra)
		self:BalanceLengthExact(vecextra:Distance(self:GetPos()))
	end,
	br_zipline = function(self, vecextra, vec)
		self:SetPos(vec)
		self:SetStartPos(vec)
		self:SetEndPos(vecextra)
		self:SetTwoWay(net.ReadBool())
	end,
	br_swingrope = function(self, vecextra, vec)
		self:SetPos(vec)
		self:SetStartPos(vec)
		self:SetEndPos(vecextra)
	end
}

entplacefunc_cl = {
	tt_cp = function()
		local svec = gui.ScreenToVector(gui.MouseX(), gui.MouseY())
		local start = LocalPlayer():EyePos()

		svec:Mul(100000)

		local tr = util.QuickTrace(start, svec, LocalPlayer())
		local pos = tr.HitPos

		net.Start("BuildMode_Checkpoint")
			net.WriteFloat(pos.x)
			net.WriteFloat(pos.y)
			net.WriteFloat(pos.z)
		net.SendToServer()

		timer.Simple(0.1, function()
			LoadCheckpoints()
		end)

		BuildModePlaceDelay = CurTime() + 0.05

		return true
	end,
	br_ladder = function()
		if not PlaceStartPos then
			PlaceAxisLock = 3
			PlaceStartPos = Vector(BuildModePos)
			PlaceMins, PlaceMaxs = GhostModel:GetRenderBounds()

			return true
		end

		net.Start("BuildMode_Place")
			net.WriteUInt(65535, 16)
			net.WriteString(BuildModeIndex)
			net.WriteFloat(PlaceStartPos.x)
			net.WriteFloat(PlaceStartPos.y)
			net.WriteFloat(PlaceStartPos.z)
			net.WriteAngle(BuildModeAngle)
			net.WriteVector(BuildModePos)
		net.SendToServer()

		LocalPlayer():EmitSound("buttonclick.wav")

		BuildModePlaceDelay = CurTime() + 0.05
		PlaceStartPos = nil
		PlaceEndPos = nil
		PlaceAxisLock = 0

		return true
	end,
	br_zipline = function()
		if not PlaceStartPos then
			PlaceAxisLock = 0
			PlaceStartPos = Vector(BuildModePos)
			PlaceMins, PlaceMaxs = GhostModel:GetRenderBounds()

			return true
		end

		net.Start("BuildMode_Place")
			net.WriteUInt(65535, 16)
			net.WriteString(BuildModeIndex)
			net.WriteFloat(PlaceStartPos.x)
			net.WriteFloat(PlaceStartPos.y)
			net.WriteFloat(PlaceStartPos.z)
			net.WriteAngle(BuildModeAngle)
			net.WriteVector(BuildModePos)
			net.WriteBool(input.IsKeyDown(KEY_LSHIFT))
		net.SendToServer()

		LocalPlayer():EmitSound("buttonclick.wav")

		BuildModePlaceDelay = CurTime() + 0.05
		PlaceStartPos = nil
		PlaceEndPos = nil
		PlaceAxisLock = 0

		return true
	end,
	br_swingrope = function()
		if not PlaceStartPos then
			PlaceAxisLock = -3
			PlaceStartPos = Vector(BuildModePos)
			PlaceMins, PlaceMaxs = GhostModel:GetRenderBounds()

			return true
		end

		net.Start("BuildMode_Place")
			net.WriteUInt(65535, 16)
			net.WriteString(BuildModeIndex)
			net.WriteFloat(PlaceStartPos.x)
			net.WriteFloat(PlaceStartPos.y)
			net.WriteFloat(PlaceStartPos.z)
			net.WriteAngle(BuildModeAngle)
			net.WriteVector(BuildModePos)
		net.SendToServer()

		LocalPlayer():EmitSound("buttonclick.wav")

		BuildModePlaceDelay = CurTime() + 0.05
		PlaceStartPos = nil
		PlaceEndPos = nil
		PlaceAxisLock = 0

		return true
	end,
	br_balance = function()
		if not PlaceStartPos then
			PlaceAxisLock = 1
			PlaceStartPos = Vector(BuildModePos)
			PlaceMins, PlaceMaxs = GhostModel:GetRenderBounds()

			return true
		end

		net.Start("BuildMode_Place")
			net.WriteUInt(65535, 16)
			net.WriteString(BuildModeIndex)
			net.WriteFloat(PlaceStartPos.x)
			net.WriteFloat(PlaceStartPos.y)
			net.WriteFloat(PlaceStartPos.z)
			net.WriteAngle(BuildModeAngle)
			net.WriteVector(BuildModePos)
		net.SendToServer()

		LocalPlayer():EmitSound("buttonclick.wav")

		BuildModePlaceDelay = CurTime() + 0.05
		PlaceStartPos = nil
		PlaceEndPos = nil
		PlaceAxisLock = 0

		return true
	end
}

entsavefunc = {
	br_zipline = function(self, tbl)
		tbl.StartPos = self:GetStartPos()
		tbl.EndPos = self:GetEndPos()
		tbl.TwoWay = self:GetTwoWay()
	end,
	br_ladder = function(self, tbl)
		tbl.LadderHeight = self:GetLadderHeight()
	end,
	br_balance = function(self, tbl)
		tbl.BalanceLength = self:GetBalanceLength()
	end,
	br_swingrope = function(self, tbl)
		tbl.StartPos = self:GetStartPos()
		tbl.EndPos = self:GetEndPos()
	end
}

entreadfunc = {
	br_zipline = function(self, tbl)
		self:SetPos(tbl.StartPos)
		self:SetStartPos(tbl.StartPos)
		self:SetEndPos(tbl.EndPos)
		self:SetTwoWay(tbl.TwoWay or false)

		return true
	end,
	br_ladder = function(self, tbl)
		timer.Simple(0, function()
			if IsValid(self) and self.LadderHeightExact then
				self:LadderHeightExact(tbl.LadderHeight)
			end
		end)

		self:SetPos(tbl.pos + tbl.ang:Forward() * 10)
		self:SetAngles(tbl.ang)

		return true
	end,
	br_balance = function(self, tbl)
		timer.Simple(0, function()
			if IsValid(self) and self.BalanceLengthExact then
				self:BalanceLengthExact(tbl.BalanceLength)
			end
		end)

		self:SetPos(tbl.pos + tbl.ang:Forward() * 10)
		self:SetAngles(tbl.ang)

		return true
	end,
	br_swingrope = function(self, tbl)
		self:SetPos(tbl.StartPos)
		self:SetStartPos(tbl.StartPos)
		self:SetEndPos(tbl.EndPos)

		return true
	end
}

local buildmode_props_index = {}

for k, v in pairs(buildmode_props) do
	buildmode_props_index[v] = k
end

local function CustomPropMat(prop)
	local index = buildmode_props_index[string.lower(prop:GetModel() or "")]
	if index and propmatsblacklist[index] and not prop.hr then return end

	if prop.hr then
		prop:SetMaterial("medge/redplainplastervertex")
	elseif index and not propmatsblacklist[index] then
		prop:SetMaterial("medge/plainplastervertex")
	else
		prop:SetMaterial("")
	end
end

function BuildModeIsCustomModel(index)
	return isstring(index) and string.StartWith(index, "models/")
end

function BuildModeSpawnable(id)
	if not isstring(id) then return end

	local kind, name = string.match(id, "^(%a+):(.+)$")
	local data

	if kind == "vehicle" then
		data = list.GetForEdit("Vehicles")[name]
	elseif kind == "npc" then
		data = list.GetForEdit("NPC")[name]
	end

	if data then return kind, name, data end
end

function BuildModeEntitySpawnable(ent)
	local id = ent:GetNW2String("BRSpawnable")

	return id ~= "" and id or nil
end

local function SpawnableModel(data)
	local model = istable(data.Model) and data.Model[1] or data.Model

	return isstring(model) and model or "models/editor/playerstart.mdl"
end

function BuildModeItemModel(index)
	if BuildModeIsCustomModel(index) then return index end

	local kind, _, data = BuildModeSpawnable(index)
	if kind then return SpawnableModel(data) end

	return buildmode_props[index] or buildmode_entmodels[index]
end

function BuildModeIsValidModelPath(model)
	return isstring(model) and string.StartWith(model, "models/") and string.EndsWith(model, ".mdl") and not string.find(model, "..", 1, true) and util.IsValidModel(model)
end

Course_StartPos = Course_StartPos or Vector()
Course_StartAng = Course_StartAng or 0

if SERVER then
	util.AddNetworkString("BuildMode")
	util.AddNetworkString("BuildMode_Place")
	util.AddNetworkString("BuildMode_Remove")
	util.AddNetworkString("BuildMode_Drag")
	util.AddNetworkString("BuildMode_Duplicate")
	util.AddNetworkString("BuildMode_Delete")
	util.AddNetworkString("BuildMode_Highlight")
	util.AddNetworkString("BuildMode_ReadSave")
	util.AddNetworkString("BuildMode_Checkpoint")
	util.AddNetworkString("BuildMode_Entity")
	util.AddNetworkString("BuildMode_SetSpawn")
	util.AddNetworkString("BuildMode_SaveCourse")
	util.AddNetworkString("BuildMode_ReadCourse")
	util.AddNetworkString("BuildMode_Sync")
	util.AddNetworkString("Course_Stop")
	util.AddNetworkString("BuildMode_Undo")
	util.AddNetworkString("BuildMode_Redo")
	util.AddNetworkString("BuildMode_Undone")
	util.AddNetworkString("BuildMode_ToggleAI")

	function Course_Sync()
		net.Start("BuildMode_Sync")
			net.WriteFloat(Course_StartPos.x)
			net.WriteFloat(Course_StartPos.y)
			net.WriteFloat(Course_StartPos.z)
			net.WriteFloat(Course_StartAng)
			net.WriteString(Course_Name)
			net.WriteString(Course_ID)
			net.WriteInt(Course_Speed, 11)
		net.Broadcast()
	end

	function Course_Stop(len, ply)
		if ply and not ply:IsSuperAdmin() then return end

		Course_Name = ""
		Course_ID = ""
		Course_Speed = 0

		for _, plr in ipairs(player.GetAll()) do
			plr:ConCommand("Beatrun_SpeedLimit 325")

			if plr.BuildMode then BuildMode_Toggle(plr) end

			plr.BuildModeUndo = nil
			plr.BuildModeRedo = nil
		end

		game.CleanUpMap()
		Course_Sync()
	end

	net.Receive("Course_Stop", Course_Stop)

	buildmode_placed = buildmode_placed or {}

	local function SpawnBuildProp(model, pos, ang, hr)
		local a = ents.Create("prop_physics")
		a:SetModel(model)
		a.hr = hr

		CustomPropMat(a)

		a:SetPos(pos)
		a:SetAngles(ang)
		a:Spawn()

		local phys = a:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
			phys:Sleep()
		end

		a:PhysicsDestroy()
		a:SetHealth(inf)

		return a
	end

	function BuildModeSetNPCAI(ent, enabled)
		ent:SetNW2Bool("BRNoAI", not enabled)

		-- No think function freezes the NPC in place, ai_disabled would affect every NPC on the server
		if enabled then
			ent:RemoveEFlags(EFL_NO_THINK_FUNCTION)
		else
			ent:AddEFlags(EFL_NO_THINK_FUNCTION)
		end
	end

	local function SetSpawnPose(ent, pos, ang)
		ent:SetNW2Vector("BRSpawnPos", pos)
		ent:SetNW2Angle("BRSpawnAng", ang)
	end

	local function SpawnSpawnable(id, pos, ang, weapon, noai)
		local kind, name, data = BuildModeSpawnable(id)
		if not kind then return end

		local ent = ents.Create(data.Class)
		if not IsValid(ent) then return end

		local model = SpawnableModel(data)

		if kind == "vehicle" then
			ent:SetModel(model)

			for k, v in pairs(data.KeyValues or {}) do ent:SetKeyValue(k, v) end

			ent:SetPos(pos)
			ent:SetAngles(ang)
			ent:Spawn()
			ent:Activate()

			if data.Members then table.Merge(ent, data.Members) end
			if ent.SetVehicleClass then ent:SetVehicleClass(name) end

			ent.VehicleName = name
			ent.VehicleTable = data
			ent.ClassOverride = data.Class
		else
			ang = Angle(0, ang.y, 0)

			if data.Model then ent:SetModel(model) end
			if data.Material then ent:SetMaterial(data.Material) end

			for k, v in pairs(data.KeyValues or {}) do ent:SetKeyValue(k, v) end

			local flags = data.TotalSpawnFlags or bit.bor(SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK, data.SpawnFlags or 0)
			ent:SetKeyValue("spawnflags", flags)
			ent.SpawnFlags = flags

			if weapon == nil and data.Weapons then weapon = table.Random(data.Weapons) end

			if isstring(weapon) and weapon ~= "" and weapon ~= "none" then
				ent:SetKeyValue("additionalequipment", weapon)
				ent.Equipment = weapon
			end

			ent:SetNW2String("BRWeapon", weapon or "")
			ent:SetPos(pos)
			ent:SetAngles(ang)
			ent:Spawn()
			ent:Activate()

			ent.NPCName = name

			if data.Model and string.lower(ent:GetModel() or "") ~= string.lower(model) then ent:SetModel(model) end
			if data.Skin then ent:SetSkin(data.Skin) end

			if data.Health then
				ent:SetHealth(data.Health)
				ent:SetMaxHealth(data.Health)
			end

			for k, v in pairs(data.BodyGroups or {}) do ent:SetBodygroup(k, v) end

			BuildModeSetNPCAI(ent, not noai)
		end

		ent:SetNW2String("BRSpawnable", id)
		SetSpawnPose(ent, pos, ang)

		return ent
	end

	BuildModeSpawnSpawnable = SpawnSpawnable

	local UNDO_LIMIT = 50

	local function IsBuildEntity(ent)
		return IsValid(ent) and (ent:GetClass() == "prop_physics" or buildmode_ents[ent:GetClass()] ~= nil or BuildModeEntitySpawnable(ent) ~= nil)
	end

	local REVERT_OP = {
		create = "delete",
		remove = "restore",
		move = "setpos",
		highlight = "togglehr",
		ai = "toggleai"
	}

	local function PushUndo(ply, action)
		ply.BuildModeUndo = ply.BuildModeUndo or {}
		ply.BuildModeRedo = {}

		action.label = action.kind
		action.op = REVERT_OP[action.kind]

		table.insert(ply.BuildModeUndo, action)

		if #ply.BuildModeUndo > UNDO_LIMIT then table.remove(ply.BuildModeUndo, 1) end
	end

	local function Resolve(ply, ent)
		local remap = ply.BuildModeRemap
		local guard = 0

		while not IsValid(ent) and remap and remap[ent] and guard < UNDO_LIMIT do
			ent = remap[ent]
			guard = guard + 1
		end

		return ent
	end

	local function SnapshotEntity(ent)
		local spawnable = BuildModeEntitySpawnable(ent)

		if spawnable then
			return {
				source = ent,
				spawnable = spawnable,
				pos = ent:GetNW2Vector("BRSpawnPos", ent:GetPos()),
				ang = ent:GetNW2Angle("BRSpawnAng", ent:GetAngles()),
				weapon = ent:GetNW2String("BRWeapon"),
				noai = ent:GetNW2Bool("BRNoAI")
			}
		end

		local class = ent:GetClass()
		local snap = {
			source = ent,
			class = class,
			ent = class,
			model = ent:GetModel(),
			pos = ent:GetPos(),
			ang = ent:GetAngles(),
			hr = ent.hr
		}

		if class == "tt_cp" then snap.cpnum = ent:GetCPNum() end
		if entsavefunc[class] then entsavefunc[class](ent, snap) end

		return snap
	end

	local function RestoreEntity(snap)
		if snap.spawnable then return SpawnSpawnable(snap.spawnable, snap.pos, snap.ang, snap.weapon, snap.noai) end
		if snap.class == "prop_physics" then return SpawnBuildProp(snap.model, snap.pos, snap.ang, snap.hr) end

		local a = ents.Create(snap.class)
		if not IsValid(a) then return end

		if snap.class == "tt_cp" then
			a:SetPos(snap.pos)
			a:SetCPNum(snap.cpnum or 1)
			a:Spawn()

			return a
		end

		local dontsetpos = entreadfunc[snap.class] and entreadfunc[snap.class](a, snap)

		if not dontsetpos then
			a:SetPos(snap.pos)
			a:SetAngles(snap.ang)
		end

		a:Spawn()

		return a
	end

	local function ApplyOperation(ply, action)
		local inverse = { label = action.label }
		local count = 0

		if action.op == "delete" then
			inverse.op = "restore"
			inverse.items = {}

			for _, ent in ipairs(action.ents) do
				ent = Resolve(ply, ent)

				if IsBuildEntity(ent) then
					table.insert(inverse.items, SnapshotEntity(ent))

					ent:Remove()
					count = count + 1
				end
			end
		elseif action.op == "restore" then
			inverse.op = "delete"
			inverse.ents = {}

			ply.BuildModeRemap = ply.BuildModeRemap or {}

			for _, snap in ipairs(action.items) do
				local ent = RestoreEntity(snap)

				if IsValid(ent) then
					table.insert(inverse.ents, ent)
					table.insert(buildmode_placed, ent)

					ply.BuildModeRemap[snap.source] = ent
					count = count + 1
				end
			end
		elseif action.op == "setpos" then
			inverse.op = "setpos"
			inverse.items = {}

			for _, item in ipairs(action.items) do
				local ent = Resolve(ply, item.ent)

				if IsValid(ent) then
					table.insert(inverse.items, { ent = ent, pos = ent:GetPos(), ang = ent:GetAngles() })

					ent:SetPos(item.pos)
					ent:SetAngles(item.ang)

					if BuildModeEntitySpawnable(ent) then SetSpawnPose(ent, item.pos, item.ang) end

					count = count + 1
				end
			end
		elseif action.op == "toggleai" then
			inverse.op = "toggleai"
			inverse.ents = {}

			for _, ent in ipairs(action.ents) do
				ent = Resolve(ply, ent)

				if IsValid(ent) and ent:IsNPC() then
					BuildModeSetNPCAI(ent, ent:GetNW2Bool("BRNoAI"))
					table.insert(inverse.ents, ent)
					count = count + 1
				end
			end
		elseif action.op == "togglehr" then
			inverse.op = "togglehr"
			inverse.ents = {}

			for _, ent in ipairs(action.ents) do
				ent = Resolve(ply, ent)

				if IsValid(ent) then
					ent.hr = not ent.hr

					CustomPropMat(ent)
					table.insert(inverse.ents, ent)
					count = count + 1
				end
			end
		end

		timer.Simple(0, LoadCheckpoints)

		return inverse, count
	end

	local function StepHistory(ply, from, to, isRedo)
		if not ply.BuildMode then return end

		local action = ply[from] and table.remove(ply[from])
		local count = 0

		if action then
			local inverse
			inverse, count = ApplyOperation(ply, action)

			ply[to] = ply[to] or {}
			table.insert(ply[to], inverse)

			if #ply[to] > UNDO_LIMIT then table.remove(ply[to], 1) end
		end

		net.Start("BuildMode_Undone")
			net.WriteString(action and action.label or "")
			net.WriteUInt(count, 16)
			net.WriteBool(isRedo)
		net.Send(ply)
	end

	net.Receive("BuildMode_Undo", function(len, ply) StepHistory(ply, "BuildModeUndo", "BuildModeRedo", false) end)

	hook.Add("PlayerSpawnedProp", "BuildModeSpawnMenuProps", function(ply, model, ent)
		if not ply.BuildMode or not IsValid(ent) then return end

		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
			phys:Sleep()
		end

		table.insert(buildmode_placed, ent)

		PushUndo(ply, { kind = "create", ents = { ent } })
	end)

	net.Receive("BuildMode_Redo", function(len, ply) StepHistory(ply, "BuildModeRedo", "BuildModeUndo", true) end)

	local function TagSpawnMenuEntity(ply, ent, id)
		if not ply.BuildMode or not IsValid(ent) or not BuildModeSpawnable(id) then return end

		ent:SetNW2String("BRSpawnable", id)
		if ent:IsNPC() then
			ent:SetNW2String("BRWeapon", ent.Equipment or "")
			BuildModeSetNPCAI(ent, false)
		end

		SetSpawnPose(ent, ent:GetPos(), ent:GetAngles())
		table.insert(buildmode_placed, ent)

		PushUndo(ply, { kind = "create", ents = { ent } })
	end

	hook.Add("PlayerSpawnedVehicle", "BuildModeSpawnMenuVehicles", function(ply, ent)
		TagSpawnMenuEntity(ply, ent, "vehicle:" .. tostring(ent.VehicleName))
	end)

	hook.Add("PlayerSpawnedNPC", "BuildModeSpawnMenuNPCs", function(ply, ent)
		TagSpawnMenuEntity(ply, ent, "npc:" .. tostring(ent.NPCName or ent:GetClass()))
	end)

	function BuildMode_Toggle(ply)
		if not ply.BuildMode and not ply:IsSuperAdmin() and not ply.BuildModePerm then return end

		ply.BuildMode = not ply.BuildMode
		ply:SetNoTarget(ply.BuildMode)

		if ply.BuildMode then
			ply:SetMoveType(MOVETYPE_NOCLIP)
		else
			ply:SetMoveType(MOVETYPE_WALK)
			CheckpointNumber = 1
		end

		net.Start("BuildMode")
			net.WriteBool(ply.BuildMode)
		net.Send(ply)
	end

	concommand.Add("Beatrun_BuildMode", function(ply, cmd, args)
		BuildMode_Toggle(ply)
	end)

	net.Receive("BuildMode_Place", function(len, ply)
		if not ply.BuildMode then return end

		local prop = net.ReadUInt(16)
		local custommodel, spawnable

		if prop == 65535 then
			prop = net.ReadString()
		elseif prop == 65534 then
			custommodel = net.ReadString()
		elseif prop == 65533 then
			spawnable = net.ReadString()
		end

		local x = net.ReadFloat()
		local y = net.ReadFloat()
		local z = net.ReadFloat()
		local ang = net.ReadAngle()
		local vec = Vector(x, y, z)
		local vecextra = net.ReadVector()

		local a

		if spawnable then
			local kind, _, data = BuildModeSpawnable(spawnable)
			if not kind or (data.AdminOnly and not ply:IsAdmin()) then return end

			a = SpawnSpawnable(spawnable, vec, ang, nil, net.ReadBool())
			if not IsValid(a) then return end
		elseif custommodel then
			if not BuildModeIsValidModelPath(custommodel) then return end

			a = SpawnBuildProp(custommodel, vec, ang)
		elseif not isstring(prop) then
			if not buildmode_props[prop] then return end

			a = SpawnBuildProp(buildmode_props[prop], vec, ang)
		else
			if not buildmode_ents[prop] then return end

			a = ents.Create(prop)
			local prespawn = entplacefunc_prespawn[prop]

			a:SetPos(vec)
			a:SetAngles(ang)

			if prespawn and entplacefunc[prop] then
				entplacefunc[prop](a, vecextra, vec)
			end

			a:Spawn()

			if not prespawn and entplacefunc[prop] then
				entplacefunc[prop](a, vecextra, vec)
			end
		end

		table.insert(buildmode_placed, a)

		PushUndo(ply, { kind = "create", ents = { a } })
	end)

	net.Receive("BuildMode_Duplicate", function(len, ply)
		if not ply.BuildMode then return end

		local selected = net.ReadTable()
		local selectedents = net.ReadTable()
		local created = {}

		for _, v in pairs(selected) do
			if IsBuildEntity(v) then
				if BuildModeEntitySpawnable(v) then
					local snap = SnapshotEntity(v)
					snap.pos = v:GetPos()
					snap.ang = v:GetAngles()

					table.insert(created, RestoreEntity(snap))
				else
					table.insert(created, SpawnBuildProp(v:GetModel(), v:GetPos(), v:GetAngles(), v.hr))
				end
			end
		end

		for _, v in pairs(selectedents) do
			if IsBuildEntity(v) then
				local a = ents.Create(v:GetClass())

				a:SetPos(v:GetPos())
				a:SetAngles(v:GetAngles())
				a:Spawn()

				table.insert(created, a)
			end
		end

		if #created > 0 then PushUndo(ply, { kind = "create", ents = created }) end
	end)

	net.Receive("BuildMode_Delete", function(len, ply)
		if not ply.BuildMode then return end

		local selected = net.ReadTable()
		local removed = {}

		for _, v in pairs(selected) do
			if IsBuildEntity(v) then
				table.insert(removed, SnapshotEntity(v))

				v:Remove()
			end
		end

		if #removed > 0 then PushUndo(ply, { kind = "remove", items = removed }) end
	end)

	net.Receive("BuildMode_Highlight", function(len, ply)
		if not ply.BuildMode then return end

		local selected = net.ReadTable()
		local changed = {}

		for _, v in pairs(selected) do
			if IsValid(v) and v:GetClass() == "prop_physics" then
				v.hr = not v.hr

				CustomPropMat(v)
				table.insert(changed, v)
			end
		end

		if #changed > 0 then PushUndo(ply, { kind = "highlight", ents = changed }) end
	end)

	net.Receive("BuildMode_ToggleAI", function(len, ply)
		if not ply.BuildMode then return end

		local changed = {}

		for _, v in pairs(net.ReadTable()) do
			if IsBuildEntity(v) and v:IsNPC() then
				BuildModeSetNPCAI(v, v:GetNW2Bool("BRNoAI"))
				table.insert(changed, v)
			end
		end

		if #changed > 0 then PushUndo(ply, { kind = "ai", ents = changed }) end
	end)

	net.Receive("BuildMode_Remove", function(len, ply)
		if not ply.BuildMode then return end

		local ent = net.ReadEntity()

		SafeRemoveEntity(ent)
	end)

	net.Receive("BuildMode_ReadSave", function(len, ply)
		if not ply.BuildMode then return end

		local a = net.ReadData(len)
		local props = util.JSONToTable(a)

		if not istable(props) then return end

		local created = {}

		for _, v in pairs(props) do
			if buildmode_props[v.model] then
				table.insert(created, SpawnBuildProp(buildmode_props[v.model], v.pos + ply:EyePos(), v.ang))
			end
		end

		if #created > 0 then PushUndo(ply, { kind = "create", ents = created }) end
	end)

	net.Receive("BuildMode_Checkpoint", function(len, ply)
		if not ply.BuildMode then return end

		local x = net.ReadFloat()
		local y = net.ReadFloat()
		local z = net.ReadFloat()

		LoadCheckpoints()

		local a = ents.Create("tt_cp")
		a:SetPos(Vector(x, y, z))
		a:SetCPNum(table.Count(Checkpoints) + 1)
		a:Spawn()

		LoadCheckpoints()

		PushUndo(ply, { kind = "create", ents = { a } })
	end)

	net.Receive("BuildMode_Entity", function(len, ply)
		if not ply.BuildMode then return end

		local ent = net.ReadString()
		local x = net.ReadFloat()
		local y = net.ReadFloat()
		local z = net.ReadFloat()
		local a = ents.Create(ent)
		a:SetPos(Vector(x, y, z))

		if entplacefunc[ent] then
			entplacefunc[ent](a)
		end

		a:Spawn()
	end)

	net.Receive("BuildMode_SetSpawn", function(len, ply)
		if not ply.BuildMode then return end

		local x = net.ReadFloat()
		local y = net.ReadFloat()
		local z = net.ReadFloat()
		local ang = net.ReadFloat()

		Course_StartPos:SetUnpacked(x, y, z)
		Course_StartAng = ang
	end)

	function Beatrun_ReadCourseNet(len, ply)
		if not ply:IsSuperAdmin() then return end

		local data = util.Decompress(net.ReadData(len))

		if not data then return print("[BR] Error while loading a course") end

		Beatrun_ReadCourse(data)
	end

	function Beatrun_ReadCourseLocal(id)
		local dir = "beatrun/courses/" .. string.Replace(game.GetMap(), " ", "-") .. "/"
		local save = file.Read(dir .. id .. ".txt", "DATA")

		if not save then return print("[BR] Non-existent save with id: " .. tostring(id)) end

		Course_ID = id

		Beatrun_ReadCourse(save, id)
	end

	function Beatrun_ReadCourse(data, id)
		game.CleanUpMap()

		local decompress = util.Decompress(data) or data
		id = id or util.CRC(decompress)
		local courseData = util.JSONToTable(decompress)

		local props, cp, pos, ang, name, entities, speed, spawnables = unpack(courseData)
		speed = speed or 325

		for _, v in pairs(props) do
			local a = ents.Create("prop_physics")
			a.hr = v.hr

			local is_model_an_index = tonumber(v.model)
			if is_model_an_index then
				a:SetModel(buildmode_props[v.model])
			else
				a:SetModel(v.model)
			end

			CustomPropMat(a)

			a:SetPos(v.pos)
			a:SetAngles(v.ang)
			a:Spawn()

			local phys = a:GetPhysicsObject()

			if IsValid(phys) then
				phys:EnableMotion(false)
				phys:Sleep()
			end

			a:PhysicsDestroy()
			a:SetHealth(inf)
		end

		for _, v in ipairs(cp) do
			LoadCheckpoints()

			local a = ents.Create("tt_cp")
			a:SetPos(v)
			a:SetCPNum(table.Count(Checkpoints) + 1)
			a:Spawn()

			LoadCheckpoints()
		end

		if entities then
			for _, v in ipairs(entities) do
				local a = ents.Create(v.ent)
				local dontsetpos = nil

				if entreadfunc[v.ent] then
					dontsetpos = entreadfunc[v.ent](a, v)
				end

				if not dontsetpos then
					a:SetPos(v.pos)
					a:SetAngles(v.ang)
				end

				a:Spawn()
			end
		end

		for _, v in ipairs(spawnables or {}) do
			SpawnSpawnable(v.id, v.pos, v.ang, v.weapon, v.noai)
		end

		Course_StartPos:Set(pos)

		Course_StartAng = ang
		Course_Name = name
		Course_ID = id
		Course_Speed = speed

		Course_Sync()

		for _, v in pairs(player.GetAll()) do
			if Course_Speed and Course_Speed ~= 0 then
				v:ConCommand("Beatrun_SpeedLimit " .. tostring(Course_Speed))
			end

			v:SetNW2Float("PBTime", 0)
			v:SetNW2Int("CPNum", 1)
			v:SetMoveType(MOVETYPE_WALK)
			v:Spawn()
		end
	end

	net.Receive("BuildMode_ReadCourse", Beatrun_ReadCourseNet)

	net.Receive("BuildMode_Drag", function(len, ply)
		if not ply.BuildMode then return end

		local selected = net.ReadTable()
		local moved = {}

		for k, v in pairs(selected) do
			if IsBuildEntity(k) then
				table.insert(moved, { ent = k, pos = k:GetPos(), ang = k:GetAngles() })

				k:SetPos(v.pos or k:GetPos())
				k:SetAngles(v.ang or k:GetAngles())

				if BuildModeEntitySpawnable(k) then SetSpawnPose(k, k:GetPos(), k:GetAngles()) end
			end
		end

		if #moved > 0 then PushUndo(ply, { kind = "move", items = moved }) end
	end)

	return
end

if CLIENT then
	BuildModePlaceDelay = 0
	BuildModePlaceAI = false
	BuildMode = false
	GhostModel = nil
	BuildModeIndex = 0

	local GhostColor = Color(255, 255, 255, 200)

	BuildModeAngle = Angle()
	BuildModePos = Vector()

	local usedown = false
	local mousedown = false
	local axislock = 0

	local axislist = { "x", "y", "z" }
	local axiscolors = { Color(255, 0, 0), Color(0, 255, 0), Color(0, 0, 255) }

	local axisdisplay1 = Vector()
	local axisdisplay2 = Vector()

	mousey = 0
	mousex = 0

	local camcontrol = false
	local aimvector = Vector()
	local dragstartx = 0
	local dragstarty = 0
	local dragging = false
	local dragoffset = Vector()

	buildmode_placed = buildmode_placed or {}
	buildmode_selected = {}

	local keytime = 0

	playerstart = IsValid(playerstart) and playerstart or ClientsideModel("models/editor/playerstart.mdl")
	playerstart:SetNoDraw(true)

	local playerstartang = Angle()
	local ZiplineStart = nil
	local ziplinemins = Vector(-8, -8, -8)
	local ziplinemaxs = Vector(8, 8, 8)

	local placedistance = 1000
	local adjustingDistance = false

	function BuildModeRotatedCenter(mins, maxs, ang)
		local center = (mins + maxs) * 0.5
		center:Rotate(ang)

		return center
	end

	local gridsizes = { 0, 4, 8, 16, 32, 64 }
	local gridindex = 1

	function BuildModeGridSize()
		return gridsizes[gridindex]
	end

	local function SnapToGrid(value)
		local grid = gridsizes[gridindex]
		if grid == 0 then return value end

		return math.Round(value / grid) * grid
	end

	function BuildModeGetState()
		return {
			dragging = dragging,
			axis = axislock > 0 and axislist[axislock] or nil,
			distance = placedistance,
			grid = gridsizes[gridindex],
			camera = camcontrol,
			secondPoint = PlaceStartPos ~= nil,
			selected = table.Count(buildmode_selected)
		}
	end

	surface.CreateFont("BuildMode", {
		font = "D-DIN",
		shadow = false,
		blursize = 0,
		underline = false,
		rotary = false,
		strikeout = false,
		additive = false,
		antialias = true,
		extended = false,
		scanlines = 0,
		italic = false,
		outline = false,
		symbol = false,
		weight = 500,
		size = ScreenScale(10)
	})

	function BuildModeCreateGhost()
		if not IsValid(GhostModel) then
			GhostModel = ClientsideModel(BuildModeItemModel(BuildModeIndex), RENDERGROUP_TRANSLUCENT)
		else
			return
		end

		GhostModel:SetColor(GhostColor)
		GhostModel:SetRenderMode(RENDERMODE_TRANSCOLOR)
		GhostModel:SetNoDraw(true)

		CustomPropMat(GhostModel)
	end

	function BuildModeUpdateGhost()
		if BuildModeIndex == 0 then
			SafeRemoveEntity(GhostModel)

			return
		end

		BuildModeCreateGhost()

		GhostModel:SetModel(BuildModeItemModel(BuildModeIndex))

		CustomPropMat(GhostModel)
	end

	local trace = {}
	local tracer = {}

	function BuildModeGhost()
		if ZiplineStart then
			render.DrawWireframeBox(ZiplineStart, angle_zero, ziplinemins, ziplinemaxs, color_white, true)
		end

		if BuildModeIndex == 0 then return end
		if BeatrunUI.IsCursorOverUI() then return end

		BuildModeCreateGhost()

		local ply = LocalPlayer()
		local eyepos = ply:EyePos()
		local eyeang = ply:EyeAngles()
		local mins, maxs = GhostModel:GetRenderBounds()

		aimvector = util.AimVector(eyeang, 133, mousex, mousey, ScrW(), ScrH())

		local closer, farther = input.IsKeyDown(KEY_MINUS), input.IsKeyDown(KEY_EQUAL)

		if closer or farther then
			local speed = 400 * FrameTime() * (input.IsKeyDown(KEY_LALT) and 0.1 or 1)

			if not adjustingDistance then
				adjustingDistance = true

				trace.start = eyepos
				trace.endpos = eyepos + aimvector * 100000
				trace.filter = ply
				trace.output = tracer

				util.TraceLine(trace)

				placedistance = math.min(placedistance, eyepos:Distance(tracer.HitPos))
			end

			placedistance = math.Clamp(placedistance + (farther and speed or -speed), 16, 100000)
		else
			adjustingDistance = false
		end

		trace.start = eyepos
		trace.endpos = eyepos + aimvector * (not PlaceStartPos and placedistance or PlaceStartPos:Distance(ply:GetPos()))
		trace.filter = ply
		trace.output = tracer

		util.TraceLine(trace)

		local ghostpos = tracer.HitPos

		local center = Vector(ghostpos)
		center.z = center.z + (maxs.z - mins.z) / 2
		center.x = SnapToGrid(center.x)
		center.y = SnapToGrid(center.y)

		local origin = center - BuildModeRotatedCenter(mins, maxs, BuildModeAngle)

		if axislock > 0 then
			BuildModePos[axislist[axislock]] = origin[axislist[axislock]]
		else
			BuildModePos:Set(origin)
		end

		if PlaceStartPos and PlaceAxisLock and math.abs(PlaceAxisLock) > 0 then
			local mul = PlaceAxisLock > 0 and 1 or -1

			if PlaceAxisLock == 1 then
				BuildModePos = PlaceStartPos + BuildModeAngle:Forward() * BuildModePos:Distance(PlaceStartPos) * mul
			elseif PlaceAxisLock == 2 then
				BuildModePos = PlaceStartPos + -BuildModeAngle:Forward() * BuildModePos:Distance(PlaceStartPos) * mul
			else
				BuildModePos = PlaceStartPos + BuildModeAngle:Up() * BuildModePos:Distance(PlaceStartPos) * mul
			end
		end

		GhostModel:SetPos(BuildModePos)
		GhostModel:SetAngles(BuildModeAngle)
		GhostModel:DrawModel()

		render.DrawWireframeBox(BuildModePos, BuildModeAngle, mins, maxs, color_white, true)

		if PlaceStartPos then
			render.DrawWireframeBox(PlaceStartPos, BuildModeAngle, PlaceMins, PlaceMaxs, BEATRUN_ACCENT, true)

			render.SetColorMaterial()
			render.DrawBeam(PlaceStartPos, BuildModePos, 2, 0, 1, BEATRUN_ACCENT)
		end

		if axislock > 0 then
			axisdisplay1:Set(BuildModePos)

			local num = axisdisplay1[axislist[axislock]]
			axisdisplay1[axislist[axislock]] = num + 200

			axisdisplay2:Set(BuildModePos)
			axisdisplay2[axislist[axislock]] = num - 200

			render.DrawLine(axisdisplay2, axisdisplay1, axiscolors[axislock])
		end

		render.DrawLine(tracer.StartPos + eyeang:Forward() * 5, ghostpos, axiscolors[3])
	end

	function BuildModePlayerStart()
		playerstartang.y = Course_StartAng

		playerstart:SetPos(Course_StartPos)
		playerstart:SetAngles(playerstartang)
		playerstart:DrawModel()
	end

	function CourseData(name, speed)
		-- [1] = Props, [2] = Checkpoints, [3] = Starting pos, [4] = Starting angle, [5] = Name, [6] = Entities, [7] = Restricted player's speed (0 = unrestricted), [8] = Vehicles and NPCs
		local save = { {}, {}, Course_StartPos, Course_StartAng, name or os.date("%H:%M:%S - %Y/%m/%d", os.time()), {}, speed or 0, {} }

		for _, v in pairs(buildmode_placed) do
			if not IsValid(v) then continue end

			if v:GetNW2Bool("BRProtected") then
				print("[BR] Ignoring protected ent")
			else
				local class = v:GetClass()
				local spawnable = BuildModeEntitySpawnable(v)

				if spawnable then
					table.insert(save[8], {
						id = spawnable,
						pos = v:GetNW2Vector("BRSpawnPos", v:GetPos()),
						ang = v:GetNW2Angle("BRSpawnAng", v:GetAngles()),
						weapon = v:IsNPC() and v:GetNW2String("BRWeapon") or nil,
						noai = v:IsNPC() and v:GetNW2Bool("BRNoAI") or nil
					})
				elseif class == "prop_physics" then
					local hr = false

					if v:GetMaterial() == "medge/redplainplastervertex" then hr = true end

					table.insert(save[1], {
						model = v:GetModel():lower(),
						pos = v:GetPos(),
						ang = v:GetAngles(),
						hr = hr
					})
				elseif buildmode_ents[class] then
					local index = table.insert(save[6], {
						ent = class,
						pos = v:GetPos(),
						ang = v:GetAngles()
					})

					if entsavefunc[class] then
						entsavefunc[class](v, save[6][index])
					end
				end
			end
		end

		for _, v in ipairs(Checkpoints) do
			table.insert(save[2], v:GetPos())
		end

		return save
	end

	function SaveCourse(name, speed)
		local save = CourseData(name, speed)
		local jsonsave = util.TableToJSON(save)
		local id = util.CRC(jsonsave)
		local dir = string.format("beatrun/courses/%s/", game.GetMap())

		file.CreateDir(dir)

		local saved = file.Write(dir .. id .. ".txt", util.Compress(jsonsave))

		return saved and id or nil
	end

	function LoadCourse(filename)
		local dir = string.format("beatrun/courses/%s/", game.GetMap())
		local raw = file.Read(dir .. filename, "DATA")
		local save = util.Compress(raw)

		if not save then
			print("NON-EXISTENT SAVE: ", filename)

			return
		end

		net.Start("BuildMode_ReadCourse")
			net.WriteData(save)
		net.SendToServer()

		LoadCheckpoints()
	end

	function LoadCourseRaw(data)
		if not data then
			print("Supply course data")

			return
		end

		net.Start("BuildMode_ReadCourse")
			net.WriteData(data)
		net.SendToServer()

		LoadCheckpoints()

		Course_ID = id
	end

	net.Receive("BuildMode_Sync", function()
		local x = net.ReadFloat()
		local y = net.ReadFloat()
		local z = net.ReadFloat()
		local ang = net.ReadFloat()
		local name = net.ReadString()
		local id = net.ReadString()
		local speed = net.ReadInt(11)

		Course_StartPos:SetUnpacked(x, y, z)

		Course_StartAng = ang
		Course_Name = name
		Course_ID = id or Course_ID
		Course_Speed = speed
	end)

	buildmodeinputs = {
		[KEY_R] = function()
			if not dragging then
				BuildModeAngle:Set(angle_zero)

				return
			end

			axislock = axislock + 1

			if axislock > 3 then
				axislock = 0
			end
		end,
		[KEY_X] = function()
			local mult = input.IsKeyDown(KEY_LCONTROL) and 0.06666666666666667 or 1

			BuildModeAngle:RotateAroundAxis(Vector(1, 0, 0), 15 * mult)

			LocalPlayer():EmitSound("buttonrollover.wav")
		end,
		[KEY_C] = function()
			local mult = input.IsKeyDown(KEY_LCONTROL) and 0.06666666666666667 or 1

			BuildModeAngle:RotateAroundAxis(Vector(1, 0, 0), -15 * mult)

			LocalPlayer():EmitSound("buttonrollover.wav")
		end,
		[KEY_V] = function()
			local mult = input.IsKeyDown(KEY_LCONTROL) and 0.06666666666666667 or 1

			BuildModeAngle:RotateAroundAxis(Vector(0, 1, 0), 15 * mult)

			LocalPlayer():EmitSound("buttonrollover.wav")
		end,
		[KEY_B] = function()
			local mult = input.IsKeyDown(KEY_LCONTROL) and 0.06666666666666667 or 1

			BuildModeAngle:RotateAroundAxis(Vector(0, 1, 0), -15 * mult)

			LocalPlayer():EmitSound("buttonrollover.wav")
		end,
		[KEY_F] = function()
			if CurTime() < BuildModePlaceDelay then return end

			local svec = gui.ScreenToVector(gui.MouseX(), gui.MouseY())
			svec:Mul(100000)

			local start = LocalPlayer():EyePos()
			local tr = util.QuickTrace(start, svec, LocalPlayer())
			local pos = tr.HitPos

			net.Start("BuildMode_Checkpoint")
				net.WriteFloat(pos.x)
				net.WriteFloat(pos.y)
				net.WriteFloat(pos.z)
			net.SendToServer()

			timer.Simple(0.1, function()
				LoadCheckpoints()
			end)

			BuildModePlaceDelay = CurTime() + 0.05
		end,
		[KEY_S] = function()
			if camcontrol then return end

			local svec = gui.ScreenToVector(gui.MouseX(), gui.MouseY())
			svec:Mul(100000)

			local start = LocalPlayer():EyePos()
			local tr = util.QuickTrace(start, svec, LocalPlayer())
			local pos = tr.HitPos
			local ang = LocalPlayer():EyeAngles().y

			Course_StartPos:Set(pos)

			net.Start("BuildMode_SetSpawn")
				net.WriteFloat(pos.x)
				net.WriteFloat(pos.y)
				net.WriteFloat(pos.z)
				net.WriteFloat(ang)
			net.SendToServer()

			Course_StartPos:Set(pos)

			Course_StartAng = ang
		end,
		[KEY_D] = function(ignorecombo)
			if (input.IsKeyDown(KEY_LSHIFT) or ignorecombo) and not camcontrol then
				local props = {}
				local ents = {}

				for k, _ in pairs(buildmode_selected) do
					if buildmode_ents[k:GetClass()] then
						table.insert(ents, k)
					else
						table.insert(props, k)
					end
				end

				net.Start("BuildMode_Duplicate")
					net.WriteTable(props)
					net.WriteTable(ents)
				net.SendToServer()

				dragging = false
				buildmodeinputs[KEY_G]()
			end
		end,
		[KEY_DELETE] = function()
			if not dragging then
				local props = {}

				for k, _ in pairs(buildmode_selected) do
					table.insert(props, k)
					buildmode_selected[k] = nil
				end

				net.Start("BuildMode_Delete")
					net.WriteTable(props)
				net.SendToServer()
			end
		end,
		[KEY_BACKSPACE] = function()
			buildmodeinputs[KEY_DELETE]()
		end,
		[KEY_T] = function()
			if not dragging then
				local props = {}

				for k, _ in pairs(buildmode_selected) do
					if k:GetClass() == "prop_physics" and not propmatsblacklist[buildmode_props_index[k:GetModel()]] then
						table.insert(props, k)
					end
				end

				if #props > 0 then
					net.Start("BuildMode_Highlight")
						net.WriteTable(props)
					net.SendToServer()
				end
			end
		end,
		[KEY_G] = function()
			if BuildModeIndex ~= 0 then return end

			BuildModeAngle:Set(angle_zero)

			dragging = not dragging

			if not dragging then
				dragging = true

				dragoffset:Set(vector_origin)

				buildmodeinputsmouse[MOUSE_RIGHT]()
			else
				local f = nil

				for k, _ in pairs(buildmode_selected) do
					f = k

					break
				end

				if IsValid(f) then
					cam.Start3D()
						local w2s = f:GetPos():ToScreen()

						input.SetCursorPos(w2s.x, w2s.y)
					cam.End3D()
				end
			end
		end,
		[KEY_PAD_MINUS] = function()
			if table.Count(buildmode_selected) == 0 then return end

			local save = {}
			local startpos = nil

			for k, _ in pairs(buildmode_selected) do
				startpos = startpos or k:GetPos()

				if not buildmode_props_index[k:GetModel()] then
					print("ignoring", k:GetModel())
				else
					table.insert(save, {
						model = buildmode_props_index[k:GetModel()],
						pos = k:GetPos() - startpos,
						ang = k:GetAngles()
					})
				end
			end

			local jsonsave = util.TableToJSON(save)

			file.CreateDir("beatrun/savedbuilds")
			file.Write("beatrun/savedbuilds/save.txt", jsonsave)
		end,
		[KEY_PAD_PLUS] = function()
			local save = file.Read("beatrun/savedbuilds/save.txt", "DATA")
			if not save then return end

			net.Start("BuildMode_ReadSave")
				net.WriteData(save)
			net.SendToServer()
		end,
		[KEY_N] = function()
			gridindex = gridindex % #gridsizes + 1

			LocalPlayer():EmitSound("buttonrollover.wav")
		end,
		[KEY_Z] = function()
			if not input.IsKeyDown(KEY_LCONTROL) and not input.IsKeyDown(KEY_RCONTROL) then return end

			net.Start("BuildMode_Undo")
			net.SendToServer()
		end,
		[KEY_Y] = function()
			if not input.IsKeyDown(KEY_LCONTROL) and not input.IsKeyDown(KEY_RCONTROL) then return end

			net.Start("BuildMode_Redo")
			net.SendToServer()
		end,
		[KEY_H] = function()
			if BuildModeToggleHelp then BuildModeToggleHelp() end
		end,
		[KEY_I] = function()
			local npcs = {}

			for k, _ in pairs(buildmode_selected) do
				if IsValid(k) and k:IsNPC() then table.insert(npcs, k) end
			end

			if #npcs > 0 then
				net.Start("BuildMode_ToggleAI")
					net.WriteTable(npcs)
				net.SendToServer()
			else
				BuildModePlaceAI = not BuildModePlaceAI
			end

			LocalPlayer():EmitSound("buttonrollover.wav")
		end
	}

	net.Receive("BuildMode_Undone", function()
		local kind = net.ReadString()
		local count = net.ReadUInt(16)
		local prefix = net.ReadBool() and "beatrun.buildmode.redo." or "beatrun.buildmode.undo."

		if kind == "" then
			notification.AddLegacy("#" .. prefix .. "nothing", NOTIFY_HINT, 3)

			return
		end

		notification.AddLegacy(language.GetPhrase(prefix .. kind):format(count), NOTIFY_UNDO, 3)
		surface.PlaySound("buttons/button15.wav")

		timer.Simple(0.1, LoadCheckpoints)
	end)

	buildmodeinputsmouse = {
		[MOUSE_LEFT] = function()
			if BuildModeSpawnable(BuildModeIndex) then
				if CurTime() < BuildModePlaceDelay then return end

				net.Start("BuildMode_Place")
					net.WriteUInt(65533, 16)
					net.WriteString(BuildModeIndex)
					net.WriteFloat(BuildModePos.x)
					net.WriteFloat(BuildModePos.y)
					net.WriteFloat(BuildModePos.z)
					net.WriteAngle(BuildModeAngle)
					net.WriteVector(BuildModePos)
					net.WriteBool(not BuildModePlaceAI)
				net.SendToServer()

				LocalPlayer():EmitSound("buttonclick.wav")

				BuildModePlaceDelay = CurTime() + 0.05
			elseif BuildModeIsCustomModel(BuildModeIndex) then
				if CurTime() < BuildModePlaceDelay then return end

				net.Start("BuildMode_Place")
					net.WriteUInt(65534, 16)
					net.WriteString(BuildModeIndex)
					net.WriteFloat(BuildModePos.x)
					net.WriteFloat(BuildModePos.y)
					net.WriteFloat(BuildModePos.z)
					net.WriteAngle(BuildModeAngle)
				net.SendToServer()

				LocalPlayer():EmitSound("buttonclick.wav")

				BuildModePlaceDelay = CurTime() + 0.05
			elseif isstring(BuildModeIndex) then
				local noplace = false

				if entplacefunc_cl[BuildModeIndex] then
					noplace = entplacefunc_cl[BuildModeIndex]()
				end

				if not noplace then
					net.Start("BuildMode_Place")
						net.WriteUInt(65535, 16)
						net.WriteString(BuildModeIndex)
						net.WriteFloat(BuildModePos.x)
						net.WriteFloat(BuildModePos.y)
						net.WriteFloat(BuildModePos.z)
						net.WriteAngle(BuildModeAngle)
					net.SendToServer()

					LocalPlayer():EmitSound("buttonclick.wav")

					BuildModePlaceDelay = CurTime() + 0.05
				end
			elseif BuildModeIndex > 0 then
				if CurTime() < BuildModePlaceDelay then return end

				net.Start("BuildMode_Place")
					net.WriteUInt(BuildModeIndex, 16)
					net.WriteFloat(BuildModePos.x)
					net.WriteFloat(BuildModePos.y)
					net.WriteFloat(BuildModePos.z)
					net.WriteAngle(BuildModeAngle)
				net.SendToServer()

				LocalPlayer():EmitSound("buttonclick.wav")

				BuildModePlaceDelay = CurTime() + 0.05
			end

			if dragging then
				local selected = {}

				dragging = false

				if table.Count(buildmode_selected) > 0 then
					for k, _ in pairs(buildmode_selected) do
						if IsValid(k) then
							selected[k] = {
								pos = k:GetRenderOrigin(),
								ang = k:GetRenderAngles()
							}
						end

						k.dragorigpos = k:GetPos()
						k.dragorigang = k:GetAngles()
					end

					net.Start("BuildMode_Drag")
						net.WriteTable(selected)
					net.SendToServer()
				end

				axislock = 0

				LocalPlayer():EmitSound("buttonclick.wav")

				return
			end

			if BuildModeIndex == 0 then
				local svec = gui.ScreenToVector(gui.MouseX(), gui.MouseY())
				svec:Mul(100000)

				local start = LocalPlayer():EyePos()
				local tr = util.QuickTrace(start, svec, LocalPlayer())

				if not input.IsKeyDown(KEY_LSHIFT) then
					table.Empty(buildmode_selected)
				end

				if IsValid(tr.Entity) and (tr.Entity:GetClass() == "prop_physics" or BuildModeEntitySpawnable(tr.Entity)) then
					buildmode_selected[tr.Entity] = not buildmode_selected[tr.Entity]

					if buildmode_selected[tr.Entity] == false then
						buildmode_selected[tr.Entity] = nil
					end

					tr.Entity.dragorigpos = tr.Entity:GetPos()
					tr.Entity.dragorigang = tr.Entity:GetAngles()
				end
			end
		end,
		[MOUSE_RIGHT] = function()
			if dragging and table.Count(buildmode_selected) > 0 then
				for k, _ in pairs(buildmode_selected) do
					if IsValid(k) then
						k:SetRenderOrigin(k.dragorigpos)
						k:SetRenderAngles(k.dragorigang)
					end

					buildmode_selected[k] = nil
				end

				dragging = false
				axislock = 0
			end
		end,
		[MOUSE_WHEEL_DOWN] = function()
			if not usedown then
				local mult = input.IsKeyDown(KEY_LCONTROL) and 0.06666666666666667 or 1

				BuildModeAngle:RotateAroundAxis(Vector(0, 0, 1), -15 * mult)

				LocalPlayer():EmitSound("buttonrollover.wav")
			else
				if not isnumber(BuildModeIndex) then BuildModeIndex = 0 end

				BuildModeIndex = BuildModeIndex - 1

				if BuildModeIndex < 0 then
					BuildModeIndex = #buildmode_props
				end

				BuildModeUpdateGhost()
			end
		end,
		[MOUSE_WHEEL_UP] = function()
			if not usedown then
				local mult = input.IsKeyDown(KEY_LCONTROL) and 0.06666666666666667 or 1

				BuildModeAngle:RotateAroundAxis(Vector(0, 0, 1), 15 * mult)

				LocalPlayer():EmitSound("buttonrollover.wav")
			else
				if not isnumber(BuildModeIndex) then BuildModeIndex = 0 end

				BuildModeIndex = BuildModeIndex + 1

				if BuildModeIndex > #buildmode_props then
					BuildModeIndex = 0
				end

				BuildModeUpdateGhost()
			end
		end
	}

	function BuildModeInput(ply, bind, pressed, code)
		if bind == "+menu" then return end
		if bind ~= "Beatrun_BuildMode" and not camcontrol then return true end
	end

	hook.Add("InitPostEntity", "buildmode_create_hook", function()
		timer.Simple(2, function()
			hook.Add("OnEntityCreated", "BuildModeProps", function(ent)
				if not ent:GetNW2Bool("BRProtected") and ent:GetClass() == "prop_physics" or buildmode_ents[ent:GetClass()] or ent:IsNPC() or ent:IsVehicle() then
					if not BuildMode then ent.buildmode_placed_manually = true end

					table.insert(buildmode_placed, ent)
				end
			end)
		end)
	end)

	local dragorigin = nil

	function BuildModeDrag()
		if not mousedown then
			dragstarty = mousey
			dragstartx = mousex
		elseif math.abs(dragstartx - mousex) > 5 and not dragging then
			local w = mousex - dragstartx
			local h = mousey - dragstarty
			local x = dragstartx
			local y = dragstarty
			local flipx = false
			local flipy = false

			if w < 0 then
				w = -w
				x = x - w
				flipx = true
			end

			if h < 0 then
				h = -h
				y = y - h
				flipy = true
			end

			surface.SetDrawColor(ColorAlpha(BEATRUN_ACCENT, 40))
			surface.DrawRect(x, y, w, h)
			surface.SetDrawColor(BEATRUN_ACCENT)
			surface.DrawOutlinedRect(x, y, w, h, 1)

			cam.Start3D()
				for _, v in ipairs(buildmode_placed) do
					if IsValid(v) and not v:GetNW2Bool("BRProtected") then
						local pos = v:GetRenderOrigin() or v:GetPos()
						local w2s = pos:ToScreen()
						local xcheck = flipx and x < w2s.x and w2s.x < w + x or not flipx and x < w2s.x and w2s.x < mousex
						local ycheck = flipy and y < w2s.y and w2s.y < h + y or not flipy and y < w2s.y and w2s.y < mousey

						if xcheck and ycheck then
							buildmode_selected[v] = true
						elseif not input.IsKeyDown(KEY_LSHIFT) then
							buildmode_selected[v] = nil
						end
					end
				end
			cam.End3D()

			if not dragging then
				dragorigin = nil

				for k, _ in pairs(buildmode_selected) do
					if IsValid(k) then
						k.dragorigpos = k:GetPos()
						k.dragorigang = k:GetAngles()
					end
				end
			end
		end
	end

	function BuildModeSelect()
		if dragging then
			local svec = gui.ScreenToVector(gui.MouseX(), gui.MouseY())
			dragoffset:Set(svec)

			if not dragorigin then
				dragorigin = dragoffset
			end
		end

		local f = nil

		for k, v in pairs(buildmode_selected) do
			f = f or k

			if not IsValid(k) then
				buildmode_selected[k] = nil
			elseif v then
				if dragging then
					local newpos = LocalPlayer():EyePos() + dragoffset * f.dragorigpos:Distance(LocalPlayer():EyePos()) - dragorigin
					local delta = newpos - f.dragorigpos - dragorigin

					delta.x = SnapToGrid(delta.x)
					delta.y = SnapToGrid(delta.y)
					delta.z = SnapToGrid(delta.z)

					local offset = k.dragorigpos + delta

					if axislock > 0 then
						local a = offset[axislist[axislock]]

						offset:Set(k.dragorigpos)
						offset[axislist[axislock]] = a
					end

					local newang = k.dragorigang + BuildModeAngle
					local bmins, bmaxs = k:GetRenderBounds()

					offset = offset + BuildModeRotatedCenter(bmins, bmaxs, k.dragorigang) - BuildModeRotatedCenter(bmins, bmaxs, newang)

					k:SetRenderOrigin(offset)
					k:SetRenderAngles(newang)
				end

				local mins, maxs = k:GetRenderBounds()
				render.DrawWireframeBox(k:GetRenderOrigin() or k:GetPos(), k:GetAngles(), mins, maxs, color_white, true)
			end
		end

		if IsValid(f) and axislock > 0 then
			axisdisplay1:Set(f:GetPos())

			local num = axisdisplay1[axislist[axislock]]
			axisdisplay1[axislist[axislock]] = num + 200

			axisdisplay2:Set(f:GetPos())

			axisdisplay2[axislist[axislock]] = num - 200

			render.DrawLine(axisdisplay2, axisdisplay1, axiscolors[axislock])
		end
	end

	local color_npc_noai = Color(140, 140, 140)

	local function DrawWorldTag(pos, text, color)
		local w2s = pos:ToScreen()
		if not w2s.visible then return end

		surface.SetFont("BeatrunUISmall")

		local tw, th = surface.GetTextSize(text)
		local pad = BeatrunUI.S(6)
		local x, y = math.floor(w2s.x - tw / 2 - pad), math.floor(w2s.y - th - pad * 3)

		surface.SetDrawColor(0, 0, 0, 170)
		surface.DrawRect(x, y, tw + pad * 2, th + pad)

		surface.SetDrawColor(color)
		surface.DrawRect(x, y, BeatrunUI.S(3), th + pad)

		draw.SimpleText(text, "BeatrunUISmall", x + pad + BeatrunUI.S(2), y + pad / 2, color_white)
	end

	function BuildModeHUDPaint()
		BuildModeDrag()

		for _, v in pairs(Checkpoints) do
			if not IsValid(v) then
				LoadCheckpoints()

				break
			end

			DrawWorldTag(v:GetPos(), language.GetPhrase("beatrun.buildmode.checkpoint"):format(v:GetCPNum()), BEATRUN_ACCENT)
		end

		DrawWorldTag(Course_StartPos, language.GetPhrase("beatrun.buildmode.spawn"), color_white)

		for _, v in ipairs(buildmode_placed) do
			if IsValid(v) and v:IsNPC() and BuildModeEntitySpawnable(v) then
				local noai = v:GetNW2Bool("BRNoAI")
				local pos = v:GetPos()
				pos.z = pos.z + v:OBBMaxs().z + 8

				DrawWorldTag(pos, language.GetPhrase(noai and "beatrun.buildmode.tool.aioff" or "beatrun.buildmode.tool.aion"), noai and color_npc_noai or BEATRUN_ACCENT)
			end
		end

		if PlaceStartPos and BuildModeIndex ~= 0 then
			local length = PlaceStartPos:Distance(BuildModePos)
			local text = language.GetPhrase("beatrun.buildmode.length"):format(math.Round(length), string.format("%.1f", length / 52.49))

			if BuildModeIndex == "br_zipline" then
				text = text .. " | " .. language.GetPhrase(input.IsKeyDown(KEY_LSHIFT) and "beatrun.buildmode.zipline.twoway" or "beatrun.buildmode.zipline.oneway")
			end

			DrawWorldTag((PlaceStartPos + BuildModePos) * 0.5, text, BEATRUN_ACCENT)
		end
	end

	local rmbWasDown, rmbPressedAt, rmbPressedAng = false, 0, Angle()

	local function CheckSecondPointCancel()
		local down = input.IsMouseDown(MOUSE_RIGHT)

		if down and not rmbWasDown then
			rmbPressedAt = CurTime()
			rmbPressedAng = LocalPlayer():EyeAngles()
		elseif not down and rmbWasDown and PlaceStartPos then
			local quick = CurTime() - rmbPressedAt < 0.25
			local turned = math.abs(math.AngleDifference(LocalPlayer():EyeAngles().y, rmbPressedAng.y)) + math.abs(math.AngleDifference(LocalPlayer():EyeAngles().p, rmbPressedAng.p))

			if quick and turned < 3 then
				PlaceStartPos = nil
				PlaceEndPos = nil
				PlaceAxisLock = 0

				LocalPlayer():EmitSound("buttonclickrelease.wav")
			end
		end

		rmbWasDown = down
	end

	function BuildModeCommand(ply, ucmd)
		-- NOTE: SetFOV does nothing clientside(networked variable).
		-- TODO: Implement this properly
		-- LocalPlayer():SetFOV(120)

		if gui.IsGameUIVisible() then return end

		camcontrol = input.IsMouseDown(MOUSE_RIGHT)

		local newx, newy = input.GetCursorPos()
		mousemoved = mousex ~= newx or mousey ~= newy
		mousey = newy
		mousex = newx

		gui.EnableScreenClicker(not camcontrol)

		usedown = input.IsKeyDown(KEY_E)
		mousedown = input.IsMouseDown(MOUSE_LEFT)

		CheckSecondPointCancel()

		if BeatrunUI.IsTyping() then
			if input.WasMousePressed(MOUSE_LEFT) and not BeatrunUI.IsCursorOverUI() then vgui.GetKeyboardFocus():KillFocus() end

			return
		end

		if BeatrunUI.IsCursorOverUI() then return end
		if keytime == CurTime() then return end

		for keybind, func in pairs(buildmodeinputs) do
			if input.WasKeyPressed(keybind) and not IsCoursesMenuOpen() then
				func()
			end
		end

		for keybind, func in pairs(buildmodeinputsmouse) do
			if input.WasMousePressed(keybind) and not IsCoursesMenuOpen() then
				func()
			end
		end

		keytime = CurTime()
	end

	net.Receive("BuildMode", function()
		BuildMode = net.ReadBool()
		if CourseGhost:GetBool() then StopGhostRecording(false, false) end

		if BuildMode then
			hook.Add("PostDrawTranslucentRenderables", "BuildModeGhost", BuildModeGhost)
			hook.Add("PostDrawTranslucentRenderables", "BuildModeSelect", BuildModeSelect)
			hook.Add("PostDrawTranslucentRenderables", "BuildModePlayerStart", BuildModePlayerStart)
			hook.Add("PlayerBindPress", "BuildModeInput", BuildModeInput)
			hook.Add("StartCommand", "BuildModeCommand", BuildModeCommand)
			hook.Add("HUDPaint", "BuildModeHUDPaint", BuildModeHUDPaint)

			LocalPlayer():DrawViewModel(false)

			-- NOTE: SetFOV does nothing clientside(networked variable).
			-- TODO: Implement this properly
			-- LocalPlayer():SetFOV(120)

			hook.Run("BuildModeState", true)
		else
			hook.Remove("PostDrawTranslucentRenderables", "BuildModeGhost")
			hook.Remove("PostDrawTranslucentRenderables", "BuildModeSelect")
			hook.Remove("PostDrawTranslucentRenderables", "BuildModePlayerStart")
			hook.Remove("PlayerBindPress", "BuildModeInput")
			hook.Remove("StartCommand", "BuildModeCommand")
			hook.Remove("HUDPaint", "BuildModeHUDPaint")

			SafeRemoveEntity(GhostModel)

			LocalPlayer():DrawViewModel(true)

			gui.EnableScreenClicker(false)

			-- NOTE: SetFOV does nothing clientside(networked variable).
			-- TODO: Implement this properly
			-- LocalPlayer():SetFOV(0)

			CheckpointNumber = 1

			hook.Run("BuildModeState", false)
		end
	end)
end
