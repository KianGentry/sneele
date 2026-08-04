extends Node3D

@onready var dialogue: CanvasLayer = $dialogue
@export var character_name: String = "NPC"
@onready var dialoguebox: Sprite3D = $"importantdialoguebox/Sprite3D"

@export var lines: Array = [
	"Hi",
	"hello",
	"and goodbye."
]

@export var complete_lines: Array = [
	"What? I said go to the shops.",
	"You got a problem with that?",
	"Didn't think so. Get on with it."
]

var player_in_area: bool = false
var objective_complete: bool = false

func _on_dialogue_closed(reason: String) -> void:
	if objective_complete == false:
		dialoguebox.modulate = Color(255,255,255)
		if reason == "finished":
			objective_complete = true
			ObjectiveManager.complete_objective("speak_to_mum")
		elif reason == "walked_away":
			objective_complete = true
			ObjectiveManager.complete_objective("speak_to_mum")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		if dialogue.visible == true:
			dialogue.close_dialogue("walked_away")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use"):
		
		if objective_complete == true: lines = complete_lines
		
		if dialogue.is_active():
			dialogue.advance()
			get_viewport().set_input_as_handled()
		
		elif player_in_area:
			dialogue.start_dialogue(character_name, lines)
			get_viewport().set_input_as_handled()
