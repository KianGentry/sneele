extends CanvasLayer

@onready var label: RichTextLabel = $RichTextLabel2
@onready var npcname: RichTextLabel = $RichTextLabel
@onready var animation: AnimationPlayer = $AnimationPlayer

var lines: Array[String] = []
var current_line: int = 0

func start_dialogue(character_name: String, dialogue_lines: Array[String]) -> void:
	npcname.text = character_name
	lines = dialogue_lines
	current_line = 0
	show_line()
	show()

func advance() -> void:
	current_line += 1
	if current_line < lines.size():
		show_line()
	else:
		hide()

func show_line() -> void:
	animation.play("scroll")
	label.text = lines[current_line]

func is_active() -> bool:
	return visible
