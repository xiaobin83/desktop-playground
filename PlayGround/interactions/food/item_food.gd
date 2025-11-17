class_name ItemFood
extends Item

@export var _reward: float = 1.0

func _ready() -> void:
	pass

func woke_up_from_pool() -> void:
	pass

func consume(_delta: float) -> float:
	raise_on_consume()
	return _reward
