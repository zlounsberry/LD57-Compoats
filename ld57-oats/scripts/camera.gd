extends Camera2D

# Just hardcoding the variables for now
@onready var shake_intensity: float = 10.0
@onready var shake_duration: float = 0.5
@onready var shake_decay: float = 0.1
@onready var is_shaking: bool = false
@onready var shake_time: float = 0.0
@onready var shake_offset: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	if is_shaking:
		shake_time -= delta
		if shake_time <= 0.0:
			is_shaking = false
			offset = Vector2.ZERO
		else:
			shake_offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
			shake_intensity -= shake_decay * delta
			offset = shake_offset
	else:
		offset = Vector2.ZERO


func start_shake(intensity: float = 3.0, duration: float = 1.0, decay: float = 0.1) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_decay = decay
	is_shaking = true
	shake_time = shake_duration
