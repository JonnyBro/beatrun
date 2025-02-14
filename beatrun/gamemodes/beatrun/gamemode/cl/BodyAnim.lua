local playermodelbones = {"ValveBiped.Bip01_R_Clavicle", "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_L_Clavicle", "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_L_Wrist", "ValveBiped.Bip01_R_Wrist", "ValveBiped.Bip01_L_Finger4", "ValveBiped.Bip01_L_Finger41", "ValveBiped.Bip01_L_Finger42", "ValveBiped.Bip01_L_Finger3", "ValveBiped.Bip01_L_Finger31", "ValveBiped.Bip01_L_Finger32", "ValveBiped.Bip01_L_Finger2", "ValveBiped.Bip01_L_Finger21", "ValveBiped.Bip01_L_Finger22", "ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger11", "ValveBiped.Bip01_L_Finger12", "ValveBiped.Bip01_L_Finger0", "ValveBiped.Bip01_L_Finger01", "ValveBiped.Bip01_L_Finger02", "ValveBiped.Bip01_R_Finger4", "ValveBiped.Bip01_R_Finger41", "ValveBiped.Bip01_R_Finger42", "ValveBiped.Bip01_R_Finger3", "ValveBiped.Bip01_R_Finger31", "ValveBiped.Bip01_R_Finger32", "ValveBiped.Bip01_R_Finger2", "ValveBiped.Bip01_R_Finger21", "ValveBiped.Bip01_R_Finger22", "ValveBiped.Bip01_R_Finger1", "ValveBiped.Bip01_R_Finger11", "ValveBiped.Bip01_R_Finger12", "ValveBiped.Bip01_R_Finger0", "ValveBiped.Bip01_R_Finger01", "ValveBiped.Bip01_R_Finger02"}

BodyAnim = BodyAnim or nil
BodyAnimMDL = BodyAnimMDL or nil
BodyAnimMDLarm = BodyAnimMDLarm or nil
BodyAnimWEPMDL = BodyAnimWEPMDL or nil
BodyAnimCycle = 0
BodyAnimEyeAng = Angle(0, 0, 0)
BodyAnimString = "nil"
BodyAnimMDLString = "nil"
BodyAnimSpeed = 1
bodyanimlastattachang = Angle(0, 0, 0)

followplayer = true
deleteonend = true
lockang = false

CamAddAng = false
CamIgnoreAng = false

local tools = {
	["gmod_tool"] = true,
	["weapon_physgun"] = true,
	["gmod_camera"] = true
}

has_tool_equipped = false

hook.Add("Think", "beatrun_detect_tool", function()
	local lp = LocalPlayer()
	if not IsValid(lp) then return end

	local weapon = lp:GetActiveWeapon()
	if not IsValid(weapon) then return end

	local class = weapon:GetClass()

	if tools[class] then
		has_tool_equipped = true
	else
		has_tool_equipped = false
	end
end)

local AnimString = "nil"
local savedeyeangb = Angle(0, 0, 0)

local animmodelstring = ""
local showweapon = false
local showvm = false
local usefullbody = false
local ignorez = false
local customcycle = false

deathanim = false

local allowmove = false
local allowedangchange = false
local attach, attachId, weapontoidle = nil, nil, nil
local smoothend = false
local endlerp = 0

camoffset = Vector()
camjoint = "eyes"

BodyAnimCrouchLerp = 1
BodyAnimCrouchLerpZ = 0
BodyAnimLimitEase = false

CamShake = false
CamShakeAng = Angle()
CamShakeMult = 1

local lastangy = 0

viewtiltlerp = Angle()
ViewTiltAngle = Angle()

local BodyAnimStartPos = Vector()
local view = {}
local justremoved = false

