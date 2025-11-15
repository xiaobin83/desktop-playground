class_name EngineController
extends Node2D

const ENABLE_FUEL := true
const ENGINE_INTERFACE := [&"start_engine"]

var _spr: Spr
var _engines: Array[Node2D] = []

var _max_fuel := 1.0
var _critical_fuel: float = 0.2
var _fuel := 1.0

var _fuel_consumption_rate: float = 1.0
var _fuel_recovery_rate: float = 0.6

enum State { WORKABLE, WORKING, CRITICAL }

var _engine_state := State.CRITICAL

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr

func _ready() -> void:
	_fuel = 0 
	_engine_state = State.CRITICAL
	for child in get_children():
		if NodeExt.has_methods(child, ENGINE_INTERFACE):
			_engines.append(child)

func get_engines() -> Array:
	return _engines

func get_observation() -> Array:

	var obs = [get_fuel()]

	# fuel state one-hot
	match _engine_state:
		State.WORKABLE:
			obs.append_array([1, 0, 0])
		State.WORKING:
			obs.append_array([0, 1, 0])
		State.CRITICAL:
			obs.append_array([0, 0, 1])

	# single engine state
	for eng in get_engines():
		if eng.is_working():
			obs.append(1)
		else:
			obs.append(0)
	
	return obs
	

func accept_physics_process(_agent, delta: float) -> void:
	match _engine_state:
		State.CRITICAL, State.WORKABLE:
			_fuel += delta * _fuel_recovery_rate
			if _fuel > _max_fuel:
				_fuel = _max_fuel
			if _fuel > _critical_fuel:
				_engine_state = State.WORKABLE

func get_fuel() -> float:
	return _fuel

func get_max_fuel() -> float:
	return _max_fuel

func get_critical_fuel() -> float:
	return _critical_fuel

# called in _physics_process
func set_move_action(action: Array, delta: float) -> void:
	if _engine_state == State.CRITICAL: return

	var engines = get_engines()
	var any_engine_working = false
	for i in range(action.size()):
		any_engine_working = _op_engine(action[i], engines[i], delta) or any_engine_working
	
	if any_engine_working:
		_engine_state = State.WORKING
	else:
		_engine_state = State.WORKABLE

	if _fuel <= 0:
		_engine_state = State.CRITICAL

func _op_engine(action: float, engine, delta: float) -> bool:
	if action > 0:
		if _fuel > 0:
			var consumed_fuel = delta * _fuel_consumption_rate
			engine.start_engine(consumed_fuel)
			_fuel -= consumed_fuel
			return true
	return false
	
