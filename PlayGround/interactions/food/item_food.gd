extends Item

@export var _reward: float = 1.0

func _get_extra_obs() -> Array[float]:
	return [0, 0, 0, 0]

func consume(_delta: float) -> float:
	despawn()
	return _reward

