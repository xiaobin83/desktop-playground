extends Node2D

var _mouse_position: Vector2;

var _mouse_pass_through: bool = true 
var _hovering_on_igm: bool = false
var _was_in_igm_area: bool

var _hovering_pickable := Pickable.PickableInterface.new(null)

var _current_pickable :Pickable.PickableInterface
var _grab_offset: Vector2;
var _igm_area

signal on_enter_igm_area
signal on_exit_igm_area

func set_igm_area(igm_area) -> void:
	_igm_area = igm_area

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_mouse_position = event.position;
		_check_hovering(event.position)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT: 
			if event.pressed:
				_try_pickup();
			elif event.is_released():
				_drop();

func _check_hovering(mousePosition: Vector2) -> void:
	var state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mousePosition
	query.collide_with_bodies = true
	query.collide_with_areas = true

	_hovering_pickable.set_node(null)
	_hovering_on_igm = false
	var result = state.intersect_point(query)
	if result:
		for collision in result:
			var wrapped = Pickable.try_wrap(_hovering_pickable, collision.collider)
			if wrapped:
				_hovering_pickable.notify_hovering()
			else:
				if collision.collider == _igm_area:
					_hovering_on_igm = true

func _try_pickup() -> void:
	if _current_pickable != null:
		return

	if _hovering_pickable.can_pickup():
		_grab_hovering()

func _grab_hovering():
	_current_pickable = _hovering_pickable.clone() 
	_current_pickable.notify_grabbed()
	_grab_offset = _current_pickable.get_node().global_position - _mouse_position

func _drop() -> void:
	if _current_pickable != null:
		_current_pickable.notify_dropped()
		_current_pickable = null

func _is_hovering_on_any() -> bool:
	return _hovering_pickable.get_node() != null

func _process(_delta: float) -> void:
	if not _mouse_pass_through:
		if not _is_hovering_on_any():
			get_window().mouse_passthrough = true;
			_mouse_pass_through = true;
	else:
		if _is_hovering_on_any():
			get_window().mouse_passthrough = false;
			_mouse_pass_through = false;
	
	if _hovering_on_igm and not _was_in_igm_area:
		on_enter_igm_area.emit()
		_was_in_igm_area = true
	elif _was_in_igm_area and not _hovering_on_igm:
		on_exit_igm_area.emit()
		_was_in_igm_area = false

func _physics_process(_delta: float) -> void:
	if _current_pickable != null:
		_current_pickable.get_node().global_position = _mouse_position + _grab_offset;
