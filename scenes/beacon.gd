extends Node3D

@onready var light: OmniLight3D = $OmniLight3D
@onready var animation: AnimatedSprite3D = $AnimatedSprite3D
@onready var timer: Timer = $Timer
@onready var timer2: Timer = $Timer2
@onready var buzz: AudioStreamPlayer3D = $AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("default")
	timer.start()

func _on_timer_timeout() -> void:
	animation.play("flash")
	buzz.play()
	light.visible = true
	timer2.start()

func _on_timer_2_timeout() -> void:
	animation.play("default")
	light.visible = false
	timer.start()
