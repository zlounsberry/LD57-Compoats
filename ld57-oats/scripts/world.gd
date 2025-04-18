extends Node2D

const PLAY: Object = preload("res://scenes/play.tscn")
const TEXTBOX: Object = preload("res://scenes/textbox.tscn")
const BALL: Object = preload("res://scenes/ball.tscn")
const PLAY_Y_POSITION: float = 588.0

@export var throw_strength: float = 0.0

@onready var is_throwing: bool = false
@onready var is_hovered: bool = false # for menu items that require clicks
@onready var has_thrown: bool = false
@onready var touchdown: bool = false
@onready var play_started: bool = false
@onready var is_squinting: bool = false # Squinting will reveal receivers and hide linebackers
@onready var can_toggle_squint: bool = true # For the squint timer node to modulate
@onready var is_narrating: bool = true


func _ready():
	var textbox = TEXTBOX.instantiate()
	$UI.add_child(textbox)
	await textbox.dialog_done
	if Globals.current_level == 0:
		$UI/Instruct.text = "Tap W or Up Arrow to hike and start play"
		for child in $UI/Instructions.get_children():
			child.hide()
		$UI/Instructions/Hike.show()
	else:
		$UI/Instruct.hide()
	Globals.current_play_count = 1
	if Globals.current_level > Globals.MAX_ROUNDS:
		print("YOU WIN")
		return
	_update_play()
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
	
	if event.is_action_released("hike"):
		if play_started:
			return
		$UI/SquintInstruction.show()
		$UI/SquintIndicator.show()
		for child in $UI/Instructions.get_children():
			child.hide()
		if Globals.current_level == 0:
			$UI/Instruct.text = "Hold down Left Mouse Button or Space to charge throw"
			$UI/Instructions/Hold.show()
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
		await get_tree().create_timer(0.5).timeout # to avoid bypassing the `if not play_started` below, add a lil timer
		play_started = true

	if event.is_action_pressed("hut"):
		if not play_started:
			$Sounds/Hut.play()

	if not play_started:
		return # early return if the play hasn't yet started

	if event.is_action_pressed("squint"):
		if not can_toggle_squint:
			print("timer not up yet")
			return
		can_toggle_squint = false
		$SquintTimer.start()
		is_squinting = !is_squinting # toggle true/false
		if is_squinting:
			$UI/SquintIndicator.play("default")
		else:
			$UI/SquintIndicator.play_backwards("default")
		for linebacker in get_tree().get_nodes_in_group("linebacker"):
			linebacker.toggle_blurry(is_squinting)
			print("setting linebackers to ", is_squinting)
		for receiver in get_tree().get_nodes_in_group("wideout"):
			receiver.toggle_blurry(!is_squinting)
			print("setting wideout to ", !is_squinting)

	if event.is_action_pressed("throw"):
		if is_throwing:
			return # Avoid stutter-stepping spacebar
		if is_hovered:
			return
		Engine.time_scale = 0.5 # Slow down for better control and/or drama maybe who knows
		is_throwing = true # Set to the throwing state
		if Globals.current_level == 0:
			$UI/Instruct.text = "Release Left Mouse Button or Space to throw downfield"
			for child in $UI/Instructions.get_children():
				child.hide()
			$UI/Instructions/Charge.show()
		for qb in get_tree().get_nodes_in_group("qb"):
			qb.is_throwing = true

	if event.is_action_released("throw"):
		has_thrown = true # Avoid stutter-stepping spacebar
		is_throwing = false # Avoid stutter-stepping spacebar
		$Sounds/Throw.play()
		if Globals.current_level == 0:
			$UI/Instruct.text = "Nothing to do but pray now"
		for child in $UI/Instructions.get_children():
			child.hide()
		for play_child in get_tree().get_nodes_in_group("play"):
			play_child.get_node("Qb").throw()
		for linebacker_child in get_tree().get_nodes_in_group("linebacker"):
			linebacker_child.can_toggle_blurry = false
			linebacker_child.set_deferred("modulate:a", 1.0)
		for wideout_child in get_tree().get_nodes_in_group("wideout"):
			wideout_child.can_toggle_blurry = false
			wideout_child.set_deferred("modulate:a", 1.0)


func _fail_state():
	Engine.time_scale = 1
	$Camera2D.start_shake()
	Globals.current_play_count += 1
	$UI/AnimationPlayer.play("fade_out")
	await $UI/AnimationPlayer.animation_finished
	if Globals.current_play_count > 4:
		print("adding text from fail state")
		_game_over(false)
	_update_play()
	$UI/AnimationPlayer.play("fade_in")
	await $UI/AnimationPlayer.animation_finished


