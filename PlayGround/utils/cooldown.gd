class_name Cooldown

var _time: float
var _passed_time: float
var _paused: bool = false

func _init(time: float):
	_time = time
	_passed_time = 0

func get_time():
	return _time

func reset(time: float):
	_time = time
	_passed_time = 0
	resume()

func pause() -> void:
	_paused = true

func resume() -> void:
	_paused = false

func process(delta: float) -> bool:
	if _paused: return false

	_passed_time += delta;
	if _passed_time > _time:
		_passed_time -= _time
		return true
	return false
