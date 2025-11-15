extends EngineController


const OP_ENGINE_TOP = &'EngineTop'
const OP_ENGINE_BOTTOM = &'EngineBottom'
const OP_ENGINE_LEFT = &'EngineLeft'
const OP_ENGINE_RIGHT = &'EngineRight'

var _move_action = [0, 0, 0, 0, 0]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(OP_ENGINE_TOP):
		_move_action[4] = 1
	if event.is_action_released(OP_ENGINE_TOP):
		_move_action[4] = 0

	if event.is_action_pressed(OP_ENGINE_BOTTOM):
		_move_action[0] = 1
		_move_action[1] = 1
	if event.is_action_released(OP_ENGINE_BOTTOM):
		_move_action[0] = 0 
		_move_action[1] = 0

	if event.is_action_pressed(OP_ENGINE_LEFT):
		_move_action[3] = 1 
	if event.is_action_released(OP_ENGINE_LEFT):
		_move_action[3] = 0 

	if event.is_action_pressed(OP_ENGINE_RIGHT):
		_move_action[2] = 1 
	if event.is_action_released(OP_ENGINE_RIGHT):
		_move_action[2] = 0 

# from Spr._physics_process
func accept_physics_process(agent, delta: float) -> void:
	super.accept_physics_process(agent, delta)
	if _spr.get_agent_heuristic() == 'human':
		set_move_action(_move_action, delta)
	else:
		set_move_action(agent.get_move_action(), delta)



