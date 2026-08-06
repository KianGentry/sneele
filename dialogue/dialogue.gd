extends CanvasLayer

@onready var label: RichTextLabel = $RichTextLabel2
@onready var npcname: RichTextLabel = $RichTextLabel
@onready var choice_buttons: Control = $ChoiceButtons
@onready var yes_button: Button = $ChoiceButtons/YesButton
@onready var no_button: Button = $ChoiceButtons/NoButton

var lines: Array = []
var current_line: int = 0
var _decision_targets: Dictionary = {}
var _decision_choice_lines: Dictionary = {}
var _decision_active: bool = false
var _branch_mode: bool = false
var _branch_lines: Array = []

@export var blip_player: AudioStreamPlayer

# Speed settings: 0.01s = 10ms per character
@export var character_delay: float = 0.01
@export_range(0.5, 2.0) var base_pitch: float = 1.0

var _timer: float = 0.0
var _is_typing: bool = false

signal dialogue_closed(reason: String)
signal dialogue_choice_selected(choice: String, branch_lines: Array)
signal yes_pressed(branch_lines: Array)
signal no_pressed(branch_lines: Array)

func _ready() -> void:
	choice_buttons.visible = false
	yes_button.pressed.connect(_on_yes_button_pressed)
	no_button.pressed.connect(_on_no_button_pressed)

func close_dialogue(reason: String) -> void:
	if visible:
		dialogue_closed.emit(reason)
		hide()
	_set_decision_state(false)
	_branch_mode = false
	_branch_lines = []
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

func start_dialogue(character_name: String, dialogue_lines: Array) -> void:
	npcname.text = character_name
	lines = dialogue_lines
	current_line = 0
	_branch_mode = false
	_branch_lines = []
	show_line()
	show()

func advance() -> void:
	if _decision_active:
		return

	# If player clicks while text is still typing, finish revealing the line instantly
	if _is_typing:
		label.visible_characters = label.get_total_character_count()
		_is_typing = false
		return

	current_line += 1
	var active_lines: Array = _get_active_lines()
	if current_line < active_lines.size():
		show_line()
	else:
		close_dialogue("finished")

func show_line() -> void:
	var active_lines: Array = _get_active_lines()
	if current_line < 0 or current_line >= active_lines.size():
		close_dialogue("finished")
		return

	var entry: Variant = active_lines[current_line]
	var line_text: String = _get_line_text(entry)
	label.text = line_text
	label.visible_characters = 0
	_timer = 0.0
	_is_typing = true
	_set_decision_state(false)

	# THIS CODE IS ASS!!!!
	if entry is Dictionary and entry.has("decision"):
		var decision: Variant = entry.get("decision")
		if decision is Dictionary:
			var yes_target: int = -1
			var no_target: int = -1
			var yes_lines: Array = []
			var no_lines: Array = []
			if decision.has("yes"):
				yes_target = int(decision.get("yes"))
			if decision.has("no"):
				no_target = int(decision.get("no"))
			if decision.has("yes_lines") and decision.get("yes_lines") is Array:
				yes_lines = decision.get("yes_lines")
			if decision.has("no_lines") and decision.get("no_lines") is Array:
				no_lines = decision.get("no_lines")
			_decision_targets = { "yes": yes_target, "no": no_target }
			_decision_choice_lines = { "yes": yes_lines, "no": no_lines }
			_set_decision_state(true)

func _get_line_text(entry: Variant) -> String:
	if entry is Dictionary:
		if entry.has("text"):
			return str(entry.get("text", ""))
		if entry.has("line"):
			return str(entry.get("line", ""))
		return str(entry)

	return str(entry)

func _set_decision_state(active: bool) -> void:
	_decision_active = active
	choice_buttons.visible = active
	if active:
		yes_button.grab_focus()
	else:
		_decision_targets.clear()
		_decision_choice_lines.clear()

func _get_active_lines() -> Array:
	if _branch_mode:
		return _branch_lines

	return lines

func _on_yes_button_pressed() -> void:
	_select_choice("yes")

func _on_no_button_pressed() -> void:
	_select_choice("no")

func _select_choice(choice: String) -> void:
	if not _decision_active:
		return

	var choice_lines: Array = _get_choice_lines(choice)
	_play_choice_sound(choice)
	if choice == "yes":
		yes_pressed.emit(choice_lines)
	elif choice == "no":
		no_pressed.emit(choice_lines)
	dialogue_choice_selected.emit(choice, choice_lines)
	_set_decision_state(false)

	if choice_lines.size() > 0:
		_begin_branch(choice_lines)
		return

	var target_line: int = int(_decision_targets.get(choice, -1))
	if target_line < 0:
		close_dialogue("finished")
		return

	var active_lines: Array = _get_active_lines()
	if target_line >= active_lines.size():
		close_dialogue("finished")
		return

	current_line = target_line
	show_line()

func _get_choice_lines(choice: String) -> Array:
	if _decision_choice_lines.has(choice):
		return _decision_choice_lines.get(choice, [])

	return []

func _begin_branch(branch_lines: Array) -> void:
	_branch_mode = true
	_branch_lines = branch_lines.duplicate(true)
	current_line = 0
	show_line()

func _play_choice_sound(choice: String) -> void:
	var active_lines: Array = _get_active_lines()
	if current_line < 0 or current_line >= active_lines.size():
		return

	var entry: Variant = active_lines[current_line]
	if not (entry is Dictionary and entry.has("decision")):
		return

	var decision: Variant = entry.get("decision")
	if not (decision is Dictionary):
		return

	var sound_key: String = "%s_sound" % choice
	if not decision.has(sound_key):
		return

	var sound_value: Variant = decision.get(sound_key)
	var stream: AudioStream = null
	if sound_value is AudioStream:
		stream = sound_value
	elif sound_value is String and not String(sound_value).is_empty():
		stream = load(String(sound_value)) as AudioStream

	if not stream:
		return

	var choice_player := AudioStreamPlayer.new()
	choice_player.stream = stream
	add_child(choice_player)
	choice_player.finished.connect(choice_player.queue_free)
	choice_player.play()

func is_active() -> bool:
	return visible

func is_waiting_for_choice() -> bool:
	return _decision_active
