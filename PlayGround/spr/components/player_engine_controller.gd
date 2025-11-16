extends EngineController


var _eng_up
var _eng_down
var _eng_left
var _eng_right

func _ready() -> void:
	super._ready()
	var engines = get_engines()
	for engine in engines:
		match engine.name:
			"up": _eng_up = engine
			"down": _eng_down = engine
			"left": _eng_left = engine
			"right": _eng_right = engine

func process_unhandled_input(event: InputEvent) -> void:
	const long_time = 10000.0

	if event.is_action_pressed("Up"):
		_eng_up.start_engine(long_time)
	if event.is_action_released("Up"):
		_eng_up.stop_engine()

	if event.is_action_pressed("Down"):
		_eng_down.start_engine(long_time)
	if event.is_action_released("Down"):
		_eng_down.stop_engine()

	if event.is_action_pressed("Left"):
		_eng_left.start_engine(long_time)
	if event.is_action_released("Left"):
		_eng_left.stop_engine()

	if event.is_action_pressed("Right"):
		_eng_right.start_engine(long_time)
	if event.is_action_released("Right"):
		_eng_right.stop_engine()
