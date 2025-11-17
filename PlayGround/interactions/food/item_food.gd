extends Item

@export var _reward: float = 1.0

func consume(_delta: float) -> float:
	raise_on_consume()
	return _reward
