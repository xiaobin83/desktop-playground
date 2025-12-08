extends Node

@onready var _agent_builder :GanAgentBuilder = $AgentBuilder
@onready var _map := $Map
@onready var _sync := $Sync
@onready var _step_button = $StepButton
@onready var _auto_button = $AutoButton

var _cooldown = Cooldown.new(1.0)

func _ready() -> void:
	_step_button.pressed.connect(_on_step_button_pressed)
	_step_button.mouse_entered.connect(_on_hovering_button.bind(_step_button, true))
	_step_button.mouse_exited.connect(_on_hovering_button.bind(_step_button, false))

	_auto_button.pressed.connect(_on_auto_button_pressed)
	_auto_button.mouse_entered.connect(_on_hovering_button.bind(_auto_button, true))
	_auto_button.mouse_exited.connect(_on_hovering_button.bind(_auto_button, false))

	_start_new()

func _on_hovering_button(button, enter) -> void:
	if enter:
		PlayerInput.notify_mouse_enter_control(button)
	else:
		PlayerInput.notify_mouse_exit_control(button)

func _on_step_button_pressed() -> void:
	var step = _sync.new_step()
	_step_button.text = "Step: %d" % step

func _on_auto_button_pressed() -> void:
	_sync.toggle_controlled_training_step()

func _start_new() -> void:
	var pos = _map.get_random_position()
	_map.place_start_position(pos)
	_agent_builder.visit(_map, pos)

func _process(delta) -> void:
	if _agent_builder.needs_reset:
		if _cooldown.process(delta):
			_agent_builder.reset()
			_map.reset()
			_sync.reset_training_step()
			_start_new()
