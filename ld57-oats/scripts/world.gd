extends Node2D

@export var throw_strength: float = 1.0
@export var right_eye_adjustment: int
@export var left_eye_adjustment: int

@onready var is_throwing: bool = false
@onready var has_thrown: bool = false

func _ready():
	right_eye_adjustment = randi_range(-20, 20)
	left_eye_adjustment = randi_range(-20, 20)
	$UI/LeftEye.text = str("LEFT: ", left_eye_adjustment)
	$UI/RightEye.text = str("RIGHT: ", right_eye_adjustment)


func _physics_process(delta: float) -> void:
	if is_throwing:
		throw_strength += 50 * delta
		$UI/ProgressBar.value = throw_strength


func _input(event: InputEvent) -> void:
	if has_thrown:
		return # early return if the ball is released - any UI stuff should go above here
	
	if event.is_action_pressed("throw"):
		if is_throwing:
			return # Avoid stutter-stepping spacebar
		Engine.time_scale = 0.5 # Slow down for better control and/or drama maybe who knows
		is_throwing = true # Set to the throwing state

	if event.is_action_released("throw"):
		has_thrown = true # Avoid stutter-stepping spacebar
		is_throwing = false # Avoid stutter-stepping spacebar
		Engine.time_scale = 0.25 # Slow down for max dramas
		$Qb.throw() # Play QB animation and set its state
		$Ball.get_thrown(throw_strength, Vector2.ZERO) # Zero as a placeholder for when I add directionality
		$Wideout.dive() # Play wideout dive animation


func _fail_state():
	print("failure!")


func _success_state(td: bool, new_position: float):
	if td:
		print("round over! you win!")
	else:
		print("sucess!! ", new_position)


func _on_miss_body_entered(_body: Node2D) -> void:
	print("incomplete!")
	$Ball.queue_free()
	_fail_state()


func _on_wideout_catch() -> void:
	for linebacker in get_tree().get_nodes_in_group("linebacker"):
		linebacker.get_node("Timeout").stop() # Stop the play from breaking down once the ball is thrown
	$Ball.get_caught()
	Engine.time_scale = 1.0
	var catch_position: float = $Wideout.position.x
	_success_state(false, catch_position)


func _on_wideout_oob() -> void:
	print("oob!")
	$Ball.queue_free()
	$Wideout.queue_free()
	_fail_state()


func _on_wideout_td() -> void:
	_success_state(true, 0.0) # win condition for the round


func _on_qb_sacked() -> void:
	print("sacked!")
	_fail_state()
