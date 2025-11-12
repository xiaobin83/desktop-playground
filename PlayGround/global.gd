extends Node

@export var _thick : float = 10.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var window = get_window();
	window.mouse_passthrough = true;
	create_world_boundary(window.size);


func create_world_boundary(size: Vector2) -> void:
	var area = StaticBody2D.new();

	# up
	var collision = CollisionShape2D.new();
	var rect = RectangleShape2D.new();
	rect.extents = Vector2(size.x / 2, _thick);
	collision.shape = rect;
	collision.position = Vector2(size.x / 2, -_thick);
	area.add_child(collision);


	# down
	collision = CollisionShape2D.new();
	rect = RectangleShape2D.new();
	rect.extents = Vector2(size.x / 2, _thick);
	collision.shape = rect;
	collision.position = Vector2(size.x / 2, size.y + _thick);
	area.add_child(collision);

	# left
	collision = CollisionShape2D.new();
	rect = RectangleShape2D.new();
	rect.extents = Vector2(_thick, size.y / 2);
	collision.shape = rect;
	collision.position = Vector2(-_thick, size.y / 2);
	area.add_child(collision);

	# right
	collision = CollisionShape2D.new();
	rect = RectangleShape2D.new();
	rect.extents = Vector2(_thick, size.y / 2);
	collision.shape = rect;
	collision.position = Vector2(size.x + _thick, size.y / 2);
	area.add_child(collision);

	add_child(area);
