extends Node

@export var _meshInstance2D: MeshInstance2D;
@export var _thick : float = 10.0;

var _immediateMesh: ImmediateMesh;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_immediateMesh = _meshInstance2D.mesh as ImmediateMesh;

	var window = get_window();
	window.mouse_passthrough = true;
	create_world_boundary(window.size);

func create_world_boundary(size: Vector2) -> void:
	var area = Area2D.new();

	_immediateMesh.clear_surfaces();
	_immediateMesh.surface_begin(Mesh.PRIMITIVE_LINES);
	_immediateMesh.surface_set_color(Color.RED);

	# up
	var collision = CollisionShape2D.new();
	var rect = RectangleShape2D.new();
	rect.extents = Vector2(size.x / 2, _thick);
	collision.shape = rect;
	collision.position = Vector2(size.x / 2, 0);
	area.add_child(collision);

	var t2 = _thick / 2;

	_immediateMesh.surface_add_vertex(Vector3(0, t2, 0));
	_immediateMesh.surface_add_vertex(Vector3(size.x, t2, 0));

	# down
	collision = CollisionShape2D.new();
	rect = RectangleShape2D.new();
	rect.extents = Vector2(size.x / 2, _thick);
	collision.shape = rect;
	collision.position = Vector2(size.x / 2, size.y);
	area.add_child(collision);

	_immediateMesh.surface_add_vertex(Vector3(0, size.y - t2, 0));
	_immediateMesh.surface_add_vertex(Vector3(size.x, size.y - t2, 0));

	# left
	collision = CollisionShape2D.new();
	rect = RectangleShape2D.new();
	rect.extents = Vector2(_thick, size.y / 2);
	collision.shape = rect;
	collision.position = Vector2(0, size.y / 2);
	area.add_child(collision);

	_immediateMesh.surface_add_vertex(Vector3(t2, 0, 0));
	_immediateMesh.surface_add_vertex(Vector3(t2, size.y, 0));

	# right
	collision = CollisionShape2D.new();
	rect = RectangleShape2D.new();
	rect.extents = Vector2(_thick, size.y / 2);
	collision.shape = rect;
	collision.position = Vector2(size.x, size.y / 2);
	area.add_child(collision);

	_immediateMesh.surface_add_vertex(Vector3(size.x - t2, 0, 0));
	_immediateMesh.surface_add_vertex(Vector3(size.x - t2, size.y, 0));

	_immediateMesh.surface_end();

	add_child(area);
