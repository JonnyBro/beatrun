local UI = BeatrunUI
local S, L = UI.S, UI.L

local iconcache = {}
local iconqueue = {}

local dummy = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
dummy:SetNoDraw(true)

local function IconSize()
	local need = S(60)

	return need <= 64 and 64 or need <= 128 and 128 or 256
end

local function RenderModelIcon(model, size)
	local tex = GetRenderTarget("BMRT" .. size .. "-" .. model, size, size)

	render.PushRenderTarget(tex, 0, 0, size, size)
	render.SuppressEngineLighting(true)

	dummy:SetModel(model)

	local sicon = PositionSpawnIcon(dummy, vector_origin)

	cam.Start3D(sicon.origin, sicon.angles, sicon.fov, 0, 0, size, size)
		render.Clear(0, 0, 0, 0, true, true)
		render.SetWriteDepthToDestAlpha(false)
		render.SetModelLighting(0, 4, 4, 4)
		render.SetModelLighting(1, 2, 2, 2)
		render.SetModelLighting(2, 2, 2, 2)
		render.SetModelLighting(3, 4, 4, 4)
		render.SetModelLighting(4, 3, 3, 3)
		render.SetModelLighting(5, 4, 4, 4)

		dummy:DrawModel()
	cam.End3D()

	render.SuppressEngineLighting(false)
	render.PopRenderTarget()

	return CreateMaterial("BM" .. size .. "-" .. model, "UnlitGeneric", {
		["$vertexcolor"] = 1,
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
		["$basetexture"] = tex:GetName()
	})
end

-- Spawnicons are 64px, anything bigger gets rendered from the model so it isn't blurry
function BuildModeModelIcon(model)
	local size = IconSize()
	local key = size .. model

	if iconcache[key] then return iconcache[key] end

	if size == 64 then
		local spawnicon = "spawnicons/" .. model:Left(-5) .. ".png"

		if file.Exists("materials/" .. spawnicon, "GAME") then
			iconcache[key] = Material(spawnicon, "smooth mips")

			return iconcache[key]
		end
	end

	iconqueue[key] = { model = model, size = size }
end

-- Render targets can't be drawn into from inside clipped vgui paint
hook.Add("HUDPaint", "BuildModeIcons", function()
	local budget = 4

	for key, job in pairs(iconqueue) do
		iconcache[key] = RenderModelIcon(job.model, job.size)
		iconqueue[key] = nil

		budget = budget - 1
		if budget <= 0 then break end
	end
end)

local function ItemIcon(item)
	if item.icon then return item.icon end
	if item.model then return BuildModeModelIcon(item.model) end
end

local CATEGORIES = {
	{ key = "blocks", label = "#beatrun.buildmode.cat.blocks" },
	{ key = "triangles", label = "#beatrun.buildmode.cat.triangles" },
	{ key = "glass", label = "#beatrun.buildmode.cat.glass" },
	{ key = "misc", label = "#beatrun.buildmode.cat.misc" },
	{ key = "entities", label = "#beatrun.buildmode.cat.entities" },
	{ key = "vehicles", label = "#beatrun.buildmode.cat.vehicles" },
	{ key = "npcs", label = "#beatrun.buildmode.cat.npcs" },
	{ key = "custom", label = "#beatrun.buildmode.cat.custom" }
}

local ENTITY_ICONS = {
	br_swingbar = Material("vgui/editor/swingbar.png", "smooth mips"),
	br_swingpipe = Material("vgui/editor/swingpipe.png", "smooth mips"),
	br_zipline = Material("vgui/editor/zipline.png", "smooth mips"),
	br_ladder = Material("vgui/editor/ladder.png", "smooth mips"),
	br_balance = Material("vgui/editor/balance.png", "smooth mips"),
	br_laser = Material("vgui/editor/laser.png", "smooth mips"),
	br_swingrope = Material("vgui/editor/swingrope.png", "smooth mips"),
	br_mat = Material("vgui/editor/mat.png", "smooth mips"),
	tt_cp = Material("vgui/editor/checkpoint.png", "smooth mips"),
	br_hookpoint = Material("sprites/sent_ball.vmt")
}

local ENTITY_NAMES = {
	br_zipline = "#beatrun.buildmode.zipline"
}

local catalogue = {}

local function PropCategory(model)
	if string.StartWith(model, "models/hunter/blocks/") then return "blocks" end
	if string.StartWith(model, "models/hunter/triangles/") then return "triangles" end
	if string.StartWith(model, "models/props_phx/construct/glass/") then return "glass" end

	return "misc"
