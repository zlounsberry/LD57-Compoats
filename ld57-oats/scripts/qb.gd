extends Node2D

signal thrown
signal sacked

@onready var has_thrown: bool = false


func throw():
	has_thrown = true
	$AnimatedSprite2D.stop()
	$AnimationPlayer.play("throw")


func _on_area_2d_area_entered(area: Area2D) -> void:
	if has_thrown:
		return
	sacked.emit()
