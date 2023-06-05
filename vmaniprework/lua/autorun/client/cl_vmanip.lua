--[[N++ Protip: View > Collapse Level 1
More detail on stuff in lua/vmanip/vmanip_baseanims.lua

Please keep in mind that you do not fire events *through vmanip*. Think of it as a fully
clientside animation system. So instead, you request to play an anim, and if the request
went through (true return value), you do your thing

You probably don't need to snoop around this file, but feel free
]]
VManip = {}
VMLegs = {}
local curtime = 0

--Non linear lerping
local function LerpC(t, a, b, powa)
	return a + (b - a) * math.pow(t, powa)
end

local properang = Angle(-79.750, 0, -90)

local leftarmbones = {"ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_L_Wrist", "ValveBiped.Bip01_L_Ulna", "ValveBiped.Bip01_L_Finger4", "ValveBiped.Bip01_L_Finger41", "ValveBiped.Bip01_L_Finger42", "ValveBiped.Bip01_L_Finger3", "ValveBiped.Bip01_L_Finger31", "ValveBiped.Bip01_L_Finger32", "ValveBiped.Bip01_L_Finger2", "ValveBiped.Bip01_L_Finger21", "ValveBiped.Bip01_L_Finger22", "ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger11", "ValveBiped.Bip01_L_Finger12", "ValveBiped.Bip01_L_Finger0", "ValveBiped.Bip01_L_Finger01", "ValveBiped.Bip01_L_Finger02"}

local playermodelbonesupper = {"ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Clavicle", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Head1", "ValveBiped.Bip01_L_Finger4", "ValveBiped.Bip01_L_Finger41", "ValveBiped.Bip01_L_Finger42", "ValveBiped.Bip01_L_Finger3", "ValveBiped.Bip01_L_Finger31", "ValveBiped.Bip01_L_Finger32", "ValveBiped.Bip01_L_Finger2", "ValveBiped.Bip01_L_Finger21", "ValveBiped.Bip01_L_Finger22", "ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger11", "ValveBiped.Bip01_L_Finger12", "ValveBiped.Bip01_L_Finger0", "ValveBiped.Bip01_L_Finger01", "ValveBiped.Bip01_L_Finger02", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Clavicle", "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_R_Finger4", "ValveBiped.Bip01_R_Finger41", "ValveBiped.Bip01_R_Finger42", "ValveBiped.Bip01_R_Finger3", "ValveBiped.Bip01_R_Finger31", "ValveBiped.Bip01_R_Finger32", "ValveBiped.Bip01_R_Finger2", "ValveBiped.Bip01_R_Finger21", "ValveBiped.Bip01_R_Finger22", "ValveBiped.Bip01_R_Finger1", "ValveBiped.Bip01_R_Finger11", "ValveBiped.Bip01_R_Finger12", "ValveBiped.Bip01_R_Finger0", "ValveBiped.Bip01_R_Finger01"}

local tableintensity = {1, 1, 1}

VManip.Reset = function()
	VManip.Anims = {}
	VManip.VMGesture = nil
	VManip.AssurePos = false
	VManip.LockToPly = false
	VManip.LockZ = 0
	VManip.VMCam = nil
	VManip.Cam_Ang = properang
	VManip.Cam_AngInt = nil
	VManip.StartCycle = 0
	VManip.Cycle = 0
	VManip.CurGesture = nil
	VManip.CurGestureData = nil
	VManip.GestureMatrix = nil
	VManip.Lerp_Peak = nil
	VManip.Lerp_Speed_In = nil
	VManip.Lerp_Speed_Out = nil
	VManip.Lerp_Curve = nil
	VManip.Duration = 0
	VManip.HoldTime = nil
	VManip.HoldQuit = false
	VManip.PreventQuit = false
	VManip.QueuedAnim = nil
	VManip.Segmented = false
	VManip.SegmentFinished = false
	VManip.CurSegment = nil
	VManip.LastSegment = false
	VManip.SegmentCount = 0
	VManip.CurSegmentSequence = nil
	VManip.GesturePastHold = false
	VManip.GestureOnHold = false
	VManip.Attachment = nil
