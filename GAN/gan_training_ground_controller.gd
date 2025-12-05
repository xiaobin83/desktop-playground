extends Node

@onready var _agent_builder := $AgentBuilder
@onready var _map := $Map
@onready var _sync := $Sync
@onready var _step_button = $StepButton

func _ready() -> void:
	_step_button.pressed.connect(_on_step_button_pressed)
	var pos = _map.get_random_position()
	_map.place_start_position(pos)
	_agent_builder.visit(_map, pos)

	_step_button.mouse_entered.connect(func () -> void:
		PlayerInput.notify_mouse_enter_control(_step_button)
	)
	_step_button.mouse_exited.connect(func () -> void:
		PlayerInput.notify_mouse_exit_control(_step_button)
	)

func _on_step_button_pressed() -> void:
	var step = _sync.new_step()
	_step_button.text = "Step: %d" % step
