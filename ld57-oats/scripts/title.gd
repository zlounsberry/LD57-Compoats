extends Node2D


func _on_start_pressed() -> void:
	$Hut.play()
	await $Hut.finished
	$Hut.play()
	await $Hut.finished
	$Hike.play()
	await $Hike.finished
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_button_pressed() -> void:
	$AnimationPlayer.play("shrink")


func _on_how_to_pressed() -> void:
	$AnimationPlayer.play("grow")
