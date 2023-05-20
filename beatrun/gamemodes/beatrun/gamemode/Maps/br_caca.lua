function CreateRopes()
	local ents = ents.GetAll()

	for k, v in pairs(ents) do
		if v:GetClass() == "move_rope" then
			local endpoint = v:GetInternalVariable("m_hEndPoint")

			if IsValid(endpoint) then
				local zipline = CreateZipline(v:GetPos(), endpoint:GetPos())
				zipline:SetNW2Bool("BRProtected", true)
			end
		end
	end

	for k, v in pairs(ents) do
		if v:GetClass():find("rope") then
			v:Remove()
		end
	end

	hook.Remove("InitPostEntity", "CreateRopes")
end

hook.Add("InitPostEntity", "CreateRopes", CreateRopes)
hook.Add("PostCleanupMap", "CreateRopes", CreateRopes)