function RemoveBodyAnim(noang)
	local shouldremove = hook.Run("BodyAnimPreRemove")

	if shouldremove then return end

	local ply = LocalPlayer()
	local newang = ply:EyeAngles()
	local noang = noang or false

	if allowedangchange then
		newang = view.angles
	else
		newang = BodyAnimEyeAng
	end

	newang.z = 0

	if IsValid(BodyAnim) then
		hook.Run("BodyAnimRemove")
		BodyAnim:SetNoDraw(true)

		if IsValid(BodyAnimMDL) then
			BodyAnimMDL:SetRenderMode(RENDERMODE_NONE)

			if BodyAnimMDL.callback ~= nil then
				BodyAnimMDL:RemoveCallback("BuildBonePositions", BodyAnimMDL.callback)
			end

			BodyAnimMDL:Remove()
		end

		if IsValid(BodyAnimMDLarm) then
			BodyAnimMDLarm:Remove()
		end

		if IsValid(BodyAnimWEPMDL) then
			BodyAnimWEPMDL:Remove()
		end

		if not noang then
			ply:SetEyeAngles(newang)
		end

		if not smoothend then
			endlerp = 1
		end

		BodyAnim:Remove()
		justremoved = true
		ply:DrawViewModel(true)
		DidDraw = false
	end

	local currentwep = ply:GetActiveWeapon()
	local vm = ply:GetViewModel()

	if ply:Alive() and not ply:UsingRH() then
		if currentwep.PlayViewModelAnimation then
			currentwep:PlayViewModelAnimation("Draw")
		else
			weapontoidle = currentwep
			currentwep:SendWeaponAnim(ACT_VM_DRAW)

			timer.Simple(vm:SequenceDuration(vm:SelectWeightedSequence(ACT_VM_DRAW)), function()
				if ply:GetActiveWeapon() == weapontoidle and weapontoidle:GetSequenceActivityName(weapontoidle:GetSequence()) == "ACT_VM_DRAW" then
					weapontoidle:GetSequenceActivityName(weapontoidle:GetSequence())
					weapontoidle:SendWeaponAnim(ACT_VM_IDLE)
				end
			end)
		end
	end
end

cachebody = {}
matrixfrom = {}
local transitionlerp = 0
local transition = false
local matrixto = {}
local scalevec = Vector(1, 1, 1)
local matrixfrompos = Vector()

armbones = {
	["ValveBiped.Bip01_L_Finger0"] = true,
	["ValveBiped.Bip01_L_Finger02"] = true,
	["ValveBiped.Bip01_R_Finger3"] = true,
	["ValveBiped.Bip01_L_Finger42"] = true,
	["ValveBiped.Bip01_L_Finger32"] = true,
	["ValveBiped.Bip01_L_Finger41"] = true,
	["ValveBiped.Bip01_R_UpperArm"] = true,
	["ValveBiped.Bip01_L_Hand"] = true,
	["ValveBiped.Bip01_R_Finger4"] = true,
	["ValveBiped.Bip01_L_Finger4"] = true,
	["ValveBiped.Bip01_L_UpperArm"] = true,
	["ValveBiped.Bip01_R_Wrist"] = true,
	["ValveBiped.Bip01_L_Clavicle"] = true,
	["ValveBiped.Bip01_L_Forearm"] = true,
	["ValveBiped.Bip01_L_Finger1"] = true,
	["ValveBiped.Bip01_R_Finger41"] = true,
	["ValveBiped.Bip01_R_Hand"] = true,
	["ValveBiped.Bip01_L_Finger3"] = true,
	["ValveBiped.Bip01_R_Ulna"] = true,
	["ValveBiped.Bip01_L_Finger31"] = true,
	["ValveBiped.Bip01_L_Finger2"] = true,
	["ValveBiped.Bip01_R_Finger42"] = true,
	["ValveBiped.Bip01_R_Finger32"] = true,
	["ValveBiped.Bip01_L_Wrist"] = true,
	["ValveBiped.Bip01_R_Finger2"] = true,
	["ValveBiped.Bip01_R_Finger21"] = true,
	["ValveBiped.Bip01_R_Finger22"] = true,
	["ValveBiped.Bip01_R_Finger1"] = true,
	["ValveBiped.Bip01_L_Finger11"] = true,
	["ValveBiped.Bip01_R_Finger11"] = true,
	["ValveBiped.Bip01_R_Finger12"] = true,
	["ValveBiped.Bip01_R_Finger0"] = true,
	["ValveBiped.Bip01_R_Finger01"] = true,
	["ValveBiped.Bip01_L_Ulna"] = true,
	["ValveBiped.Bip01_L_Finger12"] = true,
	["ValveBiped.Bip01_R_Finger02"] = true,
	["ValveBiped.Bip01_R_Forearm"] = true,
	["ValveBiped.Bip01_L_Finger21"] = true,
	["ValveBiped.Bip01_L_Finger22"] = true,
	["ValveBiped.Bip01_L_Finger01"] = true,
	["ValveBiped.Bip01_R_Clavicle"] = true,
	["ValveBiped.Bip01_R_Finger31"] = true
}

