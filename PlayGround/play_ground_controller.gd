extends GroundController

@onready var _igm :Node2D = $IGM
@onready var _spr :Spr = $Spr
@onready var _igm_area = $IGM/IGMArea

func _ready() -> void:
	super._ready()

	_igm.global_position = get_window().size
	PlayerInput.set_igm_area(_igm_area)
	Global.respawn(_spr)
	_spr.on_agent_request_reset.connect(_reset)

func _process(_delta: float) -> void:
	if not Global.is_in_play_ground(_spr):
		Global.respawn(_spr)

func _on_request_despawn(item: Item) -> void:
	_spr.set_agent_done(true)
	super._on_request_despawn(item)

func _reset() -> void:
	_spr.reset_agent()
