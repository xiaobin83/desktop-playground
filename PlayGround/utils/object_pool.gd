extends Node

var _pool := {}

const meta_path = &'_pool_path'
const meta_packed_scene = &'_pool_packed_scene'

func allocate_packed_scene(packed_scene: PackedScene, recycle_time: float = -1) -> Node:
	if not packed_scene in _pool:
		_pool[packed_scene] = []
	var list = _pool[packed_scene]
	var instance: Node 
	if list.size() > 0:
		instance = list.pop_back()	
		instance._ready()
	else:
		instance = packed_scene.instantiate()
		instance.set_meta(meta_packed_scene, packed_scene)
	if recycle_time > 0:
		get_tree().create_timer(recycle_time).timeout.connect(recycle.bind(instance))
	return instance

func allocate_path(path: String, recycle_time: float = -1) -> Node:
	if not _pool.has(path):
		_pool[path] = []
	var list = _pool[path]
	var instance: Node = null
	if list.size() > 0:
		instance = list.pop_back()
		instance._ready()
	else:
		var scene: PackedScene = load(path)
		instance = scene.instantiate()
		instance.set_meta(meta_path, path)
	if recycle_time > 0:
		get_tree().create_timer(recycle_time).timeout.connect(recycle.bind(instance))
	return instance

func recycle(instance: Node) -> void:
	var key
	if instance.has_meta(meta_packed_scene):
		key = instance.get_meta(meta_packed_scene)
	elif instance.has_meta(meta_path):
		key = instance.get_meta(meta_path)
	else:
		instance.queue_free()
		return

	var parent = instance.get_parent()
	if parent:
		parent.remove_child(instance)
	if not key in _pool:
		_pool[key] = []
	var list = _pool[key]
	list.append(instance)
