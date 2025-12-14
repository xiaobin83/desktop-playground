class_name Utils

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
