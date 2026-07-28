extends CanvasLayer

@onready var song: AudioStreamPlayer = $"../song"
@onready var start: AudioStreamPlayer = $start
@onready var transition_rect: ColorRect = $fade
@onready var hover: AudioStreamPlayer = $hover

func _on_button_pressed() -> void:
	song.stop()
	start.play()
	transition_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "color:a", 1.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

func _on_button_mouse_entered() -> void:
	hover.play()
