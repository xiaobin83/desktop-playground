class_name Pickable

const interfaces := [&"can_pickup", &"notify_grabbed", &"notify_dropped", &"notify_hovering"]
const signals := [&"on_grabbed", &"on_dropped", &"on_hovering"]

# signals
class PickableSignals:

	var _node: Node2D

	signal on_grabbed
	signal on_dropped
	signal on_hovering

	func _init(node: Node2D) -> void:
		_node = node
		_add_connections()

	func _add_connections():
		if _node: 
			_node.on_grabbed.connect(_on_grabbed)
			_node.on_dropped.connect(_on_dropped)
			_node.on_hovering.connect(_on_hovering)

	func _remove_connections():
		if _node: 
			_node.on_grabbed.disconnect(_on_grabbed)
			_node.on_dropped.disconnect(_on_dropped)
			_node.on_hovering.disconnect(_on_hovering)
	
	func _on_grabbed() -> void:
		on_grabbed.emit()

	func _on_dropped() -> void:
		on_dropped.emit()

	func _on_hovering() -> void:
		on_hovering.emit()

	func set_node(node: Node2D) -> void:
		_remove_connections()
		_node = node
		_add_connections()

	func get_node() -> Node2D:
		return _node
	
	func clone() -> PickableSignals:
		return PickableSignals.new(_node)
		
# interfaces 
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
	if NodeExt.has_methods(node, interfaces):
		pickable.set_node(node)
		return true
	return false

static func try_connect(pickable: PickableSignals, node: Node2D) -> bool:
	if pickable.get_node() == node:
		return true
	if NodeExt.has_signals(node, signals):
		pickable.set_node(node)
		return true
	return false
