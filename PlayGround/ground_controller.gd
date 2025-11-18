class_name GroundController
extends Node

func _ready() -> void:
	Global.set_item_spawner(_spawn_item)

func _spawn_item(item: PackedScene, item_global_position: Vector2) -> Item:
	var item_instance= ObjectPool.allocate_packed_scene(item) as Item
	item_instance.on_request_despawn.connect(_on_consume_item)
	item_instance.visible= true
	add_child(item_instance)
	item_instance.global_position = item_global_position
	return item_instance

func _on_consume_item(item: Item) -> void:
	item.on_request_despawn.disconnect(_on_consume_item)
	item.visible = false
	ObjectPool.recycle(item)
