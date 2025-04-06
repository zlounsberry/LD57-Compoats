extends Node2D

## Wideout CatchBox is set to disabled until the qb grabs the ball, then it's turned on again. This prevents early catch

signal catch
signal td
signal oob # for out of bounds when they pass endzone


@export var speed: float = 0.0 # Start at 0 and take off when the play starts
@export var caught_ball: bool = false # Boolean to approximate state machine
@export var in_endzone: bool = false # Boolean to approximate state machine
@export var direction = 1 # Y direction while in endzone


@onready var shader_updating: bool = true
@onready var speed_range: Vector2 = Vector2(40.0, 80.0)
@onready var blur_strength: float = 1.0
@onready var opacity_reduction: float = 0.0
@onready var shader_material: ShaderMaterial = $AnimatedSprite2D.material


func dive():
	$AnimatedSprite2D.play("dive")
	$AnimationPlayer.play("dive")


func _physics_process(delta: float) -> void:
	if in_endzone:
		var random_y = randi_range(480, 1220)
		if global_position.y <= 480:
			direction = 1
		if global_position.y >= 700:
			direction = -1
		position.y += (speed * delta * direction)
		return
	position.x += speed * delta


func reset_shader():
	shader_updating = false
	shader_material.set_shader_parameter("blur_strength", 1.0)
	shader_material.set_shader_parameter("opacity_reduction", 0.0)


func toggle_blurry(is_blurry: bool) -> void:
	reset_shader()
	#if is_blurry:
		#if blur_strength > 0:
			#blur_strength -= (0.05 / Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("blur_strength", blur_strength) # Blur was pulling in nearby frames, drove me nuts so no blur
		#if blur_strength <= 0.40:
			#opacity_reduction += (0.025 / Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("opacity_reduction", opacity_reduction)
		#while opacity_reduction >= 0:
			#opacity_reduction += (0.025 / Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("opacity_reduction", opacity_reduction)
	#else:
		#if blur_strength < 1.0:
			#blur_strength += (0.05 * Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("blur_strength", blur_strength) # Blur was pulling in nearby frames, drove me nuts so no blur
		#if blur_strength >= 0.60:
			#opacity_reduction += (0.025 * Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("opacity_reduction", opacity_reduction)
		#while opacity_reduction <= 1:
			#opacity_reduction += (0.025 * Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("opacity_reduction", opacity_reduction)
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	if is_blurry:
		tween.tween_property(self, "modulate:a", 0.0, Globals.LEVEL_DICTIONARY[Globals.current_level]["blurry_timer_wideout"])
	else:
		tween.tween_property(self, "modulate:a", 1.0, Globals.LEVEL_DICTIONARY[Globals.current_level]["blurry_timer_wideout"])


func _on_catch_box_body_entered(_body: Node2D) -> void:
	caught_ball = true
	speed = 0.0
	var endzone: Array = $TD.get_overlapping_areas()
	if not endzone.is_empty():
		print("touchdown!")
		td.emit()
	catch.emit()


func _on_oob_area_entered(_area: Area2D) -> void:
	print("failure, oob!")
	oob.emit()


func _on_shader_increment_timeout() -> void:
	# Let's say at 20 yards from the line of scrimmage the player will more or less lose sight of the 
	if not shader_updating:
		return
	var x_diff_from_start = global_position.x - get_parent().global_position.x
	if x_diff_from_start <= 0:
		return
	if blur_strength > 0:
		blur_strength -= (0.05 * Globals.LEVEL_DICTIONARY[Globals.current_level]["blurry_timer_wideout"])
	#shader_material.set_shader_parameter("blur_strength", blur_strength) # Blur was pulling in nearby frames, drove me nuts so no blur
	if blur_strength <= 0.40:
		opacity_reduction += (0.025 * Globals.LEVEL_DICTIONARY[Globals.current_level]["blurry_timer_wideout"])
	shader_material.set_shader_parameter("opacity_reduction", opacity_reduction)


func _on_endzone_timeout() -> void:
	var endzone: Array = $TD.get_overlapping_areas()
	if not endzone.is_empty():
		in_endzone = true
