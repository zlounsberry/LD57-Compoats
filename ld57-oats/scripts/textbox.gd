extends Node2D

signal dialog_done

const DIALOG_DICT: Dictionary = {
	0: {
		"Max Dialog Value": 1,
		0: "This is the first dialog on the first day",
		1: "This is the second dialog on the first day",
	},
	1: {
		"Max Dialog Value": 1,
		0: "This is the first dialog on the second day",
		1: "This is the second dialog on the second day",
	},
	2: {
		"Max Dialog Value": 1,
		0: "This is the first dialog on the last day",
		1: "This is the second dialog on the last day",
	},
}

@onready var can_advance: bool = false
@onready var current_text_value: int = 0


func _ready() -> void:
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	await tween.finished
	_display_text()
	current_text_value += 1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throw"):
		if can_advance:
			$Sprite2D.hide()
			can_advance = false
			if current_text_value > DIALOG_DICT[Globals.current_level]["Max Dialog Value"]:
				dialog_done.emit()
				queue_free()
			var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
			tween.tween_property($Label, "modulate:a", 0.0, 1.0)
			await tween.finished
			_display_text()
			current_text_value += 1


func _display_text():
	$Label.text = DIALOG_DICT[Globals.current_level][current_text_value]
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Label, "modulate:a", 1.0, 1.0)
	await get_tree().create_timer(2.0).timeout
	$Sprite2D.show()
	can_advance = true
	
