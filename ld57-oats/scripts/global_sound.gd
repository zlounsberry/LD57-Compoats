extends Node2D

func _ready():
	AudioServer.set_bus_volume_db(1, linear_to_db(0.8))
	AudioServer.set_bus_volume_db(2, linear_to_db(1))


func update_pacing():
	pass # might play with this more in the future...
	#match Globals.current_play_count:
		#1:
			#$AudioStreamPlayer.pitch_scale = 1.0
		#2:
			#$AudioStreamPlayer.pitch_scale = 1.02
		#3:
			#$AudioStreamPlayer.pitch_scale = 1.04
		#4:
			#$AudioStreamPlayer.pitch_scale = 1.06
