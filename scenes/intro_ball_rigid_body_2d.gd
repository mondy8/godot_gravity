extends RigidBody2D

func _process(delta: float) -> void:
	if(position.y > 400):
		self.queue_free()
