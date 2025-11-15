extends GroundController

@export var _items : Array[PackedScene]

@onready var _spr :Spr = $Spr

class Level:
	var item_spawn_height: float
	var item_spawn_scatter_horizontal: float
	var item_spawn_scatter_vertical: float

	func _init(height: float, h_scatter :float, v_scatter :float):
		item_spawn_height = height
		item_spawn_scatter_horizontal = h_scatter
		item_spawn_scatter_vertical = v_scatter

static var _levels = [
	Level.new(0.1, 0.1, 0.1),
	Level.new(0.1, 0.2, 0.1),
	Level.new(0.1, 0.3, 0.1),
	Level.new(0.1, 0.5, 0.1),
	Level.new(0.1, 0.8, 0.1),
	Level.new(0.1, 1.0, 0.1),

	Level.new(0.2, 0.1, 0.1),
	Level.new(0.2, 0.2, 0.1),
	Level.new(0.2, 0.3, 0.1),
	Level.new(0.2, 0.5, 0.1),
	Level.new(0.2, 0.8, 0.1),
	Level.new(0.2, 1.0, 0.1),

	Level.new(0.3, 0.1, 0.1),
	Level.new(0.3, 0.2, 0.1),
	Level.new(0.3, 0.3, 0.1),
	Level.new(0.3, 0.5, 0.1),
	Level.new(0.3, 0.8, 0.1),
	Level.new(0.3, 1.0, 0.1),

	Level.new(0.5, 1, 0.1),

	Level.new(0.8, 1, 0.1),
]

var _n_levels: int = 0
var _consumed_items: int = 0
const ITEMS_PER_LEVEL: int = 10

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
	#var item = _items[randi_range(0, _items.size() - 1)]
	var item = _items[0]
	return item

func _spawn_one() -> void:
	var item = _spawn_item(_get_random_item(), _get_spawn_position())
	_item_list.append(item)

func _get_spawn_position() -> Vector2:
	var size = Global.get_size()
	var level = _levels[_n_levels]
	var x = size.x / 2.0 + size.x * randf_range(-level.item_spawn_scatter_horizontal, level.item_spawn_scatter_horizontal)
	var y = size.y * (1.0 - level.item_spawn_height) + size.y * randf_range(-level.item_spawn_scatter_vertical, level.item_spawn_scatter_vertical)
	return Global.clamp(Vector2(x, y))

func _on_request_despawn(item: Item) -> void:
	var index = _item_list.find(item)
	if index >= 0:
		_item_list.remove_at(index)
	super._on_request_despawn(item)
	if not _is_resetting:
		_spawn_new_item += 1
		_consumed_items += 1
		if _consumed_items >= ITEMS_PER_LEVEL:
			print("level %d completed" % _n_levels)
			_consumed_items = 0
			_n_levels += 1
			if _n_levels >= _levels.size():
				_n_levels = _levels.size() - 1
		_spr.set_agent_done()
		_spr.set_difficulty_level(_n_levels)

func _reset() -> void:
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
