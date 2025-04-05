extends Node2D

@export var speed: float = 100.0

signal catch

func dive():
	$AnimatedSprite2D.play("dive")
	$AnimationPlayer.play("dive")


func _physics_process(delta: float) -> void:
	position.x += speed * delta
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("football"):
		print("Catch!")
		catch.emit()