end

VManip.Remove = function()
	if VManip:IsActive() then
		hook.Run("VManipPreRemove", VManip:GetCurrentAnim())
	end

	if IsValid(VManip.VMGesture) then
		VManip.VMGesture:Remove()
	end

	if IsValid(VManip.VMCam) then
		VManip.VMCam:Remove()
	end

	VManip.VMGesture = nil
	VManip.AssurePos = false
	VManip.LockToPly = false
	VManip.LockZ = 0
	VManip.VMCam = nil
	VManip.Cam_Ang = properang
	VManip.Cam_AngInt = nil
	VManip.Cycle = 0
	VManip.StartCycle = 0
	VManip.Attachment = nil
	VManip.CurGesture = nil
	VManip.CurGestureData = nil
	VManip.GestureMatrix = nil
	VManip.Lerp_Peak = nil
	VManip.Lerp_Speed_In = nil
	VManip.Lerp_Speed_Out = nil
	VManip.Duration = 0
	VManip.HoldTime = nil
	VManip.HoldQuit = false
	VManip.PreventQuit = false
	VManip.QueuedAnim = nil
	VManip.Segmented = false
	VManip.SegmentFinished = false
	VManip.CurSegment = nil
	VManip.LastSegment = false
	VManip.SegmentCount = 0
	VManip.CurSegmentSequence = nil
	VManip.GesturePastHold = false
	VManip.GestureOnHold = false
	hook.Run("VManipRemove")
end

VManip:Reset()

VManip.RegisterAnim = function(self, name, tbl)
	self.Anims[name] = tbl
end

VManip.GetAnim = function(self, name) return self.Anims[name] end
VManip.IsActive = function(self) return IsValid(self.VMGesture) end
VManip.GetVMGesture = function(self) return self.VMGesture end
VManip.GetCurrentAnim = function(self) return self.CurGesture end
VManip.GetCurrentSegment = function(self) return self.CurSegment end
VManip.GetCycle = function(self) return self.Cycle end

VManip.SetCycle = function(self, newcycle)
	self.Cycle = newcycle
end

VManip.IsSegmented = function(self) return self.Segmented end
VManip.GetSegmentCount = function(self) return self.SegmentCount end

local function PlayVMPSound(ent, sound, anim)
	if VManip:GetCurrentAnim() == anim and ent:Alive() then
		ent:EmitSound(sound)
	end
end

local function PlaySoundsInTable(tbl, animname)
	local ply = LocalPlayer()

	for k, v in pairs(tbl) do
		timer.Simple(v, function()
			PlayVMPSound(ply, k, animname)
		end)
	end
end

VManip.PlaySegment = function(self, sequence, lastsegment, soundtable)
	if self:IsActive() and self:IsSegmented() and self.SegmentFinished and not self.LastSegment then
		if self:GetVMGesture():LookupSequence(sequence) ~= -1 then
			if hook.Run("VManipPrePlaySegment", self:GetCurrentAnim(), sequence, lastsegment) == false then return end
			self:GetVMGesture():ResetSequence(sequence)
			VManip.CurSegment = sequence
			self:SetCycle(0)
			VManip.SegmentFinished = false
			self.SegmentCount = self.SegmentCount + 1

			if lastsegment then
				self.LastSegment = true
				VManip.Lerp_Peak = curtime + VManip.CurGestureData["lerp_peak"]
			end

			if soundtable then
				PlaySoundsInTable(soundtable, self:GetCurrentAnim())
			end

			hook.Run("VManipPlaySegment", self:GetCurrentAnim(), sequence, lastsegment)

			return true
		end
	end

	return false
end

VManip.IsPreventQuit = function(self) return self.PreventQuit end

