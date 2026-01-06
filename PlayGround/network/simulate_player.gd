class_name SimulatePlayer
extends Node

enum SimulatedPlayer {
	PlayerA = 0, PlayerB
}

@export var _simulate_player := SimulatedPlayer.PlayerA

func _enter_tree() -> void:
	var args = OS.get_cmdline_args()
	var dict = Utils.parse_args(args)
	var simulate_player = dict.get('simulate-player', null)
	if simulate_player == null:
		_simulate_player = SimulatedPlayer.PlayerA
	else:
		var player = Utils.get_enum_value(SimulatedPlayer, simulate_player)
		if player != null:
			_simulate_player = player
		else:
			_simulate_player = SimulatedPlayer.PlayerA
	var local_user = LocalUser.create_local_user(Utils.get_enum_name(SimulatedPlayer, _simulate_player))
	$ConnectionController.set_local_user(local_user)
