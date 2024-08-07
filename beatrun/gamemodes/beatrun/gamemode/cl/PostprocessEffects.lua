local function MyNeedsDepthPass()
    return true
end

doffocus = CreateClientConVar("doftest_focus", 0, true, false, "", 0, 1)
doffocus2 = CreateClientConVar("doftest_focus2", 0, true, false, "", 0, 1)
local postprocessenable = CreateClientConVar("Beatrun_PostprocessEffects", 0, true, false, "Enables silly ahh post-processing effects. EXPERIMENTAL.", 0, 1)

-- Add hook so that the _rt_ResolvedFullFrameDepth texture is updated
hook.Add( "NeedsDepthPass", "MyNeedsDepthPass", MyNeedsDepthPass )

local blur_mat = Material('pp/bokehblur')
local BOKEN_FOCUS = 0
local BOKEN_FORCE = 0

cyclestate = false

hook.Add("RenderScreenspaceEffects", "funnybrdof", function()
	if !postprocessenable:GetBool() then return end
    local ply = LocalPlayer()

	render.UpdateScreenEffectTexture(1)

	local trace = {}
	if not ply:ShouldDrawLocalPlayer() then
		eye = ply:EyePos()
		langles = ply:EyeAngles()

		if ply:InVehicle() then
			langles = ply:GetVehicle():GetAngles() + langles
		end
	else
		eye = EyePos()
		langles = EyeAngles()
		ignoreEnts = true
	end
	trace.start = ply:EyePos()
	trace.endpos = langles:Forward() * 300 + eye
	trace.filter = function(ent)
		return true
	end

	local tr = util.TraceLine(trace)
	local dist = tr.HitPos:Distance(ply:GetPos())

    if ply:GetSliding() or ply:GetClimbing() != 0 or ply:GetWallrun() == 1 or IsValid(ply:GetLadder()) then
		BOKEN_FORCE = math.Clamp(BOKEN_FORCE + 0.03 * (FrameTime() * 66), 0,1)
    else
    	BOKEN_FORCE = math.Clamp(BOKEN_FORCE - 0.03 * (FrameTime() * 66), 0,1)
    end
   
    blur_mat:SetTexture("$BASETEXTURE", render.GetScreenEffectTexture(1))
    blur_mat:SetTexture("$DEPTHTEXTURE", render.GetResolvedFullFrameDepth())
    
    blur_mat:SetFloat("$size", BOKEN_FORCE * 8)
    blur_mat:SetFloat("$focus", 0)
    blur_mat:SetFloat("$focusradius", 2 - 0.25 * 2)
    
    --blur_mat:SetFloat("$size", BOKEN_FORCE * 3)
    --blur_mat:SetFloat("$focus", 0)
    --blur_mat:SetFloat("$focusradius", 2 - 0.5 * 3)
    --print(BOKEN_FOCUS)
    
    --render.SetMaterial(fbtexture)
    --render.DrawScreenQuadEx(0,0,960,540)
    render.SetMaterial(blur_mat)
    render.DrawScreenQuad()
    --render.DrawTextureToScreenRect(render.GetResolvedFullFrameDepth(),960,0,960,540)
end)