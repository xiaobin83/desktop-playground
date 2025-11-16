extends Node2D

@export var _label: Label

func wake_up_from_pool() -> void:
	pass

func set_content(text: String) -> void:
	_label.text = text