VManip.QuitHolding = function(self, animtostop)
	if self:IsActive() then
		if hook.Run("VManipPreHoldQuit", self:GetCurrentAnim(), animtostop) == false then return end

		if (not animtostop and not VManip:IsPreventQuit()) or self:GetCurrentAnim() == animtostop then
			self.HoldQuit = true

			if self:IsSegmented() then
				self.LastSegment = true
			end

			hook.Run("VManipHoldQuit", self:GetCurrentAnim(), animtostop)
		end

		if self.QueuedAnim == animtostop then
			self.QueuedAnim = nil
		end
	end
end

--For event related animations that you want to make sure will play no matter what
VManip.QueueAnim = function(self, animtoqueue)
	if self:GetAnim(animtoqueue) then
		self.QueuedAnim = animtoqueue
	end
end

VMLegs.Reset = function()
	VMLegs.Anims = {}
	VMLegs.LegParent = nil
	VMLegs.LegModel = nil
	VMLegs.Cycle = 0
	VMLegs.StartCycle = 0
	VMLegs.SeqID = nil
	VMLegs.CurLegs = nil
end

VMLegs.Remove = function()
	if IsValid(VMLegs.LegParent) then
		VMLegs.LegParent:Remove()
	end

	if IsValid(VMLegs.LegModel) then
		VMLegs.LegModel:Remove()
	end

	VMLegs.LegParent = nil
	VMLegs.LegModel = nil
	VMLegs.Cycle = 0
	VMLegs.StartCycle = 0
	VMLegs.SeqID = nil
	VMLegs.CurLegs = nil
end

VMLegs:Reset()

VMLegs.RegisterAnim = function(self, name, tbl)
	self.Anims[name] = tbl
end

VMLegs.GetAnim = function(self, name) return self.Anims[name] end
VMLegs.IsActive = function(self) return IsValid(self.LegParent) end
VMLegs.GetCurrentAnim = function(self) return self.CurLegs end

