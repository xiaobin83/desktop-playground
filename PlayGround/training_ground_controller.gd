extends GroundController

@export var _items : Array[PackedScene]

@onready var _spr :Spr = $Spr

var _is_resetting: bool
var _spawn_new_item: int = 0

var _item_list := []

func _ready() -> void:
	super._ready()
	_spr.collision_layer = _collision_layer
	_spr.collision_mask = _collision_mask
	_spr.set_sensor_collision_mask(_collision_mask)
	_spr.set_item_group_name(_item_group_name)
	_spr.on_agent_request_reset.connect(_reset)
	_is_resetting = false
	_spawn_new_item = 1

func _get_random_item() -> PackedScene:
	var item = _items[randi_range(0, _items.size() - 1)]
	return item

func _spawn_one() -> void:
	var random_position = Global.get_random_position()
	var item = _spawn_item(_get_random_item(), random_position)
	_item_list.append(item)

func _on_request_despawn(item: Item) -> void:
	var index = _item_list.find(item)
	if index >= 0:
		_item_list.remove_at(index)
	super._on_request_despawn(item)
	if not _is_resetting:
		_spawn_new_item += 1
		_spr.set_agent_done()

func _reset() -> void:
	print("reset")
	_is_resetting = true
	for item in _item_list:
		item.despawn()
	_spawn_new_item = 1
	_is_resetting = false

func _process(_delta: float) -> void:
	if _spawn_new_item > 0:
		for i in range(_spawn_new_item):
			_spawn_one()
	_spawn_new_item = 0

	if not Global.is_in_play_ground(_spr):
		_spr.set_agent_done()
		Global.respawn(_spr)
