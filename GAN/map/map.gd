class_name Map
extends Node

@export var _size : Vector2i = Vector2i(10, 10)

class Grid:
	var blocker_north := GanWorld.Blocker.None
	var blocker_west := GanWorld.Blocker.None
	var blocker_south := GanWorld.Blocker.None
	var blocker_east := GanWorld.Blocker.None
	var inner_item := GanWorld.InnerItem.None
	var visited := false

	static var _channel_size := Grid.new().encode(Vector2.ZERO).size()

	static func get_channel_size() -> int:
		return _channel_size

	func place_start() -> void:
		inner_item = GanWorld.InnerItem.Start

	func encode(normalized_pos: Vector2) -> Array[float]:
		var arr :Array[float] = []
		# blockers
		arr.append(GanWorld.encode_blocker(blocker_north))
		arr.append(GanWorld.encode_blocker(blocker_west))
		arr.append(GanWorld.encode_blocker(blocker_south))
		arr.append(GanWorld.encode_blocker(blocker_east))
		# inner item
		arr.append(GanWorld.encode_inner_item(inner_item))
		# visited
		if visited: arr.append(1)
		else: arr.append(0)
		# position (normalized)
		arr.append(normalized_pos.x)
		arr.append(normalized_pos.y)
		return arr

class Inventory:
	var count_exit := 0
	var count_treasure := 0

	static var _channel_size := Inventory.new().encode().size()

	static func get_channel_size() -> int:
		return _channel_size

	func encode() -> Array[float]:
		var arr :Array[float] = []
		arr.append(float(count_exit))
		arr.append(float(count_treasure))
		return arr

	static func encode_empty() -> Array[float]:
		var arr :Array[float] = []
		arr.append(0.0) # count_exit
		arr.append(0.0) # count_treasure
		return arr

var _data : Array[Grid]
var _inventory : Inventory = Inventory.new()

func _enter_tree() -> void:
	_data = []
	for y in _size.y:
		for x in _size.x:
			_data.append(Grid.new())

func get_size() -> Vector2i:
	return _size

func get_data() -> Array[Grid]:
	return _data

static func _filled_array(value, size: int) -> Array:
	var arr = []
	for i in size:
		arr.append(value)
	return arr

func get_local_map_encoded(pos: Vector2i, radius: int) -> Array:
	var view_sz = radius * 2 + 1
	var channel_size = Grid.get_channel_size()
	var local_map = []
	for i in view_sz * view_sz:
		local_map.append(_filled_array(0.0, channel_size))
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var grid_x = pos.x + dx
			var grid_y = pos.y + dy
			var view_x = dx + radius
			var view_y = dy + radius
			if grid_x >= 0 and grid_x < _size.x and grid_y >= 0 and grid_y < _size.y:
				var grid = _data[grid_y * _size.x + grid_x]
				var normalized_pos = Vector2(grid_x / float(_size.x - 1), grid_y / float(_size.y - 1))
				local_map[view_y * view_sz + view_x] = grid.encode(normalized_pos)

	return local_map

static func get_empty_local_map_encoded(radius: int) -> Array:
	var view_sz = radius * 2 + 1
	var channel_size = Grid.get_channel_size()
	var local_map = []
	for i in view_sz * view_sz:
		local_map.append(_filled_array(0.0, channel_size))
	return local_map

func get_inventory_encoded() -> Array[float]:
	return _inventory.encode()

static func get_empty_inventory_encoded() -> Array[float]:
	return Inventory.encode_empty()

func get_random_position() -> Vector2i:
	var x = randi_range(0, _size.x - 1)
	var y = randi_range(0, _size.y - 1)
	return Vector2i(x, y)

func place_start_position(pos: Vector2i) -> void:
	_assert(pos)
	_data[pos.y * _size.x + pos.x].place_start()

func place_blocker_north(pos: Vector2i, blocker: GanWorld.Blocker) -> void:
	_assert(pos)
	_data[pos.y * _size.x + pos.x].blocker_north = blocker

func place_blocker_west(pos: Vector2i, blocker: GanWorld.Blocker) -> void:
	_assert(pos)
	_data[pos.y * _size.x + pos.x].blocker_west = blocker

func place_blocker_south(pos: Vector2i, blocker: GanWorld.Blocker) -> void:
	_assert(pos)
	_data[pos.y * _size.x + pos.x].blocker_south = blocker

func place_blocker_east(pos: Vector2i, blocker: GanWorld.Blocker) -> void:
	_assert(pos)
	_data[pos.y * _size.x + pos.x].blocker_east = blocker

func place_inner_item(pos: Vector2i, inner_item: GanWorld.InnerItem) -> void:
	_assert(pos)
	_data[pos.y * _size.x + pos.x].inner_item = inner_item

func visit(pos: Vector2i) -> void:
	_assert(pos)
	_data[pos.y * _size.x + pos.x].visited = true

func _direction_to_vector(direction: int) -> Vector2i:
	match direction:
		0:
			return Vector2i(0, -1) # north
		1:
			return Vector2i(-1, 0) # west
		2:
			return Vector2i(0, 1) # south
		3:
			return Vector2i(1, 0) # east
		_:
			return Vector2i.ZERO

func _direction_valid(direction: int) -> bool:
	return direction >= 0 and direction <= 3

func is_trapped(pos: Vector2i) -> bool:
	for direction in 4:
		if can_move(pos, direction):
			return false
	return true

func can_move(pos: Vector2i, direction: int) -> bool:
	if not _direction_valid(direction):
		return false
	var v = _direction_to_vector(direction)
	return _can_move(pos, v)

func _can_move(pos: Vector2i, direction: Vector2i) -> bool:
	_assert(pos)
	var x = pos.x
	var y = pos.y
	if direction == Vector2i(0, -1): # north
		if y <= 0:
			return false
		var grid = _data[y * _size.x + x]
		if grid.blocker_north != GanWorld.Blocker.None:
			return false
	elif direction == Vector2i(-1, 0): # west
		if x <= 0:
			return false
		var grid = _data[y * _size.x + x]
		if grid.blocker_west != GanWorld.Blocker.None:
			return false
	elif direction == Vector2i(0, 1): # south
		if y >= _size.y - 1:
			return false
		var grid = _data[y * _size.x + x]
		if grid.blocker_south != GanWorld.Blocker.None:
			return false
	elif direction == Vector2i(1, 0): # east
		if x >= _size.x - 1:
			return false
		var grid = _data[y * _size.x + x]
		if grid.blocker_east != GanWorld.Blocker.None:
			return false
	return true

func move(pos: Vector2i, direction: Vector2i) -> Vector2i:
	_assert(pos)
	var new_pos = pos + direction
	_assert(new_pos)
	return new_pos

func _assert(pos: Vector2i) -> void:
	assert(pos.x >= 0 and pos.x < _size.x and pos.y >= 0 and pos.y < _size.y, 'Position %s out of map size %s' % [pos, _size])
