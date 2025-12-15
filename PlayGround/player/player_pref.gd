class_name PlayerPref

const FILE_PATH := 'user://player_pref.json'

static var _player_pref := _load_player_pref()

static func _load_player_pref() -> Dictionary:
	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		if result != null:
			return result
		else:
			printerr('load PlayerPref error: %s' % [result.error_string])
	return {}

static func has_key(key: StringName) -> bool:
	return key in _player_pref

static func get_value(key: StringName, default: Variant = null) -> Variant:
	return _player_pref.get(key, default)

static func set_value(key: String, value: Variant) -> void:
	_player_pref.set(key, value)

static func flush() -> void:
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_player_pref))
		file.close()
	else:
		printerr('flush PlayerRef error')
