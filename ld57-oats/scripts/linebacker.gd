extends Node2D

signal timer_expired

@export var tackler: bool = false

@onready var is_chasing: bool = false
@onready var can_toggle_blurry: bool = true
@onready var chase_tween_time: float = 5.0
@onready var opacity_reduction = 0.0
@onready var blur_strength = 1.0


func _ready() -> void:
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("idle_pre_play")
	if tackler:
		$Area2D.add_to_group("tackler")


func run_anim() -> void:
	$AnimatedSprite2D.play("run")
	is_chasing = true
	$Chase.start()


func _defeated():
	$AnimationPlayer.play("defeated")


func toggle_blurry(is_blurry: bool) -> void:
	if not can_toggle_blurry:
		return
	if not is_in_group("enemy"):
		return
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	if is_blurry:
		tween.tween_property($AnimatedSprite2D, "modulate:a", 0.0, 1.0)
	else:
		tween.tween_property($AnimatedSprite2D, "modulate:a", 1.0, 3.0)


func _on_timeout_timeout() -> void:
	timer_expired.emit()
	if self.is_in_group("enemy"):
		run_anim()
		$AnimationPlayer.stop()
		if $Area2D.is_in_group("tackler"):
			$Knockdown.play()
	else:
		_defeated()


func _on_chase_timeout() -> void:
	var qb_location: Vector2 = get_parent().get_node("Qb").position
	if chase_tween_time >= 1:
		chase_tween_time -= 0.5
	if is_chasing:
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "position", qb_location, chase_tween_time)
		
