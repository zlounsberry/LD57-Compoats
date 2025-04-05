extends Node

const LEVEL_DICTIONARY: Dictionary = {
	0: {
		"starting_x_position": 1000.0,
		"defense_timer": 6.0,
	},
	1: {
		"starting_x_position": 550.0,
		"defense_timer": 5.0,
	},
	2: {
		"starting_x_position": 250.0,
		"defense_timer": 3.0,
	}
}

@onready var current_level: int = 0
@onready var current_x_position: float = 0
