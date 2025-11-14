extends Node

var _rolling_count: int = 0
var _spr: Spr
var _current_rotation: float = 0.0
var _accumulated_rotation: float = 0.0

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr
	_rolling_count = 0
	_current_rotation = spr.global_rotation * 180.0 / PI

func _process(delta: float) -> void:
	if _spr == null: return
	var new_rotation = _spr.global_rotation * 180.0 / PI
	var delta_rotation = new_rotation - _current_rotation
	if delta_rotation > 180:
		delta_rotation -= 360
	elif delta_rotation < -180:
		delta_rotation += 360
	_accumulated_rotation += delta_rotation
	_current_rotation = new_rotation
	if abs(_accumulated_rotation) >= 360:
		var rolls = int(_accumulated_rotation / 360)
		_rolling_count += abs(rolls)
		_accumulated_rotation -= rolls * 360
		print("Rolled: %d times" % _rolling_count)
