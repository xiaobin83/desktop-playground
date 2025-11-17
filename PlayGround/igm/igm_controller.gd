extends Node

@export var _igm_options: Node2D

var _items_grabbing = {}
var _in_igm_area: bool

func _ready() -> void:
	PlayerInput.on_enter_igm_area.connect(_on_enter_igm_area)
	PlayerInput.on_exit_igm_area.connect(_on_exit_igm_area)
	
	NodeExt.foreach_child(_igm_options, \
		func(child: Node):
			if child is PickableMenuItem:
				child.on_grabbed.connect(_on_grabbed_item.bind(child))
				child.on_dropped.connect(_on_dropped_item.bind(child)))

func _on_grabbed_item(item: PickableMenuItem) -> void:
	_items_grabbing[item] = null

func _on_dropped_item(item: PickableMenuItem) -> void:
	_items_grabbing.erase(item)
	_igm_options.visible = not _in_igm_area and _items_grabbing.size() > 0 

func _on_enter_igm_area() -> void:
	_in_igm_area = true
	_igm_options.visible = true

func _on_exit_igm_area() -> void:
	_in_igm_area = false
	_igm_options.visible = _items_grabbing.size() > 0 
