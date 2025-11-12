extends RigidBody2D;

signal on_grabbed;
signal on_dropped;

func can_pickup() -> bool:
    return true

func notify_grabbed() -> void:
    emit_signal('on_grabbed');
    
func notify_dropped() -> void:
    emit_signal('on_dropped');

func _process(_delta: float) -> void:
    if !Global.is_in_play_ground(self):
        Global.respawn(self)
