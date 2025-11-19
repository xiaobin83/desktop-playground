class_name Spr;

extends RigidBody2D;

@export var _counter: Node
@export var _engine_controller : GDScript

@onready var _sensor : ISensor2D = $Sensor

var _engine_node
var _ai_agent: AIAgent

signal on_grabbed
signal on_dropped
signal on_hovering

# signal from agent
signal on_agent_request_reset


var _is_grabbed: bool = false;
var _touching_items = {}

func _init() -> void:
	assert(NodeExt.has_methods(self, Pickable.interfaces))

func _enter_tree() -> void:
	_engine_node = $EngineController
	_engine_node.set_script(_engine_controller)

func _ready() -> void:
	NodeExt.call_in_children(self, 'notify_spr_initialized', self)

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
	agent.init(self)

func agent_request_reset() -> void:
	on_agent_request_reset.emit()

func set_agent_done() -> void:
	_ai_agent.done = true
	_ai_agent.needs_reset = true

func reset_agent() -> void:
	_ai_agent.reset()

func get_spr_obs() -> Array:
	return _sensor.get_observation()
#endregion

func _physics_process(_delta: float) -> void:
	if _ai_agent:
		if _ai_agent.needs_reset:
			_ai_agent.reset()
			agent_request_reset()
			return
		var action = _ai_agent.get_move_action()
		_engine_node.set_move_action(action)

func _process(delta: float) -> void:
	if _ai_agent:
		_ai_agent.process_touching_items(_touching_items.keys(), delta)
	else:
		for item in _touching_items.keys():
			item.consume(delta)
