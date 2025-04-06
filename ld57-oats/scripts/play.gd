extends Node2D

signal ball_caught
signal wideout_oob
signal wideout_td
signal qb_sacked
signal qb_threw_ball

@export var left_adjustment: int = 0.0
@export var right_adjustment: int = 0.0

func hike_ball():
	$Ball.freeze = false
	$Ball.apply_impulse(Vector2(-500,-250), $Qb.position)


func start_play_animations():
	$Wideout/CatchBox/CollisionShape2D.set_deferred("disabled", false) # Enable the collision shape for the wideout now that the ball is past its plane
	$Wideout/AnimatedSprite2D.play("default")
	$Qb/AnimationPlayer.play("idle")
	for linebacker in get_tree().get_nodes_in_group("linebacker"):
		linebacker.get_node("AnimatedSprite2D").play("default")
		linebacker.get_node("AnimationPlayer").play("idle_live")


func _on_wideout_catch() -> void:
	ball_caught.emit()


func _on_wideout_oob() -> void:
	wideout_oob.emit()


func _on_wideout_td() -> void:
	wideout_td.emit()


func _on_qb_sacked() -> void:
	qb_sacked.emit()


func _on_qb_ball_thrown() -> void:
	qb_threw_ball.emit()
