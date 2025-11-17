extends GroundController 

@export var _item_food: PackedScene

@onready var _spr :Spr = $Spr

var _is_resetting: bool
var _spawn_new_food: int = 0

var _food_list := []

func _ready() -> void:
	super._ready()
	_spr.on_agent_reward_changed.connect(_on_reward_changed)
	_spr.on_agent_request_reset.connect(_reset)
	_is_resetting = false
	_spawn_new_food = 1

func _spawn_food() -> void:
	var size = get_window().size
	var x = randf_range(0, size.x)
	var y = randf_range(0, size.y)
	var item = Global.spawn_item(_item_food, Vector2(x, y))
	_food_list.append(item)

func _on_consume_item(item: Item) -> void:
	var index = _food_list.find(item)
	if index >= 0:
		_food_list.remove_at(index)
	super._on_consume_item(item)
	if not _is_resetting:
		_spawn_new_food += 1

func _on_reward_changed(reward: float) -> void:
	if reward > 1.0:
		_spr.set_agent_done(true)

func _reset() -> void:
	print("reset")
	_is_resetting = true
	_spr.reset_agent()
	for item in _food_list:
		item.consume()
	_spawn_new_food = 1
	_is_resetting = false

func _process(_delta: float) -> void:
	if _spawn_new_food > 0:
		for i in range(_spawn_new_food):
			_spawn_food()
	_spawn_new_food = 0
