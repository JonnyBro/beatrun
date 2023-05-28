function CLoadout:InitRegistry()
	local registry = {}

	for _, v in pairs(list.Get("Weapon")) do
		if not v.ClassName or not v.Spawnable then continue end

		registry[v.ClassName] = {
			name = (v.PrintName and v.PrintName ~= "") and v.PrintName or v.ClassName,
		}
	end

	self.weaponRegistry = registry

	table.sort(self.categories)
end

function CLoadout:CreateLoadout(items)
	local loadout = {}

	if istable(items) and table.IsSequential(items) then
		for _, item in ipairs(items) do
			loadout[#loadout + 1] = { item[1] }
		end
	end

	return table.insert(DATATHEFT_LOADOUTS, loadout)
end

function CLoadout:DeleteLoadout(index)
	table.remove(DATATHEFT_LOADOUTS, index)

	if #DATATHEFT_LOADOUTS == 0 then
		self:CreateLoadout()
	end

	self.loadoutIndex = #DATATHEFT_LOADOUTS
	self:UpdateLists()
end

function CLoadout:Apply()
	local loadout = DATATHEFT_LOADOUTS[self.loadoutIndex]

	loadout = util.Compress(util.TableToJSON(loadout))

	if not loadut then
		LocalPlayer():ChatPrint("Failed to compress the loadut!")

		return
	end

	net.Start("Beatrun_UpdateLoadouts", false)
		net.WriteData(loadout, #loadout)
	net.SendToServer()
end

function CLoadout:AddWeapon(class)
	local items = DATATHEFT_LOADOUTS[self.loadoutIndex]

	if #items < self:GetWeaponLimit() then
		table.insert(items, { class })
	else
		Derma_Message("Your loadout is full!", "Loadout", "OK")
	end
end

function CLoadout:AddInventoryWeapons()
	local items = DATATHEFT_LOADOUTS[self.loadoutIndex]

	local alreadyInLoadout = {}

	for _, v in ipairs(items) do
		alreadyInLoadout[v[1]] = true
	end

	local weaponsList = LocalPlayer():GetWeapons()

	for _, v in ipairs(weaponsList) do
		local class = (v.GetClass and v:GetClass()) or v.ClassName

		if not alreadyInLoadout[class] then
			table.insert(DATATHEFT_LOADOUTS[self.loadoutIndex], { class })
		end
	end

	self:UpdateLists()
end

function CLoadout:RemoveWeapon(index)
	table.remove(DATATHEFT_LOADOUTS[self.loadoutIndex], index)
end

function CLoadout:Init()
	self.filter = ""

	self.loadoutIndex = 1
	DATATHEFT_LOADOUTS = {}

	if IsValid(self.frame) then
		self.frame:Close()
		self.frame = nil
	end

	self:InitRegistry()

	if #DATATHEFT_LOADOUTS == 0 then
		self:CreateLoadout()
	end

	self:Apply()
end

hook.Add("InitPostEntity", "CLoadout_Initialize", function()
	hook.Remove("InitPostEntity", "CLoadout_Initialize")

	timer.Simple(1, function()
		CLoadout:Init()
	end)
end)

concommand.Add("Beatrun_GamemodesMenu", function()
	CLoadout:ShowPanel()
end, nil, "Opens the loadout customization window.")