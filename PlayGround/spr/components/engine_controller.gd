class_name EngineController
extends Node2D

const ENABLE_FUEL := true
const ENGINE_INTERFACE := [&"start_engine", &"stop_engine"]

var _spr: Spr
var _engines: Array[Node2D] = []
var _max_fuel := 1.0
var _fuel := 1.0
var _fuel_consumption_rate: float = 0.01

var _op_engine: Callable

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr

func _ready() -> void:
	_fuel = _max_fuel
	if ENABLE_FUEL:
		_op_engine = _op_engine_with_fuel
	else:
		_op_engine = _op_engine_without_fuel

	for child in get_children():
		if NodeExt.has_methods(child, ENGINE_INTERFACE):
			_engines.append(child)

func get_engines() -> Array:
	return _engines

func accept_physics_process(_agent, _delta: float) -> void:
	pass

func get_fuel() -> float:
	return _fuel

func get_max_fuel() -> float:
	return _max_fuel

# called in _physics_process
func set_move_action(action: Array, delta: float) -> void:
	var engines = get_engines()
	for i in range(action.size()):
		_op_engine.call(action[i], engines[i], delta)

func _op_engine_without_fuel(action: float, engine, _delta: float) -> void:
	if action > 0:
		engine.start_engine(1)
	else:
		engine.stop_engine()

func _op_engine_with_fuel(action: float, engine, delta: float) -> void:
	if action > 0:
		_fuel -= delta * _fuel_consumption_rate
		if _fuel > 0:
			engine.start_engine(1)
		else:
			_fuel = 0
	else:
		_fuel += delta * _fuel_consumption_rate * 0.5
		engine.stop_engine()