function CacheBodyAnim()
	if not IsValid(BodyAnim) then return end

	local pos = LocalPlayer():GetPos()

	BodyAnim:SetupBones()
	matrixfrompos:Set(LocalPlayer():GetPos())

	for i = 0, BodyAnim:GetBoneCount() - 1 do
		local m = BodyAnim:GetBoneMatrix(i)
		m:SetTranslation(m:GetTranslation() - pos)
		cachebody[i] = m
	end

	matrixto = {}
	transition = true
	transitionlerp = 0
end

function CacheLerpBodyAnim()
	if not LocalPlayer():Alive() then
		transition = false

		return
	end

	if transition and transitionlerp < 1 then
		BodyAnim:SetupBones()
		BodyAnimMDL:SetNoDraw(true)

		local pos = LocalPlayer():GetPos()
		local this = BodyAnim
		this.m = this.m or Matrix()

		local from = matrixfrom
		local to = matrixto

		for bone = 0, this:GetBoneCount() - 1 do
			if not armbones[BodyAnim:GetBoneName(bone)] then
				if not to[bone] then
					to[bone] = {{}, {}, {}}
				end

				local ModelBoneMatrix = BodyAnim:GetBoneMatrix(bone)
				ModelBoneMatrix:SetTranslation(ModelBoneMatrix:GetTranslation())

				from[bone] = cachebody[bone]:FastToTable(from[bone]) or from[bone]
				to[bone] = to[bone] or ModelBoneMatrix:FastToTable(to[bone])

				local bonematrix = this:GetBoneMatrix(bone)
				bonematrix:SetTranslation(bonematrix:GetTranslation() - pos)

				to[bone] = bonematrix:FastToTable(to[bone])

				for i = 1, 3 do
					local from = from[bone][i]
					local v = to[bone][i]

					v[1] = LerpL(transitionlerp, from[1], v[1])
					v[2] = LerpL(transitionlerp, from[2], v[2])
					v[3] = LerpL(transitionlerp, from[3], v[3])
					v[4] = LerpL(transitionlerp, from[4], v[4])
				end

				if not this.m then
					this.m = Matrix(to[bone])
				else
					local bt = to[bone]
					local bt1 = bt[1]
					local bt2 = bt[2]
					local bt3 = bt[3]
					slot15 = bt[4]

					this.m:SetUnpacked(bt1[1], bt1[2], bt1[3], bt1[4], bt2[1], bt2[2], bt2[3], bt2[4], bt3[1], bt3[2], bt3[3], bt3[4], 0, 0, 0, 1)
				end

				this.m:SetTranslation(this.m:GetTranslation() + pos)
				this.m:SetScale(scalevec)
				this:SetBoneMatrix(bone, this.m)
			end
		end

		transitionlerp = math.min(transitionlerp + FrameTime() * 4, 1)
	elseif transition and transitionlerp >= 1 then
		BodyAnimMDL:SetNoDraw(false)
	end
end

