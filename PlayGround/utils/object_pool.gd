extends Node

var _pool: Dictionary = {}

func allocate(path: String, recycleTime: float = -1) -> Node:
	if not _pool.has(path):
		_pool[path] = []
	var list = _pool[path]
	var instance: Node = null
	if list.size() > 0:
		instance = list.pop_back()
	else:
		var scene: PackedScene = load(path)
		instance = scene.instantiate()
		instance.set_meta('_pool_object_path', path)
	if recycleTime > 0:
		get_tree().create_timer(recycleTime).timeout.connect(func() -> void: recycle(instance))
	return instance

func recycle(instance: Node) -> void:
	if instance.has_meta('_pool_object_path'):
		var path: String = instance.get_meta('_pool_object_path')
		if instance.get_parent():
			instance.get_parent().remove_child(instance)
		if not _pool.has(path):
			_pool[path] = []
		var list = _pool[path]
		list.append(instance)
	else:
		instance.queue_free()
