class_name Item
extends Node2D

signal on_consume(item: Item)

func _on_body_entered(body: Node2D) -> void:
	if body is Spr:
		body.entered_item(self)

func _on_body_exited(body: Node2D) -> void:
	if body is Spr:
		body.exited_item(self)

func consume() -> void:
	on_consume.emit(self)
