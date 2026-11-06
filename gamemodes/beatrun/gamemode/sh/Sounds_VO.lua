if CLIENT then CreateClientConVar("Beatrun_FaithVO", "0", true, true, "", 0, 1) end
local meta = FindMetaTable("Player")

sound.Add({
	name = "Faith.StrainSoft",
	volume = 1,
	pitch = { 90, 105 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/strain_soft_1.ogg", "mirrorsedge/vo/faith/strain_soft_2.ogg", "mirrorsedge/vo/faith/strain_soft_3.ogg", "mirrorsedge/vo/faith/strain_soft_4.ogg", "mirrorsedge/vo/faith/strain_soft_5.ogg", "mirrorsedge/vo/faith/strain_soft_6.ogg", "mirrorsedge/vo/faith/strain_soft_7.ogg", "mirrorsedge/vo/faith/strain_soft_8.ogg" }
})

sound.Add({
	name = "Faith.StrainMedium",
	volume = 1,
	pitch = { 90, 105 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/strain_medium_1.ogg", "mirrorsedge/vo/faith/strain_medium_2.ogg", "mirrorsedge/vo/faith/strain_medium_3.ogg", "mirrorsedge/vo/faith/strain_medium_4.ogg", "mirrorsedge/vo/faith/strain_medium_5.ogg", "mirrorsedge/vo/faith/strain_medium_6.ogg", "mirrorsedge/vo/faith/strain_medium_7.ogg", "mirrorsedge/vo/faith/strain_medium_8.ogg" }
})

sound.Add({
	name = "Faith.StrainHard",
	volume = 1,
	pitch = { 95, 100 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/strain_hard_1.ogg", "mirrorsedge/vo/faith/strain_hard_2.ogg", "mirrorsedge/vo/faith/strain_hard_3.ogg", "mirrorsedge/vo/faith/strain_hard_4.ogg", "mirrorsedge/vo/faith/strain_hard_5.ogg", "mirrorsedge/vo/faith/strain_hard_6.ogg", "mirrorsedge/vo/faith/strain_hard_7.ogg", "mirrorsedge/vo/faith/strain_hard_8.ogg" }
})

sound.Add({
	name = "Faith.ImpactSoft",
	volume = 1,
	pitch = { 95, 105 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/impact_soft_01.ogg", "mirrorsedge/vo/faith/impact_soft_02.ogg", "mirrorsedge/vo/faith/impact_soft_03.ogg", "mirrorsedge/vo/faith/impact_soft_04.ogg", "mirrorsedge/vo/faith/impact_soft_05.ogg", "mirrorsedge/vo/faith/impact_soft_06.ogg", "mirrorsedge/vo/faith/impact_soft_07.ogg", "mirrorsedge/vo/faith/impact_soft_08.ogg", "mirrorsedge/vo/faith/impact_soft_09.ogg", "mirrorsedge/vo/faith/impact_soft_10.ogg", "mirrorsedge/vo/faith/impact_soft_11.ogg", "mirrorsedge/vo/faith/impact_soft_12.ogg", "mirrorsedge/vo/faith/impact_soft_13.ogg", "mirrorsedge/vo/faith/impact_soft_14.ogg" }
})

sound.Add({
	name = "Faith.Impact",
	volume = 1,
	pitch = { 95, 105 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/impact_med_01.ogg", "mirrorsedge/vo/faith/impact_med_02.ogg", "mirrorsedge/vo/faith/impact_med_03.ogg", "mirrorsedge/vo/faith/impact_med_04.ogg", "mirrorsedge/vo/faith/impact_med_05.ogg", "mirrorsedge/vo/faith/impact_med_06.ogg", "mirrorsedge/vo/faith/impact_med_07.ogg", "mirrorsedge/vo/faith/impact_med_08.ogg", "mirrorsedge/vo/faith/impact_med_09.ogg", "mirrorsedge/vo/faith/impact_med_10.ogg", "mirrorsedge/vo/faith/impact_med_11.ogg", "mirrorsedge/vo/faith/impact_med_12.ogg", "mirrorsedge/vo/faith/impact_med_13.ogg", "mirrorsedge/vo/faith/impact_med_14.ogg" }
})

sound.Add({
	name = "Faith.ImpactHard",
	volume = 1,
	pitch = { 95, 105 },
	level = 50,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/impact_hard_01.ogg", "mirrorsedge/vo/faith/impact_hard_02.ogg", "mirrorsedge/vo/faith/impact_hard_03.ogg", "mirrorsedge/vo/faith/impact_hard_04.ogg", "mirrorsedge/vo/faith/impact_hard_05.ogg", "mirrorsedge/vo/faith/impact_hard_06.ogg", "mirrorsedge/vo/faith/impact_hard_07.ogg", "mirrorsedge/vo/faith/impact_hard_08.ogg", "mirrorsedge/vo/faith/impact_hard_09.ogg", "mirrorsedge/vo/faith/impact_hard_10.ogg", "mirrorsedge/vo/faith/impact_hard_11.ogg", "mirrorsedge/vo/faith/impact_hard_12.ogg", "mirrorsedge/vo/faith/impact_hard_13.ogg", "mirrorsedge/vo/faith/impact_hard_14.ogg" }
})

sound.Add({
	name = "Faith.Breath.SoftShortIn",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/breath_soft_short_in_01.ogg", "mirrorsedge/vo/faith/breath_soft_short_in_02.ogg", "mirrorsedge/vo/faith/breath_soft_short_in_03.ogg", "mirrorsedge/vo/faith/breath_soft_short_in_04.ogg", "mirrorsedge/vo/faith/breath_soft_short_in_05.ogg", "mirrorsedge/vo/faith/breath_soft_short_in_06.ogg", "mirrorsedge/vo/faith/breath_soft_short_in_07.ogg", "mirrorsedge/vo/faith/breath_soft_short_in_08.ogg" }
})

sound.Add({
	name = "Faith.Breath.SoftShortOut",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/breath_soft_short_out_01.ogg", "mirrorsedge/vo/faith/breath_soft_short_out_02.ogg", "mirrorsedge/vo/faith/breath_soft_short_out_03.ogg", "mirrorsedge/vo/faith/breath_soft_short_out_04.ogg", "mirrorsedge/vo/faith/breath_soft_short_out_05.ogg", "mirrorsedge/vo/faith/breath_soft_short_out_06.ogg", "mirrorsedge/vo/faith/breath_soft_short_out_07.ogg", "mirrorsedge/vo/faith/breath_soft_short_out_08.ogg" }
})

sound.Add({
	name = "Faith.Breath.SoftLongIn",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 35,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/breath_soft_long_in_01.ogg", "mirrorsedge/vo/faith/breath_soft_long_in_02.ogg", "mirrorsedge/vo/faith/breath_soft_long_in_03.ogg", "mirrorsedge/vo/faith/breath_soft_long_in_04.ogg", "mirrorsedge/vo/faith/breath_soft_long_in_05.ogg", "mirrorsedge/vo/faith/breath_soft_long_in_06.ogg" }
})

sound.Add({
	name = "Faith.Breath.SoftLongOut",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 35,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/breath_soft_long_out_01.ogg", "mirrorsedge/vo/faith/breath_soft_long_out_02.ogg", "mirrorsedge/vo/faith/breath_soft_long_out_03.ogg", "mirrorsedge/vo/faith/breath_soft_long_out_04.ogg", "mirrorsedge/vo/faith/breath_soft_long_out_05.ogg", "mirrorsedge/vo/faith/breath_soft_long_out_06.ogg" }
})

sound.Add({
	name = "Faith.Breath.MediumShortIn",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/breath_medium_short_in_01.ogg", "mirrorsedge/vo/faith/breath_medium_short_in_02.ogg", "mirrorsedge/vo/faith/breath_medium_short_in_03.ogg", "mirrorsedge/vo/faith/breath_medium_short_in_04.ogg", "mirrorsedge/vo/faith/breath_medium_short_in_05.ogg", "mirrorsedge/vo/faith/breath_medium_short_in_06.ogg", "mirrorsedge/vo/faith/breath_medium_short_in_07.ogg", "mirrorsedge/vo/faith/breath_medium_short_in_08.ogg" }
})

sound.Add({
	name = "Faith.Breath.MediumShortOut",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/breath_medium_short_out_01.ogg", "mirrorsedge/vo/faith/breath_medium_short_out_02.ogg", "mirrorsedge/vo/faith/breath_medium_short_out_03.ogg", "mirrorsedge/vo/faith/breath_medium_short_out_04.ogg", "mirrorsedge/vo/faith/breath_medium_short_out_05.ogg", "mirrorsedge/vo/faith/breath_medium_short_out_06.ogg", "mirrorsedge/vo/faith/breath_medium_short_out_07.ogg", "mirrorsedge/vo/faith/breath_medium_short_out_08.ogg" }
})

sound.Add({
	name = "Faith.Breath.MediumLongIn",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/breath_medium_long_in_01.ogg", "mirrorsedge/vo/faith/breath_medium_long_in_02.ogg", "mirrorsedge/vo/faith/breath_medium_long_in_03.ogg", "mirrorsedge/vo/faith/breath_medium_long_in_04.ogg", "mirrorsedge/vo/faith/breath_medium_long_in_05.ogg", "mirrorsedge/vo/faith/breath_medium_long_in_06.ogg", "mirrorsedge/vo/faith/breath_medium_long_in_07.ogg", "mirrorsedge/vo/faith/breath_medium_long_in_08.ogg" }
})

sound.Add({
	name = "Faith.Breath.MediumLongOut",
	volume = 0.75,
	pitch = { 95, 105 },
	level = 40,
	channel = CHAN_VOICE,
	sound = { "mirrorsedge/vo/faith/breath_medium_long_out_01.ogg", "mirrorsedge/vo/faith/breath_medium_long_out_02.ogg", "mirrorsedge/vo/faith/breath_medium_long_out_03.ogg", "mirrorsedge/vo/faith/breath_medium_long_out_04.ogg", "mirrorsedge/vo/faith/breath_medium_long_out_05.ogg", "mirrorsedge/vo/faith/breath_medium_long_out_06.ogg", "mirrorsedge/vo/faith/breath_medium_long_out_07.ogg", "mirrorsedge/vo/faith/breath_medium_long_out_08.ogg" }
})

function meta:FaithVO(vo, filter)
	if self:GetInfoNum("Beatrun_FaithVO", 0) >= 1 then
		if CLIENT then
			nextbreath = CurTime() + 1
		elseif game.SinglePlayer() then
			Entity(1):SendLua("nextbreath = CurTime()+1")
		end

		self:EmitSound(vo, nil, nil, nil, nil, nil, nil, filter)
	end
end