function StartBodyAnim(animtable)
	local prestart = hook.Run("BodyAnimPreStart", animtable)

	if prestart then return end

	if IsValid(BodyAnim) and not justremoved then return end

	justremoved = false
	local ply = LocalPlayer()

	if ply:InVehicle() then return end

	animmodelstring = animtable.animmodelstring
	AnimString = animtable.AnimString
	BodyAnimString = AnimString
	BodyAnimSpeed = animtable.BodyAnimSpeed or 1
	BodyAnimMDLString = animmodelstring
	BodyLimitX = animtable.BodyLimitX or 30
	BodyLimitY = animtable.BodyLimitY or 50
	CamIgnoreAng = animtable.CamIgnoreAng or false
	smoothend = animtable.smoothend or false
	camjoint = animtable.camjoint or "eyes"
	usefullbody = animtable.usefullbody or 2
	deleteonend = animtable.deleteonend
	followplayer = animtable.followplayer or false
	lockang = animtable.lockang or false
	allowmove = animtable.allowmove or false
	ignorez = animtable.ignorez or false
	deathanim = animtable.deathanim or false
	customcycle = animtable.customcycle or false
	showweapon = animtable.showweapon or false
	showvm = animtable.showvm or false

	ply.OrigEyeAng = ply:EyeAngles()
	ply.OrigEyeAng.x = 0

	if VMLegs and VMLegs:IsActive() then
		VMLegs:Remove()
	end

	if deleteonend == nil then
		deleteonend = true
	end

	if followplayer == nil then
		followplayer = true
	end

	hook.Add("CalcView", "BodyAnimCalcView2", BodyAnimCalcView2)
	BodyAnimAngLerp = ply:EyeAngles()

	if AnimString == nil or not ply:Alive() and not deathanim then return end

	savedeyeangb = Angle(0, 0, 0)
	BodyAnim = ClientsideModel("models/" .. tostring(animmodelstring) .. ".mdl", RENDERGROUP_BOTH)
	BodyAnim:SetAngles(Angle(0, ply:EyeAngles().y, 0))
	BodyAnim:SetPos(ply:GetPos())
	BodyAnim:SetNoDraw(false)

	if not IsValid(ply:GetHands()) then return end

	local plymodel = ply
	local playermodel = ply:GetModel()
	local handsmodel = ply:GetHands():GetModel()

	if usefullbody == 2 then
		BodyAnimMDL = ClientsideModel(playermodel, RENDERGROUP_BOTH)

		function BodyAnimMDL.GetPlayerColor()
			return LocalPlayer():GetPlayerColor()
		end

		BodyAnimMDL:SnatchModelInstance(ply)
		BodyAnimMDLarm = ClientsideModel(handsmodel, RENDERGROUP_BOTH)

		function BodyAnimMDLarm.GetPlayerColor()
			return LocalPlayer():GetPlayerColor()
		end

		BodyAnimMDLarm:SetLocalPos(Vector(0, 0, 0))
		BodyAnimMDLarm:SetLocalAngles(Angle(0, 0, 0))
		BodyAnimMDLarm:SetParent(BodyAnim)
		BodyAnimMDLarm:AddEffects(EF_BONEMERGE)

		for num, _ in pairs(ply:GetHands():GetBodyGroups()) do
			BodyAnimMDLarm:SetBodygroup(num - 1, ply:GetHands():GetBodygroup(num - 1))
			BodyAnimMDLarm:SetSkin(ply:GetHands():GetSkin())
		end

		for _, v in ipairs(playermodelbones) do
			local plybone = BodyAnimMDL:LookupBone(v)

			if plybone then
				BodyAnimMDL:ManipulateBoneScale(plybone, vector_origin)
			end
		end

		if not ply:ShouldDrawLocalPlayer() then
			local head = BodyAnim:LookupBone("ValveBiped.Bip01_Head1")

			if head then
				BodyAnim:ManipulateBoneScale(head, vector_origin)
			end
		end
	elseif usefullbody == 1 then
		BodyAnimMDL = ClientsideModel(playermodel, RENDERGROUP_BOTH)
	else
		BodyAnimMDL = ClientsideModel(string.Replace(handsmodel, "models/models/", "models/"), RENDERGROUP_BOTH)

		function BodyAnimMDL.GetPlayerColor()
			return LocalPlayer():GetPlayerColor()
		end

		plymodel = ply:GetHands()
	end

	for num, _ in pairs(plymodel:GetBodyGroups()) do
		BodyAnimMDL:SetBodygroup(num - 1, plymodel:GetBodygroup(num - 1))
		BodyAnimMDL:SetSkin(plymodel:GetSkin())
	end

	BodyAnimMDL:SetLocalPos(Vector(0, 0, 0))
	BodyAnimMDL:SetLocalAngles(Angle(0, 0, 0))
	BodyAnimMDL:SetParent(BodyAnim)
	BodyAnimMDL:AddEffects(EF_BONEMERGE)
	BodyAnim:SetSequence(AnimString)

	if tobool(showweapon) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetModel() ~= "" then
		BodyAnimWEPMDL = ClientsideModel(ply:GetActiveWeapon():GetModel(), RENDERGROUP_BOTH)
		BodyAnimWEPMDL:SetPos(ply:GetPos())
		BodyAnimWEPMDL:SetAngles(Angle(0, EyeAngles().y, 0))
		BodyAnimWEPMDL:SetParent(BodyAnim)
		BodyAnimWEPMDL:AddEffects(EF_BONEMERGE)
	end

	if BodyAnimMDL:LookupBone("ValveBiped.Bip01_Head1") ~= nil and not ply:ShouldDrawLocalPlayer() then
		BodyAnimMDL:ManipulateBoneScale(BodyAnimMDL:LookupBone("ValveBiped.Bip01_Head1"), Vector(0, 0, 0))
	end

	if not showvm then
		ply:DrawViewModel(false)
	end

	BodyAnimCycle = 0
	DidDraw = false
	angclosenuff = false

	hook.Run("BodyAnimStart")