end

local function BuildCatalogue()
	table.Empty(catalogue)

	for index, model in ipairs(buildmode_props) do
		table.insert(catalogue, {
			id = index,
			category = PropCategory(model),
			name = string.StripExtension(string.GetFileFromFilename(model)),
			model = model
		})
	end

	local function AddSpawnables(listName, kind, category)
		local items = {}

		for name, data in pairs(list.GetForEdit(listName)) do
			if data.OnCeiling and not data.OnFloor then continue end

			local id = kind .. ":" .. name
			local icon = "entities/" .. name .. ".png"

			table.insert(items, {
				id = id,
				category = category,
				name = L(data.Name or name),
				icon = file.Exists("materials/" .. icon, "GAME") and Material(icon, "smooth mips") or nil,
				model = BuildModeItemModel(id)
			})
		end

		table.sort(items, function(a, b) return a.name < b.name end)
		table.Add(catalogue, items)
	end

	AddSpawnables("Vehicles", "vehicle", "vehicles")
	AddSpawnables("NPC", "npc", "npcs")

	for class in SortedPairs(buildmode_ents) do
		local name = ENTITY_NAMES[class] or scripted_ents.GetMember(class, "PrintName") or class

		table.insert(catalogue, {
			id = class,
			category = "entities",
			name = L(name),
			icon = ENTITY_ICONS[class] or Material("editor/obsolete")
		})
	end
end

local CUSTOM_FILE = "beatrun/buildmode_models.txt"
local CUSTOM_LIMIT = 60

local customModels = util.JSONToTable(file.Read(CUSTOM_FILE, "DATA") or "") or {}
local customItems = {}

local function SaveCustomModels()
	file.CreateDir("beatrun")
	file.Write(CUSTOM_FILE, util.TableToJSON(customModels))
end

local function IsCatalogueModel(model)
	for _, v in ipairs(buildmode_props) do
		if v == model then return true end
	end

	return false
end

local function AddCustomModel(model)
	model = string.lower(model)

	if IsCatalogueModel(model) then return end

	table.RemoveByValue(customModels, model)
	table.insert(customModels, 1, model)

	while #customModels > CUSTOM_LIMIT do table.remove(customModels) end

	SaveCustomModels()
end

local function CustomItem(model)
	if customItems[model] then return customItems[model] end

	customItems[model] = {
		id = model,
		category = "custom",
		name = string.StripExtension(string.GetFileFromFilename(model)),
		model = model
	}

	return customItems[model]
end

local function CustomList()
	local list, seen = {}, {}

	for _, model in ipairs(customModels) do
		if not seen[model] and util.IsValidModel(model) then
			seen[model] = true
			table.insert(list, CustomItem(model))
		end
	end

	for _, ent in ipairs(buildmode_placed or {}) do
		if IsValid(ent) and ent:GetClass() == "prop_physics" then
			local model = string.lower(ent:GetModel() or "")

			if model ~= "" and not seen[model] and not IsCatalogueModel(model) then
				seen[model] = true
				table.insert(list, CustomItem(model))
			end
		end
	end

	return list
end

local function ItemById(id)
	if BuildModeIsCustomModel(id) then return CustomItem(id) end

	for _, item in ipairs(catalogue) do
		if item.id == id then return item end
	end
end

local function SelectItem(id)
	BuildModeIndex = id or 0

	LocalPlayer():EmitSound("buttonclick.ogg")

	if BuildModeIndex == 0 then
		SafeRemoveEntity(GhostModel)

		return
	end

	if BuildModeIsCustomModel(BuildModeIndex) then AddCustomModel(BuildModeIndex) end

	BuildModeUpdateGhost()

	PlaceStartPos = nil
	PlaceEndPos = nil
	PlaceAxisLock = 0
end

local panels = {}
local paletteWidth = 0
local paletteState = { category = "blocks", query = "", hovered = nil }
local helpPanel

local function Root(className)
	local panel = vgui.Create(className or "DPanel")
	panel:SetMouseInputEnabled(true)
	panel:SetKeyboardInputEnabled(false)

	table.insert(panels, panel)

	return panel
end

local function PaintBox(panel, w, h, withEdge)
	UI.PaintWindowBackground(panel, w, h)
	UI.PaintPanel(w, h, Color(0, 0, 0, 0), withEdge)
