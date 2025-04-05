extends RigidBody2D

const THROWN_ADJUSTMENT: float = 10.0


func get_thrown(throw_strength: float, throw_direction: Vector2):
	$Sprite2D.play("thrown")
	freeze = false
	#apply_impulse(THROWN_ADJUSTMENT * Vector2(throw_strength, -throw_strength), throw_direction)
	apply_central_impulse(THROWN_ADJUSTMENT * Vector2(throw_strength, -throw_strength))
	
