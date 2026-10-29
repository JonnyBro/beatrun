local FaithVO = CreateConVar("Beatrun_FaithVO", 0, { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY })
local meta = FindMetaTable("Player")

sound.Add({
	name = "Faith.StrainSoft",
	volume = 1,
	pitch = { 90, 105 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Strain_Soft_1.ogg", "mirrorsedge/VO/Faith/Strain_Soft_2.ogg", "mirrorsedge/VO/Faith/Strain_Soft_3.ogg", "mirrorsedge/VO/Faith/Strain_Soft_4.ogg", "mirrorsedge/VO/Faith/Strain_Soft_5.ogg", "mirrorsedge/VO/Faith/Strain_Soft_6.ogg", "mirrorsedge/VO/Faith/Strain_Soft_7.ogg", "mirrorsedge/VO/Faith/Strain_Soft_8.ogg" }
})

sound.Add({
	name = "Faith.StrainMedium",
	volume = 1,
	pitch = { 90, 105 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Strain_Medium_1.ogg", "mirrorsedge/VO/Faith/Strain_Medium_2.ogg", "mirrorsedge/VO/Faith/Strain_Medium_3.ogg", "mirrorsedge/VO/Faith/Strain_Medium_4.ogg", "mirrorsedge/VO/Faith/Strain_Medium_5.ogg", "mirrorsedge/VO/Faith/Strain_Medium_6.ogg", "mirrorsedge/VO/Faith/Strain_Medium_7.ogg", "mirrorsedge/VO/Faith/Strain_Medium_8.ogg" }
})

sound.Add({
	name = "Faith.StrainHard",
	volume = 1,
	pitch = { 95, 100 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Strain_Hard_1.ogg", "mirrorsedge/VO/Faith/Strain_Hard_2.ogg", "mirrorsedge/VO/Faith/Strain_Hard_3.ogg", "mirrorsedge/VO/Faith/Strain_Hard_4.ogg", "mirrorsedge/VO/Faith/Strain_Hard_5.ogg", "mirrorsedge/VO/Faith/Strain_Hard_6.ogg", "mirrorsedge/VO/Faith/Strain_Hard_7.ogg", "mirrorsedge/VO/Faith/Strain_Hard_8.ogg" }
})

sound.Add({
	name = "Faith.ImpactSoft",
	volume = 1,
	pitch = { 95, 105 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Impact_Soft_01.ogg", "mirrorsedge/VO/Faith/Impact_Soft_02.ogg", "mirrorsedge/VO/Faith/Impact_Soft_03.ogg", "mirrorsedge/VO/Faith/Impact_Soft_04.ogg", "mirrorsedge/VO/Faith/Impact_Soft_05.ogg", "mirrorsedge/VO/Faith/Impact_Soft_06.ogg", "mirrorsedge/VO/Faith/Impact_Soft_07.ogg", "mirrorsedge/VO/Faith/Impact_Soft_08.ogg", "mirrorsedge/VO/Faith/Impact_Soft_09.ogg", "mirrorsedge/VO/Faith/Impact_Soft_10.ogg", "mirrorsedge/VO/Faith/Impact_Soft_11.ogg", "mirrorsedge/VO/Faith/Impact_Soft_12.ogg", "mirrorsedge/VO/Faith/Impact_Soft_13.ogg", "mirrorsedge/VO/Faith/Impact_Soft_14.ogg" }
})

sound.Add({
	name = "Faith.Impact",
	volume = 1,
	pitch = { 95, 105 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Impact_Med_01.ogg", "mirrorsedge/VO/Faith/Impact_Med_02.ogg", "mirrorsedge/VO/Faith/Impact_Med_03.ogg", "mirrorsedge/VO/Faith/Impact_Med_04.ogg", "mirrorsedge/VO/Faith/Impact_Med_05.ogg", "mirrorsedge/VO/Faith/Impact_Med_06.ogg", "mirrorsedge/VO/Faith/Impact_Med_07.ogg", "mirrorsedge/VO/Faith/Impact_Med_08.ogg", "mirrorsedge/VO/Faith/Impact_Med_09.ogg", "mirrorsedge/VO/Faith/Impact_Med_10.ogg", "mirrorsedge/VO/Faith/Impact_Med_11.ogg", "mirrorsedge/VO/Faith/Impact_Med_12.ogg", "mirrorsedge/VO/Faith/Impact_Med_13.ogg", "mirrorsedge/VO/Faith/Impact_Med_14.ogg" }
})

sound.Add({
	name = "Faith.ImpactHard",
	volume = 1,
	pitch = { 95, 105 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Impact_Hard_01.ogg", "mirrorsedge/VO/Faith/Impact_Hard_02.ogg", "mirrorsedge/VO/Faith/Impact_Hard_03.ogg", "mirrorsedge/VO/Faith/Impact_Hard_04.ogg", "mirrorsedge/VO/Faith/Impact_Hard_05.ogg", "mirrorsedge/VO/Faith/Impact_Hard_06.ogg", "mirrorsedge/VO/Faith/Impact_Hard_07.ogg", "mirrorsedge/VO/Faith/Impact_Hard_08.ogg", "mirrorsedge/VO/Faith/Impact_Hard_09.ogg", "mirrorsedge/VO/Faith/Impact_Hard_10.ogg", "mirrorsedge/VO/Faith/Impact_Hard_11.ogg", "mirrorsedge/VO/Faith/Impact_Hard_12.ogg", "mirrorsedge/VO/Faith/Impact_Hard_13.ogg", "mirrorsedge/VO/Faith/Impact_Hard_14.ogg" }
})

sound.Add({
	name = "Faith.Breath.SoftShortIn",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Breath_Soft_Short_In_01.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_02.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_03.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_04.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_05.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_06.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_07.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_In_08.ogg" }
})

sound.Add({
	name = "Faith.Breath.SoftShortOut",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_01.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_02.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_03.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_04.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_05.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_06.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_07.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Short_Out_08.ogg" }
})

sound.Add({
	name = "Faith.Breath.SoftLongIn",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 35,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Breath_Soft_Long_In_01.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Long_In_02.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Long_In_03.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Long_In_04.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Long_In_05.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Long_In_06.ogg" }
})

sound.Add({
	name = "Faith.Breath.SoftLongOut",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 35,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Breath_Soft_Long_Out_01.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Long_Out_02.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Long_Out_03.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Long_Out_04.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Long_Out_05.ogg", "mirrorsedge/VO/Faith/Breath_Soft_Long_Out_06.ogg" }
})

sound.Add({
	name = "Faith.Breath.MediumShortIn",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Breath_Medium_Short_In_01.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_02.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_03.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_04.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_05.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_06.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_07.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_In_08.ogg" }
})

sound.Add({
	name = "Faith.Breath.MediumShortOut",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_01.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_02.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_03.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_04.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_05.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_06.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_07.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Short_Out_08.ogg" }
})

sound.Add({
	name = "Faith.Breath.MediumLongIn",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Breath_Medium_Long_In_01.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_02.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_03.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_04.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_05.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_06.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_07.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_In_08.ogg" }
})

sound.Add({
	name = "Faith.Breath.MediumLongOut",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_01.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_02.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_03.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_04.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_05.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_06.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_07.ogg", "mirrorsedge/VO/Faith/Breath_Medium_Long_Out_08.ogg" }
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
