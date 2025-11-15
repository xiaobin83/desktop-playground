class_name SprEngine

extends Node2D

@export var _engine_light: Sprite2D
@export var _fuel_burning_rate: float = 1.0
@export var _light_out_speed: float = 10.0


var _spr : Spr
var _engine_working_time: float
var _light_on_time: float
var _light_on_color := Color.RED
var _light_off_color := Color.WHITE
var _is_working: bool


func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr

func start_engine(fuel: float) -> void:
	_engine_working_time += fuel *_fuel_burning_rate 

func is_working() -> bool:
	return _is_working

func get_force() -> Vector2:
	return _get_force(_is_working)

func _physics_process_engine(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if _spr == null:
		return
	if _engine_working_time > 0:
		_engine_working_time -= delta;
		_light_on_time = 1.0
		_is_working = true
	else:
		_is_working = false

	_physics_process_engine(delta)

func _process(delta: float) -> void:
	if _light_on_time > 0:
		var color = _light_off_color.lerp(_light_on_color, _light_on_time)
		_engine_light.self_modulate = color
		_light_on_time -= delta * _light_out_speed
	else:
		_engine_light.self_modulate = _light_off_color

func _get_force(_working: bool) -> Vector2:
	return Vector2.ZERO
