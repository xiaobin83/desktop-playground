class_name ItemSun
extends Item

@export var _energy := 1.0
@export var _energy_consuming_speed := 0.1
@export var radius := 300.0

@onready var _collision_shape := $CollisionShape2D

var _current_energy: float

func _ready() -> void:
	_current_energy = _energy
	if _collision_shape.shape is CircleShape2D:
		_collision_shape.shape.radius = radius

func woke_up_from_pool() -> void:
	_current_energy = _energy

func consume(delta: float) -> float:
	var amount = _energy_consuming_speed * delta
	_current_energy -= amount
	if _current_energy <= 0.0:
		amount += _current_energy
		raise_on_consume()
	return amount

func get_endurance() -> float:
	return _current_energy / _energy

