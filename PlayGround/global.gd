extends Node

@export var _thick : float = 10.0;

var _item_spawner: Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var window = get_window();
	window.mouse_passthrough = true;
	create_world_boundary(window.size);

func create_world_boundary(size: Vector2) -> void:
	var area = StaticBody2D.new();
	area.collision_layer = ~0
	area.collision_mask = 0

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

func is_in_play_ground(spr: Spr):
	var size = get_window().size;
	var pos = spr.global_position;
	if pos.x < -_thick or pos.x > size.x + _thick \
		or pos.y < -_thick or pos.y > size.y + _thick:
		return false;
	return true;

func respawn(spr: Spr):
	var size = get_window().size;
	spr.freeze = true;
	spr.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	await get_tree().create_timer(1).timeout
	spr.global_position = Vector2(size.x / 2, size.y / 2);
	spr.linear_velocity = Vector2.ZERO;
	spr.angular_velocity = 0;
	spr.freeze = false;

func set_item_spawner(callable: Callable) -> void:
	_item_spawner = callable

func spawn_item(item: PackedScene, item_global_position :Vector2) -> Item:
	assert(_item_spawner, "no spawner provided")
	return _item_spawner.call(item, item_global_position) as Item;

func spawn_item_at_random_position(item: PackedScene) -> Item:
	assert(_item_spawner, "no spawner provided")
	return _item_spawner.call(item, get_random_position())

func get_random_position() -> Vector2:
	var size = get_window().size
	var x = randf_range(0, size.x)
	var y = randf_range(0, size.y)
	return Vector2(x, y)
