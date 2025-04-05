extends Node2D

## Wideout CatchBox is set to disabled until the qb grabs the ball, then it's turned on again. This prevents early catch

signal catch
signal td
signal oob # for out of bounds when they pass endzone


@export var speed: float = 0.0 # Start at 0 and take off when the play starts
@export var caught_ball: bool = false
@export var eye_adjustment_value: float = 0.0

@onready var shader_updating: bool = true
@onready var speed_range: Vector2 = Vector2(40.0, 80.0)
@onready var blur_strength: float = 1.0
@onready var opacity_strength: float = 0.0
@onready var shader_material: ShaderMaterial = $AnimatedSprite2D.material
@onready var starting_line_position: Vector2 = get_parent().global_position


func dive():
	$AnimatedSprite2D.play("dive")
	$AnimationPlayer.play("dive")


func _physics_process(delta: float) -> void:
	position.x += speed * delta


func reset_shader():
	shader_updating = false
	shader_material.set_shader_parameter("blur_strength", 1.0)
	shader_material.set_shader_parameter("opacity_reduction", 0.0)


func _on_catch_box_body_entered(_body: Node2D) -> void:
	print("Catch!")
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
	var x_diff_from_start = global_position.x - starting_line_position.x
	if x_diff_from_start <= 0:
		return
	if blur_strength > 0:
		blur_strength -= (x_diff_from_start / (7500 + (7500 * eye_adjustment_value))) # Hardcode for now
		print(blur_strength)
	shader_material.set_shader_parameter("blur_strength", blur_strength)
	if opacity_strength < 1:
		opacity_strength += (x_diff_from_start / (2000 + (200 * eye_adjustment_value))) # Hardcode for now
	shader_material.set_shader_parameter("opacity_reduction", opacity_strength)
