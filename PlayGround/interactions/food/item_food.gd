class_name ItemFood
extends Item 

static var _all_foods = []

func _ready() -> void:
	_all_foods.append(self)

func consume() -> void:
	var index = _all_foods.find(self)
	if index >= 0:
		_all_foods.remove_at(index)
	super.consume()

static func get_all_food_items() -> Array:
	return _all_foods
