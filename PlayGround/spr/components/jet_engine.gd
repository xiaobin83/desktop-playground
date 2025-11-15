extends SprEngine

@export var _force: float = 10.0

func _get_force(working: bool) -> Vector2:
	return Vector2.UP.rotated(global_rotation) * _force if working else Vector2.ZERO

func _physics_process_engine(_delta: float) -> void:
	_spr.apply_force(get_force(), global_position - _spr.global_position)

	