end

local function AngleText()
	local p, y, r = BuildModeAngle:Unpack()

	return string.format("%d %d %d", math.Round(p), math.Round(y), math.Round(r))
end

local function BuildStatus()
	local panel = Root()
	panel:SetPos(S(20), S(20))
	panel:SetMouseInputEnabled(false)

	local pad = S(14)
	local lineLarge = draw.GetFontHeight("BeatrunUILarge")
	local line = draw.GetFontHeight("BeatrunUI")
	local lineSmall = draw.GetFontHeight("BeatrunUISmall")

	panel:SetSize(S(360), pad * 2 + lineLarge + line + lineSmall + S(8))

	local lines = {}

	panel.Think = function(self)
		local state = BuildModeGetState()
		local tool

		if state.dragging then
			tool = L("beatrun.buildmode.tool.moving"):format(state.selected)

			if state.axis then tool = tool .. " | " .. L("beatrun.buildmode.tool.axis"):format(string.upper(state.axis)) end
		elseif BuildModeIndex ~= 0 then
			local item = ItemById(BuildModeIndex)

			tool = L("beatrun.buildmode.tool.placing"):format(item and item.name or tostring(BuildModeIndex))

			if state.secondPoint then tool = tool .. " | " .. L("beatrun.buildmode.tool.secondpoint") end

			local kind = BuildModeSpawnable(BuildModeIndex)
			if kind == "npc" then tool = tool .. " | " .. L(BuildModePlaceAI and "beatrun.buildmode.tool.aion" or "beatrun.buildmode.tool.aioff") end
		else
			tool = L("beatrun.buildmode.tool.select")
		end

		local grid = state.grid > 0 and tostring(state.grid) or L("beatrun.buildmode.off")

		lines[1] = "★ " .. string.upper(L("beatrun.buildmode.title"))
		lines[2] = string.upper(tool)
		lines[3] = L("beatrun.buildmode.status"):format(state.selected, AngleText(), grid, math.Round(state.distance))

		local width = 0

		for i, font in ipairs({ "BeatrunUILarge", "BeatrunUI", "BeatrunUISmall" }) do
			surface.SetFont(font)
			width = math.max(width, surface.GetTextSize(lines[i]))
		end

		width = math.max(S(360), width + S(4) + pad * 2)

		if self:GetWide() ~= width then self:SetWide(width) end
	end

	panel.Paint = function(self, w, h)
		if not lines[1] then return end

		local theme = CurrentTheme()
		local x = S(4) + pad
		local y = pad

		PaintBox(self, w, h, true)

		draw.SimpleText(lines[1], "BeatrunUILarge", x, y, theme.text.primary)
		y = y + lineLarge + S(4)

		draw.SimpleText(lines[2], "BeatrunUI", x, y, theme.accent)
		y = y + line + S(4)

		draw.SimpleText(lines[3], "BeatrunUISmall", x, y, theme.text.muted)
	end
end

local function OpenFieldEditor(field, placeholder, text, onChange, onEnter)
	if IsValid(field.editor) then return end

	local x, y = field:LocalToScreen(0, 0)

	local editor = vgui.Create("EditablePanel")
	editor:SetPos(x, y)
	editor:SetSize(field:GetWide(), field:GetTall())
	editor:MakePopup()

	table.insert(panels, editor)
	field.editor = editor

	local entry = UI.MakeTextEntry(editor, placeholder)
	entry:Dock(FILL)
	entry:SetFont("BeatrunUISmall")
	entry:SetText(text or "")
	entry:SetUpdateOnType(true)
	entry:RequestFocus()
	entry:SetCaretPos(#(text or ""))

	local function Close()
		if IsValid(editor) then editor:Remove() end
	end

	function entry:OnValueChange(value)
		if onChange then onChange(value or "") end
	end

	entry.OnEnter = function(self)
		local value = self:GetValue()

		Close()

		if onEnter then onEnter(value) end
	end

	editor.mouseWasDown = true

	editor.Think = function(self)
		if input.IsKeyDown(KEY_ESCAPE) then return Close() end

		local down = input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)

		if down and not self.mouseWasDown and not (self:IsHovered() or self:IsChildHovered()) then Close() end

		self.mouseWasDown = down
	end
end

