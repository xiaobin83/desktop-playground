class_name PickableMenuItem
extends Area2D 

signal on_grabbed
signal on_dropped
signal on_hovering

var _initial_position :Vector2


func _init() -> void:
	assert(NodeExt.has_methods(self, Pickable.interfaces))

func _ready() -> void:
	_initial_position = position 

func can_pickup() -> bool:
	return true 

func notify_grabbed() -> void:
	on_grabbed.emit()

func notify_dropped() -> void:
	on_dropped.emit()
	position = _initial_position

func notify_hovering() -> void:
	on_hovering.emit()
