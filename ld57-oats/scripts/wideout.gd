extends Node2D

## Wideout CatchBox is set to disabled until the qb grabs the ball, then it's turned on again. This prevents early catch

signal catch
signal td

@export var speed: float = 0.0 # Start at 0 and take off when the play starts
@export var caught_ball: bool = false # Boolean to approximate state machine
@export var in_endzone: bool = false # Boolean to approximate state machine
@export var direction = 1 # Y direction while in endzone

@onready var can_toggle_blurry: bool = true
@onready var shader_updating: bool = true
@onready var speed_range: Vector2 = Vector2(60.0, 95.0)
@onready var blur_strength: float = 1.0
@onready var opacity_reduction: float = 0.0
@onready var shader_material: ShaderMaterial = $AnimatedSprite2D.material


func dive():
	$AnimatedSprite2D.modulate.a = 1.0
	$AnimatedSprite2D.play("dive")
	$AnimationPlayer.play("dive")


func _physics_process(delta: float) -> void:
	if in_endzone:
		if global_position.y <= 480:
			direction = 1
		if global_position.y >= 700:
			direction = -1
		position.y += (speed * delta * direction)
		return
	position.x += speed * delta


func toggle_blurry(is_blurry: bool) -> void:
	if not can_toggle_blurry:
		return
	if $Visible.is_playing():
		$Visible.stop()
	if is_blurry:
		prints(self, "toggle_invisible")
		$Visible.play("toggle_invisible")
	else:
		prints(self, "toggle_visible")
		$Visible.play("toggle_visible")


func _on_catch_box_body_entered(_body: Node2D) -> void:
	caught_ball = true
	speed = 0.0
	var endzone: Array = $TD.get_overlapping_areas()
	catch.emit()
	if not endzone.is_empty():
		td.emit()
		return


func _on_shader_increment_timeout() -> void:
	# Let's say at 10 yards from the line of scrimmage the player will more or less lose sight of the wideout
	# Keeping the poor naming convention from when I used a shader here...
	if not shader_updating:
		return
	var x_diff_from_start = global_position.x - get_parent().global_position.x
	if x_diff_from_start <= 0:
		return
	$ShaderIncrement.stop()
	while $AnimatedSprite2D.modulate.a > 0:
		$AnimatedSprite2D.modulate.a -= 0.005
		await get_tree().create_timer(0.01).timeout


func _on_endzone_timeout() -> void:
	var endzone: Array = $TD.get_overlapping_areas()
	if not endzone.is_empty():
		in_endzone = true
