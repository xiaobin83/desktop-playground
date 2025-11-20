class_name AIAgent
extends AIController2D

var _move_action := [0, 0, 0, 0, 0, 0]

const MAX_DISTANCE = 10000

var _spr :Spr
var _selected_item
var _accumulated_reward :float = 0.0

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr
	spr.set_ai_agent(self)

func get_obs() -> Dictionary:
	var obs :Array[float] = []
	var items = get_tree().get_nodes_in_group(_spr.get_item_group_name())
	if items and items.size() > 0:
		_selected_item = items[0]
		var item_pos = to_local(_selected_item.global_position)
		obs.append_array(Items.get_one_hot(_selected_item.get_item_type()))
		obs.append(item_pos.x)
		obs.append(item_pos.y)
		obs.append(item_pos.length())
		#obs.append_array(Item.get_extra_obs(item))
	else:
		_selected_item = null
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

func _get_pose_reward() -> float:
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

# called from RL framework
func set_action(action) -> void:
	var outputs = action["move_action"]
	for i in range(_move_action.size()):
		var value = clamp(outputs[i], -1.0, 1.0)
		_move_action[i] = value

func process_touching_items(items: Array, delta: float) -> void:
	var r = 0.0
	for item in items:
		if item == _selected_item:
			r += item.consume(delta)
	r += _get_pose_reward()
	reward += r
	_accumulated_reward += r

func visit_physics_process(engine_controller, delta: float) -> void:
	var fuel = engine_controller.get_fuel()
	var max_fuel = engine_controller.get_max_fuel()
	if fuel <= 0.2 * max_fuel:
		reward -= 0.1 * delta  # penalize low fuel
	engine_controller.set_move_action(_move_action, delta)

func reset() -> void:
	print("AIAgent accumulated reward: %.2f" % _accumulated_reward)
	_accumulated_reward = 0.0
	super.reset()
