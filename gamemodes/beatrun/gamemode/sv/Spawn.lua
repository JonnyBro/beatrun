DEFINE_BASECLASS("gamemode_base")

local entMeta = FindMetaTable("Entity")

-- successfully yonked from DarkRP, thanks <3
local oldPlyColor

local function disableBabyGod(ply)
	if not IsValid(ply) or not ply.Babygod then return end

	ply.Babygod = nil

	ply:SetRenderMode(RENDERMODE_NORMAL)
	ply:GodDisable()

	local reinstateOldColor = true

	for _, p in ipairs(player.GetAll()) do
		reinstateOldColor = reinstateOldColor and p.Babygod == nil
	end

	if reinstateOldColor then
		entMeta.SetColor = oldPlyColor
		oldPlyColor = nil
	end

	ply:SetColor(ply.babyGodColor or color_white)

	ply.babyGodColor = nil
end

local function enableBabyGod(ply)
	timer.Remove(ply:EntIndex() .. "babygod")

	ply.Babygod = true

	ply:GodEnable()

	ply.babyGodColor = ply:GetColor()

	ply:SetRenderMode(RENDERMODE_TRANSALPHA)

	if not oldPlyColor then
		oldPlyColor = entMeta.SetColor

		entMeta.SetColor = function(p, c, ...)
			if not p.Babygod then return oldPlyColor(p, c, ...) end

			p.babyGodColor = c

			oldPlyColor(p, Color(c.r, c.g, c.b, 100))
		end
	end

	ply:SetColor(ply.babyGodColor)

	timer.Create(ply:EntIndex() .. "babygod", 5, 1, function() disableBabyGod(ply) end)
end

function GM:PlayerSpawn(ply, transition)
	player_manager.SetPlayerClass(ply, "player_beatrun")

	ply:StripAmmo()

	BaseClass.PlayerSpawn(self, ply, transition)

	if GetGlobalBool("GM_DEATHMATCH") or GetGlobalBool("GM_DATATHEFT") then
		enableBabyGod(ply)
	end
end

hook.Add("KeyPress", "DisableBabyGodOnAttack", function(ply, key) if key == IN_ATTACK and ply.Babygod then disableBabyGod(ply) end end)