extends Node2D

const PLAY: Object = preload("res://scenes/play.tscn")
const TEXTBOX: Object = preload("res://scenes/textbox.tscn")
const BALL: Object = preload("res://scenes/ball.tscn")
const PLAY_Y_POSITION: float = 588.0

@export var throw_strength: float = 0.0

@onready var is_throwing: bool = false
@onready var has_thrown: bool = false
@onready var play_started: bool = false
@onready var is_squinting: bool = false # Squinting will reveal receivers and hide linebackers
@onready var can_toggle_squint: bool = true # For the squint timer node to modulate
@onready var is_narrating: bool = true
@onready var current_play_count: int = 1


func _ready():
	#var textbox = TEXTBOX.instantiate()
	#$UI.add_child(textbox)
	#await textbox.dialog_done
	if Globals.current_level > Globals.MAX_ROUNDS:
		print("YOU WIN")
		return
	_update_play()
	#$UI/Adjustment.text = str("EYESIGHT: ", round(eye_adjustment))
	$UI/Down.text = str("DOWN: ", current_play_count)
	$UI/AnimationPlayer.play("fade_in")
	await $UI/AnimationPlayer.animation_finished


func _physics_process(delta: float) -> void:
	if is_throwing:
		throw_strength += 50 * delta
		for play_child in get_tree().get_nodes_in_group("play"):
			var aim: Node2D = play_child.get_node("Qb/Aim")
			aim.rotation -= delta / 2
			var progbar: TextureProgressBar = aim.get_node("TextureProgressBar")
			progbar.value = throw_strength


func _input(event: InputEvent) -> void:
	if has_thrown:
		return # early return if the ball is released - any UI stuff should go above here
	
	if event.is_action_pressed("ui_up"):
		if play_started:
			return
		play_started = true
		for play_child in get_tree().get_nodes_in_group("play"):
			play_child.hike_ball()
			play_child.get_node("Wideout").speed = randf_range(
				play_child.get_node("Wideout").speed_range.x, 
				play_child.get_node("Wideout").speed_range.y
			)
			play_child.get_node("Wideout/ShaderIncrement").start() 
		$Sounds/Hike.play()
		for linebacker in get_tree().get_nodes_in_group("linebacker"):
			linebacker.get_node("Timeout").start() # Stop the play from breaking down once the ball is thrown


	if not play_started:
		return # early return if the play hasn't yet started

	if event.is_action_pressed("squint"):
		if not can_toggle_squint:
			return
		can_toggle_squint = false
		$SquintTimer.start()
		is_squinting = !is_squinting # toggle true/false
		for linebacker in get_tree().get_nodes_in_group("linebacker"):
			linebacker.toggle_blurry(is_squinting) # Stop the play from breaking down once the ball is thrown
		for receiver in get_tree().get_nodes_in_group("wideout"):
			receiver.toggle_blurry(!is_squinting) # Stop the play from breaking down once the ball is thrown

	if event.is_action_pressed("throw"):
		if is_throwing:
			return # Avoid stutter-stepping spacebar
		Engine.time_scale = 0.5 # Slow down for better control and/or drama maybe who knows
		is_throwing = true # Set to the throwing state
		for qb in get_tree().get_nodes_in_group("qb"):
			qb.is_throwing = true

	if event.is_action_released("throw"):
		has_thrown = true # Avoid stutter-stepping spacebar
		is_throwing = false # Avoid stutter-stepping spacebar
		$Sounds/Throw.play()
		for play_child in get_tree().get_nodes_in_group("play"):
			play_child.get_node("Qb").throw()
		for linebacker_child in get_tree().get_nodes_in_group("linebacker"):
			linebacker_child.modulate.a = 1.0
		for wideout_child in get_tree().get_nodes_in_group("wideout"):
			wideout_child.modulate.a = 1.0


