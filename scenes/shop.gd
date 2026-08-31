extends Area3D

var player_in_area: bool = false
var door_unlocked: bool = false
var _is_transitioning: bool = false
var _pending_choice: String = ""
var _pending_transition: bool = false

@onready var player_ui: CanvasLayer = $"../../../Entities/Player/UI"
@onready var player: CharacterBody3D = $"../../../Entities/Player/CharacterBody3D"
@onready var blackbg: Sprite2D = $"../../../Background/Parallax2D/Sprite2D/Sprite2D2"
@onready var shopspawn: Marker3D = $"../../../shop/Interactions/transition/Marker3D"
@onready var dialogue: CanvasLayer = $dialogue
@onready var buzz: AudioStreamPlayer = $buzz
var objective_assigned: bool = false
var times_entered: int = 0

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		if dialogue.visible:
			dialogue.close_dialogue("walked_away")

func _input(event: InputEvent) -> void:
	if not player_in_area:
		return
	if event.is_action_pressed("use"):
		if dialogue.is_active():
			dialogue.advance()
			get_viewport().set_input_as_handled()
		elif door_unlocked:
			_run_transition(shopspawn)
			get_viewport().set_input_as_handled()
		else:
			_show_interaction_prompt()
			get_viewport().set_input_as_handled()

func _show_interaction_prompt() -> void:
	dialogue.set_box_visible(false)
	dialogue.set_choice_labels("Interact", "Use Item")
	dialogue.start_dialogue("", [{
		"text": "",
		"decision": {
			"yes_lines": [],
			"no_lines": []
		}
	}])

func _on_dialogue_choice_selected(choice: String, _branch_lines: Array) -> void:
	_pending_choice = choice

func _on_dialogue_closed(reason: String) -> void:
	if objective_assigned == false:
		objective_assigned = true
		ObjectiveManager.add_objective("Find a key", "Find a key to enter the shops", false)
		
	if reason == "walked_away":
		_pending_choice = ""
		_pending_transition = false
		return

	if _pending_choice == "yes":
		_pending_choice = ""
		call_deferred("_start_locked_message")
	elif _pending_choice == "no":
		_pending_choice = ""
		call_deferred("_handle_use_item")
	elif _pending_transition:
		_pending_transition = false
		call_deferred("_do_transition")

func _start_locked_message() -> void:
	dialogue.set_box_visible(true)
	dialogue.start_dialogue("", ["This door is locked... maybe find a key?"])

func _handle_use_item() -> void:
	dialogue.set_box_visible(true)
	if _has_key():
		door_unlocked = true
		_pending_transition = true
		dialogue.start_dialogue("", ["Door unlocked!"])
	else:
		dialogue.start_dialogue("", ["You have no item for this."])

func _has_key() -> bool:
	for item in InventoryManager.get_items():
		if item.name.to_lower() == "key":
			return true
	return false

func _do_transition() -> void:
	times_entered += 1
	if times_entered < 2:
		ObjectiveManager.complete_objective("go_to_the_shops")
		ObjectiveManager.add_objective("Get Milk", "Get milk from the shop's fridge or somet. No one sees these descriptions.", false)
		ObjectiveManager.add_objective("Get Sugar", "Get sugar from the shelves... dummy!", false)
	else:
		return
	_run_transition(shopspawn)

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