end

hook.Add("Think", "BodyAnimThink", function()
	if not IsValid(BodyAnim) then return end

	local ply = LocalPlayer()

	if not ply:Alive() and not deathanim then
		RemoveBodyAnim()

		return
	end

	BodyAnimCycle = BodyAnimCycle + FrameTime() / BodyAnim:SequenceDuration() * BodyAnimSpeed

	if not customcycle then
		BodyAnim:SetCycle(BodyAnimCycle)
	end

	hook.Run("BodyAnimThink")

	if deleteonend and not customcycle and BodyAnimCycle >= 1 then
		RemoveBodyAnim()
	end
end)

local BodyAnimPosEase = Vector()
local BodyAnimPosEaseLerp = 1

function BodyAnimSetEase(pos)
	BodyAnimPosEase:Set(pos)
	BodyAnimPosEaseLerp = 0
end

local lastattachpos = Vector(0, 0, 0)
local lastatt, savedatt = nil, nil
local lerpchangeatt = 1
local lastattdata = nil
local lerpedpos = Vector()
local lastlockang = false
local lastlockangstart = Angle()
local lasteyeang = Angle()
local updatethirdperson = true

function BodyAnimCalcView2(ply, pos, angles, fov)
	if ply:InVehicle() then
		RemoveBodyAnim()

		return
	end

	if has_tool_equipped and IsValid(BodyAnim) then
		BodyAnim:SetNoDraw(true)
		BodyAnim:SetRenderOrigin(pos * 1000)

		return
	end

	if IsValid(BodyAnim) and pos:Distance(ply:EyePos()) > 20 then
		if updatethirdperson then
			ply:SetNoDraw(false)
			BodyAnim:SetNoDraw(true)
			BodyAnim:SetRenderOrigin(pos * 1000)
			updatethirdperson = false
		end

		return
	else
		updatethirdperson = true
	end

	if IsValid(BodyAnim) or attach ~= nil then
		if IsValid(BodyAnim) then
			if followplayer then
				local pos = ply:GetPos()

				if BodyAnimCrouchLerp < 1 and (BodyAnimCrouchLerp ~= 0 or math.abs(BodyAnimCrouchLerpZ - pos.z) > 16 or math.abs(ply:GetNW2Float("BodyAnimCrouchLerpZ") - pos.z) > 16) then
					if ply:OnGround() then
						BodyAnimCrouchLerp = 1
					end

					if ply:Crouching() then
						local from = BodyAnimCrouchLerpZ

						if ply:UsingRH() then
							from = ply:EyePos().z - 64
						end

						pos.z = Lerp(BodyAnimCrouchLerp, from, pos.z)
						BodyAnimCrouchLerp = math.Approach(BodyAnimCrouchLerp, 1, FrameTime() * 5)
					end
				end

				if BodyAnimPosEaseLerp < 1 then
					local easedpos = LerpVector(BodyAnimPosEaseLerp, BodyAnimPosEase, pos)
					BodyAnimPosEaseLerp = math.Approach(BodyAnimPosEaseLerp, 1, FrameTime() * 5)
					BodyAnim:SetPos(easedpos)
					BodyAnim:SetRenderOrigin(easedpos)
				else
					BodyAnim:SetPos(pos)
					BodyAnim:SetRenderOrigin(pos)
				end
			elseif BodyAnimPosEaseLerp < 1 then
				local easedpos = LerpVector(BodyAnimPosEaseLerp, BodyAnimPosEase, BodyAnimStartPos)
				BodyAnimPosEaseLerp = math.Approach(BodyAnimPosEaseLerp, 1, FrameTime() * 5)

				BodyAnim:SetPos(easedpos)
				BodyAnim:SetRenderOrigin(easedpos)
			end

			local oldang = BodyAnim:GetAngles()
			local eyeang = ply:EyeAngles()
			eyeang.x = 0
			eyeang.z = 0

			if CamIgnoreAng then
				BodyAnim:SetAngles(eyeang)
			end

			if lastatt and lastatt ~= camjoint then
				savedatt = lastatt
				lerpchangeatt = 0
			end

			local head = BodyAnim:LookupBone("ValveBiped.Bip01_Head1")

			if head then
				BodyAnim:ManipulateBonePosition(head, vector_origin)
			end

			attachId = BodyAnim:LookupAttachment(camjoint)
			attach = BodyAnim:GetAttachment(attachId) or attach

			if lerpchangeatt < 1 then
				local attachId = BodyAnim:LookupAttachment(savedatt)

				lastattdata = BodyAnim:GetAttachment(attachId) or attach
				lerpedpos = LerpVector(lerpchangeatt, lastattdata.Pos, attach.Pos)
				lerpchangeatt = math.Approach(lerpchangeatt, 1, FrameTime() * 5)
			end

			if not ply:ShouldDrawLocalPlayer() then
				local head = BodyAnim:LookupBone("ValveBiped.Bip01_Head1")

				if head then
					BodyAnim:ManipulateBonePosition(head, Vector(-1000, 0, 0))
				end
			end

			BodyAnim:SetAngles(oldang)
		end

		if attach ~= nil then
			view.origin = has_tool_equipped and pos or attach.Pos

			if savedeyeangb == Angle(0, 0, 0) then
				savedeyeangb = Angle(0, attach.Ang.y, 0)
			end

			view.angles = ply:EyeAngles()

			if lockang2 and not has_tool_equipped then
				view.angles = has_tool_equipped and angles or attach.Ang
				view.angles.x = ply:EyeAngles().x
				view.origin = has_tool_equipped and pos or attach.Pos
			end

			allowedangchange = true

			if lockang ~= lastlockang then
				lerplockang = 0
				lastlockang = lockang

				lastlockangstart:Set(lasteyeang)
			end

			if ply:Alive() and (lockang and not has_tool_equipped) then
				local attachId = BodyAnim:LookupAttachment(camjoint)
				local attach = BodyAnim:GetAttachment(attachId) or attach
				local ang = attach.Ang

				if lerplockang < 1 then
					ang = LerpAngle(lerplockang, lastlockangstart, attach.Ang)
					lerplockang = math.Approach(lerplockang, 1, FrameTime() * 4.5)
				end

				view.angles = has_tool_equipped and angles or ang
				view.angles:Add(ViewTiltAngle)
				allowedangchange = false

				local neweyeang = Angle(view.angles)
				neweyeang.y = BodyAnim:GetAngles().y
				neweyeang.z = 0

				ply:SetEyeAngles(neweyeang)
			end

			lasteyeang:Set(ply:EyeAngles())

			local vm = ply:GetViewModel()

			BodyAnimEyeAng = attach.Ang
			BodyAnimPos = attach.Pos
			lastattachpos = attach.Pos
			bodyanimlastattachang = ply:EyeAngles()
			view.pos = attach.Pos

			if not IsValid(BodyAnim) and endlerp < 1 then
				endlerp = math.Approach(endlerp, 1, RealFrameTime() * 6)
				attach.Pos = LerpVector(endlerp, attach.Pos, ply:EyePos())
				attach.Ang = LerpAngle(endlerp * 2, attach.Ang, ply:EyeAngles() + ply:GetViewPunchAngles() + ply:GetCLViewPunchAngles())

				if IsValid(vm) then
					vm:SetNoDraw(false)
				end
			elseif not IsValid(BodyAnim) and endlerp == 1 then
				attach = nil
				endlerp = 0
				hook.Remove("CalcView", "BodyAnimCalcView2")

				if IsValid(vm) then
					vm:SetNoDraw(false)
				end

				return
			end

			if not ply:ShouldDrawLocalPlayer() and not ply:InVehicle() then
				local ang = Vector(view.angles:Unpack())
				ang[1] = 0
				ang[3] = 0

				local MEAng = ang.y
				local target = not lockang and MEAng or ply.OrigEyeAng.y

				viewtiltlerp.y = math.ApproachAngle(viewtiltlerp.y, target, FrameTime() * (1 + math.abs(math.AngleDifference(viewtiltlerp.y, target)) * 5))

				local MEAngDiff = math.AngleDifference(viewtiltlerp.y, not lockang and lastangy or ply.OrigEyeAng.y) * 0.15

				ViewTiltAngle = Angle(0, 0, MEAngDiff + viewtiltlerp.z)

				view.angles:Add(ViewTiltAngle)

				ply:SetNoDraw(false)

				view.angles:Add(ply:GetViewPunchAngles() + ply:GetCLViewPunchAngles())

				hook.Run("BodyAnimCalcView", view)

				pos:Set(view.origin)

				if not has_tool_equipped then
					angles:Set(view.angles)
				end

				if lerpchangeatt < 1 then
					pos:Set(lerpedpos)
				end

				camang = angles
				campos = pos
				lastatt = camjoint

				if CamShake then
					CamShakeAng:Set(AngleRand() * 0.005 * CamShakeMult)
					angles:Add(CamShakeAng)
				end

				lastangy = ang.y
				hook.Run("CalcViewBA", ply, pos, angles)

				return
			else
				ply:SetNoDraw(true)
			end
		end

		if attach == nil or CurTime() < (mantletimer or 0) then
			view.origin = has_tool_equipped and pos or lastattachpos
			pos:Set(lastattachpos)

			return
		end
	end
