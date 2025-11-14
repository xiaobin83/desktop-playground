class_name SprEngine

extends Node2D

@export var _engine_light: Sprite2D

var _spr : Spr
var _engine_working_time: float

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr

func start_engine(time: float) -> void:
	_engine_working_time = time

func stop_engine() -> void:
	_engine_working_time = 0

func _is_working() -> bool:
	return _engine_working_time > 0

func _physics_process_engine(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if _spr == null:
		return
	if _engine_working_time > 0:
		_engine_working_time -= delta;
		_physics_process_engine(delta)

func _process(_delta: float) -> void:
	if _is_working():
		_engine_light.self_modulate = Color.RED;
	else:
		_engine_light.self_modulate = Color.WHITE;
