extends Node2D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		$Ball.freeze = false
		$Ball.apply_central_impulse(Vector2(1000,-1000))