end

hook.Add("CreateMove", "BodyLimitMove", function(cmd)
	if IsValid(BodyAnimMDL) and not allowmove then
		cmd:ClearButtons()
		cmd:ClearMovement()
	end
end)

hook.Add("PostDrawOpaqueRenderables", "IgnoreZBodyAnim", function(depth, sky)
	if IsValid(BodyAnimMDL) then
		CacheLerpBodyAnim()

		if ignorez then
			cam.IgnoreZ(true)
			BodyAnimMDL:DrawModel()
			local customarmdraw = hook.Run("BodyAnimDrawArm")

			if not customarmdraw and IsValid(BodyAnimMDLarm) then
				BodyAnimMDLarm:DrawModel()
			end

			cam.IgnoreZ(false)
		end
	end
end)

-- local lasteyeang = Angle()
local lastlimitx = 0
local lastlimity = 0
local pastlimitx = false
local pastlimity = false

hook.Add("CreateMove", "BodyAnim_Mouse", function(cmd)
	local ply = LocalPlayer()

	if not lockang and IsValid(BodyAnim) then
		local nang = cmd:GetViewAngles()
		local oang = ply.OrigEyeAng
		local limitx = BodyLimitX or 30
		local limity = BodyLimitY or 50

		pastlimitx = limitx < math.AngleDifference(nang.x, oang.x) and not has_tool_equipped
		pastlimity = limity < math.abs(math.AngleDifference(nang.y, oang.y)) and not has_tool_equipped

		if limitx ~= lastlimitx and pastlimitx or limity ~= lastlimity and pastlimity then
			BodyAnimLimitEase = true
		end

		if pastlimitx then
			local ang = nang

			if BodyAnimLimitEase then
				ply:CLViewPunch(Angle(-0.2, 0, 0))
				ang.x = math.Approach(ang.x, oang.x + limitx, FrameTime() * 125)
			else
				ang.x = oang.x + limitx
			end

			cmd:SetViewAngles(ang)
		elseif not pastlimity then
			BodyAnimLimitEase = false
		end

		if pastlimity then
			local ang = ply:EyeAngles()

			if math.AngleDifference(nang.y, oang.y) < 0 then
				if BodyAnimLimitEase then
					ang.y = math.ApproachAngle(ang.y, oang.y - limity, FrameTime() * 300)
				else
					ang.y = oang.y - limity
				end
			elseif BodyAnimLimitEase then
				ang.y = math.ApproachAngle(ang.y, oang.y + limity, FrameTime() * 300)
			else
				ang.y = oang.y + limity
			end

			cmd:SetViewAngles(ang)
		elseif not pastlimitx then
			BodyAnimLimitEase = false
		end

		lasteyeang = nang
		lastlimity = BodyLimitY
		lastlimitx = BodyLimitX
	end
end)

hook.Add("InputMouseApply", "BodyAnim_Mouse", function(cmd)
	local newvalues = false

	if lockang and not has_tool_equipped then
		cmd:SetMouseX(0)
		cmd:SetMouseY(0)

		return true
	end

	if pastlimitx then
		cmd:SetMouseY(0)
		newvalues = true
	end

	if pastlimity then
		cmd:SetMouseX(0)
		newvalues = true
	end

	if newvalues then return true end
end)