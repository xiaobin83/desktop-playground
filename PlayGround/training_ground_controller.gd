extends Node

@export var _item_food: PackedScene

@onready var _spr :Spr = $Spr

var _is_resetting: bool

func _ready() -> void:
	_spr.on_request_reset.connect(_on_spr_request_reset)
	_spawn_food()

func _spawn_food() -> void:
	var item_food = ObjectPool.allocate_packed_scene(_item_food) as ItemFood
	item_food.on_consume.connect(_on_consume_food)
	item_food.visible= true
	add_child(item_food)
	var size = get_window().size
	var x = randf_range(0, size.x)
	var y = randf_range(0, size.y)
	item_food.global_position = Vector2(x, y)

func _on_consume_food(item: Item) -> void:
	item.on_consume.disconnect(_on_consume_food)
	item.visible = false
	ObjectPool.recycle(item)
	if not _is_resetting: 
		_spawn_food()

func _on_spr_request_reset() -> void:
	_is_resetting = true
	Global.respawn(_spr)
	var list = []
	list.append_array(ItemFood.get_all_food_items())
	for item in list:
		item.consume()
	_spawn_food()
	_is_resetting = false
