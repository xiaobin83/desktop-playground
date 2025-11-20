extends EngineController

func accept_physics_process(agent, delta: float) -> void:
	agent.visit_physics_process(self, delta)
