extends Node2D

signal sacked
signal ball_thrown

@onready var has_thrown: bool = false


func _ready() -> void:
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("idle_pre_play")


func throw():
	has_thrown = true
	$AnimatedSprite2D.stop()
	$AnimationPlayer.play("throw")
	await $AnimationPlayer.animation_finished
	ball_thrown.emit()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if has_thrown:
		return
	if area.is_in_group("tackler"):
		print("sacked")
		sacked.emit()


func _on_catch_hike_body_entered(body: Node2D) -> void:
	body.set_deferred("freeze", true)
	body.get_node("AnimationPlayer").play("idle")
	get_parent().start_play_animations() # This lives in the Play script
