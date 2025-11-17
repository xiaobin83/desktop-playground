extends Node

@onready var _igm :Node2D = $IGM
@onready var _spr :Spr = $Spr
@onready var _igm_area = $IGM/IGMArea

func _ready() -> void:
	_igm.global_position = get_window().size
	PlayerInput.set_igm_area(_igm_area)
	Global.respawn(_spr)

	_spr.on_agent_reward_changed.connect(_on_reward_changed)
	_spr.on_agent_request_reset.connect(_reset)

	Global.set_item_spawner(_spawn_item)

func _process(_delta: float) -> void:
	if not Global.is_in_play_ground(_spr):
		Global.respawn(_spr)

func _on_reward_changed(_reward: float) -> void:
	_spr.set_agent_done(true)

func _reset() -> void:
	_spr.reset_agent()

func _spawn_item(item: PackedScene, item_global_position :Vector2) -> Item:
	var item_instance= ObjectPool.allocate_packed_scene(item) as Item
	item_instance.on_consume.connect(_on_consume_item)
	item_instance.visible= true
	add_child(item_instance)
	item_instance.global_position = item_global_position
	return item_instance

func _on_consume_item(item: Item) -> void:
	item.on_consume.disconnect(_on_consume_item)
	item.visible = false
	ObjectPool.recycle(item)
