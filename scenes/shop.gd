extends Area3D

var player_in_area: bool = false
var is_playing: bool = false
var _is_transitioning: bool = false
@onready var player_ui: CanvasLayer = $"../../../Entities/Player/UI"
@onready var player: CharacterBody3D = $"../../../Entities/Player/CharacterBody3D"
@onready var blackbg: Sprite2D = $"../../../Background/Parallax2D/Sprite2D/Sprite2D2"
@onready var shopspawn: Marker3D = $"../../../shop/Interactions/transition/Marker3D"
@onready var lvl1_1_spawn: Marker3D = $"../../../level_1_1/Interactions/Interactable2/Marker3D"

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = false

func _input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("use"):
		_run_transition(shopspawn)
	else:
		return

func _run_transition(target_spawn: Marker3D) -> void:
	if _is_transitioning:
		return

	_is_transitioning = true
	player_ui.flash.visible = true
	player_ui.flash.color.a = 0.0

	var fade_in: Tween = create_tween()
	fade_in.tween_property(player_ui.flash, "color:a", 1.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await fade_in.finished
	blackbg.visible = true

	player.global_position = target_spawn.global_position

	var fade_out: Tween = create_tween()
	fade_out.tween_property(player_ui.flash, "color:a", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await fade_out.finished

	player_ui.flash.visible = false
	_is_transitioning = false
