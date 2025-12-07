extends Node2D

@export var _map :Map;
@export var _agent_builder :GanAgentBuilder

@export var _cell_size : Vector2 = Vector2(32, 32)
@export var _grid_color : Color = Color(0.8, 0.8, 0.8)

var _agent_trajectory : Array[Vector2i] = []

func _ready() -> void:
	_agent_builder.on_action.connect(_on_agent_action)

func _on_agent_action(type: GanAgentBuilder.ActionType) -> void:
	match type:
		GanAgentBuilder.ActionType.Reset:
			_agent_trajectory.clear()
		GanAgentBuilder.ActionType.Move:
			_agent_trajectory.append(_agent_builder.get_grid_pos())
		GanAgentBuilder.ActionType.Place:
			pass
	queue_redraw()

func _draw() -> void:
	_draw_map()
	_draw_builder()
	_draw_trajectory()

func _draw_trajectory() -> void:
	for i in range(0, _agent_trajectory.size() - 1):
		var p0 = _agent_trajectory[i]
		var p1 = _agent_trajectory[i+1]
		var pos0 = Vector2(p0.x, p0.y) * _cell_size + _cell_size / 2
		var pos1 = Vector2(p1.x, p1.y) * _cell_size + _cell_size / 2
		draw_line(pos0, pos1, Color.GREEN)

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
			for dir in range(GanWorld.Blocker.Count):
				var blocker = grid.blockers[dir]
				if blocker <= GanWorld.Blocker.Path:
					continue
				match dir:
					Map.Direction.North:
						draw_line(pos, pos + Vector2(_cell_size.x, 0), Color.RED, 4)
					Map.Direction.West:
						draw_line(pos, pos + Vector2(0, _cell_size.y), Color.RED, 4)
					Map.Direction.South:
						draw_line(pos + Vector2(0, _cell_size.y), pos + _cell_size, Color.RED, 4)
					Map.Direction.East:
						draw_line(pos + Vector2(_cell_size.x, 0), pos + _cell_size, Color.RED, 4)

			# draw inner items
			match grid.inner_item:
				GanWorld.InnerItem.Treasure:
					draw_circle(pos + _cell_size / 2, 8, Color.YELLOW)
				GanWorld.InnerItem.Start:
					draw_rect(Rect2(pos + _cell_size / 4, _cell_size / 2), Color.SEA_GREEN)
				GanWorld.InnerItem.Exit:
					draw_rect(Rect2(pos + _cell_size / 4, _cell_size / 2), Color.GREEN)

			# status
			if grid.visited:
				draw_circle(pos + _cell_size / 2, 10, Color.BLUE)
