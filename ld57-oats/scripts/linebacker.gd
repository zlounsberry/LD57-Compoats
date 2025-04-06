extends Node2D

signal timer_expired

@export var tackler: bool = false
@export var timer_increment: float = 6.0

@onready var is_chasing: bool = false
@onready var chase_tween_time: float = 5.0
@onready var opacity_reduction = 0.0
@onready var blur_strength = 1.0


func _ready() -> void:
	$Timeout.wait_time = timer_increment
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("idle_pre_play")
	if tackler:
		$Area2D.add_to_group("tackler")


func run_anim() -> void:
	$AnimatedSprite2D.play("run")
	is_chasing = true
	$Chase.start()
	#var tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	#tween.tween_property(self, "position", move_towards, 5.0)


func _defeated():
	$AnimationPlayer.play("defeated")


func toggle_blurry(is_blurry: bool) -> void:
	#if is_blurry:
		#if blur_strength > 0:
			#blur_strength -= (0.05 / Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("blur_strength", blur_strength) # Blur was pulling in nearby frames, drove me nuts so no blur
		#if blur_strength <= 0.40:
			#opacity_reduction += (0.025 / Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("opacity_reduction", opacity_reduction)
		#while opacity_reduction >= 0:
			#opacity_reduction += (0.025 / Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("opacity_reduction", opacity_reduction)
	#else:
		#if blur_strength < 1.0:
			#blur_strength += (0.05 * Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("blur_strength", blur_strength) # Blur was pulling in nearby frames, drove me nuts so no blur
		#if blur_strength >= 0.60:
			#opacity_reduction += (0.025 * Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("opacity_reduction", opacity_reduction)
		#while opacity_reduction <= 1:
			#opacity_reduction += (0.025 * Globals.LEVEL_DICTIONARY[Globals.current_level]["correction_factor"])
		#shader_material.set_shader_parameter("opacity_reduction", opacity_reduction)
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	if is_blurry:
		tween.tween_property(self, "modulate:a", 0.0, Globals.LEVEL_DICTIONARY[Globals.current_level]["blurry_timer_linebacker"])
	else:
		tween.tween_property(self, "modulate:a", 1.0, Globals.LEVEL_DICTIONARY[Globals.current_level]["blurry_timer_linebacker"])


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
		