func _success_state(td: bool, new_position: float):
	Engine.time_scale = 1.0
	await get_tree().create_timer(1.0).timeout
	$UI/AnimationPlayer.play("fade_out")
	print("success")
	if td:
		# $Sounds/Whistle.play()
		$Sounds/TD.play()
		await $Sounds/TD.finished
		Globals.current_level += 1
		if Globals.current_level > Globals.MAX_ROUNDS:
			print("past final level")
			print("adding text from success win state")
			_game_over(true)
			return
		Globals.current_x_position = Globals.LEVEL_DICTIONARY[Globals.current_level]["starting_x_position"]
		get_tree().reload_current_scene()
	else:
		if touchdown:
			return
		Globals.current_play_count += 1
		Globals.current_x_position = new_position
		_update_play()
		$UI/AnimationPlayer.play("fade_in")
		await $UI/AnimationPlayer.animation_finished


func _game_over(win_state: bool):
	print("GAME OVER")
	var textbox = TEXTBOX.instantiate()
	textbox.game_over = true
	textbox.won_game = win_state
	$UI.add_child(textbox)
	await textbox.dialog_done
	Globals.current_level = 0
	Globals.current_play_count = 1
	$UI/AnimationPlayer.play("fade_out")
	await $UI/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/title.tscn")


func _update_play():
	if not is_inside_tree():
		return # this should avoid null group call for the next line
	if Globals.current_play_count <= 4:
		$Scoreboard.frame = Globals.current_play_count - 1 # Need a -1 here coz it starts at 0
	is_squinting = false
	$UI/SquintIndicator.frame = 0
	$UI/Scramble.hide()
	$UI/ScrambleIcons.hide()
	$UI/SquintInstruction.hide()
	$UI/SquintIndicator.hide()
	$UI/Instruct.text = "Tap W or Up Arrow to hike and start play"
	for child in $UI/Instructions.get_children():
		child.hide()
	$UI/Instructions/Hike.show()
	Engine.time_scale = 1.0
	GlobalSound.update_pacing()
	# $Sounds/Whistle.play()
	for play_child in get_tree().get_nodes_in_group("play"):
		play_child.queue_free()
	var new_play = PLAY.instantiate()
	add_child(new_play)
	if Globals.current_play_count == 1:
		new_play.position = Vector2(Globals.LEVEL_DICTIONARY[Globals.current_level]["starting_x_position"], PLAY_Y_POSITION)
		Globals.current_x_position = new_play.position.x
	else:
		new_play.position = Vector2(Globals.current_x_position, PLAY_Y_POSITION)
	new_play.ball_caught.connect(_on_play_ball_caught)
	new_play.wideout_td.connect(_on_play_wideout_td)
	new_play.qb_sacked.connect(_on_play_qb_sacked)
	new_play.qb_threw_ball.connect(_on_play_qb_threw_ball)
	for linebacker_child in get_tree().get_nodes_in_group("linebacker"):
		linebacker_child.get_node("Timeout").wait_time = Globals.LEVEL_DICTIONARY[Globals.current_level]["defense_timer"]
	is_throwing = false # reset play states
	has_thrown = false # reset play states
	play_started = false # reset play states
	throw_strength = 0.0
	for play_child in get_tree().get_nodes_in_group("play"):
		play_child.get_node("Qb/Aim/TextureProgressBar").value = throw_strength


func _on_miss_body_entered(_body: Node2D) -> void:
	$Sounds/Miss.play()
	for play_child in get_tree().get_nodes_in_group("play"):
		play_child.get_node("Ball").queue_free()
	_fail_state()


func _on_play_wideout_td() -> void:
	touchdown = true
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
	$Sounds/Sack.play()
	for qb in get_tree().get_nodes_in_group("qb"):
		# Handle plays that set players off the screen
		if qb.global_position.x <= Globals.LEVEL_DICTIONARY[2]["starting_x_position"]: 
			Globals.current_x_position = Globals.LEVEL_DICTIONARY[2]["starting_x_position"]
		else:
			Globals.current_x_position = qb.global_position.x
	_fail_state()


func _on_play_qb_threw_ball() -> void:
	Engine.time_scale = 0.5 # Slow down for max dramas
	for play_child in get_tree().get_nodes_in_group("play"):
		var ball = BALL.instantiate()
		play_child.add_child(ball)
		ball.global_position = play_child.get_node("Qb").global_position
		ball.get_thrown(throw_strength)
		play_child.get_node("Wideout").dive()


func _on_squint_timer_timeout() -> void:
	can_toggle_squint = true


func _on_music_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioServer.set_bus_volume_db(1, linear_to_db(0.8))
	else:
		AudioServer.set_bus_volume_db(1, linear_to_db(0.0))
		print("off")


func _on_sfx_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioServer.set_bus_volume_db(2, linear_to_db(1.0))
	else:
		AudioServer.set_bus_volume_db(2, linear_to_db(0.0))
		print("off")


func _on_audio_mouse_entered() -> void:
	print("hovered")
	is_hovered = true


func _on_audio_mouse_exited() -> void:
	print("unhovered")
	is_hovered = false
