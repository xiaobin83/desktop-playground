extends Node

@export var _left_eye: Sprite2D;
@export var _right_eye: Sprite2D;

var _eye_blink: Blink.BlinkInstance = Blink.create(Blink.Style.EyeBlink, 8.0);

func notify_spr_initialized(spr: Spr) -> void:
	spr.on_grabbed.connect(_on_spr_grabbed);
	spr.on_dropped.connect(_on_spr_dropped);

func _on_spr_grabbed() -> void:
	pass;

func _on_spr_dropped() -> void:
	pass;

func _process(delta: float) -> void:
	var intensity = _eye_blink.process(delta);
	_left_eye.visible = intensity < 0.3;
	_right_eye.visible = intensity < 0.3;
