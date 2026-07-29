extends Control

@onready var black: ColorRect = $ColorRect/ColorRect2
@onready var timer: Timer = $Timer

func _ready() -> void:
	# set alpha to 0
	black.color.a = 0.0
	
	timer.start()

func fade_in_color_rect() -> void:
	# new tween
	var tween: Tween = create_tween()
	
	# alpha increase over a second
	tween.tween_property(black, "color:a", 1.0, 1.0)
	
	# say when ts complete
	tween.finished.connect(_on_fade_in_finished)

func _on_fade_in_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func _on_timer_timeout() -> void:
	fade_in_color_rect()
