local valvebiped = {"ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Head1", "ValveBiped.forward", "ValveBiped.Bip01_R_Clavicle", "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_Hand", "ValveBiped.Anim_Attachment_RH", "ValveBiped.Bip01_R_Finger4", "ValveBiped.Bip01_R_Finger41", "ValveBiped.Bip01_R_Finger42", "ValveBiped.Bip01_R_Finger3", "ValveBiped.Bip01_R_Finger31", "ValveBiped.Bip01_R_Finger32", "ValveBiped.Bip01_R_Finger2", "ValveBiped.Bip01_R_Finger21", "ValveBiped.Bip01_R_Finger22", "ValveBiped.Bip01_R_Finger1", "ValveBiped.Bip01_R_Finger11", "ValveBiped.Bip01_R_Finger12", "ValveBiped.Bip01_R_Finger0", "ValveBiped.Bip01_R_Finger01", "ValveBiped.Bip01_R_Finger02", "ValveBiped.Bip01_R_Ulna", "ValveBiped.Bip01_R_Wrist", "ValveBiped.Bip01_R_Elbow", "ValveBiped.Bip01_R_Bicep", "ValveBiped.Bip01_R_Shoulder", "ValveBiped.Bip01_R_Trapezius", "ValveBiped.Bip01_L_Clavicle", "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand", "ValveBiped.Anim_Attachment_LH", "ValveBiped.Bip01_L_Finger4", "ValveBiped.Bip01_L_Finger41", "ValveBiped.Bip01_L_Finger42", "ValveBiped.Bip01_L_Finger3", "ValveBiped.Bip01_L_Finger31", "ValveBiped.Bip01_L_Finger32", "ValveBiped.Bip01_L_Finger2", "ValveBiped.Bip01_L_Finger21", "ValveBiped.Bip01_L_Finger22", "ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger11", "ValveBiped.Bip01_L_Finger12", "ValveBiped.Bip01_L_Finger0", "ValveBiped.Bip01_L_Finger01", "ValveBiped.Bip01_L_Finger02", "ValveBiped.Bip01_L_Ulna", "ValveBiped.Bip01_L_Wrist", "ValveBiped.Bip01_L_Elbow", "ValveBiped.Bip01_L_Bicep", "ValveBiped.Bip01_L_Shoulder", "ValveBiped.Bip01_L_Trapezius", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_Foot", "ValveBiped.Bip01_R_Toe0", "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_L_Foot", "ValveBiped.Bip01_L_Toe0", "ValveBiped.Bip01_L_Pectoral", "ValveBiped.Bip01_R_Pectoral", "ValveBiped.Cod", "j_ringpalm_L", "j_pinkypalm_L", "j_ringpalm_ri", "j_pinkypalm_ri"}

local scalevec = Vector(1, 1, 1)

local function Disarm_Render(self)
	if not IsValid(self) or not IsValid(self.ModelBM) or not IsValid(self.Victim) then return end

	local owner = self.Victim

	self:SetupBones()
	self.ModelBM:SetupBones()
	owner:SetupBones()

	if owner.DisarmNoDraw then
		owner:SetNoDraw(true)
	end

	for k, v in ipairs(valvebiped) do
		local lookbone = self.ModelBM:LookupBone(valvebiped[k])

		if lookbone then
			self.GhostMatrix = self.ModelBM:GetBoneMatrix(lookbone)
			local ModelBone = owner:LookupBone(v)
			local GhostBone = self.ModelBM:LookupBone(v)

			if GhostBone ~= nil and ModelBone ~= nil then
				local ModelBoneMatrix = nil
				ModelBoneMatrix = owner:GetBoneMatrix(ModelBone)

				if ModelBoneMatrix ~= nil then
					self.bonematrixtablefrom[lookbone] = self.GhostMatrix:FastToTable(self.bonematrixtablefrom[lookbone]) or self.bonematrixtablefrom[lookbone]
					self.bonematrixtableto[lookbone] = self.bonematrixtableto[lookbone] or ModelBoneMatrix:FastToTable(self.bonematrixtableto[lookbone])
					local blerpvalue = self.bonelerpvalue

					for i = 1, 3 do
						local from = self.bonematrixtablefrom[lookbone][i]
						local v = self.bonematrixtableto[lookbone][i]

						v[1] = LerpL(blerpvalue, v[1], from[1])
						v[2] = LerpL(blerpvalue, v[2], from[2])
						v[3] = LerpL(blerpvalue, v[3], from[3])
						v[4] = LerpL(blerpvalue, v[4], from[4])
					end

					if not self.m then
						self.m = Matrix(self.bonematrixtableto[lookbone])
					else
						local bt = self.bonematrixtableto[lookbone]
						local bt1 = bt[1]
						local bt2 = bt[2]
						local bt3 = bt[3]
						slot16 = bt[4]

						self.m:SetUnpacked(bt1[1], bt1[2], bt1[3], bt1[4], bt2[1], bt2[2], bt2[3], bt2[4], bt3[1], bt3[2], bt3[3], bt3[4], 0, 0, 0, 1)
					end

					self.m:SetScale(scalevec)
					self.ModelBM:SetBoneMatrix(GhostBone, self.m)
				end
			end
		end
	end

	local cycle = self:GetCycle()

	if cycle then
		self.bonelerpvalue = math.Clamp(self.bonelerpvalue + FrameTime() * (0.1 + self:GetCycle() * 2), 0, 1)
	end
end

function Disarm_CleanUp()
	local ply = LocalPlayer()

	if ply.DisarmVictim then
		ply.DisarmVictim:Remove()
	end

	if ply.DisarmVictimMDL then
		ply.DisarmVictimMDL:Remove()
	end

	hook.Remove("Think", "Disarm_Think")
end

function Disarm_Think()
	local ba = IsValid(BodyAnim)

	if ba then
		local victimanim = LocalPlayer().DisarmVictim

		victimanim:SetPos(BodyAnim:GetPos())
		victimanim:SetAngles(BodyAnim:GetAngles())
		victimanim:SetCycle(BodyAnimCycle)
	end

	if not ba or BodyAnimCycle >= 1 then
		Disarm_CleanUp()
	end
end

function Disarm_BlockMove(cmd)
	cmd:SetForwardMove(0)
	cmd:SetSideMove(0)
	cmd:SetUpMove(0)
	cmd:SetButtons(0)

	if BodyAnimCycle > 0 and not lockang or not LocalPlayer():Alive() or LocalPlayer().DisarmForcedEnd < CurTime() then
		hook.Remove("CreateMove", "Disarm_BlockMove")
	end
end

function Disarm_Init(victim)
	if not IsValid(victim) then return end

	local ply = LocalPlayer()
	Disarm_CleanUp()

	local eyeang = ply:EyeAngles()
	eyeang.x = 0
	eyeang.z = 0

	ParkourEvent("disarmscar", ply, true)

	ply.OrigEyeAng = eyeang
	BodyAnim:SetAngles(eyeang)

	victim.InDisarm = true

	ply.DisarmForcedEnd = CurTime() + 4
	ply.DisarmVictim = ClientsideModel("models/disarmvictim.mdl")
	ply.DisarmVictimMDL = ClientsideModel(victim:GetModel())

	local victimanim = ply.DisarmVictim
	local victimMDL = ply.DisarmVictimMDL

	victimanim.bonelerpvalue = 0
	victimanim:SetSequence("snatchscar")
	victimanim.ModelBM = victimMDL
	victimanim.bonematrixtablefrom = {}
	victimanim.bonematrixtableto = {}
	victimanim.Victim = victim

	victimMDL:SetParent(victimanim)
	victimMDL:AddEffects(EF_BONEMERGE)
	victimMDL:SnatchModelInstance(victim)
	victimMDL:SetSkin(victim:GetSkin() or 0)

	for i = 0, victimMDL:GetNumBodyGroups() do
		local bodyg = victim:GetBodygroup(i)

		victimMDL:SetBodygroup(i, bodyg)
	end

	hook.Add("Think", "Disarm_Think", Disarm_Think)
	hook.Add("CreateMove", "Disarm_BlockMove", Disarm_BlockMove)
	victimanim.RenderOverride = Disarm_Render

	timer.Simple(0.001, function()
		victim.DisarmNoDraw = true
		victim:SetNoDraw(true)
	end)
end

net.Receive("DisarmStart", function()
	Disarm_Init(net.ReadEntity())
end)

hook.Add("CreateClientsideRagdoll", "Disarm_Ragdoll", function(ent, oldrag)
	if ent.InDisarm then
		local ply = LocalPlayer()
		local victimanim = ply.DisarmVictim
		local rag = ClientsideRagdoll(ent:GetModel())

		rag:SetNoDraw(false)
		rag:SetRenderMode(RENDERMODE_NORMAL)
		rag:DrawShadow(true)
		rag:SnatchModelInstance(oldrag)
		rag:SetSkin(oldrag:GetSkin() or 0)

		for i = 0, rag:GetNumBodyGroups() do
			local bodyg = oldrag:GetBodygroup(i)
			rag:SetBodygroup(i, bodyg)
		end

		-- local vel = Vector()
		local num = rag:GetPhysicsObjectCount() - 1

		for i = 0, num do
			local bone = rag:GetPhysicsObjectNum(i)

			if IsValid(bone) then
				local lookup = victimanim:LookupBone(rag:GetBoneName(rag:TranslatePhysBoneToBone(i)))

				if lookup then
					local bp, ba = victimanim:GetBonePosition(lookup)

					if bp and ba then
						bone:SetPos(bp)
						bone:SetAngles(ba)
					end
				end
			end
		end

		oldrag:Remove()

		timer.Simple(30, function()
			if IsValid(rag) then
				rag:SetSaveValue("m_bFadingOut", true)
			end
		end)

		timer.Simple(0, function()
			Disarm_CleanUp()
		end)
	end
end)