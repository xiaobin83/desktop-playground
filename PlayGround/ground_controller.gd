class_name GroundController
extends Node

@export_flags_2d_physics var _collision_layer :int
@export_flags_2d_physics var _collision_mask :int

var _item_group_name :StringName

func _ready() -> void:
	_item_group_name = Items.get_group_name(get_index())

func _spawn_item(item: PackedScene, item_global_position: Vector2) -> Item:
	var item_instance= ObjectPool.allocate_packed_scene(item) as Item
	item_instance.collision_layer = _collision_layer
	item_instance.collision_mask = _collision_mask
	item_instance.on_request_despawn.connect(_on_request_despawn)
	item_instance.visible= true
	add_child(item_instance)
	item_instance.global_position = item_global_position
	item_instance.set_item_group_name(_item_group_name)
	return item_instance

func _on_request_despawn(item: Item) -> void:
	item.on_request_despawn.disconnect(_on_request_despawn)
	item.visible = false
	ObjectPool.recycle(item)

func get_item_group_name() -> StringName:
	return _item_group_name
