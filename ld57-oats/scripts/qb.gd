extends CharacterBody2D

@export var move_speed : float = 200.0
@export var rotate_speed : float = 5.0

signal sacked
signal ball_thrown

@onready var has_thrown: bool = false
@onready var is_throwing: bool = false
@onready var is_scrambling: bool = false


func _ready() -> void:
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("idle_pre_play")


func _physics_process(delta: float) -> void:
	handle_movement(delta)
	move_and_slide()


func handle_movement(delta: float) -> void:
	var direction = Vector2.ZERO
	if not is_scrambling:
		return
	if is_throwing or has_thrown:
		velocity = Vector2.ZERO
		return
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	direction = direction.normalized()
	velocity = direction * move_speed


func throw():
	has_thrown = true
	$AnimatedSprite2D.stop()
	$AnimationPlayer.play("throw")
	await $AnimationPlayer.animation_finished
	ball_thrown.emit()


func _on_area_2d_area_entered(area: Area2D) -> void:
#	 The logic for getting stuffed lives here
	if has_thrown:
		return
	if area.is_in_group("tackler"):
		sacked.emit()


func _on_catch_hike_body_entered(body: Node2D) -> void:
	$CatchHike.queue_free() # Remove this to avoid future collisions (could also disable, I'm not your boss)
	body.queue_free()
	get_parent().start_play_animations() # This lives in the Play script
