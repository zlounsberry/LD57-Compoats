extends Camera2D

# Public variables
var shake_intensity : float = 10.0 # The initial shake intensity
var shake_duration : float = 0.5   # Duration of the shake
var shake_decay : float = 0.1      # Decay speed of the shake

# Private variables
var is_shaking : bool = false
var shake_time : float = 0.0
var shake_offset : Vector2 = Vector2.ZERO

# Update the shake effect each frame
func _process(delta: float) -> void:
	if is_shaking:
		shake_time -= delta
		if shake_time <= 0.0:
			is_shaking = false
			offset = Vector2.ZERO
		else:
			# Randomize the shake offset
			shake_offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
			# Gradually reduce the shake intensity over time
			shake_intensity -= shake_decay * delta
			offset = shake_offset
	else:
		offset = Vector2.ZERO

# Public function to trigger the camera shake
func start_shake(intensity: float = 3.0, duration: float = 1.0, decay: float = 0.1) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_decay = decay
	is_shaking = true
	shake_time = shake_duration
