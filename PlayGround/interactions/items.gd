class_name Items
extends Node

enum Type {
	None = 0,
	Food = 1,
	Sun = 2,
}

static func get_one_hot(type: Type) -> Array[float]:
	var one_hot :Array[float] = [0.0, 0.0]
	if type != Type.None:
		one_hot[type - 1] = 1.0
	return one_hot