VManip.PlayAnim = function(self, name)
	local ply = LocalPlayer()
	if ply:GetViewEntity() ~= ply and not self:IsActive() then return end

	--doesnt always work
	if IsValid(ply:GetActiveWeapon()) then
		if ply:GetActiveWeapon():GetHoldType() == "duel" then return false end
	else
		return false
	end

	if ply:InVehicle() or not ply:Alive() then return false end
	if self:IsActive() then return false end
	local vm = ply:GetViewModel()
	local bypass = hook.Run("VManipPreActCheck", name, vm)

	if not bypass then
		if type(ply:GetActiveWeapon().GetStatus) == "function" then
			if ply:GetActiveWeapon():GetStatus() == 5 then return false end
		end

		if vm:GetSequenceActivity(vm:GetSequence()) == ACT_VM_RELOAD then return false end
	end

	local animtoplay = self:GetAnim(name)

	if not animtoplay then
		print("Invalid anim", name)

		return false
	end

	if hook.Run("VManipPrePlayAnim", name) == false then return false end
	curtime = CurTime()
	self.Remove()
	self.GesturePastHold = false
	self.GestureOnHold = false
	self.CurGestureData = animtoplay
	self.CurGesture = name
	self.Lerp_Peak = curtime + animtoplay["lerp_peak"]
	vmatrixpeakinfo = animtoplay["lerp_peak"]
	self.Lerp_Speed_In = animtoplay["lerp_speed_in"] or 1
	self.Lerp_Speed_Out = animtoplay["lerp_speed_out"] or 1
	self.Loop = animtoplay["loop"]
	VManip_modelname = animtoplay["model"]
	vmanipholdtime = animtoplay["holdtime"]
	self.VMGesture = ClientsideModel("models/" .. VManip_modelname, RENDERGROUP_BOTH)
	self.VMCam = ClientsideModel("models/" .. VManip_modelname, RENDERGROUP_BOTH) --Saves me the headache of attachment shit
	self.Cam_AngInt = animtoplay["cam_angint"] or tableintensity
	self.SeqID = self.VMGesture:LookupSequence(name)

	if animtoplay["assurepos"] then
		self.VMGesture:SetPos(ply:EyePos())
		VManip.AssurePos = true
	elseif not animtoplay["locktoply"] then
		self.VMGesture:SetPos(vm:GetPos())
	end

	if animtoplay["locktoply"] then
		self.LockToPly = true
		local eyepos = ply:EyePos()
		self.VMGesture:SetAngles(ply:EyeAngles())
		self.VMGesture:SetPos(eyepos)
		self.LockZ = eyepos.z
	else
		self.VMGesture:SetAngles(vm:GetAngles())
		self.VMGesture:SetParent(vm)
	end

	self.Cam_Ang = animtoplay["cam_ang"] or properang
	self.VMCam:SetPos(vector_origin)
	self.VMCam:SetAngles(angle_zero)
	self.VMGesture:ResetSequenceInfo()
	self.VMGesture:SetPlaybackRate(1)
	self.VMGesture:ResetSequence(self.SeqID)
	self.VMCam:ResetSequenceInfo()
	self.VMCam:SetPlaybackRate(1)
	self.VMCam:ResetSequence(self.SeqID)
	self.VMatrixlerp = 1
	self.Speed = animtoplay["speed"] or 1
	self.Lerp_Curve = animtoplay["lerp_curve"] or 1
	self.StartCycle = animtoplay["startcycle"] or 0
	self.Segmented = animtoplay["segmented"] or false
	self.HoldTime = animtoplay["holdtime"] or nil
	self.HoldTimeData = self.HoldTime
	self.PreventQuit = animtoplay["preventquit"] or false

	if self.HoldTime then
		self.HoldTime = curtime + self.HoldTime
	end

	self.Cycle = self.StartCycle
	self.VMGesture:SetNoDraw(true)
	self.VMCam:SetNoDraw(true)
	self.Duration = self.VMGesture:SequenceDuration(self.SeqID)

	if animtoplay["sounds"] and animtoplay["sounds"] ~= {} then
		PlaySoundsInTable(animtoplay["sounds"], self.CurGesture)
	end

	hook.Run("VManipPostPlayAnim", name)

	return true
end

VMLegs.PlayAnim = function(self, name)
	if self:IsActive() then return false end
	local animtoplay = self:GetAnim(name)

	if not animtoplay then
		print("Invalid anim", name)

		return false
	end

	local ply = LocalPlayer()
	self.Cycle = 0
	self.CurLegs = name
	self.Speed = animtoplay["speed"]
	self.FBoost = animtoplay["forwardboost"]
	self.UBoost = animtoplay["upwardboost"]
	self.UBoostCache = Vector(0, 0, self.UBoost)
	local model = animtoplay["model"]
	local vm = ply:GetViewModel()
	local vmang = vm:GetAngles()
	local vmpos = vm:GetPos()
	self.LegParent = ClientsideModel("models/" .. model, RENDERGROUP_BOTH)
	self.LegParent:SetPos(vmpos)
	self.LegParent:SetParent(vm)
	local legang = vm:GetAngles()
	legang = Angle(0, legang.y, 0)
	VMLegs.LegParent:SetAngles(legang)
	self.LegModel = ClientsideModel(string.Replace(ply:GetModel(), "models/models/", "models/"), RENDERGROUP_TRANSLUCENT)
	self.LegModel:SetPos(vmpos)
	self.LegModel:SetAngles(vmang)
	local plyhands = ply:GetHands()

	if IsValid(plyhands) then
		self.LegModel.GetPlayerColor = plyhands.GetPlayerColor --yes, this is how you do player color. Fucking lol
	end

	self.LegModel:SetParent(self.LegParent)
	self.LegModel:AddEffects(EF_BONEMERGE)

	for i = 0, self.LegModel:GetNumBodyGroups() do
		local bodyg = ply:GetBodygroup(i)
		self.LegModel:SetBodygroup(i, bodyg)
	end

	for k, v in pairs(playermodelbonesupper) do
		local plybone = self.LegModel:LookupBone(v)

		if plybone ~= nil then
			self.LegModel:ManipulateBoneScale(plybone, Vector(0, 0, 0))
		end
	end

	self.SeqID = self.LegParent:LookupSequence(name)
	self.LegParent:ResetSequenceInfo()
	self.LegParent:SetPlaybackRate(1)
	self.LegParent:ResetSequence(self.SeqID)
