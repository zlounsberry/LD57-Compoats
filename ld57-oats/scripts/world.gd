extends Node2D


func _ready():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.hit.connect(_hit_qb)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		Engine.time_scale = 0.25
		$QB.freeze = false
		$QB.apply_central_impulse(Vector2(1000,-1000))


func _hit_qb():
	pass
