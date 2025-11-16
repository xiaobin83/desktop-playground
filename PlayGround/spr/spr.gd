class_name Spr;

extends RigidBody2D;

@export var _counter: Node
@export var _engine_controller : GDScript 

var _engine_node

signal on_grabbed
signal on_dropped
signal on_touch_item(item: Item)

signal on_request_reset

var _is_grabbed: bool = false;

func _init() -> void:
	assert(NodeExt.fits(self, Pickable.interface))

func _enter_tree() -> void:
	_engine_node = $EngineController
	_engine_node.set_script(_engine_controller)

func _ready() -> void:
	NodeExt.call_in_children(self, 'notify_spr_initialized', self)

func _unhandled_input(event: InputEvent) -> void:
	_engine_node.process_unhandled_input(event)

func is_grabbed() -> bool:
	return _is_grabbed

func can_pickup() -> bool:
	return true

func notify_grabbed() -> void:
	_is_grabbed = true
	freeze = true
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	on_grabbed.emit();

func notify_dropped() -> void:
	_is_grabbed = false
	freeze = false
	on_dropped.emit();

func notify_hovering() -> void:
	pass

func _process(delta: float) -> void:
	_engine_node.process(delta)

func get_counter() -> Node:
	return _counter

# in physics update
func touch_item(item: Item) -> void:
	call_deferred('_touch_item', item)

func _touch_item(item: Item) -> void:
	on_touch_item.emit(item)
	item.consume()

func request_reset() -> void:
	on_request_reset.emit()
