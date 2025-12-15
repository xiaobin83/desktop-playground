class_name LocalUser
extends RefCounted

const USER_ID := &'user_id'

var _name := ''
var _user_id_key: StringName

static func create_local_user(name: String) -> LocalUser:
	var local_user = LocalUser.new(name)
	return local_user

func _init(name: String) -> void:
	_name = name
	_user_id_key = '%s_%s' % [USER_ID, _name]

func get_user_name() -> String:
	return _name

func get_user_id() -> String:
	var id: String
	if not PlayerPref.has_key(_user_id_key):
		if _name != null and _name.length() > 0:
			id = _name + '_' + OS.get_unique_id()
		else:
			id = OS.get_unique_id()
		PlayerPref.set_value(_user_id_key, id)
		PlayerPref.flush()
	else:
		id = PlayerPref.get_value(_user_id_key)
	return id

var _printer: Printer

func get_printer(extra_tag: String) -> Printer:
	if _printer: return _printer
	var tag = '[%s][%s]' % [_name, extra_tag]
	_printer = Printer.new(tag)
	return _printer
