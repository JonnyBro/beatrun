local FaithVO = CreateConVar("Beatrun_FaithVO", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE})

local meta = FindMetaTable("Player")

sound.Add({
	name = "Faith.StrainSoft",
	volume = 0.75,
	pitch = 100,
	level = 40,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Strain_Soft_1.wav", "mirrorsedge/VO/Faith/Strain_Soft_2.wav", "mirrorsedge/VO/Faith/Strain_Soft_3.wav", "mirrorsedge/VO/Faith/Strain_Soft_4.wav", "mirrorsedge/VO/Faith/Strain_Soft_5.wav", "mirrorsedge/VO/Faith/Strain_Soft_6.wav", "mirrorsedge/VO/Faith/Strain_Soft_7.wav", "mirrorsedge/VO/Faith/Strain_Soft_8.wav"}
})

sound.Add({
	name = "Faith.StrainMedium",
	volume = 0.75,
	pitch = 100,
	level = 40,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Strain_Medium_1.wav", "mirrorsedge/VO/Faith/Strain_Medium_2.wav", "mirrorsedge/VO/Faith/Strain_Medium_3.wav", "mirrorsedge/VO/Faith/Strain_Medium_4.wav", "mirrorsedge/VO/Faith/Strain_Medium_5.wav", "mirrorsedge/VO/Faith/Strain_Medium_6.wav", "mirrorsedge/VO/Faith/Strain_Medium_7.wav", "mirrorsedge/VO/Faith/Strain_Medium_8.wav"}
})

sound.Add({
	name = "Faith.StrainHard",
	volume = 0.75,
	pitch = 100,
	level = 40,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Strain_Hard_1.wav", "mirrorsedge/VO/Faith/Strain_Hard_2.wav", "mirrorsedge/VO/Faith/Strain_Hard_3.wav", "mirrorsedge/VO/Faith/Strain_Hard_4.wav", "mirrorsedge/VO/Faith/Strain_Hard_5.wav", "mirrorsedge/VO/Faith/Strain_Hard_6.wav", "mirrorsedge/VO/Faith/Strain_Hard_7.wav", "mirrorsedge/VO/Faith/Strain_Hard_8.wav"}
})

sound.Add({
	name = "Faith.Impact",
	volume = 0.75,
	pitch = 100,
	level = 40,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Impact_Med_01.wav", "mirrorsedge/VO/Faith/Impact_Med_02.wav", "mirrorsedge/VO/Faith/Impact_Med_03.wav", "mirrorsedge/VO/Faith/Impact_Med_04.wav", "mirrorsedge/VO/Faith/Impact_Med_05.wav", "mirrorsedge/VO/Faith/Impact_Med_06.wav", "mirrorsedge/VO/Faith/Impact_Med_07.wav", "mirrorsedge/VO/Faith/Impact_Med_08.wav", "mirrorsedge/VO/Faith/Impact_Med_09.wav", "mirrorsedge/VO/Faith/Impact_Med_10.wav", "mirrorsedge/VO/Faith/Impact_Med_11.wav", "mirrorsedge/VO/Faith/Impact_Med_12.wav", "mirrorsedge/VO/Faith/Impact_Med_13.wav", "mirrorsedge/VO/Faith/Impact_Med_14.wav"}
})

sound.Add({
	name = "Faith.Breath.SoftShortIn",
	volume = 0.75,
	pitch = 100,
	level = 35,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Breath_Soft_Short_In_01.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_02.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_03.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_04.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_05.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_06.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_07.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_08.wav"}
})

sound.Add({
	name = "Faith.Breath.SoftShortOut",
	volume = 0.75,
	pitch = 100,
	level = 35,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Breath_Soft_Short_Out_01.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_02.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_03.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_04.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_05.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_06.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_07.wav", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_08.wav"}
})

sound.Add({
	name = "Faith.Breath.SoftLongIn",
	volume = 0.75,
	pitch = 100,
	level = 35,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Breath_Soft_Long_In_01.wav", "mirrorsedge/VO/Faith/Breath_Soft_Long_In_02.wav", "mirrorsedge/VO/Faith/Breath_Soft_Long_In_03.wav", "mirrorsedge/VO/Faith/Breath_Soft_Long_In_04.wav", "mirrorsedge/VO/Faith/Breath_Soft_Long_In_05.wav", "mirrorsedge/VO/Faith/Breath_Soft_Long_In_06.wav"}
})

sound.Add({
	name = "Faith.Breath.SoftLongOut",
	volume = 0.75,
	pitch = 100,
	level = 35,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Breath_Soft_Long_Out_01.wav", "mirrorsedge/VO/Faith/Breath_Soft_Long_Out_02.wav", "mirrorsedge/VO/Faith/Breath_Soft_Long_Out_03.wav", "mirrorsedge/VO/Faith/Breath_Soft_Long_Out_04.wav", "mirrorsedge/VO/Faith/Breath_Soft_Long_Out_05.wav", "mirrorsedge/VO/Faith/Breath_Soft_Long_Out_06.wav"}
})

sound.Add({
	name = "Faith.Breath.MediumShortIn",
	volume = 0.75,
	pitch = 100,
	level = 35,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Breath_Medium_Short_In_01.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_02.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_03.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_04.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_05.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_06.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_07.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_08.wav"}
})

sound.Add({
	name = "Faith.Breath.MediumShortOut",
	volume = 0.75,
	pitch = 100,
	level = 35,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Breath_Medium_Short_Out_01.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_02.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_03.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_04.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_05.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_06.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_07.wav", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_08.wav"}
})

sound.Add({
	name = "Faith.Breath.MediumLongIn",
	volume = 0.75,
	pitch = 100,
	level = 35,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Breath_Medium_Long_In_01.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_02.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_03.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_04.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_05.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_06.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_07.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_08.wav"}
})

sound.Add({
	name = "Faith.Breath.MediumLongOut",
	volume = 0.75,
	pitch = 100,
	level = 35,
	channel = CHAN_VOICE,
	sound = {"mirrorsedge/VO/Faith/Breath_Medium_Long_Out_01.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_02.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_03.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_04.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_05.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_06.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_07.wav", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_08.wav"}
})

function meta:FaithVO(vo)
	if FaithVO:GetBool() then
		if CLIENT then
			nextbreath = CurTime() + 1
		elseif game.SinglePlayer() then
			Entity(1):SendLua("nextbreath = CurTime()+1")
		end

		self:EmitSound(vo)
	end
end