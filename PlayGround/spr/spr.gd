class_name Spr;

extends RigidBody2D;

@export var _counter: Node

signal on_grabbed;
signal on_dropped;

var _is_grabbed: bool = false;

func _ready() -> void:
	var spr_components = get_tree().get_nodes_in_group('spr_components')
	for comp in spr_components:
		print(comp.name)
		if comp.has_method('notify_spr_initialized'):
			comp.notify_spr_initialized(self)

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

func _process(_delta: float) -> void:
	if !Global.is_in_play_ground(self):
		Global.respawn(self)

func get_counter() -> Node:
	return _counter
