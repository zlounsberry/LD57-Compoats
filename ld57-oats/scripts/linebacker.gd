extends Node2D

@export var tackler: bool = false


func _ready() -> void:
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("idle")
	if tackler:
		$Area2D.add_to_group("tackler")


func run_anim(move_towards: Vector2) -> void:
	$AnimatedSprite2D.play("run")
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position", move_towards, 5.0)


func _defeated():
	$AnimationPlayer.play("defeated")


func _on_timeout_timeout() -> void:
	if self.is_in_group("enemy"):
		var qb_location: Vector2 = get_parent().get_node("Qb").position
		run_anim(qb_location)
	else:
		_defeated()
