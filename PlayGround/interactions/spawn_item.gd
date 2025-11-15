extends PickableMenuItem

@export var _item: PackedScene

func notify_dropped() -> void:
	Global.spawn_item(_item, global_position)
	super.notify_dropped()
