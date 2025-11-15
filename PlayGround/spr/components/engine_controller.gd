class_name EngineController
extends Node2D

var _spr: Spr
var _engines: Array[Node2D] = []

const _engine_interface := [&"start_engine", &"stop_engine"]

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr

func init_engine_controller() -> void:
	for child in get_children():
		if NodeExt.fits(child, _engine_interface):
			_engines.append(child)

func process_unhandled_input(_event: InputEvent) -> void:
	pass

func process(_delta: float) -> void:
	pass

func get_engines() -> Array:
	return _engines