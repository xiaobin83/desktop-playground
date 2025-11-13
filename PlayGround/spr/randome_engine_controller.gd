extends Node2D

@export var _durationMin: float
@export var _durationMax: float

var _spr: Spr 
var _engines: Array[Node2D] = []
var _cooldown: Cooldown 

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr
	_spr.on_grabbed.connect(_on_grabbed)
	_spr.on_dropped.connect(_on_dropped)

func _ready() -> void:
	for eng in get_children():
		if eng.has_method('start_engine') and eng.has_method('stop_engine'):
			_engines.append(eng)
	_cooldown = Cooldown.new(randf_range(_durationMin, _durationMax))

func _exit_tree() -> void:
	_spr.on_grabbed.disconnect(_on_grabbed)
	_spr.on_dropped.disconnect(_on_dropped)

func _process(delta: float) -> void:
	if _cooldown.process(delta):
		_start_random_engine()
		_cooldown.reset(randf_range(_durationMin, _durationMax))


func _start_random_engine() -> void:
	var size = _engines.size();
	if size == 0:
		return
	var index = randi_range(0, size - 1)
	_engines[index].start_engine(randf_range(0, _cooldown.get_time()))

func _stop_all_engines():
	for eng in _engines:
		eng.stop_engine()

func _on_grabbed() -> void:
	_stop_all_engines()
	_cooldown.pause()

func _on_dropped() -> void:
	_cooldown.resume()
	pass


