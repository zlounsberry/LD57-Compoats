extends Node2D

## Wideout CatchBox is set to disabled until the qb grabs the ball, then it's turned on again. This prevents early catch

const SPEED: float = 50.0

@export var speed: float = 0.0 # Start at 0 and take off when the play starts
@export var caught_ball: bool = false


signal catch
signal td
signal oob # for out of bounds when they pass endzone


func dive():
	$AnimatedSprite2D.play("dive")
	$AnimationPlayer.play("dive")


func _physics_process(delta: float) -> void:
	position.x += speed * delta
	

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
