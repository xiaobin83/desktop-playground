class_name Spr;

extends RigidBody2D;


signal on_grabbed;
signal on_dropped;

func can_pickup() -> bool:
    return true

func notify_grabbed() -> void:
    on_grabbed.emit();
    
func notify_dropped() -> void:
    on_dropped.emit();

func _process(_delta: float) -> void:
    if !Global.is_in_play_ground(self):
        Global.respawn(self)
