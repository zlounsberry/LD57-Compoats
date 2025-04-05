extends Node2D

@export var speed: float = 100.0


signal catch
signal oob # for out of bounds when they pass endzone


func dive():
	$AnimatedSprite2D.play("dive")
	$AnimationPlayer.play("dive")


func _physics_process(delta: float) -> void:
	position.x += speed * delta
	

func _on_catch_box_body_entered(body: Node2D) -> void:
	print("Catch!")
	catch.emit()


func _on_oob_area_entered(area: Area2D) -> void:
	print("failure, oob!")
	oob.emit()
