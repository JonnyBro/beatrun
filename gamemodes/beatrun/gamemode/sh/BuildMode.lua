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
	br_mat = "models/mechanics/robotics/stand.mdl",
	br_swingrope = "models/hunter/blocks/cube025x025x025.mdl",
	br_laser = "models/maxofs2d/button_02.mdl",
	br_zipline = "models/hunter/blocks/cube025x025x025.mdl",
	tt_cp = "models/props_phx/construct/windows/window_angle360.mdl",
	br_swingbar = "models/hunter/plates/plate2.mdl"
}

local misc = {"models/hunter/misc/lift2x2.mdl", "models/hunter/misc/stair1x1.mdl", "models/hunter/misc/stair1x1inside.mdl", "models/hunter/misc/stair1x1outside.mdl", "models/props_combine/combine_barricade_short02a.mdl", "models/props_combine/combine_bridge_b.mdl", "models/props_docks/channelmarker_gib02.mdl", "models/props_docks/channelmarker_gib04.mdl", "models/props_docks/channelmarker_gib03.mdl", "models/props_lab/blastdoor001a.mdl", "models/props_lab/blastdoor001c.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_wasteland/cargo_container01b.mdl", "models/props_wasteland/cargo_container01c.mdl", "models/props_wasteland/horizontalcoolingtank04.mdl", "models/props_wasteland/laundry_washer001a.mdl", "models/props_wasteland/laundry_washer003.mdl", "models/props_junk/TrashDumpster01a.mdl", "models/props_junk/TrashDumpster02.mdl", "models/props_junk/wood_crate001a.mdl", "models/props_junk/wood_crate002a.mdl", "models/props_junk/wood_pallet001a.mdl", "models/props_c17/fence01a.mdl", "models/props_c17/fence01b.mdl", "models/props_c17/fence02a.mdl", "models/props_c17/fence03a.mdl", "models/props_c17/fence04a.mdl", "models/props_wasteland/interior_fence001g.mdl", "models/props_wasteland/interior_fence002d.mdl", "models/props_wasteland/interior_fence002e.mdl", "models/props_building_details/Storefront_Template001a_Bars.mdl", "models/props_wasteland/wood_fence01a.mdl", "models/props_wasteland/wood_fence02a.mdl", "models/props_c17/concrete_barrier001a.mdl", "models/props_wasteland/medbridge_base01.mdl", "models/props_wasteland/medbridge_post01.mdl", "models/props_wasteland/medbridge_strut01.mdl", "models/props_c17/column02a.mdl", "models/props_junk/iBeam01a_cluster01.mdl", "models/props_junk/iBeam01a.mdl", "models/props_canal/canal_cap001.mdl", "models/props_canal/canal_bridge04.mdl", "models/Mechanics/gears2/pinion_80t3.mdl", "models/props_phx/gears/rack36.mdl", "models/props_phx/gears/rack70.mdl", "models/cranes/crane_frame.mdl", "models/cranes/crane_docks.mdl", "models/props_wasteland/cranemagnet01a.mdl"}

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
	br_swingbar = true
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
	if propmatsblacklist[buildmode_props_index[prop:GetModel()]] then return end

	if prop.hr then
		prop:SetMaterial("medge/redplainplastervertex")
	else
		prop:SetMaterial("medge/plainplastervertex")
	end
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
		end

		game.CleanUpMap()
		Course_Sync()
	end

	net.Receive("Course_Stop", Course_Stop)

	buildmode_placed = buildmode_placed or {}

	function BuildMode_Toggle(ply)
		if not ply.BuildMode and not ply:IsSuperAdmin() and not ply.BuildModePerm then return end

		ply.BuildMode = not ply.BuildMode

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

	concommand.Add("buildmode", function(ply, cmd, args)
		BuildMode_Toggle(ply)
	end)

	net.Receive("BuildMode_Place", function(len, ply)
		if not ply.BuildMode then return end

		local prop = net.ReadUInt(16)

		if prop == 65535 then
			prop = net.ReadString()
		end

		local x = net.ReadFloat()
		local y = net.ReadFloat()
		local z = net.ReadFloat()
		local ang = net.ReadAngle()
		local vec = Vector(x, y, z)
		local vecextra = net.ReadVector()

		if not isstring(prop) then
			local a = ents.Create("prop_physics")
			a:SetModel(buildmode_props[prop])

			CustomPropMat(a)

			a:SetPos(vec)
			a:SetAngles(ang)
			a:Spawn()

			local phys = a:GetPhysicsObject()
			phys:EnableMotion(false)
			phys:Sleep()

			a:PhysicsDestroy()
			a:SetHealth(inf)
		else
			local a = ents.Create(prop)
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
	end)

	net.Receive("BuildMode_Duplicate", function(len, ply)
		if not ply.BuildMode then return end

		local selected = net.ReadTable()
		local selectedents = net.ReadTable()

		for _, v in pairs(selected) do
			local a = ents.Create("prop_physics")
			a:SetModel(v:GetModel())

			CustomPropMat(a)

			a:SetPos(v:GetPos())
			a:SetAngles(v:GetAngles())
			a:Spawn()
			a.hr = v.hr

			CustomPropMat(a)

			local phys = a:GetPhysicsObject()
			phys:EnableMotion(false)
			phys:Sleep()

			a:PhysicsDestroy()
			a:SetHealth(inf)
		end

		for _, v in pairs(selectedents) do
			local a = ents.Create(v:GetClass())

			a:SetPos(v:GetPos())
			a:SetAngles(v:GetAngles())
			a:Spawn()
		end
	end)

	net.Receive("BuildMode_Delete", function(len, ply)
		if not ply.BuildMode then return end

		local selected = net.ReadTable()

		for _, v in pairs(selected) do
			if IsValid(v) then
				v:Remove()
			end
		end
	end)

	net.Receive("BuildMode_Highlight", function(len, ply)
		if not ply.BuildMode then return end

		local selected = net.ReadTable()

		for _, v in pairs(selected) do
			v.hr = not v.hr

			CustomPropMat(v)
		end
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

		for _, v in pairs(props) do
			local a = ents.Create("prop_physics")

			a:SetModel(buildmode_props[v.model])

			CustomPropMat(a)

			a:SetPos(v.pos + ply:EyePos())
			a:SetAngles(v.ang)
			a:Spawn()

			local phys = a:GetPhysicsObject()
			phys:EnableMotion(false)
			phys:Sleep()

			a:PhysicsDestroy()
			a:SetHealth(inf)
		end
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

		local props, cp, pos, ang, name, entities, speed = unpack(courseData)
		speed = speed or 0

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

		for k, v in pairs(selected) do
			k:SetPos(v.pos or k:GetPos())
			k:SetAngles(v.ang or k:GetAngles())
		end
	end)

	return
