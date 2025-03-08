local rtcache = {}
local rtmatcache = {}

local propspanel = {
	w = 384,
	h = 400
}

propspanel.x = 1632 - propspanel.w * 0.5
propspanel.y = 702 - propspanel.h * 0.5
propspanel.bgcolor = Color(32, 32, 32)
propspanel.outlinecolor = Color(55, 55, 55)
propspanel.alpha = 0.9
propspanel.elements = {}

local elementstogglepanel = {
	w = 384,
	h = 40
}

elementstogglepanel.x = 1632 - elementstogglepanel.w * 0.5
elementstogglepanel.y = 459
elementstogglepanel.bgcolor = Color(32, 32, 32)
elementstogglepanel.outlinecolor = Color(55, 55, 55)
elementstogglepanel.alpha = 0.9
elementstogglepanel.elements = {}

local bmbuttons = {
	w = 190,
	h = 100,
	x = 1632 - propspanel.w * 0.5
}

bmbuttons.y = 972 - bmbuttons.h * 0.5
bmbuttons.bgcolor = Color(32, 32, 32)
bmbuttons.outlinecolor = Color(55, 55, 55)
bmbuttons.alpha = 0.45
bmbuttons.elements = {}

local bminfo = {
	w = 190,
	h = 100,
	x = 1634
}

bminfo.y = 972 - bminfo.h * 0.5
bminfo.bgcolor = Color(32, 32, 32)
bminfo.outlinecolor = Color(55, 55, 55)
bminfo.alpha = 0.45
bminfo.elements = {}
local propspanel_elements = propspanel.elements
local EntitiesElements = {}

local function infostring()
	local p, y, r = BuildModeAngle:Unpack()
	r = math.Round(r)
	y = math.Round(y)
	p = math.Round(p)

	local angle = p .. ", " .. y .. ", " .. r
	local str = language.GetPhrase("beatrun.buildmodehud.info"):format(BuildModeIndex, table.Count(buildmode_selected), angle)

	return str
end

AEUI:Text(bminfo, infostring, "AEUIDefault", bminfo.w / 2, bminfo.h / 2 - 20, true)

local function BuildModeHUDButton(e)
	buildmodeinputs[e.key](true)
end

local function GreyButtons()
	return table.Count(buildmode_selected) == 0
end

local function PanelElementsToggle(e)
	local showingents = propspanel.elements == EntitiesElements
	propspanel.elements = showingents and propspanel_elements or EntitiesElements

	e.string = showingents and "#beatrun.buildmodehud.props" or "#beatrun.buildmodehud.entities"

	propspanel.maxscroll = nil
	propspanel.scroll = nil
end

local b = AEUI:AddButton(bmbuttons, "#beatrun.buildmodehud.drag", BuildModeHUDButton, "AEUIDefault", 2, 0, false)
b.key = KEY_G
b.greyed = GreyButtons
local b = AEUI:AddButton(bmbuttons, "#beatrun.buildmodehud.copy", BuildModeHUDButton, "AEUIDefault", 2, 25, false)
b.key = KEY_D
b.greyed = GreyButtons
local b = AEUI:AddButton(bmbuttons, "#beatrun.buildmodehud.delete", BuildModeHUDButton, "AEUIDefault", 2, 50, false)
b.key = KEY_DELETE
b.greyed = GreyButtons
local b = AEUI:AddButton(bmbuttons, "#beatrun.buildmodehud.highlight", BuildModeHUDButton, "AEUIDefault", 2, 75, false)
b.key = KEY_T
b.greyed = GreyButtons

AEUI:AddButton(elementstogglepanel, "#beatrun.buildmodehud.props", PanelElementsToggle, "AEUILarge", 192, 20, true)

local dummy = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")

dummy:SetNoDraw(true)

function GenerateBuildModeRT(model)
	if not rtcache[model] then
		local texw = 64
		local texh = 64
		local tex = GetRenderTarget("BMRT-" .. model, texw, texh)

		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		render.PushRenderTarget(tex, 0, 0, texw, texh)
		render.SuppressEngineLighting(true)

		dummy:SetModel(model)

		local sicon = PositionSpawnIcon(dummy, vector_origin)

		cam.Start3D(sicon.origin, sicon.angles, sicon.fov)
			render.Clear(0, 0, 0, 0)
			render.ClearDepth()
			render.SetWriteDepthToDestAlpha(false)
			render.SetModelLighting(0, 4, 4, 4)
			render.SetModelLighting(1, 2, 2, 2)
			render.SetModelLighting(2, 2, 2, 2)
			render.SetModelLighting(3, 4, 4, 4)
			render.SetModelLighting(4, 3, 3, 3)
			render.SetModelLighting(5, 4, 4, 4)

			dummy:DrawModel()
		cam.End3D()

		render.PopRenderTarget()
		render.PopFilterMag()
		render.PopFilterMin()
		render.SuppressEngineLighting(false)
		rtcache[model] = tex

		local mat = CreateMaterial("BM-" .. model, "UnlitGeneric", {
			["$vertexcolor"] = 1,
			["$translucent"] = 1,
			["$vertexalpha"] = 1,
			["$basetexture"] = tex:GetName()
		})

		rtmatcache[model] = mat
	end

	return rtmatcache[model]