end

--#########################--
local posparentcache
local curtimecheck = 0 --prevents the hook from ever running twice in the same frame

hook.Add("PostDrawViewModel", "VManip", function(vm, ply, weapon)
	if VManip:IsActive() then
		curtime = CurTime()
		if curtime == curtimecheck and not gui.IsGameUIVisible() then return end
		curtimecheck = CurTime()

		--Some SWEPs have RIDICULOUS offsets
		if VManip.AssurePos then
			if posparentcache ~= weapon then
				posparentcache = weapon
				VManip.VMGesture:SetParent(nil)
				VManip.VMGesture:SetPos(EyePos())
				VManip.VMGesture:SetAngles(vm:GetAngles())
				VManip.VMGesture:SetParent(vm)
			end
		end

		--A more cruel version of AssurePos
		if VManip.LockToPly then
			local eyeang = ply:EyeAngles()
			local eyepos = EyePos()
			local vmang = vm:GetAngles()
			local finang = eyeang - vmang
			finang.y = 0 --fucks up on 180
			local newang = eyeang + (finang * 0.25)
			VManip.VMGesture:SetAngles(newang)
			VManip.VMGesture:SetPos(eyepos)
		end

		--fun fact, this only runs on respawn for an obvious reason
		if not ply:Alive() then
			VManip:Remove()

			return
		end

		--VManip.VMGesture:FrameAdvance(FrameTime()*VManip.Speed) --shit the bed, don't use this
		if VManip.Loop then
			if VManip.Cycle >= 1 then
				VManip.Lerp_Peak = curtime + VManip.CurGestureData["lerp_peak"]
				VManip.Cycle = 0
			end

			if VManip.HoldQuit then
				VManip.Loop = false
			end
		end

		if not VManip.GestureOnHold then
			VManip.Cycle = VManip.Cycle + FrameTime() * VManip.Speed
		end

		VManip.VMGesture:SetCycle(VManip.Cycle)
		VManip.VMCam:SetCycle(VManip.Cycle)

		if VManip.HoldTime then
			if curtime >= VManip.HoldTime and not VManip.GestureOnHold and not VManip.GesturePastHold and not VManip.HoldQuit then
				-- local seqdur=VManip.VMGesture:SequenceDuration()
				-- VManip.Cycle=(VManip.HoldTimeData)/(seqdur) ply:ChatPrint(seqdur)
				-- VManip.VMGesture:SetCycle(VManip.Cycle)
				VManip.GestureOnHold = true
			elseif VManip.HoldQuit and VManip.GestureOnHold then
				VManip.GestureOnHold = false
				VManip.GesturePastHold = true
				VManip.Lerp_Peak = curtime + VManip.CurGestureData["lerp_peak"] - VManip.CurGestureData["holdtime"]
			end
		end

		if (curtime < VManip.Lerp_Peak or (VManip:IsSegmented() and not VManip.LastSegment)) and (not VManip.GestureOnHold or VManip.GesturePastHold) then
			VManip.VMatrixlerp = math.Clamp(VManip.VMatrixlerp - (FrameTime() * 7) * VManip.Lerp_Speed_In, 0, 1)
		elseif not VManip.Loop and (not VManip.GestureOnHold or VManip.GesturePastHold) then
			if not VManip:IsSegmented() or VManip.LastSegment then
				VManip.VMatrixlerp = math.Clamp(VManip.VMatrixlerp + (FrameTime() * 7) * VManip.Lerp_Speed_Out, 0, 1)
			end
		end

		local rigpick2 = leftarmbones
		local rigpick = leftarmbones
		VManip.VMGesture:SetupBones()
		VManip.VMGesture:DrawModel()

		--[[The actual manipulation part below]]
		for k, v in pairs(rigpick) do
			if v == "ValveBiped.Bip01_L_Ulna" then
				local lb = VManip.VMGesture:LookupBone("ValveBiped.Bip01_L_Forearm")

				if lb then
					VManip.GestureMatrix = VManip.VMGesture:GetBoneMatrix(lb)
				end
			else
				local lb = VManip.VMGesture:LookupBone(rigpick2[k])

				if lb then
					VManip.GestureMatrix = VManip.VMGesture:GetBoneMatrix(lb)
				end
			end

			local VMBone = vm:LookupBone(v)

			if VMBone ~= nil then
				local VMBoneMatrix = vm:GetBoneMatrix(VMBone)

				if VMBoneMatrix then
					local VMBoneMatrixCache = VMBoneMatrix:ToTable()
					local VMGestureMatrixCache = VManip.GestureMatrix:ToTable()

					for k, v in pairs(VMGestureMatrixCache) do
						for l, b in pairs(v) do
							VMGestureMatrixCache[k][l] = LerpC(VManip.VMatrixlerp, b, VMBoneMatrixCache[k][l], VManip.Lerp_Curve)
						end
					end

					if type(ply:GetActiveWeapon().GetStatus) == "function" then
						if ply:GetActiveWeapon():GetStatus() ~= 5 then
							vm:SetBoneMatrix(VMBone, Matrix(VMGestureMatrixCache))
						end
					else
						vm:SetBoneMatrix(VMBone, Matrix(VMGestureMatrixCache))
					end
				end
			end
		end

		if VManip.Cycle >= 1 and not VManip.Loop then
			if VManip:IsSegmented() and not VManip.SegmentFinished then
				VManip.SegmentFinished = true
				hook.Run("VManipSegmentFinish", VManip:GetCurrentAnim(), VManip:GetCurrentSegment(), VManip.LastSegment, VManip:GetSegmentCount())
			elseif VManip:IsSegmented() and VManip.LastSegment then
				if VManip.VMatrixlerp >= 1 then
					VManip:Remove()
				end
			elseif not VManip:IsSegmented() then
				if VManip.CurGestureData["loop"] then
					if VManip.VMatrixlerp >= 1 then
						VManip:Remove()
					end
				else
					VManip.Remove()

					return
				end
			end
		end
	elseif VManip.QueuedAnim then
		if VManip:PlayAnim(VManip.QueuedAnim) then
			VManip.QueuedAnim = nil
		end
	end
end)

