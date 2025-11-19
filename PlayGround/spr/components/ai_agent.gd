class_name AIAgent
extends AIController2D

var _move_action := [0, 0, 0, 0, 0, 0]

const MAX_DISTANCE = 10000

var _spr :Spr
var _selected_item

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr
	spr.set_ai_agent(self)

func get_obs() -> Dictionary:
	var obs :Array[float] = []
	_items = get_tree().get_nodes_in_group(_spr.get_item_group_name())
	if _items and _items.size() > 0:
		var item = _items[0]
		var item_pos = to_local(item.global_position)
		obs.append_array(Items.get_one_hot(item.get_item_type()))
		obs.append(item_pos.x)
		obs.append(item_pos.y)
		obs.append(item_pos.length())
		#obs.append_array(Item.get_extra_obs(item))
	else:
		obs.append_array(Items.get_one_hot(Items.Type.None))
		obs.append(10000)
		obs.append(10000)
		obs.append(MAX_DISTANCE)
		#obs.append_array(Item.get_default_extra_obs())

	obs.append_array(_spr.get_spr_obs())

	return {"obs": obs}


func get_reward() -> float:
	#print("reward %.2f" % reward)
	return reward

func get_contacting_stable_pose_reward() -> float:
	return 0

func get_stable_pose_reward() -> float:
	if _selected_item:
		var local_pos = to_local(_selected_item.global_position)
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

func process_touching_items(items: Array, delta: float) -> void:
	var r = 0.0
	for item in items:
		r += item.consume(delta)
	r += get_stable_pose_reward()
	reward += r
