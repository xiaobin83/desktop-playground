class_name Spr;

extends RigidBody2D;

@export var _counter: Node

@onready var _sensor : ISensor2D = $Sensor
@onready var _label :Label = $Head/Label
@onready var _fuel_bar :ProgressBar = $Head/FuelBar
@onready var _engine_controller :EngineController = $EngineController
@onready var _alignment_light :ColorRect = $AlignmentLight

const MAX_VELOCITY = 1000.0
var _ai_agent: AIAgent
var _ai_agent_item_group_name: StringName
var _force_alignment_decay: float = 1.0
var _n_levels: int = 0

signal on_grabbed
signal on_dropped
signal on_hovering

# signal from agent
signal on_agent_request_reset

var _is_grabbed: bool = false;
var _touching_items = {}

func _init() -> void:
	assert(NodeExt.has_methods(self, Pickable.interfaces))

func _ready() -> void:
	NodeExt.call_in_children(self, 'notify_spr_initialized', self)

func set_sensor_collision_mask(mask: int) -> void:
	if _sensor is RaycastSensor2D:
		_sensor.collision_mask = mask

func set_item_group_name(item_group_name: StringName) -> void:
	_ai_agent_item_group_name = item_group_name
	_label.text = item_group_name

func get_item_group_name() -> StringName:
	return _ai_agent_item_group_name

func is_grabbed() -> bool:
	return _is_grabbed

func can_pickup() -> bool:
	return true

func notify_grabbed() -> void:
	_is_grabbed = true
	freeze = true
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	on_grabbed.emit();

func notify_dropped() -> void:
	_is_grabbed = false
	freeze = false
	on_dropped.emit();

func notify_hovering() -> void:
	on_hovering.emit()

func get_counter() -> Node:
	return _counter

func entered_item(item: Item) -> void:
	_touching_items[item] = true

func exited_item(item: Item) -> void:
	_touching_items.erase(item)

#region Agent
func set_ai_agent(agent: AIAgent) -> void:
	_ai_agent = agent
	_ai_agent.init(self)

func _agent_request_reset() -> void:
	on_agent_request_reset.emit()

func set_agent_done() -> void:
	_ai_agent.done = true
	_ai_agent.needs_reset = true

func reset_agent() -> void:
	_ai_agent.reset()

func get_observation() -> Array:
	var obs = [linear_velocity.x/MAX_VELOCITY, linear_velocity.y/MAX_VELOCITY, global_rotation]
	obs.append_array(_engine_controller.get_observation())
	obs.append_array(_sensor.get_observation())
	return obs

func get_agent_heuristic():
	if _ai_agent:
		return _ai_agent.heuristic
	return 'human'

func set_difficulty_level(level: int) -> void:
	_n_levels = level

func reward_agent(_reward: Callable) -> void:
	"""
	var fuel = _engine_controller.get_fuel()
	var critical_fuel = _engine_controller.get_critical_fuel()
	var r = RewardLookup.get_fuel_reward(critical_fuel, fuel)
	reward.call(RewardLookup.FUEL, r)
	r = RewardLookup.get_pose_reward(global_rotation)
	reward.call(RewardLookup.POSE, r)
	"""
func reward_engine_force_alignment(reward: Callable, pos: Vector2) -> void:
	_force_alignment_decay *= RewardLookup.get_force_alignment_decay_rate(_n_levels)
	var alignment = _get_engine_force_alignment(pos)
	reward.call(RewardLookup.FORCE_ALIGNMENT, _force_alignment_decay * RewardLookup.get_reward(RewardLookup.FORCE_ALIGNMENT) * alignment)

#endregion

func _get_engine_force_alignment(pos: Vector2) -> float:
	var dir = pos - global_position
	dir = dir.normalized()
	var alignment = 0.0
	for eng in _engine_controller.get_engines():
		var move_dir = eng.get_force().normalized()
		alignment += move_dir.dot(dir)
	return alignment

func get_agent_name() -> StringName:
	return _ai_agent_item_group_name

func _physics_process(delta: float) -> void:
	_engine_controller.accept_physics_process(_ai_agent, delta)

func _process(delta: float) -> void:
	if _fuel_bar:
		var fuel = _engine_controller.get_fuel()
		_fuel_bar.value = fuel
		var critical_fuel = _engine_controller.get_critical_fuel()
		if fuel < critical_fuel:
			_fuel_bar.self_modulate = Color.RED
		else:
			_fuel_bar.self_modulate = Color.WHITE

	# alignment
	var selected = _ai_agent.get_selected_item()
	var alignment = 0.0
	if selected:
		alignment = _get_engine_force_alignment(selected.global_position)
	else:
		alignment = 0
	if alignment > 0:
		_alignment_light.self_modulate = Color.GREEN
	elif alignment < 0:
		_alignment_light.self_modulate = Color.RED
	else:
		_alignment_light.self_modulate = Color.GRAY

	if get_agent_heuristic() != 'human':
		if _ai_agent.needs_reset:
			_force_alignment_decay = 1.0
			_ai_agent.reset()
			_agent_request_reset()
			return
		_ai_agent.process_touching_items(_touching_items.keys(), delta)
	else:
		for item in _touching_items.keys():
			item.consume(delta)
