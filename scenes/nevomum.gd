extends Node3D

@onready var dialogue_ui = $dialogue
@onready var dialogue_animation = $dialogue/AnimationPlayer
@onready var speaker_name: RichTextLabel = $dialogue/RichTextLabel
@onready var dialogue_text: RichTextLabel = $dialogue/RichTextLabel2

@export var dialogues: Array[String]

var current_dialogue = 0
var started = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if Input.is_action_just_pressed("use"):
		current_dialogue += 1
		dialogue_ui.visible = true
		dialogue_text.text = dialogues[current_dialogue]
		speaker_name.text = "Nevo's Mum"
		dialogue_animation.play("RESET")
		dialogue_animation.play("scroll")