end

local function BMPropClick(e)
	BuildModeIndex = e.prop or 0

	LocalPlayer():EmitSound("buttonclick.wav")

	if BuildModeIndex == 0 then
		SafeRemoveEntity(GhostModel)

		return
	end

	BuildModeCreateGhost()
	GhostModel:SetModel(buildmode_props[BuildModeIndex] or buildmode_entmodels[BuildModeIndex])
	PlaceStartPos = nil
	PlaceEndPos = nil
	PlaceAxisLock = 0
end

local img = AEUI:AddImage(propspanel, Material("vgui/empty.png"), BMPropClick, 0, 0, 64, 64)
img.prop = 0
img.hover = "#beatrun.buildmodehud.select"
local row = 1
local col = 0

for k, v in pairs(buildmode_props) do
	local spawnicon = "spawnicons/" .. v:Left(-5) .. ".png"

	if file.Exists("materials/" .. spawnicon, "GAME") then
		rtmatcache[v] = Material(spawnicon)
	else
		GenerateBuildModeRT(v)
	end

	local img = AEUI:AddImage(propspanel, rtmatcache[v], BMPropClick, 64 * row, 64 * col, 64, 64)
	img.prop = k
	img.hover = v
	row = row + 1

	if row > 5 then
		col = col + 1
		row = 0
	end
end

local img = AEUI:AddImage(propspanel, Material("vgui/empty.png"), BMPropClick, 64 * row, 64 * col, 64, 64)
img.prop = 0
img.hover = "#beatrun.buildmodehud.select"

local function BuildModeElements()
	propspanel.elements = EntitiesElements

	table.Empty(EntitiesElements)

	row = 1
	col = 0

	local img = AEUI:AddImage(propspanel, Material("vgui/empty.png"), BMPropClick, 0, 0, 64, 64)
	img.prop = 0
	img.hover = "#beatrun.buildmodehud.select"

	local buildmode_enticons = {
		br_swingbar = Material("vgui/editor/swingbar.png"),
		br_swingpipe = Material("vgui/editor/swingpipe.png"),
		br_zipline = Material("vgui/editor/zipline.png"),
		br_ladder = Material("vgui/editor/ladder.png"),
		br_balance = Material("vgui/editor/balance.png"),
		br_laser = Material("vgui/editor/laser.png"),
		br_swingrope = Material("vgui/editor/swingrope.png"),
		br_mat = Material("vgui/editor/mat.png"),
		tt_cp = Material("vgui/editor/checkpoint.png")
	}

	local buildmode_entnames = {
		br_zipline = "#beatrun.buildmodehud.zipline"
	}

	local obsolete = Material("editor/obsolete")

	for k, _ in pairs(buildmode_ents) do
		local img = AEUI:AddImage(propspanel, buildmode_enticons[k] or obsolete, BMPropClick, 64 * row, 64 * col, 64, 64)
		img.prop = k
		img.hover = buildmode_entnames[k] or scripted_ents.GetMember(k, "PrintName")

		row = row + 1

		if row > 5 then
			col = col + 1
			row = 0
		end
	end

	propspanel.elements = propspanel_elements
	hook.Remove("InitPostEntity", "BuildModeElements")
end

BuildModeElements()
hook.Add("InitPostEntity", "BuildModeElements", BuildModeElements)

local function BMPanel(state)
	if state then
		AEUI:AddPanel(elementstogglepanel)
		AEUI:AddPanel(propspanel)
		AEUI:AddPanel(bmbuttons)
		AEUI:AddPanel(bminfo)
	else
		AEUI:RemovePanel(elementstogglepanel)
		AEUI:RemovePanel(propspanel)
		AEUI:RemovePanel(bmbuttons)
		AEUI:RemovePanel(bminfo)
	end
end

hook.Add("BuildModeState", "BMPanel", BMPanel)