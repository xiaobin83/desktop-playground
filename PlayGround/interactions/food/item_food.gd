extends Item

func get_item_type() -> Items.Type:
	return Items.Type.Food

func _get_extra_obs() -> Array[float]:
	return [0, 0, 0, 0]

func consume(_delta: float) -> float:
	despawn()
	return 200
