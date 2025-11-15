class_name AIAgent
extends AIController2D

var _move_action := [0, 0, 0, 0, 0]

const MAX_X = 1000.0
const MAX_Y = 1000.0
const MAX_DISTANCE = sqrt(MAX_X * MAX_X + MAX_Y * MAX_Y)
const MAX_ANGLE = atan(MAX_Y/MAX_X)
const MAX_NORMALIZED_DISTANCE = 3.0

var _spr :Spr
var _selected_item : Item

var _rewards := {}
var _last_normalized_distance = 1.0
var _normalized_distance = MAX_NORMALIZED_DISTANCE
var _step = 0
var _accumulated_reward = 0.0

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr
	spr.set_ai_agent(self)

func get_selected_item() -> Item:
	return _selected_item

func get_obs() -> Dictionary:
	var obs :Array[float] = []
	if _selected_item:
		var item_pos = to_local(_selected_item.global_position)
		obs.append_array(Items.get_one_hot(_selected_item.get_item_type()))
		obs.append(item_pos.x/MAX_X) #normalized
		obs.append(item_pos.y/MAX_Y)
		obs.append(item_pos.length()/MAX_DISTANCE)
		if abs(item_pos.x) < 0.001:
			obs.append(PI/2.0)
		else:
			obs.append(atan(item_pos.y/item_pos.x))
		#obs.append_array(Item.get_extra_obs(item))
	else:
		obs.append_array(Items.get_one_hot(Items.Type.None))
		obs.append(MAX_NORMALIZED_DISTANCE) # normalized max distance
		obs.append(MAX_NORMALIZED_DISTANCE)
		obs.append(MAX_NORMALIZED_DISTANCE)
		obs.append(MAX_ANGLE)
		#obs.append_array(Item.get_default_extra_obs())

	obs.append_array(_spr.get_observation())

	return {"obs": obs}

func _process(_delta: float) -> void:
	var items = get_tree().get_nodes_in_group(_spr.get_item_group_name())
	#print('items in group %s: %d' % [_spr.get_item_group_name(), items.size()])
	if items and items.size() > 0:
		_selected_item = items[0]
	else:
		_selected_item = null

#flush rewards
func get_reward() -> float:
	_reward_pose()
	reward = 0
	for key in _rewards:
		reward += _rewards[key]
	return reward

func zero_reward():
	_accumulated_reward += reward
	if RewardLookup.CONSUME not in _rewards:
		_rewards[RewardLookup.CONSUME] = 0.0
	_rewards['x_total_reward'] = reward
	_rewards['x_accumulated_reward'] = _accumulated_reward
	_rewards['x_distance'] = _normalized_distance
	AgentStatusClient.report_scalars(_spr.get_agent_name(), _rewards, _step)
	_rewards.clear()
	_step += 1
	super.zero_reward()

func _reward_pose() -> void:
	if _selected_item:
		_spr.reward_engine_force_alignment(_reward, _selected_item.global_position)
		var local_pos = to_local(_selected_item.global_position)

		_normalized_distance = local_pos.length() / MAX_DISTANCE
		if _normalized_distance < _last_normalized_distance:
			var delta = _last_normalized_distance - _normalized_distance
			if delta / _last_normalized_distance > RewardLookup.GET_CLOSER_THRESHOLD:
				_last_normalized_distance = _normalized_distance
				_reward(RewardLookup.GET_CLOSER, RewardLookup.get_reward(RewardLookup.GET_CLOSER))
	else:
		_normalized_distance = MAX_NORMALIZED_DISTANCE

	_spr.reward_agent(_reward)


func get_action_space() -> Dictionary:
	return {
		"move_action" : {
			"size": 5,
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
	for item in items:
		if item == _selected_item:
			var result = item.consume(delta)
			if result[Item.IS_CONSUMED]:
				_reward(RewardLookup.CONSUME, RewardLookup.get_reward(RewardLookup.CONSUME))
			else:
				_reward(RewardLookup.PARTIAL_CONSUME, RewardLookup.get_reward(RewardLookup.PARTIAL_CONSUME) * result[Item.CONSUME_AMOUNT])

func _reward(what: StringName, value: float) -> void:
	var v = _rewards.get(what, 0)
	_rewards[what] = v + value

func get_move_action() -> Array:
	return _move_action

func reset() -> void:
	super.reset()
	_last_normalized_distance = MAX_NORMALIZED_DISTANCE
	_normalized_distance = MAX_NORMALIZED_DISTANCE
	_accumulated_reward = 0.0
