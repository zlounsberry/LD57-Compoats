extends Node2D

signal dialog_done

const DIALOG_DICT: Dictionary = {
	0: {
		"Max Dialog Value": 3,
		0: "Welcome to the bigtime, kid. It's first and goal, and the Playoffs are on the line here. We've only got time for 4 plays, so make em count. All we need is one touchdown to win it.",
		1: "They say you've got the best arm in the League... And easily the worst depth perception... That's fine, worst case you can gimme a deep ball to where you think your receiver is, right?",
		2: "Remember that if you lose sight of the receiver, just squint real hard with the right mouse button. Sure you'll lose sight of their defenders, but you should be able to find your mark before they hit you, right?",
		3: "Now go get us our playoff win. Ice water in your veins!",
	},
	1: {
		"Max Dialog Value": 2,
		0: "Hey kid, we need that golden arm of yours, and we'll take the eyesight that comes with it. It's the Divisional Championship game, and we need a touchdown to win it.",
		1: "Watch the defensive line, they've gotten a bit better at breaking through and our boys are tired... They set us back around midfield, but I believe in you!",
		2: "Now go get us our divisional win. Ice water in your veins!",
	},
	2: {
		"Max Dialog Value": 3,
		0: "Doesn't get much bigger than this kid, the Big Game! I'm not gonna lie, we're in rough shape... But you're our legally blind ringer! I know you can get us downfield...",
		1: "Like, literally... All the way down field... It was a rough kickoff... BUT we've still got 4 plays to make this happen. Wild how that keeps happening.",
		2: "Our boys are beat up. They won't hold our opponent's defenders back for long. We gotta make this happen quick! Best of luck, I know you can do it!",
		3: "Now go get us our championship win. Ice water in your veins!",
	},
}

const GAME_OVER_DICT: Dictionary = {
	"win": {
		"Max Dialog Value": 1,
		0: "You did it! You won the championship for your team! I knew your depth perception wasn't an issue, you crushed it like I knew you would!",
		1: "And thanks to you, the player, for trying out this Ludum Dare 57 Compo entry until the end! I really appreciate you, and I hope you had fun :) Go ahead and click to try again.",
	},
	"lose": {
		"Max Dialog Value": 0,
		0: "Ah sorry kid, your depth perception got the better of you this time... You'll get em next season for sure! Go ahead and click to try again.",
	}
}

@export var game_over: bool = false
@export var won_game: bool = false

@onready var can_advance: bool = false
@onready var current_text_value: int = 0


func _ready() -> void:
	get_tree().paused = true
	prints("textbox, game over:", game_over, "won_game:", won_game, "current level:", Globals.current_level)
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Wow I just learned you need to update the pause mode of tweens you add?? Wild
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	await tween.finished
	_display_text()
	current_text_value += 1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		print("clicked in textbox")
		$Hold.start()
		if can_advance:
			$Sprite2D.hide()
			can_advance = false
			var dict_finished: bool = false # Set a boolean based on my terrible indexing schema
			if not game_over:
				if current_text_value > DIALOG_DICT[Globals.current_level]["Max Dialog Value"]:
					dict_finished = true
			else:
				if won_game:
					if current_text_value > GAME_OVER_DICT["win"]["Max Dialog Value"]:
						dict_finished = true
				else:
					if current_text_value > GAME_OVER_DICT["lose"]["Max Dialog Value"]:
						dict_finished = true
			if dict_finished:
				get_tree().paused = false
				dialog_done.emit()
				queue_free()
			if not is_inside_tree():
				return # this should avoid null group call for the next function
			var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Wow I just learned you need to update the pause mode of tweens you add?? Wild
			tween.tween_property($Label, "modulate:a", 0.0, 1.0)
			await tween.finished
			_display_text()
			current_text_value += 1

	if event.is_action_released("throw"):
		$Hold.stop()


func _display_text():
	var text_dictionary: Dictionary
	if not game_over:
		text_dictionary = DIALOG_DICT
		$Label.text = text_dictionary[Globals.current_level][current_text_value]
	else:
		text_dictionary = GAME_OVER_DICT
		if won_game:
			$Label.text = text_dictionary["win"][current_text_value]
		else:
			$Label.text = text_dictionary["lose"][current_text_value]
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Label, "modulate:a", 1.0, 1.0)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Wow I just learned you need to update the pause mode of tweens you add?? Wild
	await get_tree().create_timer(0.5).timeout
	$Sprite2D.show()
	can_advance = true


func _on_hold_timeout() -> void:
	get_tree().paused = false
	dialog_done.emit()
	queue_free()
