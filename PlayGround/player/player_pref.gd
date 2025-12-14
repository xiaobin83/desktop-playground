class_name PlayerPref

static var _player_pref := {}

static func has_key(key: StringName) -> bool:
	return key in _player_pref

static func get_value(key: StringName, default: Variant = null) -> Variant:
	return _player_pref.get(key, default)

static func set_value(key: String, value: Variant) -> void:
	_player_pref.set(key, value)

static func flush() -> void:
	var file = FileAccess.open('user://player_pref.json', FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_player_pref))
		file.close()
	else:
		printerr('flush PlayerRef error')