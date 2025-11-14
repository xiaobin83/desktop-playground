extends SprEngine

@export var _force: float = 10.0

func _physics_process_engine(delta: float) -> void:
	_spr.apply_force(Vector2.UP.rotated(global_rotation) * _force, global_position - _spr.global_position)
