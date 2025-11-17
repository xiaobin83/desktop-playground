extends PickableMenuItem

@export var _food : PackedScene

func notify_dropped() -> void:
	Global.spawn_item(_food, global_position)
	super.notify_dropped()
