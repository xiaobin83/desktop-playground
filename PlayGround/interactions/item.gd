class_name Item
extends Node2D

signal on_consume(item: Item)

func woke_up_from_pool() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is Spr:
		body.entered_item(self)

func _on_body_exited(body: Node2D) -> void:
	if body is Spr:
		body.exited_item(self)

# return consumed amount
func consume(_delta: float) -> float:
	raise_on_consume()
	return 1.0

func raise_on_consume() -> void:
	on_consume.emit(self)
