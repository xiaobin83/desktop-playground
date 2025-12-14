extends Node 

enum SimulatePlayer {
	PlayerA, PlayerB
}

@export var _simulate_player := SimulatePlayer.PlayerA

func _enter_tree() -> void:
	var local_user = LocalUser.create_local_user(Utils.get_enum_name(SimulatePlayer, _simulate_player))
	$ConnectionController.set_local_user(local_user)