local anglef = Angle(0, 1, 0)

--Very basic stuff, you see
hook.Add("PostDrawViewModel", "VMLegs", function(vm, ply, weapon)
	if VMLegs:IsActive() then
		-- if ply:GetViewEntity() != ply then
		-- VMLegs.LegModel:SetNoDraw(true)
		-- else
		-- VMLegs.LegModel:SetNoDraw(false)
		-- end
		local legang = vm:GetAngles()
		legang = Angle(0, legang.y, 0)
		VMLegs.LegParent:SetAngles(legang)
		VMLegs.LegParent:SetPos(vm:GetPos() + (legang:Forward() * VMLegs.FBoost) + VMLegs.UBoostCache)
		VMLegs.Cycle = VMLegs.Cycle + FrameTime() * VMLegs.Speed
		VMLegs.LegParent:SetCycle(VMLegs.Cycle)

		if VMLegs.Cycle >= 1 then
			VMLegs.Remove()

			return
		end
	end
end)

concommand.Add("VManip_List", function(ply)
	PrintTable(VManip.Anims)
end)

concommand.Add("VManip_ListSimple", function(ply)
	for k, v in pairs(VManip.Anims) do
		print(k, " | ", v["model"])
	end
end)

net.Receive("VManip_SimplePlay", function(len)
	local anim = net.ReadString()
	VManip:PlayAnim(anim)
end)

