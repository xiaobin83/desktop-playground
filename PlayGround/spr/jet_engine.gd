extends Node2D

@export var _force: float = 10.0

var _rb: RigidBody2D
var _engine_working_time: float 

func notify_spr_initialized(spr: Spr) -> void:
	_rb = spr

func start_engine(time: float) -> void:
	_engine_working_time = time

func stop_engine() -> void:
	_engine_working_time = 0

func _physics_process(delta: float) -> void:
	if _rb == null:
		return
	if _engine_working_time > 0:
		_engine_working_time -= delta;
		_rb.apply_force(Vector2.UP.rotated(global_rotation) * _force, global_position - _rb.global_position)
