extends Node

@export var _root_control :Control 
@export var _simulate_player_label: Label
@export var _btn_connect :Button
@export var _text_room_id :TextEdit
@export var _conn :Connection 

var _local_user :LocalUser
var _printer :LocalUser.Printer

# called in _enter_tree
func set_local_user(local_user: LocalUser) -> void:
	_local_user = local_user
	_printer = local_user.get_printer()
	_printer.p('set_local_user %s, id = %s' % [_local_user.get_user_name(), _local_user.get_user_id()])

func _ready() -> void:
	_text_room_id.text = 'default'
	_simulate_player_label.text = _local_user.get_user_name()
	_btn_connect.pressed.connect(_on_btn_connect_pressed)
	_execlude_from_mouse_pass_through(_root_control)

func _execlude_from_mouse_pass_through(control: Control) -> void:
	if not control: return

	_notify_mouse_entered_and_exited(control)
	for child in control.get_children(true):
		if child is Control:
			_execlude_from_mouse_pass_through(child)

func _notify_mouse_entered_and_exited(control)  -> void:
	control.mouse_entered.connect(_on_mouse_entered.bind(control))
	control.mouse_exited.connect(_on_mouse_exited.bind(control))

func _on_btn_connect_pressed() -> void:
	print("start connection ...")
	await _conn.start_connection_async(_local_user.get_user_id(), _text_room_id.text)
	print('connected')

func _on_mouse_entered(control) -> void:
	PlayerInput.notify_mouse_enter_control(control)

func _on_mouse_exited(control) -> void:
	PlayerInput.notify_mouse_exit_control(control)
