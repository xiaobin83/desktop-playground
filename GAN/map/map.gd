class_name Map
extends Node

@export var _size : Vector2i = Vector2i(10, 10)

enum Direction {
	None = -1, North = 0, West, South, East, Count
}

class Grid:
	var blockers: Array = [GanWorld.Blocker.None, GanWorld.Blocker.None, GanWorld.Blocker.None,GanWorld.Blocker.None]
	var inner_item := GanWorld.InnerItem.None
	var visited := false
	var built := false

	static var _channel_size := Grid.new().encode(0).size()

	static func get_channel_size() -> int:
		return _channel_size

	func place_start() -> void:
		inner_item = GanWorld.InnerItem.Start
		built = true

	func encode(has_agent: bool) -> Array[float]:
		var arr :Array[float] = []
		# blockers
		for b in blockers:
			arr.append(GanWorld.encode_blocker(b))
		# inner item
		arr.append(GanWorld.encode_inner_item(inner_item))
		# visited
		if visited: arr.append(1)
		else: arr.append(0)

		if has_agent: arr.append(1)
		else: arr.append(0)

		if built: arr.append(1)
		else: arr.append(0)

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
	reset()

func reset() -> void:
	_data = []
	for y in _size.y:
		for x in _size.x:
			_data.append(Grid.new())
	_inventory = Inventory.new()

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
	# (channel, x, y)
	for i in channel_size:
		var layer = []
		for k in view_sz:
			layer.append(_filled_array(0.0, view_sz))
		local_map.append(layer)
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var grid_x = pos.x + dx
			var grid_y = pos.y + dy
			var view_x = dx + radius
			var view_y = dy + radius
			if grid_x >= 0 and grid_x < _size.x and grid_y >= 0 and grid_y < _size.y:
				var grid = _data[grid_y * _size.x + grid_x]
				var has_agent = dx == 0 and dy == 0
				var layer_of_grid = grid.encode(has_agent)
				for index in layer_of_grid.size():
					var p = layer_of_grid[index]
					local_map[index][view_y][view_x] = p

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
	_data[to_index(pos)].place_start()

func place_blocker(pos: Vector2i, direction: int, blocker: GanWorld.Blocker) -> void:
	_assert(pos)
	_data[pos.y * _size.x + pos.x].blockers[direction] = blocker

func place_blockers(pos: Vector2i, blockers: Array[GanWorld.Blocker]) -> float:
	_assert(pos)
	var target_blockers = _data[pos.y * _size.x + pos.x].blockers 
	var count = 0
	var total_count = 0
	for dir in range(Direction.Count):
		total_count += 1
		var next_pos = get_next_pos(pos, dir)
		if is_valid(next_pos):
			var other_blocker = get_blocker(next_pos, _get_counter_direction(dir))
			if other_blocker != GanWorld.Blocker.Path:
				target_blockers[dir] = blockers[dir]
				count += 1
	if total_count == 0: return 1.0
	return count as float / total_count

func place_inner_item(pos: Vector2i, inner_item: GanWorld.InnerItem) -> void:
	_assert(pos)
	var index = to_index(pos)
	_data[index].inner_item = inner_item

func visit(pos: Vector2i) -> float:
	_assert(pos)
	var index = to_index(pos)
	if not _data[index].visited:
		_data[index].visited = true
		return 1.0
	return 0.0

func to_index(pos: Vector2i) -> int:
	return pos.y * _size.x + pos.x

func try_build(pos: Vector2i) -> bool:
	_assert(pos)
	var i = pos.y * _size.x + pos.x
	if not _data[i].built:
		_data[i].built = true
		return true
	return false

static func _direction_to_vector(direction: Direction) -> Vector2i:
	match direction:
		Direction.North:
			return Vector2i(0, -1) # north
		Direction.West:
			return Vector2i(-1, 0) # west
		Direction.South:
			return Vector2i(0, 1) # south
		Direction.East:
			return Vector2i(1, 0) # east
		_:
			return Vector2i.ZERO

func _direction_valid(direction: int) -> bool:
	return direction >= 0 and direction <= 3

func is_trapped(pos: Vector2i) -> bool:
	for direction in range(Direction.Count):
		if can_move(pos, direction):
			return false
	return true

func get_blocker(pos: Vector2i, direction: int) -> GanWorld.Blocker:
	_assert(pos)
	assert(direction < 4) # 4 directions
	return _data[pos.y * _size.x + pos.x].blockers[direction]

func can_move(pos: Vector2i, direction: Direction) -> bool:
	if not _direction_valid(direction):
		return false
	var blocker = get_blocker(pos, direction)
	if blocker > GanWorld.Blocker.Path:
		return false

	var next_pos = get_next_pos(pos, direction)
	if next_pos.x < 0 or next_pos.x >= _size.x:
		return false
	if next_pos.y < 0 or next_pos.y >= _size.y:
		return false

	blocker = get_blocker(next_pos, _get_counter_direction(direction)) 
	if blocker > GanWorld.Blocker.Path:
		return false

	return true

func _get_counter_direction(direction: int) -> int:
	match direction:
		Direction.North:
			return Direction.South
		Direction.West:
			return Direction.East
		Direction.South:
			return Direction.North
		Direction.East:
			return Direction.West
		_:
			return Direction.None 

static func get_next_pos(pos: Vector2i, direction: Direction) -> Vector2i:
	return pos + _direction_to_vector(direction)

func move(pos: Vector2i, direction: int) -> Vector2i:
	place_blocker(pos, direction, GanWorld.Blocker.Path)
	return _move(pos, _direction_to_vector(direction))

func _move(pos: Vector2i, direction: Vector2i) -> Vector2i:
	_assert(pos)
	var new_pos = pos + direction
	_assert(new_pos)
	return new_pos

func is_valid(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < _size.x and pos.y >= 0 and pos.y < _size.y

func _assert(pos: Vector2i) -> void:
	assert(is_valid(pos), 'Position %s out of map size %s' % [pos, _size])
