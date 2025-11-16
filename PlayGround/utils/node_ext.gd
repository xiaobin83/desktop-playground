class_name NodeExt

static func call_in_children(node: Node, method: StringName, ...args) -> void:
	_call_in_children(node, method, args)

static func _call_in_children(node: Node, method: StringName, args: Array) -> void:
	for child in node.get_children():
		if child.has_method(method):
			child.callv(method, args) 
		_call_in_children(child, method, args) 

static func fits(node: Node, interface: Array) -> bool:
	for method in interface:
		if not node.has_method(method):
			return false 
	return true 

static func foreach_child(node: Node, callable: Callable):
	for child in node.get_children():
		callable.call(child)
		foreach_child(child, callable)

