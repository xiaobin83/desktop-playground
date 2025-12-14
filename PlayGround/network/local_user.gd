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

func get_user_name() -> String:
	return _name

func get_user_id() -> String:
	var id: String
	if not PlayerPref.has_key(_user_id_key):
		id = OS.get_unique_id()
		PlayerPref.set_value(_user_id_key, id)
	else:
		id = PlayerPref.get_value(_user_id_key)
	return id


class Printer:
	var _p: Callable
	var _err: Callable

	func p(...args) -> void:
		_p.callv(args)
	
	func err(...args) -> void:
		_err.callv(args)

var _printer: Printer 

func get_printer() -> Printer:
	if _printer: return _printer
	_printer = Printer.new()
	var tag = '[%s]' % _name
	_printer._p = print.bind(tag)
	_printer._err = printerr.bind(tag)
	return _printer



