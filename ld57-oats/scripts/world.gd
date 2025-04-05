extends Node2D

@export var throw_strength: float = 1.0
@export var eye_adjustment: float

@onready var is_throwing: bool = false
@onready var has_thrown: bool = false

func _ready():
	eye_adjustment = randf_range(-2.0, 2.0)
	$UI/Adjustment.text = str("EYESIGHT: ", eye_adjustment)


func _physics_process(delta: float) -> void:
	if is_throwing:
		throw_strength += 50 * delta
		$UI/ProgressBar.value = throw_strength


func _input(event: InputEvent) -> void:
	if has_thrown:
		return # early return if the ball is released - any UI stuff should go above here
	
	if event.is_action_pressed("ui_up"):
		$Play.hike_ball()
		for linebacker in get_tree().get_nodes_in_group("linebacker"):
			linebacker.get_node("Timeout").start() # Stop the play from breaking down once the ball is thrown
		$Play/Wideout.speed = randf_range($Play/Wideout.speed_range.x, $Play/Wideout.speed_range.y)
		print("speed = ", $Play/Wideout.speed)
		$Play/Wideout/ShaderIncrement.start() # Start making the wideout blurrier as they go
		$Play/Wideout.eye_adjustment_value = eye_adjustment


	if event.is_action_pressed("throw"):
		if is_throwing:
			return # Avoid stutter-stepping spacebar
		Engine.time_scale = 0.5 # Slow down for better control and/or drama maybe who knows
		is_throwing = true # Set to the throwing state

	if event.is_action_released("throw"):
		has_thrown = true # Avoid stutter-stepping spacebar
		is_throwing = false # Avoid stutter-stepping spacebar
		Engine.time_scale = 0.25 # Slow down for max dramas
		$Play/Qb.throw() # Play QB animation and set its state
		$Play/Ball.get_thrown(throw_strength, Vector2.ZERO) # Zero as a placeholder for when I add directionality
		$Play/Wideout.dive() # Play wideout dive animation
		$Play/Wideout.reset_shader() # Show the player where the wideout is


func _fail_state():
	Engine.time_scale = 1.0
	print("failure!")


func _success_state(td: bool, new_position: float):
	Engine.time_scale = 1.0
	if td:
		print("round over! you win!")
	else:
		print("sucess!! ", new_position)


func _on_miss_body_entered(_body: Node2D) -> void:
	print("incomplete!")
	$Ball.queue_free()
	_fail_state()


func _on_qb_sacked() -> void:
	print("sacked!")
	_fail_state()


func _on_play_wideout_td() -> void:
	_success_state(true, 0.0) # win condition for the round


func _on_play_wideout_oob() -> void:
	print("oob!")
	$Ball.queue_free()
	$Wideout.queue_free()
	_fail_state()


func _on_play_ball_caught() -> void:
	for linebacker in get_tree().get_nodes_in_group("linebacker"):
		linebacker.get_node("Timeout").stop() # Stop the play from breaking down once the ball is thrown
	$Play/Ball.get_caught()
	var catch_position: float = $Play/Wideout.position.x
	_success_state(false, catch_position)
