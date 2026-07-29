extends Control

@onready var black: ColorRect = $ColorRect/ColorRect2
@onready var timer: Timer = $Timer

func _ready() -> void:
	# Make sure it starts fully transparent
	black.color.a = 0.0
	
	timer.start()

func fade_in_color_rect() -> void:
	# Create a new Tween node dynamically
	var tween: Tween = create_tween()
	
	# Animate the alpha channel (color:a) to 1.0 over 1.0 second
	tween.tween_property(black, "color:a", 1.0, 1.0)
	
	# Connect the completion signal
	tween.finished.connect(_on_fade_in_finished)

func _on_fade_in_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func _on_timer_timeout() -> void:
	fade_in_color_rect()
