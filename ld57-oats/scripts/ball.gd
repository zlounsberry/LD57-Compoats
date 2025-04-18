extends RigidBody2D

const THROWN_ADJUSTMENT: float = 10.0


func get_thrown(throw_strength: float):
	$Sprite2D.play("thrown")
	freeze = false
	apply_central_impulse(THROWN_ADJUSTMENT * Vector2(throw_strength, -throw_strength))


func get_caught():
	set_deferred("freeze", true)
	$AnimationPlayer.play("catch")
	await $AnimationPlayer.animation_finished
	queue_free()