--[[Maybe merge these two in one message, using enums]]
net.Receive("VManip_StopHold", function(len)
	local anim = net.ReadString()

	if anim == "" then
		VManip:QuitHolding()
	else
		VManip:QuitHolding(anim)
	end
end)

--CalcView attachments need to be retrieved outside of CalcView
hook.Add("NeedsDepthPass", "VManip_RubatPLZ", function()
	--Just gonna slide this in there, yea.
	if VManip.QueuedAnim then
		local ply = LocalPlayer()

		if ply:GetViewEntity() ~= ply or ply:ShouldDrawLocalPlayer() then
			VManip.QueuedAnim = nil
		end
	end

	--Good.
	if not VManip:IsActive() then return end

	if not LocalPlayer():Alive() then
		VManip:Remove()

		return
	end

	local allatt = VManip.VMCam:GetAttachments()
	if #allatt == 0 then return end
	local lookup = allatt[1]["id"]
	local att = VManip.VMCam:GetAttachment(lookup)
	VManip.Attachment = att
end)

local ISCALC = false
hook.Add("CalcView", "VManip_Cam", function(ply, origin, angles, fov)
	// we dont really care about camera manipulations from other hooks during this, thus we can ignore them.
	// some important calculations can happen in calcview hooks however, so running them is important

	if ISCALC then return end
	ISCALC = true
	hook.Run("CalcView", ply, pos, ang, fov)
	ISCALC = false

	if not VManip:IsActive() or not VManip.Attachment then return end
	if ply:GetViewEntity() ~= ply or ply:ShouldDrawLocalPlayer() then return end
	local view = {}
	local camang = VManip.Attachment.Ang - VManip.Cam_Ang
	view.angles = angles + Angle(camang.x * VManip.Cam_AngInt[1], camang.y * VManip.Cam_AngInt[2], camang.z * VManip.Cam_AngInt[3])

	return view
end)

--ply:ChatPrint(tostring(angles).." | "..tostring(view.angles))
--prevent reload hook
hook.Add("StartCommand", "VManip_PreventReload", function(ply, ucmd)
	if VManip:IsActive() then
		ucmd:RemoveKey(8192)
	end
end)

--prevent reload on tfa hook
hook.Add("TFA_PreReload", "VManip_PreventTFAReload", function(wepom, keyreleased)
	if VManip:IsActive() then return "no" end
end)

--Time to load everythin'
local function VManip_FindAndImport()
	local path = "vmanip/anims/"
	local anims = file.Find(path .. "*.lua", "lcl")

	for k, v in pairs(anims) do
		include(path .. v)
	end

	print("VManip loaded with " .. table.Count(VManip.Anims) .. " animations")
end

hook.Add("InitPostEntity", "VManip_ImportAnims", function()
	VManip_FindAndImport()
	hook.Remove("InitPostEntity", "VManip_ImportAnims")
end)

hook.Add("VManipPreActCheck", "VManipArcCWFix", function(name, vm)
	local ply = LocalPlayer()
	local activewep = ply:GetActiveWeapon()

	if activewep.ArcCW then
		if activewep:ShouldDrawCrosshair() or vm:GetCycle() > 0.99 then return true end --crossh check is pretty rudimentary
	end
end)

--vm getcycle is fucked for some reason except on some anims, makes me wonder
hook.Add("VManipPrePlayAnim", "VManipArcCWReload", function()
	local ply = LocalPlayer()
	local activewep = ply:GetActiveWeapon()

	if activewep.ArcCW then
		if activewep:GetNWBool("reloading") then return false end
	end
end)

concommand.Add("VManip_FindAndImport", VManip_FindAndImport)
RunConsoleCommand("VManip_FindAndImport") --Runs it again if this file is refreshed