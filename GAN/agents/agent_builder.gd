"""
Agent Builder
	Build a map with items listed in GanWorld.Blocker and GanWorld.InnerItem

	# Move-and-build
	Rule,
		1. The world is composed by m*n grids
		2. Each grid contains 0 ~ 1 InnerItem
		3. Each grid has blockers to the 4 sides; north, south, east, and west
		4. After the builder build a cell, he goes to the next grid. And he can only go
			through GanWorld.Blocker.None
		5. The generation process ends
			if he cannot move
			or a GanWorld.Inner.Exit is placed

	Action,
		- move, 4 direction
		- placement blockers, GanWorld.Blocker.Count blockers
		- placement inner, GanWorld.Inner.Count items

	Observation,
		Local,
			- Local map, center at the builder, 5x5 (see two steps further)
		Global,
			- numbers of items placed

	Reward,
		- has GanWorld.Inner.Exit placed
		- move to new grid
		- has other item placed
"""

class_name GanAgentBuilder
extends AIController2D

const CELL_VIEW_RADIUS := 2 # 5x5 grid
const OBS_LOCAL_MAP := &'local_map'
const OBS_INVENTORY := &'inventory'

const ACT_MOVE_DIR := &'move_dir'
const ACT_PLACE_BLOCKER_NORTH := &'pn'
const ACT_PLACE_BLOCKER_WEST := &'pw'
const ACT_PLACE_BLOCKER_SOUTH := &'ps'
const ACT_PLACE_BLOCKER_EAST := &'pe'
const ACT_PLACE_INNER := &'inner'

enum ActionType {
	Place, Move, Reset
}
signal on_action(type: ActionType)

var _grid_pos :Vector2i = Vector2i.ZERO
var _map :Map

# return 1 if not visited, 0 if already visited 
func visit(map: Map, pos: Vector2i) -> float:
	_map = map
	_grid_pos = pos
	var v = _map.visit(_grid_pos)
	on_action.emit(ActionType.Move)
	return v

func get_grid_pos() -> Vector2i:
	return _grid_pos

func get_obs() -> Dictionary:
	if _map:
		return {
			OBS_LOCAL_MAP: _map.get_local_map_encoded(_grid_pos, CELL_VIEW_RADIUS),
			OBS_INVENTORY: _map.get_inventory_encoded()
		}
	else:
		return {
			OBS_LOCAL_MAP: Map.get_empty_local_map_encoded(CELL_VIEW_RADIUS),
			OBS_INVENTORY: Map.get_empty_inventory_encoded()
		}

func get_action_space() -> Dictionary:
	return {
		ACT_MOVE_DIR: {
			'size': 4,
			'action_type': 'discrete'
		},
		ACT_PLACE_BLOCKER_NORTH: { # placement north
			'size': GanWorld.Blocker.Count,
			'action_type': 'discrete'
		},
		ACT_PLACE_BLOCKER_WEST: { # placement west
			'size': GanWorld.Blocker.Count,
			'action_type': 'discrete'
		},
		ACT_PLACE_BLOCKER_SOUTH: { # placement south
			'size': GanWorld.Blocker.Count,
			'action_type': 'discrete'
		},
		ACT_PLACE_BLOCKER_EAST: { # placement east
			'size': GanWorld.Blocker.Count,
			'action_type': 'discrete'
		},
		ACT_PLACE_INNER: { # inner content
			'size': GanWorld.InnerItem.Count,
			'action_type': 'discrete'
		}
	}

func get_obs_space() -> Dictionary:
	var view_sz = CELL_VIEW_RADIUS * 2 + 1
	return {
		# local map, view_sz * view_sz grid, each grid has channels
		OBS_LOCAL_MAP: {
			'size': [Map.Grid.get_channel_size(), view_sz, view_sz],
			'space': 'box'
		},
		OBS_INVENTORY: {
			'size': [Map.Inventory.get_channel_size()],
			'space': 'box',
		}
	}

func set_action(action) -> void:
	# place blocker, inner
	if not _map: return

	if _map.try_build(_grid_pos):
		var blockers : Array[GanWorld.Blocker] = [
			# sequence matters
			GanWorld.decode_blocker_action(action[ACT_PLACE_BLOCKER_NORTH]),
			GanWorld.decode_blocker_action(action[ACT_PLACE_BLOCKER_WEST]),
			GanWorld.decode_blocker_action(action[ACT_PLACE_BLOCKER_SOUTH]),
			GanWorld.decode_blocker_action(action[ACT_PLACE_BLOCKER_EAST])
		]
		var p = _map.place_blockers(_grid_pos, blockers)
		reward += p * 0.01

		var inner_item = GanWorld.decode_inner_item_action(action[ACT_PLACE_INNER])
		_map.place_inner_item(_grid_pos, inner_item)
		if inner_item == GanWorld.InnerItem.Exit:
			_mark_done_and_reset()
			return

		on_action.emit(ActionType.Place)
		
	else:
		reward -= 0.1

	# move
	var move_dir = action[ACT_MOVE_DIR]
	if _map.can_move(_grid_pos, move_dir):
		var pos = _map.move(_grid_pos, move_dir)
		reward += 0.01
		var r = visit(_map, pos)
		reward += r * 0.1
	else:
		if _map.is_trapped(_grid_pos):
			print('trapped')
			reward -= 1.0
			_mark_done_and_reset()
		reward -= 0.01


func _mark_done_and_reset() -> void:
	done = true
	needs_reset = true

func get_reward() -> float:
	return reward

func reset() -> void:
	super.reset()
	on_action.emit(ActionType.Reset)
	_map = null
	_grid_pos = Vector2i.ZERO