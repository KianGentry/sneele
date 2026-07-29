extends Area3D

@onready var flush: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var timer: Timer = $Timer

var player_in_area: bool = false
var is_playing: bool = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = false

func _input(event: InputEvent) -> void:
	if is_playing == false:
		if player_in_area and event.is_action_pressed("use"):
			timer.start()
			is_playing = true
			flush.play()
	else:
		return

func _on_timer_timeout() -> void:
	is_playing = false
