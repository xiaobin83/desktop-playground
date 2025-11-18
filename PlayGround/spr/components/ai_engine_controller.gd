extends EngineController

@onready var _ai_agent : AIAgent = $AIAgent

func notify_spr_initialized(spr: Spr) -> void:
	super.notify_spr_initialized(spr)
	spr.on_request_set_agent_done.connect(_set_done)
	spr.on_reset_agent.connect(_reset)

func _ready() -> void:
	super._ready()
	_ai_agent.init(self)

func _process(delta: float) -> void:
	if _ai_agent.needs_reset:
		_spr.agent_request_reset()
		return

	var reward_changed = false
	for item in _spr.get_touching_items():
		_ai_agent.reward += item.consume(delta)
		reward_changed = true
	if reward_changed:
		_spr.agent_raise_reward_changed(_ai_agent.reward)

	var action = _ai_agent.get_move_action()
	var engines = get_engines()
	for i in range(action.size()):
		_op_engine(action[i], engines[i])

func _op_engine(action: float, engine) -> void:
	if action > 0:
		engine.start_engine(1)
	else:
		engine.stop_engine()

func _set_done(is_success: bool) -> void:
	_ai_agent.is_success = is_success
	_ai_agent.done = true
	_ai_agent.needs_reset = true

func _reset() -> void:
	_ai_agent.reset()
