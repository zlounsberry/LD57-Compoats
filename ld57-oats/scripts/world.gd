extends Node2D

@export var throw_strength: float = 1.0

@onready var is_throwing: bool = false

func _ready():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.hit.connect(_hit_qb)


func _physics_process(delta: float) -> void:
	if is_throwing:
		throw_strength += 50 * delta
		$UI/ProgressBar.value = throw_strength


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		is_throwing = true

	if event.is_action_released("throw"):
		is_throwing = false
		Engine.time_scale = 0.25
		$Wideout.dive()
		$QB.freeze = false
		$QB.apply_central_impulse(10 * Vector2(throw_strength, -throw_strength))


func _hit_qb():
	pass
