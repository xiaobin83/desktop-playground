class_name EngineController
extends Node2D

var _spr: Spr
var _engines: Array[Node2D] = []

const _engine_interface := [&"start_engine", &"stop_engine"]

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr

func _ready() -> void:
	for child in get_children():
		if NodeExt.has_methods(child, _engine_interface):
			_engines.append(child)

func get_engines() -> Array:
	return _engines

func set_move_action(_action: Array) -> void:
	pass
