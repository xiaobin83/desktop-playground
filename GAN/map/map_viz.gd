extends Node2D

@export var _map :Map;
@export var _agent_builder :GanAgentBuilder

@export var _cell_size : Vector2 = Vector2(32, 32)
@export var _grid_color : Color = Color(0.8, 0.8, 0.8)

func _ready() -> void:
	_agent_builder.on_action.connect(_on_agent_action)

func _on_agent_action() -> void:
	queue_redraw()

func _draw() -> void:
	_draw_map()
	_draw_builder()

func _draw_builder() -> void:
	var posi = _agent_builder.get_grid_pos()
	var pos = Vector2(posi.x, posi.y)
	var draw_pos = pos * _cell_size + _cell_size / 2
	draw_circle(draw_pos, 8, Color(1, 0, 0))

	var obs = _agent_builder.get_obs() # just for debug
	if obs:
		pass

func _draw_map() -> void:
	var map_size = _map.get_size()
	var data = _map.get_data()
	for y in map_size.y:
		for x in map_size.x:
			var grid = data[y * map_size.x + x]
			var pos = Vector2(x, y) * _cell_size
			# draw grid
			draw_rect(Rect2(pos, _cell_size), _grid_color, false, 1)
			# draw blockers
			if grid.blocker_north != GanWorld.Blocker.None:
				draw_line(pos, pos + Vector2(_cell_size.x, 0), Color.RED, 4)
			if grid.blocker_west != GanWorld.Blocker.None:
				draw_line(pos, pos + Vector2(0, _cell_size.y), Color.RED, 4)
			if grid.blocker_south != GanWorld.Blocker.None:
				draw_line(pos + Vector2(0, _cell_size.y), pos + _cell_size, Color.RED, 4)
			if grid.blocker_east != GanWorld.Blocker.None:
				draw_line(pos + Vector2(_cell_size.x, 0), pos + _cell_size, Color.RED, 4)
			# draw inner items
			if grid.inner_item == GanWorld.InnerItem.Treasure:
				draw_circle(pos + _cell_size / 2, 8, Color.YELLOW)
			elif grid.inner_item == GanWorld.InnerItem.Exit:
				draw_rect(Rect2(pos + _cell_size / 4, _cell_size / 2), Color.GREEN)

			if grid.visited:
				draw_circle(pos + _cell_size / 2, 10, Color.BLUE)