local function PaintField(field, w, h, text, placeholder)
	local theme = CurrentTheme()

	surface.SetDrawColor(theme.panels.primary)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(field:IsHovered() and theme.text.muted or theme.border)
	surface.DrawOutlinedRect(0, 0, w, h, 1)

	if IsValid(field.editor) then return end

	local empty = text == ""

	draw.SimpleText(empty and L(placeholder) or text, "BeatrunUISmall", 5, h / 2, empty and theme.text.muted or theme.text.primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local CURSOR = {
	{ 0, 0 }, { 0.55, 0.53 }, { 0.32, 0.53 }, { 0.45, 0.83 },
	{ 0.33, 0.88 }, { 0.2, 0.58 }, { 0, 0.75 }
}

local cursorPoly = {}

local function DrawCursorIcon(w, h, color)
	local size = math.min(w, h) * 0.5
	local x, y = w / 2 - size * 0.28, h / 2 - size * 0.45

	for i, p in ipairs(CURSOR) do
		cursorPoly[i] = cursorPoly[i] or {}
		cursorPoly[i].x = x + p[1] * size
		cursorPoly[i].y = y + p[2] * size
	end

	draw.NoTexture()
	surface.SetDrawColor(color)
	surface.DrawPoly(cursorPoly)
end

local function BuildPalette(width, height)
	local panel = Root()
	panel:SetSize(width, height)
	panel:SetPos(ScrW() - S(20) - width, S(20))
	panel:DockPadding(0, 0, 0, S(10))

	panel.Paint = function(self, w, h) PaintBox(self, w, h) end

	local tabs = UI.MakeTabBar(panel, 34)
	tabs.tabPadding = S(14)
	tabs.wrap = true

	local searchRow = vgui.Create("DPanel", panel)
	searchRow:SetTall(S(32))
	searchRow:Dock(TOP)
	searchRow:DockMargin(S(12), S(10), S(12), S(8))
	searchRow.Paint = nil

	local search = vgui.Create("DButton", searchRow)
	search:Dock(FILL)
	search:SetText("")
	search:SetCursor("beam")

	search.Paint = function(self, w, h) PaintField(self, w, h, paletteState.query, "#beatrun.buildmode.search") end

	local customInfo = vgui.Create("DPanel", panel)
	customInfo:Dock(TOP)
	customInfo:DockMargin(S(12), S(10), S(12), S(8))
	customInfo:SetVisible(false)
	customInfo.Paint = nil

	local infoText = UI.MakeLabel(customInfo, "#beatrun.buildmode.custom.info", "AEUIDefault", CurrentTheme().text.muted)
	infoText:Dock(TOP)
	infoText:SetWrap(true)
	infoText:SetAutoStretchVertical(true)

	local pathRow = vgui.Create("DButton", customInfo)
	pathRow:SetTall(S(32))
	pathRow:Dock(TOP)
	pathRow:DockMargin(0, S(8), 0, 0)
	pathRow:SetText("")
	pathRow:SetCursor("beam")

	pathRow.Paint = function(self, w, h) PaintField(self, w, h, "", "#beatrun.buildmode.custom.path") end

	customInfo.PerformLayout = function(self)
		self:SizeToChildren(false, true)
	end

	local footer = vgui.Create("DPanel", panel)
	footer:SetTall(draw.GetFontHeight("BeatrunUISmall") + S(8))
	footer:Dock(BOTTOM)
	footer:DockMargin(S(12), S(6), S(12), 0)

	footer.Paint = function(self, w, h)
		local theme = CurrentTheme()
		local item = paletteState.hovered or ItemById(BuildModeIndex)
		local text = item and item.name or L("beatrun.buildmode.tool.select")

		draw.SimpleText(text, "BeatrunUISmall", 0, h / 2, item and theme.text.primary or theme.text.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local scroll = UI.MakeScroll(panel)
	scroll:DockMargin(S(12), 0, S(4), 0)

	local grid = scroll:Add("DIconLayout")
	grid:Dock(TOP)
	grid:SetSpaceX(S(6))
	grid:SetSpaceY(S(6))

	local cell = S(66)

	local function AddCell(item)
		local btn = grid:Add("DButton")
		btn:SetSize(cell, cell)
		btn:SetText("")
		btn:SetCursor("hand")

		btn.Paint = function(self, w, h)
			local theme = CurrentTheme()
			local id = item and item.id or 0
			local selected = BuildModeIndex == id

			surface.SetDrawColor(selected and ColorAlpha(theme.accent, 40) or theme.panels.primary)
			surface.DrawRect(0, 0, w, h)

			if item then
				local icon = ItemIcon(item)

				if icon then
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(icon)
					surface.DrawTexturedRect(S(3), S(3), w - S(6), h - S(6))
				end
			else
				DrawCursorIcon(w, h, theme.text.primary)
			end

			if selected then
				surface.SetDrawColor(theme.accent)
				surface.DrawOutlinedRect(0, 0, w, h, S(2))
			elseif self:IsHovered() then
				surface.SetDrawColor(theme.text.primary)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			else
				surface.SetDrawColor(theme.border)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
			end
		end

		btn.OnCursorEntered = function() paletteState.hovered = item end

		btn.OnCursorExited = function()
			if paletteState.hovered == item then paletteState.hovered = nil end
		end

		btn.DoClick = function() SelectItem(item and item.id or 0) end
	end

	local function Rebuild()
		grid:Clear()
		paletteState.hovered = nil

		AddCell(nil)

		local query = string.lower(string.Trim(paletteState.query))
		local custom = paletteState.category == "custom" and query == ""

		searchRow:SetVisible(not custom)
		customInfo:SetVisible(custom)
		panel:InvalidateLayout()

		if custom then
			for _, item in ipairs(CustomList()) do AddCell(item) end
		else
			local items = catalogue

			if query ~= "" then
				items = table.Add(table.Copy(catalogue), CustomList())
			end

			for _, item in ipairs(items) do
				local match

				if query ~= "" then
					match = string.find(string.lower(item.name), query, 1, true) ~= nil or (isstring(item.id) and string.find(item.id, query, 1, true) ~= nil)
				else
					match = item.category == paletteState.category
				end

				if match then AddCell(item) end
			end
		end

		grid:Layout()
	end

	for _, cat in ipairs(CATEGORIES) do
		tabs:AddTab(cat.key, cat.label, function(key)
			paletteState.category = key

			paletteState.query = ""

			Rebuild()
		end)
	end

	search.DoClick = function(self)
		OpenFieldEditor(self, "#beatrun.buildmode.search", paletteState.query, function(value)
			paletteState.query = value

			timer.Create("Beatrun_BuildModeSearch", 0.15, 1, function()
				if IsValid(grid) then Rebuild() end
			end)
		end)
	end

	panel.Think = function()
		local count = #(buildmode_placed or {})
		if count == panel.placedCount then return end

		panel.placedCount = count

		if paletteState.category == "custom" and paletteState.query == "" then Rebuild() end
	end

	pathRow.DoClick = function(self)
		OpenFieldEditor(self, "#beatrun.buildmode.custom.path", "", nil, function(value)
			local model = string.lower(string.Trim(string.Replace(value, "\\", "/")))
			if model == "" then return end

			if not BuildModeIsValidModelPath(model) then
				notification.AddLegacy(L("beatrun.buildmode.custom.invalid"):format(model), NOTIFY_ERROR, 4)
				surface.PlaySound("buttons/button10.wav")

				return
			end

			SelectItem(model)
			Rebuild()
		end)
	end

	tabs:Select(paletteState.category)

	return panel
end

local function BuildActions(x, y, width)
	local panel = Root()
	panel:SetPos(x, y)
	panel:SetWide(width)
	panel:DockPadding(S(12), S(12), S(12), S(12))

	panel.Paint = function(self, w, h) PaintBox(self, w, h) end

	local gap = S(6)
	local rows = {}

	local function Row()
		local row = vgui.Create("DPanel", panel)
		row:SetTall(S(32))
		row:Dock(TOP)
		row:DockMargin(0, 0, 0, gap)
		row.Paint = nil

		row.PerformLayout = function(self, w)
			local children = self:GetChildren()
			local bw = (w - gap * (#children - 1)) / #children

			for i, child in ipairs(children) do
				child:SetPos((i - 1) * (bw + gap), 0)
				child:SetSize(bw, self:GetTall())
			end
		end

		table.insert(rows, row)

		return row
	end

	local function Action(row, text, key, style, onClick, needsSelection)
		local btn = UI.MakeButton(row, string.upper(L(text)) .. "  [" .. key .. "]", style, "BeatrunUISmall")

		btn.DoClick = onClick

		if needsSelection then
			btn.Think = function(self)
				local enabled = table.Count(buildmode_selected) > 0
				if self:IsEnabled() ~= enabled then self:SetEnabled(enabled) end
			end
		end

		return btn
	end

	local selection = Row()
	Action(selection, "#beatrun.buildmode.action.move", "G", "secondary", function() buildmodeinputs[KEY_G]() end, true)
	Action(selection, "#beatrun.buildmode.action.copy", "SHIFT+D", "secondary", function() buildmodeinputs[KEY_D](true) end, true)

	local selection2 = Row()
	Action(selection2, "#beatrun.buildmode.action.highlight", "T", "secondary", function() buildmodeinputs[KEY_T]() end, true)
	Action(selection2, "#beatrun.buildmode.action.delete", "DEL", "danger", function() buildmodeinputs[KEY_DELETE]() end, true)

	local history = Row()
	Action(history, "#beatrun.buildmode.action.undo", "CTRL+Z", "secondary", function()
		net.Start("BuildMode_Undo")
		net.SendToServer()
	end)

	Action(history, "#beatrun.buildmode.action.redo", "CTRL+Y", "secondary", function()
		net.Start("BuildMode_Redo")
		net.SendToServer()
	end)

	local tools = Row()
	local gridBtn = Action(tools, "#beatrun.buildmode.action.grid", "N", "secondary", function() buildmodeinputs[KEY_N]() end)

	gridBtn.Think = function(self)
		local grid = BuildModeGridSize()
		local text = string.upper(L("beatrun.buildmode.action.grid")) .. ": " .. (grid > 0 and grid or string.upper(L("beatrun.buildmode.off"))) .. "  [N]"

		if self:GetText() ~= text then self:SetText(text) end
	end

	Action(tools, "#beatrun.buildmode.action.help", "H", "secondary", function() BuildModeToggleHelp() end)

	local course = Row()

	Action(course, "#beatrun.buildmode.action.save", "", "primary", function()
		if BeatrunUI.OpenCourseSave then BeatrunUI.OpenCourseSave() end
	end):SetText(string.upper(L("beatrun.buildmode.action.save")))

	local exit = Row()
	Action(exit, "#beatrun.buildmode.action.exit", "", "secondary", function() RunConsoleCommand("Beatrun_BuildMode") end):SetText(string.upper(L("beatrun.buildmode.action.exit")))

	panel:SetTall(S(12) * 2 + #rows * (S(32) + gap) - gap)

	return panel
end

local HINTS = {
	moving = {
		{ "#beatrun.buildmode.key.lmb", "#beatrun.buildmode.hint.confirm" },
		{ "#beatrun.buildmode.key.rmb", "#beatrun.buildmode.hint.cancel" },
		{ "R", "#beatrun.buildmode.hint.axis" },
		{ "#beatrun.buildmode.key.wheel", "#beatrun.buildmode.hint.rotate" },
		{ "N", "#beatrun.buildmode.hint.grid" }
	},
	secondpoint = {
		{ "#beatrun.buildmode.key.lmb", "#beatrun.buildmode.hint.endpoint" },
		{ "SHIFT", "#beatrun.buildmode.hint.twoway" },
		{ "#beatrun.buildmode.key.rmbclick", "#beatrun.buildmode.hint.cancelplace" }
	},
	placing = {
		{ "#beatrun.buildmode.key.lmb", "#beatrun.buildmode.hint.place" },
		{ "#beatrun.buildmode.key.wheel", "#beatrun.buildmode.hint.rotate" },
		{ "X C V B", "#beatrun.buildmode.hint.tilt" },
		{ "CTRL", "#beatrun.buildmode.hint.fine" },
		{ "R", "#beatrun.buildmode.hint.resetangle" },
		{ "= -", "#beatrun.buildmode.hint.distance" },
		{ "E+{wheel}", "#beatrun.buildmode.hint.cycle" }
	},
	placingnpc = {
		{ "#beatrun.buildmode.key.lmb", "#beatrun.buildmode.hint.place" },
		{ "#beatrun.buildmode.key.wheel", "#beatrun.buildmode.hint.rotate" },
		{ "I", "#beatrun.buildmode.hint.placeai" },
		{ "= -", "#beatrun.buildmode.hint.distance" },
		{ "E+{wheel}", "#beatrun.buildmode.hint.cycle" }
	},
	selected = {
		{ "G", "#beatrun.buildmode.hint.move" },
		{ "SHIFT+D", "#beatrun.buildmode.hint.copy" },
		{ "T", "#beatrun.buildmode.hint.highlight" },
		{ "DEL", "#beatrun.buildmode.hint.delete" },
		{ "I", "#beatrun.buildmode.hint.toggleai" },
		{ "SHIFT+{lmb}", "#beatrun.buildmode.hint.addselect" },
		{ "CTRL+Z", "#beatrun.buildmode.hint.undo" },
		{ "CTRL+Y", "#beatrun.buildmode.hint.redo" }
	},
	idle = {
		{ "#beatrun.buildmode.key.lmb", "#beatrun.buildmode.hint.select" },
		{ "#beatrun.buildmode.key.drag", "#beatrun.buildmode.hint.boxselect" },
		{ "#beatrun.buildmode.key.rmbhold", "#beatrun.buildmode.hint.look" },
		{ "S", "#beatrun.buildmode.hint.spawn" },
		{ "F", "#beatrun.buildmode.hint.checkpoint" },
		{ "Q", "#beatrun.buildmode.hint.spawnmenu" },
		{ "H", "#beatrun.buildmode.hint.help" }
	}
}

local function KeyText(key)
	return (string.gsub(L(key), "{(%w+)}", function(name) return L("beatrun.buildmode.key." .. name) end))
end

local function HintContext()
	local state = BuildModeGetState()

	if state.dragging then return "moving" end
	if BuildModeIndex ~= 0 then
		if state.secondPoint then return "secondpoint" end

		return BuildModeSpawnable(BuildModeIndex) == "npc" and "placingnpc" or "placing"
	end
	if state.selected > 0 then return "selected" end

	return "idle"
end

local function BuildHints()
	local panel = Root()
	panel:SetMouseInputEnabled(false)

	local gap = S(16)
	local pad = S(10)

	panel.Paint = function(self, w, h) PaintBox(self, w, h) end

	local function Fill(context)
		panel:Clear()
		panel.context = context

		local maxW = ScrW() - S(60) - paletteWidth
		local x, y = pad, pad
		local rowH, width = 0, 0

		for _, hint in ipairs(HINTS[context]) do
			local item = UI.MakeKeyHint(panel, KeyText(hint[1]), hint[2])

			if x + item:GetWide() + pad > maxW and x > pad then
				x = pad
				y = y + rowH + S(8)
			end

			item:SetPos(x, y)

			x = x + item:GetWide() + gap
			rowH = math.max(rowH, item:GetTall())
			width = math.max(width, x - gap + pad)
		end

		panel:SetSize(width, y + rowH + pad)
		panel:SetPos(S(20), ScrH() - panel:GetTall() - S(20))
	end

	panel.Think = function(self)
		local context = HintContext()
		if context ~= self.context then Fill(context) end
	end

	Fill(HintContext())
end

local HELP = {
	{
		title = "#beatrun.buildmode.help.camera",
		keys = {
			{ "#beatrun.buildmode.key.rmbhold", "#beatrun.buildmode.hint.look" },
			{ "#beatrun.buildmode.key.rmbhold", "#beatrun.buildmode.hint.fly" }
		}
	},
	{
		title = "#beatrun.buildmode.help.selection",
		keys = {
			{ "#beatrun.buildmode.key.lmb", "#beatrun.buildmode.hint.select" },
			{ "SHIFT+{lmb}", "#beatrun.buildmode.hint.addselect" },
			{ "#beatrun.buildmode.key.drag", "#beatrun.buildmode.hint.boxselect" },
			{ "G", "#beatrun.buildmode.hint.move" },
			{ "SHIFT+D", "#beatrun.buildmode.hint.copy" },
			{ "T", "#beatrun.buildmode.hint.highlight" },
			{ "DEL", "#beatrun.buildmode.hint.delete" },
			{ "I", "#beatrun.buildmode.hint.toggleai" }
		}
	},
	{
		title = "#beatrun.buildmode.help.placing",
		keys = {
			{ "E+{wheel}", "#beatrun.buildmode.hint.cycle" },
			{ "#beatrun.buildmode.key.lmb", "#beatrun.buildmode.hint.place" },
			{ "#beatrun.buildmode.key.wheel", "#beatrun.buildmode.hint.rotate" },
			{ "X C V B", "#beatrun.buildmode.hint.tilt" },
			{ "CTRL", "#beatrun.buildmode.hint.fine" },
			{ "R", "#beatrun.buildmode.hint.resetangle" },
			{ "= -", "#beatrun.buildmode.hint.distance" },
			{ "ALT", "#beatrun.buildmode.hint.slow" },
			{ "I", "#beatrun.buildmode.hint.placeai" }
		}
	},
	{
		title = "#beatrun.buildmode.help.moving",
		keys = {
			{ "#beatrun.buildmode.key.lmb", "#beatrun.buildmode.hint.confirm" },
			{ "#beatrun.buildmode.key.rmb", "#beatrun.buildmode.hint.cancel" },
			{ "R", "#beatrun.buildmode.hint.axis" }
		}
	},
	{
		title = "#beatrun.buildmode.help.course",
		keys = {
			{ "S", "#beatrun.buildmode.hint.spawn" },
			{ "F", "#beatrun.buildmode.hint.checkpoint" },
			{ "Q", "#beatrun.buildmode.hint.spawnmenusaved" },
			{ "NUM -", "#beatrun.buildmode.hint.savebuild" },
			{ "NUM +", "#beatrun.buildmode.hint.pastebuild" }
		}
	},
	{
		title = "#beatrun.buildmode.help.other",
		keys = {
			{ "N", "#beatrun.buildmode.hint.grid" },
			{ "CTRL+Z", "#beatrun.buildmode.hint.undo" },
			{ "CTRL+Y", "#beatrun.buildmode.hint.redo" },
			{ "H", "#beatrun.buildmode.hint.help" }
		}
	}
}

function BuildModeToggleHelp()
	if IsValid(helpPanel) then
		helpPanel:Remove()

		return
	end

	if not BuildMode then return end

	helpPanel = Root()
	helpPanel:SetMouseInputEnabled(false)

	local pad = S(20)
	local columnW = S(380)
	local rowH = draw.GetFontHeight("BeatrunUISmall") + S(12)
	local titleH = draw.GetFontHeight("BeatrunUI") + S(10)

	local heights = {}
	local x, y, column = pad, pad + draw.GetFontHeight("BeatrunUILarge") + S(16), 1
	local startY = y

	for _, group in ipairs(HELP) do
		local groupH = titleH + #group.keys * rowH + S(14)

		if y + groupH > S(640) and y > startY then
			column = column + 1
			x = pad + (column - 1) * (columnW + pad)
			y = startY
		end

		local title = UI.MakeLabel(helpPanel, "// " .. string.upper(L(group.title)), "BeatrunUI")
		title:SetPos(x, y)

		local ky = y + titleH

		for _, key in ipairs(group.keys) do
			local hint = UI.MakeKeyHint(helpPanel, KeyText(key[1]), key[2])
			hint:SetPos(x, ky)

			ky = ky + rowH
		end

		y = ky + S(14)
		heights[column] = math.max(heights[column] or 0, y)
	end

	local w = pad + math.max(column, 1) * (columnW + pad)
	local h = 0

	for _, colH in pairs(heights) do h = math.max(h, colH) end

	helpPanel:SetSize(w, h + pad)
	helpPanel:Center()

	helpPanel.Paint = function(self, pw, ph)
		local theme = CurrentTheme()

		PaintBox(self, pw, ph, true)

		draw.SimpleText("★ " .. string.upper(L("beatrun.buildmode.help.title")), "BeatrunUILarge", pad, pad, theme.text.primary)
		draw.SimpleText(L("beatrun.buildmode.help.close"), "BeatrunUISmall", pw - pad, pad + S(6), theme.text.muted, TEXT_ALIGN_RIGHT)
	end
end

local function RemovePanels()
	for _, panel in ipairs(panels) do
		if IsValid(panel) then panel:Remove() end
	end

	table.Empty(panels)
end

local function CreatePanels()
	RemovePanels()

	if #catalogue == 0 then BuildCatalogue() end

	local width = S(66) * 7 + S(6) * 6 + S(12) + S(16)

	paletteWidth = width

	local actions = BuildActions(0, 0, width)
	local paletteH = math.min(S(640), ScrH() - S(40) - actions:GetTall() - S(12))

	actions:SetPos(ScrW() - S(20) - width, S(20) + paletteH + S(12))

	BuildStatus()
	BuildPalette(width, paletteH)
	BuildHints()
end

hook.Add("InitPostEntity", "BuildModeCatalogue", function()
	BuildCatalogue()
end)

hook.Add("BuildModeState", "BMPanel", function(state)
	if state then
		CreatePanels()
	else
		RemovePanels()

		paletteState.hovered = nil
	end
end)

hook.Add("OnScreenSizeChanged", "BuildModeHUD_Resize", function()
	if BuildMode then CreatePanels() end
end)
