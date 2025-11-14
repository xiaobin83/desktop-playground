extends Node2D

@export var _durationMin : float = 10.0
@export var _durationMax : float = 20.0

var _spr: Spr
var _cooldown : Cooldown

func notify_spr_initialized(spr: Spr) -> void:
	_spr = spr
	_spr.on_grabbed.connect(_on_spr_grabbed)
	_spr.on_dropped.connect(_on_spr_dropped)

func _ready() -> void:
	_cooldown = Cooldown.new(randf_range(_durationMin, _durationMax))

func _on_spr_grabbed() -> void:
	_report()
	_spr.get_counter().reset_rolling_count();
	_cooldown.pause()

func _on_spr_dropped() -> void:
	_cooldown.reset(randf_range(_durationMin, _durationMax))

func _report() -> void:
	var count = _spr.get_counter().get_rolling_count()
	var speak_bubble = ObjectPool.allocate("res://PlayGround/ui_widgets/speak_bubble.tscn", 3)
	speak_bubble.set_content("%d次翻滚!" % count)
	get_tree().root.add_child(speak_bubble)
	speak_bubble.global_position = _spr.global_position + Vector2(0, -50)
	speak_bubble.global_rotation = 0

func _process(delta: float) -> void:
	if _cooldown.process(delta):
		_report()
		if !_spr.is_grabbed():
			_cooldown.reset(randf_range(_durationMin, _durationMax))
