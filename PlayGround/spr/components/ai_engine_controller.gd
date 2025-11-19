extends EngineController

func set_move_action(action: Array) -> void:
	var engines = get_engines()
	for i in range(action.size()):
		_op_engine(action[i], engines[i])


func _op_engine(action: float, engine) -> void:
	if action > 0:
		engine.start_engine(1)
	else:
		engine.stop_engine()
