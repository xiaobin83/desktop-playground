extends EngineController 

@onready var _ai_agent : AIAgent = $AIAgent

func notify_spr_initialized(spr: Spr) -> void:
	super.notify_spr_initialized(spr)
	spr.on_touch_item.connect(_on_touch_item)

func _ready() -> void:
	super._ready()
	_ai_agent.init(self)

func _process(_delta: float) -> void:
	if _ai_agent.needs_reset:
		_ai_agent.reset()
		_spr.request_reset()
		return

	var action = _ai_agent.get_move_action()
	var engines = get_engines()
	_op_engine(action[0], engines[0])
	_op_engine(action[1], engines[1])
	_op_engine(action[2], engines[2])
	_op_engine(action[3], engines[3])

func _op_engine(action: float, engine) -> void:
	engine.start_engine(action)

func _on_touch_item(_item: Item) -> void:
	_ai_agent.reward += 1.0
