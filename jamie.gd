extends Node3D

@onready var dialogue: CanvasLayer = $dialogue
@export var character_name: String = "NPC"
@export var yes_sound: AudioStreamPlayer
@export var no_sound: AudioStreamPlayer

func _ready() -> void:
	pass

@onready var lines: Array = [
	"Hi",
	"Can we get a chinese?",
	{
		"text": "Please?",
		"decision": {
			"yes_lines": ["Thanks for that."], 
			"no_lines": ["Fucking dickhead."]
		}
	}
]

var player_in_area: bool = false

func _on_dialogue_closed(reason: String) -> void:
	if reason == "finished":
		pass
	elif reason == "walked_away":
		pass

func _on_dialogue_yes_pressed(branch_lines: Array) -> void:
	ObjectiveManager.add_objective("Get a chinese", "Jamie wants a chinese", false)
	yes_sound.play()

func _on_dialogue_no_pressed(branch_lines: Array) -> void:
	no_sound.play()

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
		
		if dialogue.is_active():
			dialogue.advance()
			get_viewport().set_input_as_handled()
			
		elif player_in_area:
			# Pass character_name along with lines here
			dialogue.start_dialogue(character_name, lines)
			get_viewport().set_input_as_handled()
