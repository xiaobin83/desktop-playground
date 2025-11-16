class_name AIAgent
extends AIController2D

var _move_action := [0, 0, 0, 0, 0, 0]

func get_obs() -> Dictionary:
	var obs = []
	var all_items = ItemFood.get_all_food_items()
	if all_items.size() > 0:
		var item = all_items[0]
		var local_pos = to_local(item.global_position)
		obs.append(local_pos.x)
		obs.append(local_pos.y)
	else:
		obs.append(-1)
		obs.append(-1)

	return {"obs": obs}

func get_reward() -> float:	
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"move_action" : {
			"size": 6,
			"action_type": "continuous"
		},
	}
	
func set_action(action) -> void:	
	var outputs = action["move_action"]
	for i in range(_move_action.size()):
		_move_action[i] = clamp(outputs[i], 0, 1.0)

func get_move_action() -> Array:
	return _move_action