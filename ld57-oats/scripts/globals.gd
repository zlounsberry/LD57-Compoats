extends Node

const MAX_ROUNDS: int = 2
const LEVEL_DICTIONARY: Dictionary = {
	0: {
		"starting_x_position": 1000.0,
		"defense_timer": 4.0,
		"blurry_timer_linebacker": 2.0,
		"blurry_timer_wideout": 1.0
	},
	1: {
		"starting_x_position": 550.0,
		"defense_timer": 3.0,
		"blurry_timer_linebacker": 2.0,
		"blurry_timer_wideout": 2.0
	},
	2: {
		"starting_x_position": 250.0,
		"defense_timer": 1.5,
		"blurry_timer_linebacker": 1.0,
		"blurry_timer_wideout": 3.0
	}
}

@onready var current_level: int = 0
@onready var current_x_position: float = 0