end

if CLIENT then
	BuildModePlaceDelay = 0
	BuildMode = false
	GhostModel = nil
	BuildModeIndex = 0
	local GhostColor = Color(255, 255, 255, 200)
	BuildModeAngle = Angle()
	BuildModePos = Vector()
	-- local BuildModeDist = 500
	local usedown = false
	local mousedown = false
	local axislock = 0

	local axislist = {"x", "y", "z"}

	local axiscolors = {Color(255, 0, 0), Color(0, 255, 0), Color(0, 0, 255)}

	local axisdisplay1 = Vector()
	local axisdisplay2 = Vector()
	mousey = 0
	mousex = 0
	-- local mousemoved = false
	local camcontrol = false
	-- local scrw = ScrW()
	-- local scrh = ScrH()
	-- local nscrw = ScrW()
	-- local nscrh = ScrH()
	local aimvector = Vector()
	local dragstartx = 0
	local dragstarty = 0
	-- local dragstartvec = Vector()
	local dragging = false
	local dragoffset = Vector()
	-- local hulltr = {}
	-- local hulltrout = {}
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

	surface.CreateFont("BuildMode", {
		shadow = false,
		blursize = 0,
		underline = false,
		rotary = false,
		strikeout = false,
		additive = false,
		antialias = true,
		extended = false,
		scanlines = 0,
		font = "D-DIN",
		italic = false,
		outline = false,
		symbol = false,
		weight = 500,
		size = ScreenScale(10)
	})

	-- local blur = Material("pp/blurscreen")

	--[[
	local function DrawBlurRect(x, y, w, h)
		local X = 0
		local Y = 0

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(blur)

		for i = 1, 5 do
			blur:SetFloat("$blur", i / 3 * 5)
			blur:Recompute()

			render.UpdateScreenEffectTexture()
			render.SetScissorRect(x, y, x + w, y + h, true)

			surface.DrawTexturedRect(X * -1, Y * -1, scrw, scrh)

			render.SetScissorRect(0, 0, 0, 0, false)
		end
	end
	]]

	function BuildModeCreateGhost()
		if not IsValid(GhostModel) then
			GhostModel = ClientsideModel(buildmode_props[BuildModeIndex] or buildmode_entmodels[BuildModeIndex], RENDERGROUP_TRANSLUCENT)
		else
			if propmatsblacklist[BuildModeIndex] then
				GhostModel:SetMaterial("")
			end

			return
		end

		GhostModel:SetColor(GhostColor)
		GhostModel:SetRenderMode(RENDERMODE_TRANSCOLOR)
		GhostModel:SetNoDraw(true)

		CustomPropMat(GhostModel)
	end

	local trace = {}
	local tracer = {}
	-- local flatn = Angle(0, 0, 1)

	function BuildModeGhost()
		if ZiplineStart then
			render.DrawWireframeBox(ZiplineStart, angle_zero, ziplinemins, ziplinemaxs, color_white, true)
		end

		if BuildModeIndex == 0 then return end
		if AEUI.HoveredPanel then return end

		BuildModeCreateGhost()

		local ply = LocalPlayer()
		local eyepos = ply:EyePos()
		local eyeang = ply:EyeAngles()
		local mins, maxs = GhostModel:GetRenderBounds()

		aimvector = util.AimVector(eyeang, 133, mousex, mousey, ScrW(), ScrH())

		local dmult = 1

		if input.IsKeyDown(KEY_LALT) then dmult = 0.1 end

		if input.IsKeyDown(KEY_EQUAL) then
			placedistance = math.min(placedistance + 100 * FrameTime() * dmult, inf)
		end

		if input.IsKeyDown(KEY_MINUS) then
			placedistance = math.max(placedistance - 100 * FrameTime() * dmult, 0)
		end

		trace.start = eyepos
		trace.endpos = eyepos + aimvector * (not PlaceStartPos and placedistance or PlaceStartPos:Distance(ply:GetPos()))
		trace.filter = ply
		trace.output = tracer

		util.TraceLine(trace)

		local ghostpos = tracer.HitPos
		ghostpos.z = ghostpos.z - mins.z

		if axislock > 0 then
			BuildModePos[axislist[axislock]] = ghostpos[axislist[axislock]]
		else
			BuildModePos:Set(ghostpos)
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
			render.DrawWireframeBox(PlaceStartPos, BuildModeAngle, PlaceMins, PlaceMaxs, color_white, true)
		end

		if axislock > 0 then
			axisdisplay1:Set(BuildModePos)

			local num = axisdisplay1[axislist[axislock]]
			axisdisplay1[axislist[axislock]] = num + 200

			axisdisplay2:Set(BuildModePos)
			axisdisplay2[axislist[axislock]] = num - 200

			render.DrawLine(axisdisplay2, axisdisplay1, axiscolors[axislock])
		end

		ghostpos.z = ghostpos.z + mins.z

		render.DrawLine(tracer.StartPos + eyeang:Forward() * 5, ghostpos, axiscolors[3])
	end

	function BuildModePlayerStart()
		playerstartang.y = Course_StartAng

		playerstart:SetPos(Course_StartPos)
		playerstart:SetAngles(playerstartang)
		playerstart:DrawModel()
	end

	function CourseData(name, speed)
		-- [1] = Props, [2] = Checkpoints, [3] = Starting pos, [4] = Starting ang, [5] = Name, [6] = Entities, [7] = Restricted player's speed (0 = unrestricted)
		local save = {{}, {}, Course_StartPos, Course_StartAng, name or os.date("%H:%M:%S - %d/%m/%Y", os.time()), {}, speed or 0}

		for _, v in pairs(buildmode_placed) do
			if not IsValid(v) then continue end

			if v:GetNW2Bool("BRProtected") then
				print("[BR] Ignoring protected ent")
			else
				local class = v:GetClass()

				if class == "prop_physics" then
					local hr = false

					if v:GetMaterial() == "medge/redplainplastervertex" then hr = true end
					-- if v.buildmode_placed_manually then hr = false end

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
		local dir = "beatrun/courses/" .. string.Replace(game.GetMap(), " ", "-") .. "/"

		file.CreateDir(dir)

		file.Write(dir .. id .. ".txt", util.Compress(jsonsave))

		print("Save created: " .. id .. ".txt")
	end

	concommand.Add("Beatrun_SaveCourse", function(ply, cmd, args, argstr)
		local name = args[1] or os.date("%H:%M:%S - %d/%m/%Y", os.time())

		SaveCourse(name, args[2] or 0)
	end)

	function LoadCourse(id)
		local dir = "beatrun/courses/" .. string.Replace(game.GetMap(), " ", "-") .. "/"
		local save = util.Compress(file.Read(dir .. id .. ".txt", "DATA"))

		if not save then
			print("NON-EXISTENT SAVE: ", id)

			return
		end

		net.Start("BuildMode_ReadCourse")
			net.WriteData(save)
		net.SendToServer()

		LoadCheckpoints()
	end

	concommand.Add("Beatrun_LoadCourse", function(ply, cmd, args, argstr)
		local id = args[1]

		if not id then
			print("Supply course name")

			return
		end

		LoadCourse(id)
	end)

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

	--[[
	concommand.Add("Beatrun_PrintCourse", function(ply, cmd, args, argstr)
		local dir = "beatrun/courses/" .. string.Replace(game.GetMap(), " ", "-") .. "/"
		local save = file.Read(dir .. args[1] .. ".txt", "DATA")

		if not save then
			print("NON-EXISTENT SAVE: ", args[1])

			return
		end

		print(save)
	end)
	--]]

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
					if not propmatsblacklist[buildmode_props_index[k:GetModel()]] then
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

			net.Start("BuildMode_ReadSave")
				net.WriteData(save)
			net.SendToServer()
		end
	}

	buildmodeinputsmouse = {
		[MOUSE_LEFT] = function()
			if isstring(BuildModeIndex) then
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
				local svec = gui.ScreenToVector(gui.MouseX(), gui.MouseY()) -- util.AimVector(LocalPlayer():EyeAngles(), 133, mousex, mousey, ScrW(), ScrH())
				svec:Mul(100000)

				local start = LocalPlayer():EyePos()
				local tr = util.QuickTrace(start, svec, LocalPlayer())

				if not input.IsKeyDown(KEY_LSHIFT) then
					table.Empty(buildmode_selected)
				end

				if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_physics" then
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
				BuildModeIndex = BuildModeIndex - 1

				if BuildModeIndex < 0 then
					BuildModeIndex = #buildmode_props
				end

				if BuildModeIndex == 0 then
					SafeRemoveEntity(GhostModel)

					return
				end

				BuildModeCreateGhost()

				GhostModel:SetModel(buildmode_props[BuildModeIndex] or buildmode_entmodels[BuildModeIndex])
			end
		end,
		[MOUSE_WHEEL_UP] = function()
			if not usedown then
				local mult = input.IsKeyDown(KEY_LCONTROL) and 0.06666666666666667 or 1

				BuildModeAngle:RotateAroundAxis(Vector(0, 0, 1), 15 * mult)

				LocalPlayer():EmitSound("buttonrollover.wav")
			else
				BuildModeIndex = BuildModeIndex + 1

				if BuildModeIndex > #buildmode_props then
					BuildModeIndex = 0
				end

				if BuildModeIndex == 0 then
					SafeRemoveEntity(GhostModel)

					return
				end

				BuildModeCreateGhost()

				GhostModel:SetModel(buildmode_props[BuildModeIndex] or buildmode_entmodels[BuildModeIndex])
			end
		end
	}

	function BuildModeInput(ply, bind, pressed, code)
		if bind ~= "buildmode" and not camcontrol then return true end
	end

	hook.Add("InitPostEntity", "buildmode_create_hook", function()
		timer.Simple(2, function()
			hook.Add("OnEntityCreated", "BuildModeProps", function(ent)
				if not ent:GetNW2Bool("BRProtected") and ent:GetClass() == "prop_physics" or buildmode_ents[ent:GetClass()] then
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

			surface.SetDrawColor(50, 125, 255, 80)
			surface.DrawRect(x, y, w, h)
			surface.SetDrawColor(125, 125, 125, 125)
			surface.DrawOutlinedRect(x, y, w, h)
			surface.SetDrawColor(0, 200, 0, 255)

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
					local offset = k.dragorigpos + newpos - f.dragorigpos - dragorigin

					if axislock > 0 then
						local a = offset[axislist[axislock]]

						offset:Set(k.dragorigpos)
						offset[axislist[axislock]] = a
					end

					k:SetRenderOrigin(offset)
					k:SetRenderAngles(k.dragorigang + BuildModeAngle)
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

	function BuildModeHUDPaint()
		BuildModeDrag()

		if dragging then
			surface.SetDrawColor(0, 255, 0)
			surface.DrawRect(0, 0, 50, 50)
		end

		surface.SetFont("DebugFixed")
		surface.SetTextColor(255, 255, 255)

		for _, v in pairs(Checkpoints) do
			if not IsValid(v) then
				LoadCheckpoints()

				break
			end

			local w2s = v:GetPos():ToScreen()
			local num = v:GetCPNum()

			surface.SetTextPos(w2s.x, w2s.y)
			surface.DrawText("Checkpoint: " .. num)
		end

		local startw2s = Course_StartPos:ToScreen()

		surface.SetTextPos(startw2s.x, startw2s.y)
		surface.DrawText("Spawn")
	end

	function BuildModeCommand(ply, ucmd)
		LocalPlayer():SetFOV(120)

		if gui.IsGameUIVisible() then return end

		camcontrol = input.IsMouseDown(MOUSE_RIGHT)

		local newx, newy = input.GetCursorPos()
		mousemoved = mousex ~= newx or mousey ~= newy
		mousey = newy
		mousex = newx

		gui.EnableScreenClicker(not camcontrol)

		usedown = input.IsKeyDown(KEY_E)
		mousedown = input.IsMouseDown(MOUSE_LEFT)

		if AEUI.HoveredPanel then return end
		if keytime == CurTime() then return end

		for k, v in pairs(buildmodeinputs) do
			if input.WasKeyPressed(k) then
				v()
			end
		end

		for k, v in pairs(buildmodeinputsmouse) do
			if input.WasMousePressed(k) then
				v()
			end
		end

		keytime = CurTime()
	end

	net.Receive("BuildMode", function()
		BuildMode = net.ReadBool()

		if BuildMode then
			hook.Add("PostDrawTranslucentRenderables", "BuildModeGhost", BuildModeGhost)
			hook.Add("PostDrawTranslucentRenderables", "BuildModeSelect", BuildModeSelect)
			hook.Add("PostDrawTranslucentRenderables", "BuildModePlayerStart", BuildModePlayerStart)
			hook.Add("PlayerBindPress", "BuildModeInput", BuildModeInput)
			hook.Add("StartCommand", "BuildModeCommand", BuildModeCommand)
			hook.Add("HUDPaint", "BuildModeHUDPaint", BuildModeHUDPaint)

			LocalPlayer():DrawViewModel(false)
			LocalPlayer():SetFOV(120)

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

			LocalPlayer():SetFOV(0)

			CheckpointNumber = 1

			hook.Run("BuildModeState", false)
		end
	end)
end
