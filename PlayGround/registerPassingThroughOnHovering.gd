extends Node

static var _hoveringCount: int = 0;

func _on_area_2d_mouse_entered() -> void:
	_hoveringCount += 1;
	get_window().mouse_passthrough = false;

func _on_area_2d_mouse_exit() -> void:
	_hoveringCount -= 1;
	get_window().mouse_passthrough = _hoveringCount <= 0;
