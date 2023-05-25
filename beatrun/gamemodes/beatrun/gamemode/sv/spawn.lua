DEFINE_BASECLASS("gamemode_base")

function GM:PlayerSpawn(ply, transition)
	player_manager.SetPlayerClass(ply, "player_beatrun")

	ply:StripAmmo()

	BaseClass.PlayerSpawn(self, ply, transition)
end