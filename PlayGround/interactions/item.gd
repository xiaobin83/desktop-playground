class_name Item
extends Node2D

signal on_consume(item: Item)

func _on_body_entered(body: Node2D) -> void:
	if body is Spr:
		body.touch_item(self)

func consume() -> void:
	on_consume.emit(self)
