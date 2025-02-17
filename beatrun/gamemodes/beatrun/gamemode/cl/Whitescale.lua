local worldmats
local editedmats
local worldmats_texture = {}
local worldmats_color = {}
local whitescale = false

local function World_Whitescale()
	worldmats = game.GetWorld():GetMaterials()
	editedmats = {}

	local propmats = ents.FindByClass("prop_dynamic")
	local dupeprops = {}

	for _, v in pairs(propmats) do
		if dupeprops[v:GetModel()] then continue end

		for _, v in pairs(v:GetMaterials()) do
			table.insert(worldmats, v)
		end

		dupeprops[v:GetModel()] = true
	end

	for k, v in pairs(worldmats) do
		if v:find("water/") then continue end

		local newmat = Material(v)

		table.insert(editedmats, newmat)
		table.insert(worldmats_color, newmat:GetVector("$color"))
		table.insert(worldmats_texture, newmat:GetString("$basetexture") or 0)

		newmat:SetTexture("$basetexture", "models/debug/debugwhite")
		-- if math.random()>0.5 then

		local noise = util.SharedRandom(k, -0.25, 0)
		newmat:SetVector("$color", Vector(0.65 + noise, 0.65 + noise, 0.65 + noise))

		-- else
		-- newmat:SetVector("$color",Vector(0.95,0.05,0.05))
		-- end
	end

	whitescale = true

	net.Start("ToggleWhitescale")
		net.WriteBool(whitescale)
	net.SendToServer()
end

local function World_WhitescaleOff()
	if not editedmats then return end

	for k, v in pairs(editedmats) do
		local oldtexture = worldmats_texture[k]

		if oldtexture ~= 0 then
			v:SetTexture("$basetexture", worldmats_texture[k])
		end

		v:SetVector("$color", worldmats_color[k])
	end

	whitescale = false
end

local function ToggleWhitescale()
	if whitescale then
		World_WhitescaleOff()
	else
		World_Whitescale()
	end
end

concommand.Add("Beatrun_ToggleWhitescale", ToggleWhitescale)