func _fail_state():
	$Camera2D.start_shake()
	current_play_count += 1
	Engine.time_scale = 1.0
	$UI/AnimationPlayer.play("fade_out")
	await $UI/AnimationPlayer.animation_finished
	_update_play()
	$UI/AnimationPlayer.play("fade_in")
	await $UI/AnimationPlayer.animation_finished
	print("failure!")


func _success_state(td: bool, new_position: float):
	Engine.time_scale = 1.0
	await get_tree().create_timer(2.0).timeout
	$UI/AnimationPlayer.play("fade_out")
	await $UI/AnimationPlayer.animation_finished
	if td:
		Globals.current_level += 1
		get_tree().reload_current_scene()
	else:
		current_play_count += 1
		Globals.current_x_position = new_position
		_update_play()
		$UI/AnimationPlayer.play("fade_in")
		await $UI/AnimationPlayer.animation_finished


func _update_play():
	if not is_inside_tree():
		return # this should avoid null group call for the next line
	if current_play_count > 4:
		print("rond over")
		return
	for play_child in get_tree().get_nodes_in_group("play"):
		play_child.queue_free()
	var new_play = PLAY.instantiate()
	add_child(new_play)
	if current_play_count == 1:
		new_play.position = Vector2(Globals.LEVEL_DICTIONARY[Globals.current_level]["starting_x_position"], PLAY_Y_POSITION)
		Globals.current_x_position = new_play.position.x
	else:
		new_play.position = Vector2(Globals.current_x_position, PLAY_Y_POSITION)
	$UI/Down.text = str("DOWN: ", current_play_count)
	new_play.ball_caught.connect(_on_play_ball_caught)
	#new_play.wideout_oob.connect(_on_play_wideout_oob)
	new_play.wideout_td.connect(_on_play_wideout_td)
	new_play.qb_sacked.connect(_on_play_qb_sacked)
	new_play.qb_threw_ball.connect(_on_play_qb_threw_ball)
	for linebacker_child in get_tree().get_nodes_in_group("linebacker"):
		linebacker_child.timer_increment = Globals.LEVEL_DICTIONARY[Globals.current_level]["defense_timer"]
	is_throwing = false # reset play states
	has_thrown = false # reset play states
	play_started = false # reset play states
	throw_strength = 0.0
	for play_child in get_tree().get_nodes_in_group("play"):
		play_child.get_node("Qb/Aim/TextureProgressBar").value = throw_strength


func _on_miss_body_entered(_body: Node2D) -> void:
	print("incomplete!")
	$Sounds/Miss.play()
	for play_child in get_tree().get_nodes_in_group("play"):
		play_child.get_node("Ball").queue_free()
	_fail_state()


func _on_play_wideout_td() -> void:
	_success_state(true, 0.0) # win condition for the round


func _on_play_ball_caught() -> void:
	$Sounds/Catch.play()
	for linebacker in get_tree().get_nodes_in_group("linebacker"):
		linebacker.get_node("Timeout").stop() # Stop the play from breaking down once the ball is thrown
	for play_child in get_tree().get_nodes_in_group("play"):
		play_child.get_node("Ball").get_caught()
	var catch_position: float
	for wideout_child in get_tree().get_nodes_in_group("wideout"):
		catch_position = wideout_child.global_position.x
	_success_state(false, catch_position)


func _on_play_qb_sacked() -> void:
	_fail_state()


func _on_play_qb_threw_ball() -> void:
	Engine.time_scale = 0.25 # Slow down for max dramas
	for play_child in get_tree().get_nodes_in_group("play"):
		var ball = BALL.instantiate()
		play_child.add_child(ball)
		ball.global_position = play_child.get_node("Qb").global_position
		ball.get_thrown(throw_strength)
		play_child.get_node("Wideout").dive()
		play_child.get_node("Wideout").reset_shader() # Show the player where the wideout is


func _on_squint_timer_timeout() -> void:
	can_toggle_squint = true
