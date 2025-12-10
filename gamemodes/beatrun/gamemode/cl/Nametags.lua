local NametagsEnable = CreateClientConVar("Beatrun_Nametags", "1", true, false, language.GetPhrase("beatrun.convars.nametags"), 0, 1)
local enemy = Color(255, 0, 0)

local function GetNametagColor(ply)
	if ply == LocalPlayer() then return nil end
	if GetGlobalBool("GM_DATATHEFT") or GetGlobalBool("GM_DEATHMATCH") then return nil end
	local dist = LocalPlayer():GetPos():Distance(ply:GetPos())
	ply.distfromlocal = dist
	if not (NametagsEnable:GetBool() and not GetGlobalBool("EM_HideNametags") and dist < 50000) then return nil end
	
	local infectionmode = GetGlobalBool("GM_INFECTION")
	local eventmode = GetGlobalBool("GM_EVENTMODE")
	local localinfected = LocalPlayer():GetNW2Bool("Infected")
	local plyinfected = ply:GetNW2Bool("Infected")
	
	local color = color_white
	if eventmode then
		local statusKey = ply:GetNW2String("EPlayerStatus", "Member")
		local sdata = GetStatusData(statusKey)
		color = sdata.color
	end
	
	if infectionmode then
		if localinfected ~= plyinfected then
			color = enemy
		else
			return nil
		end
	end
	
	return color
end

local function HideNearby(ply)
	if ply == LocalPlayer() then return end
	if GetGlobalBool("GM_DATATHEFT") or GetGlobalBool("GM_DEATHMATCH") then return end
	local dist = LocalPlayer():GetPos():Distance(ply:GetPos())
	ply.distfromlocal = dist
	if not (NametagsEnable:GetBool() and not GetGlobalBool("EM_HideNametags") and dist < 50000) then return end
	
	local infectionmode = GetGlobalBool("GM_INFECTION")
	local localinfected = LocalPlayer():GetNW2Bool("Infected")
	local plyinfected = ply:GetNW2Bool("Infected")
	
	if dist < 30 then
		if infectionmode and CurTime() > (LocalPlayer().InfectionTouchDelay or 0) and localinfected and not plyinfected then
			LocalPlayer().InfectionTouchDelay = CurTime() + 1
			net.Start("Infection_Touch")
			net.WriteEntity(ply)
			net.SendToServer()
		end
		return true
	end
end
hook.Add("PrePlayerDraw", "HideNearby", HideNearby)

local function DrawNametags()
	for _, ply in ipairs(player.GetAll()) do
		local color = GetNametagColor(ply)
		if not color or not ply:Alive()then continue end
		
		local dist = ply.distfromlocal
		local pos = nil
		if dist < 250 then
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
		
		local ang = LocalPlayer():EyeAngles()
		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), 90)
		
		local scale = math.max(2.5 * dist / 2000, 0.5)
		
		cam.IgnoreZ(true)
		cam.Start3D2D(pos, Angle(0, ang.y, ang.z), scale)
			render.DepthRange(0, 0)
			draw.DrawText(ply:Nick(), "BeatrunHUD", 2, 2, color, TEXT_ALIGN_CENTER)
			render.DepthRange(0, 1)
		cam.End3D2D()
		cam.IgnoreZ(false)
	end
end

hook.Add("PostDrawOpaqueRenderables", "BeatrunNametags", DrawNametags)