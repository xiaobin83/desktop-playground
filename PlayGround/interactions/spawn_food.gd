extends PickableMenuItem

@export var _food : PackedScene

func notify_dropped() -> void:
	var food = _food.instantiate() as Node2D
	Global.add_child(food)
	food.global_position = global_position

	super.notify_dropped()
