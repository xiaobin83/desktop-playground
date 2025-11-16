class_name Pickable

const interface := [&"can_pickup", &"notify_grabbed", &"notify_dropped", &"notify_hovering"]

class PickableInterface:

	var _node: Node2D

	func _init(node: Node2D) -> void:
		_node = node

	func can_pickup() -> bool:
		return _node != null and _node.can_pickup()
	
	func notify_grabbed() -> void:
		if _node != null:
			_node.notify_grabbed()
	
	func notify_dropped() -> void:
		if _node != null:
			_node.notify_dropped()

	func notify_hovering() -> void:
		if _node != null:
			_node.notify_hovering()

	func set_node(node: Node2D) -> void:
		_node = node

	func get_node() -> Node2D:
		return _node

	func clone() -> PickableInterface:
		return PickableInterface.new(_node)

static func try_wrap(pickable: PickableInterface, node: Node2D) -> bool:
	if pickable.get_node() == node:
		return true
	if NodeExt.fits(node, interface):
		pickable.set_node(node)
		return true
	return false


