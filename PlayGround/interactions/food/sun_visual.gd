extends Node2D

@export var _item: Node2D
@export var _min_radius := 10.0
@export var _radius := 300.0
@export var _move_speed := 100.0
@export var _rotation_speed := 1.0 

@onready var _progress_bar: ProgressBar = $ProgressBar

var _pickable_signals := Pickable.PickableSignals.new(null)
var _target_radius :float
var _current_radius :float
var _angle := 0.0
var _leaves: Array
var _item_sun : ItemSun 

func _ready() -> void:
	if _item:
		if Pickable.try_connect(_pickable_signals, _item):
			_pickable_signals.on_grabbed.connect(_on_grabbed)
			_pickable_signals.on_dropped.connect(_on_dropped)
		if _item is ItemSun:
			_progress_bar.visible = true
			_item_sun = _item
			_current_radius = _min_radius
			_radius = _item.radius
			_target_radius = _radius
		else:
			_progress_bar.visible = false 
			_current_radius = _min_radius
			_target_radius = _min_radius

	_leaves = $Dots.get_children()
	
func _on_grabbed() -> void:
	_target_radius = _radius

func _on_dropped() -> void:
	_target_radius = _min_radius

func _process(delta: float) -> void:
	if _item_sun:
		_progress_bar.value = _item_sun.get_endurance()

	_angle += delta * _rotation_speed
	if _angle > 180.0:
		_angle -= 360.0
	elif _angle < -180.0:
		_angle += 360.0

	_current_radius = lerpf(_current_radius, _target_radius, delta * _move_speed)
	
	var count = _leaves.size()
	if count > 1:
		var angle_step = 360.0 / count
		var angle = _angle
		for leaf in _leaves:
			leaf.position = Vector2(0.0, _current_radius).rotated(deg_to_rad(angle))
			angle += angle_step
			if angle > 180.0:
				angle -= 360.0
			elif angle < -180.0:
				angle += 360.0
	elif count == 1:
		_leaves[0].position = Vector2.ZERO
