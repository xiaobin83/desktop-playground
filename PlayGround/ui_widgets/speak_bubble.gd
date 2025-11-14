extends Node2D

@export var _label: Label

func set_content(text: String) -> void:
	_label.text = text
