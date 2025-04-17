--[[
local wmx, wmy = 0, 0
local wmtime = 0

hook.Add("PostRender", "Watermark", function()
	surface.SetFont("DebugFixed")
	surface.SetTextColor(255, 255, 255, 75)
	local steamid = LocalPlayer():SteamID()
	local _, th = surface.GetTextSize(steamid)

	if SysTime() > wmtime then
		wmx, wmy = math.random(0, ScrW() - 100), math.random(0, ScrH() - 100)
		wmtime = SysTime() + 2
	end

	cam.Start2D()
		surface.SetTextPos(wmx, wmy)
		surface.DrawText("Beta")
		surface.SetTextPos(wmx, wmy + th)
		surface.DrawText(steamid)
		surface.SetTextPos(wmx, wmy + (th * 2))
		surface.DrawText(system.SteamTime())
		surface.SetTextPos(wmx, wmy + (th * 3))
		surface.DrawText(LocalPlayer():Nick())
	cam.End2D()
end)
--]]