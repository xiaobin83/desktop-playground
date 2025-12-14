class_name Utils

const UNKNOWN_ENUM_VALUE = &'unknown_enum_value'

static var _enum_map := {}

static func _get_enum_map(e: Dictionary) -> Dictionary:
	if e in _enum_map: return _enum_map.get(e)
	var map = {}
	for key in e: map[e[key]] = StringName(key)
	_enum_map[e] = map
	return map

static func get_enum_name(e: Dictionary, enum_value) -> StringName:
	return _get_enum_map(e).get(enum_value, UNKNOWN_ENUM_VALUE)

static func parse_int(s: String, default: int = 0) -> int:
	var clean = s.strip_edges()
	if clean.is_empty():
		return default 
	if clean.match(r"^-?\d+$"):
		return int(clean)
	return default 

static func try_parse_int(s: String) -> Variant:
	var clean = s.strip_edges()
	if clean.is_empty():
		return null 
	if clean.match(r"^-?\d+$"):
		return int(clean)
	return null 
