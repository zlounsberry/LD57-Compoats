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
		Engine.time_scale = 0.5
		is_throwing = true

	if event.is_action_released("throw"):
		is_throwing = false
		Engine.time_scale = 0.25
		$Qb.throw()
		print("throwing at ", throw_strength)
		$Ball.get_thrown(throw_strength, Vector2.ZERO) # Zero as a placeholder for when I add directionality
		$Wideout.dive()

func _fail_state():
	print("failure!")


func _success_state(new_position: float):
	print("sucess!! ", new_position)


func _hit_qb():
	is_throwing = true # just to set the play as over
	_fail_state()


func _on_miss_body_entered(body: Node2D) -> void:
	print("incomplete!")
	$Ball.queue_free()
	_fail_state()


func _on_wideout_catch() -> void:
	print("catch!")
	var catch_position: float = $Wideout.position.x
	_success_state(catch_position)


func _on_wideout_oob() -> void:
	print("oob!")
	$Ball.queue_free()
	$Wideout.queue_free()
	_fail_state()
