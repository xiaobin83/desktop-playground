class_name AIAgent
extends AIController2D

var _move_action := [0, 0, 0, 0, 0, 0]
var is_success: bool = false

const ITEM = &'ITEM'

var _spr :Spr

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr

func get_obs() -> Dictionary:
	var obs :Array[float] = []
	var items = get_tree().get_nodes_in_group(ITEM)
	if items and items.size() > 0:
		var item = items[0]
		var item_pos = to_local(item.global_position)
		obs.append(item_pos.x)
		obs.append(item_pos.y)
		obs.append_array(Item.get_extra_obs(item))
	else:
		obs.append(10000) # a large value
		obs.append(10000) # a large value
		obs.append_array(Item.get_default_extra_obs())

	"""
	var spr_pos = _spr.global_position
	var spr_linear_velocity = _spr.linear_velocity
	obs.append(spr_pos.x / 10) # local pos
	obs.append(spr_pos.y / 10)
	obs.append(spr_linear_velocity.x / 10) # local pos
	obs.append(spr_linear_velocity.y / 10)
	obs.append(rad_to_deg(_spr.rotation))
	"""

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
		var value = clamp(outputs[i], -1.0, 1.0)
		_move_action[i] = value 

func get_move_action() -> Array:
	return _move_action

func get_info() -> Dictionary:
	if done:
		return {"is_success": is_success}
	return {}
