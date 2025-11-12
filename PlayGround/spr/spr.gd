extends RigidBody2D;

signal on_grabbed;
signal on_dropped;

func can_pickup() -> bool:
    return true

func notify_grabbed() -> void:
    emit_signal('on_grabbed');
    
func notify_dropped() -> void:
    emit_signal('on_dropped');