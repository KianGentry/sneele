extends CanvasLayer

@onready var label: RichTextLabel = $RichTextLabel2
@onready var npcname: RichTextLabel = $RichTextLabel

var lines: Array[String] = []
var current_line: int = 0

@export var blip_player: AudioStreamPlayer

# Speed settings: 0.01s = 10ms per character
@export var character_delay: float = 0.01
@export_range(0.5, 2.0) var base_pitch: float = 1.0

var _timer: float = 0.0
var _is_typing: bool = false

signal dialogue_closed(reason: String)

func close_dialogue(reason: String) -> void:
	if visible:
		dialogue_closed.emit(reason)
		hide()
	current_line = 0

func _process(delta: float) -> void:
	if not _is_typing:
		return
		
	_timer += delta
	
	# Reveal characters at a constant rate
	while _timer >= character_delay and label.visible_characters < label.get_total_character_count():
		_timer -= character_delay
		label.visible_characters += 1
		
		_play_blip_for_character(label.visible_characters - 1)
		
	# Stop typing loop once the line is finished
	if label.visible_characters >= label.get_total_character_count():
		_is_typing = false

func _play_blip_for_character(char_index: int) -> void:
	if not blip_player or char_index >= label.text.length():
		return
		
	var current_char: String = label.text[char_index]
	
	# Skip spaces and line breaks
	if current_char.strip_edges() != "":
		blip_player.pitch_scale = base_pitch * randf_range(0.95, 1.05)
		blip_player.play()

func start_dialogue(character_name: String, dialogue_lines: Array[String]) -> void:
	npcname.text = character_name
	lines = dialogue_lines
	current_line = 0
	show_line()
	show()

func advance() -> void:
	# If player clicks while text is still typing, finish revealing the line instantly
	if _is_typing:
		label.visible_characters = label.get_total_character_count()
		_is_typing = false
		return

	current_line += 1
	if current_line < lines.size():
		show_line()
	else:
		close_dialogue("finished")

func show_line() -> void:
	label.text = lines[current_line]
	label.visible_characters = 0
	_timer = 0.0
	_is_typing = true

func is_active() -> bool:
	return visible
