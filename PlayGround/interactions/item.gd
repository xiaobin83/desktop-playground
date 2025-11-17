class_name Item
extends Node2D

const _default_extra_obs :Array[float] = [0, 0, 0, 0]

signal on_consume(item: Item)

func woke_up_from_pool() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is Spr:
		body.entered_item(self)

func _on_body_exited(body: Node2D) -> void:
	if body is Spr:
		body.exited_item(self)

# return consumed amount
func consume(_delta: float) -> float:
	raise_on_consume()
	return 1.0

func despawn() -> void:
	raise_on_consume()

func raise_on_consume() -> void:
	on_consume.emit(self)

static func get_extra_obs(item: Item) -> Array[float]:
	var obs = item._get_extra_obs()
	assert(obs.size() == get_default_extra_obs().size(), '_get_extra_obs should return float array which has %d floats' % get_default_extra_obs().size()) 
	return obs

#override this to define the obs, it should have the exact length of obs array as the default one
func _get_extra_obs() -> Array[float]:
	return get_default_extra_obs()

static func get_default_extra_obs() -> Array[float]:
	return _default_extra_obs
