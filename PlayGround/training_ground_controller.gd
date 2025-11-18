extends GroundController

@export var _items : Array[PackedScene]

@onready var _spr :Spr = $Spr

var _is_resetting: bool
var _spawn_new_item: int = 0
var _last_reward: float = 0.0

var _item_list := []

func _ready() -> void:
	super._ready()
	_spr.on_agent_reward_changed.connect(_on_reward_changed)
	_spr.on_agent_request_reset.connect(_reset)
	_is_resetting = false
	_spawn_new_item = 1

func _get_random_item() -> PackedScene:
	var item = _items[randi_range(0, _items.size() - 1)]
	return item

func _spawn_one() -> void:
	var item = Global.spawn_item_at_random_position(_get_random_item())
	_item_list.append(item)

func _on_request_despawn(item: Item) -> void:
	var index = _item_list.find(item)
	if index >= 0:
		_item_list.remove_at(index)
	super._on_request_despawn(item)
	if not _is_resetting:
		_spawn_new_item += 1
		_spr.set_agent_done(_last_reward > 0.0)

func _on_reward_changed(reward: float) -> void:
	_last_reward = reward

func _reset() -> void:
	print("reset")
	_is_resetting = true
	_spr.reset_agent()
	for item in _item_list:
		item.despawn()
	_spawn_new_item = 1
	_is_resetting = false

func _process(_delta: float) -> void:
	if _spawn_new_item > 0:
		for i in range(_spawn_new_item):
			_spawn_one()
	_spawn_new_item = 0
