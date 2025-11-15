class_name Spr;

extends RigidBody2D;

@export var _counter: Node

@export var _engine_controller : GDScript 
@onready var _engine_node := $EngineController

signal on_grabbed;
signal on_dropped;

var _is_grabbed: bool = false;

func _ready() -> void:
	_engine_node.set_script(_engine_controller)
	_engine_node.init_engine_controller()
	NodeExt.call_in_children(self, 'notify_spr_initialized', self)

func _unhandled_input(event: InputEvent) -> void:
	_engine_node.process_unhandled_input(event)

func is_grabbed() -> bool:
	return _is_grabbed

func can_pickup() -> bool:
	return true

func notify_grabbed() -> void:
	_is_grabbed = true
	on_grabbed.emit();

func notify_dropped() -> void:
	_is_grabbed = false
	on_dropped.emit();

func _process(delta: float) -> void:
	if !Global.is_in_play_ground(self):
		Global.respawn(self)
	_engine_node.process(delta)

func get_counter() -> Node:
	return _counter
