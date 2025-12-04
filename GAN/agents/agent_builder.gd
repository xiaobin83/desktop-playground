"""
Agent Builder
	Build a map with items listed in GanWorld.Blocker and GanWorld.InnerItem

	# Move-and-build 
	Rule,
		1. The world is composed by m*n grids 
		2. Each grid conains 0 ~ 1 InnerItem
		3. Each grid has blockers to the 4 sides; north, south, east, and west
		4. After the builder build a cell, he gose to the next grid. And he can only go
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

extends AIController2D 

func get_obs() -> Dictionary:
	return { 'obs': [ ]}


func get_action_space() -> Dictionary:
	return {
		'move_dir': {
			'size': 4,
			'action_type': 'discrete'
		},
		'pn': { # placement north
			'size': GanWorld.Blocker.Count, 
			'action_type': 'discrete'
		},
		'pw': { # placement west
			'size': GanWorld.Blocker.Count,
			'action_type': 'discrete'
		},
		'ps': { # placement south
			'size': GanWorld.Blocker.Count,
			'action_type': 'discrete'
		},
		'pe': { # placement east
			'size': GanWorld.Blocker.Count,
			'action_type': 'discrete'
		},
		'inner': { # inner content
			'size': GanWorld.InnerItem.Count,
			'action_type': 'discrete'
		}

	}

func set_action(_action) -> void:
	# place blocker, inner
	# move 
	return




