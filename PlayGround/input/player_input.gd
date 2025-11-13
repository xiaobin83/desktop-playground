extends Node2D

var _spr_grab_offset: Vector2;
var _current_spr: Spr; 
var _hovering_spr: Spr; 
var _has_interacting_spr: bool = false;
var _mouse_position: Vector2;

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
	var state = get_world_2d().direct_space_state;
	var query = PhysicsPointQueryParameters2D.new();
	query.position = mousePosition;
	query.collide_with_bodies = true;
	var result = state.intersect_point(query);
	if result:
		for collision in result:
			if collision.collider is Spr:
				_hovering_spr = collision.collider;
				return;
	_hovering_spr = null;

func _try_pickup() -> void:
	if _current_spr != null:
		return;
	
	if _hovering_spr != null and _hovering_spr.has_method('can_pickup'):
		if _hovering_spr.can_pickup():
			_grab(_hovering_spr);

func _grab(spr: Spr):
	if spr.has_method('notify_grabbed'):
		spr.notify_grabbed();
	_current_spr = spr;
	_spr_grab_offset = _current_spr.global_position - _mouse_position;
	_current_spr.freeze = true
	_current_spr.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC;

func _drop() -> void:
	if _current_spr != null:
		if _current_spr.has_method('notify_dropped'):
			_current_spr.notify_dropped();
		_current_spr.freeze = false
		_current_spr = null;

func _process(_delta: float) -> void:
	if !_has_interacting_spr:
		if _hovering_spr != null or _current_spr != null:
			get_window().mouse_passthrough = false;
			_has_interacting_spr = true;
	else:
		if _hovering_spr == null and _current_spr == null:
			get_window().mouse_passthrough = true;
			_has_interacting_spr = false;

	

func _physics_process(_delta: float) -> void:
	if _current_spr != null:
		_current_spr.global_position = _mouse_position + _spr_grab_offset;
