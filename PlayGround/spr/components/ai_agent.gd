class_name AIAgent
extends AIController2D

var _move_action := [0, 0, 0, 0, 0, 0]
var is_success: bool = false

const ITEM = &'ITEM'
const MAX_DISTANCE = 10000

var _spr :Spr
var _items :Array

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr

func get_obs() -> Dictionary:
	var obs :Array[float] = []
	_items = get_tree().get_nodes_in_group(ITEM)
	if _items and _items.size() > 0:
		var item = _items[0]
		var item_pos = to_local(item.global_position)
		obs.append(item_pos.x)
		obs.append(item_pos.y)
		obs.append(item_pos.length())
		#obs.append_array(Item.get_extra_obs(item))
	else:
		obs.append(10000) 
		obs.append(10000) 
		obs.append(MAX_DISTANCE)
		#obs.append_array(Item.get_default_extra_obs())

	#obs.append_array(_get_spr_obs())

	return {"obs": obs}

func _get_spr_obs() -> Array[float]:
	return [_spr.linear_velocity.length(), _spr.angular_velocity]

func get_reward() -> float:
	#print("reward %.2f" % reward)
	return reward

func get_contacting_stable_pose_reward() -> float:
	return 0

func get_stable_pose_reward() -> float:
	if _items and _items.size() > 0:
		var local_pos = to_local(_items[0].global_position)
		return -local_pos.length() * 0.001
	return 0 

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
