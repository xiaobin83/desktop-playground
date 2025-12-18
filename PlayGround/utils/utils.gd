class_name Utils

const UNKNOWN_ENUM_VALUE = &'unknown_enum_value'

static var _enum_map := {}
static var _enum_reverse_map = {}

static func _get_enum_map(e: Dictionary) -> Dictionary:
	if e in _enum_map: return _enum_map.get(e)
	var map = {}
	for key in e: map[e[key]] = StringName(key)
	_enum_map[e] = map
	return map

static func _get_enum_reverse_map(e: Dictionary) -> Dictionary:
	if e in _enum_reverse_map: return _enum_reverse_map.get(e)
	var map = {}
	for key in e: map[key.to_lower()] = int(e[key])
	_enum_reverse_map[e] = map
	return map

static func get_enum_name(e: Dictionary, enum_value) -> StringName:
	return _get_enum_map(e).get(enum_value, UNKNOWN_ENUM_VALUE)

static func get_enum_value(e: Dictionary, enum_name: String) -> Variant:
	return _get_enum_reverse_map(e).get(enum_name.to_lower(), null)

static func parse_args(args: Array[String]) -> Dictionary:
	var result = {}
	for arg in args:
		if arg.begins_with('--'):
			var split = arg.substr(2).split('=', false, 2)
			if split.size() == 2:
				result[split[0]] = split[1]
			else:
				result[split[0]] = true
	return result

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

static func create_regex(pattern: String) -> RegEx:
	var regex = RegEx.new()
	var error = regex.compile(pattern)
	if error != OK:
		push_error('Failed to compile regex pattern: %s' % pattern)
		return null
	return regex
