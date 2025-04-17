local NametagsEnable = CreateClientConVar("Beatrun_Nametags", "1", true, false, language.GetPhrase("beatrun.convars.nametags"), 0, 1)

local enemy = Color(255, 0, 0)

local function HideNearby(ply)
	if ply == LocalPlayer() then return end
	if GetGlobalBool("GM_DATATHEFT") or GetGlobalBool("GM_DEATHMATCH") then return end

	ply.distfromlocal = LocalPlayer():GetPos():Distance(ply:GetPos())
	local Distance = ply.distfromlocal or 40000

	if Distance < 20000 and NametagsEnable:GetBool() then
		local infectionmode = GetGlobalBool("GM_INFECTION")
		local localinfected = LocalPlayer():GetNW2Bool("Infected")
		local plyinfected = ply:GetNW2Bool("Infected")
		local ang = LocalPlayer():EyeAngles()
		local color = color_white
		local dontdraw = false

		if (ply.distfromlocal or 100) < 30 then
			if infectionmode and CurTime() > (LocalPlayer().InfectionTouchDelay or 0) and localinfected and not plyinfected then
				LocalPlayer().InfectionTouchDelay = CurTime() + 1

				net.Start("Infection_Touch")
					net.WriteEntity(ply)
				net.SendToServer()
			end

			dontdraw = true
		end

		if infectionmode and localinfected and not plyinfected or not localinfected and plyinfected then
			color = enemy
		elseif infectionmode then
			return
		end

		local pos = nil

		if Distance < 250 then
			local bone = ply:LookupBone("ValveBiped.Bip01_Head1")

			if bone then
				pos = ply:GetBonePosition(bone)
			end
		end

		local offset = 25

		if not pos then
			pos = ply:GetPos()
			offset = 90
		end

		pos.z = pos.z + offset

		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), 90)

		cam.Start3D2D(pos, Angle(0, ang.y, 90), math.max(2.5 * Distance / 2000, 0.5))
			cam.IgnoreZ(true)
			draw.DrawText(ply:Nick(), "BeatrunHUD", 2, 2, color, TEXT_ALIGN_CENTER)
			cam.IgnoreZ(false)
		cam.End3D2D()

		return dontdraw
	end
end

hook.Add("PrePlayerDraw", "HideNearby", HideNearby)