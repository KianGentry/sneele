extends Control

@onready var list_container: VBoxContainer = $PanelContainer/MarginContainer/MainVBox/ObjectiveList

# Export a variable so we can drag and drop our new scene into it
@export var objective_entry_scene: PackedScene

var ui_elements: Dictionary = {}

func _ready() -> void:
	ObjectiveManager.objective_added.connect(_on_objective_added)
	ObjectiveManager.objective_updated.connect(_on_objective_updated)
	
	for obj in ObjectiveManager.active_objectives.values():
		_on_objective_added(obj)

func _on_objective_added(objective: Objective) -> void:
	var entry = objective_entry_scene.instantiate()
	list_container.add_child(entry)
	entry.setup(objective)
	
	ui_elements[objective.id] = entry

func _on_objective_updated(objective: Objective) -> void:
	if ui_elements.has(objective.id):
		var entry = ui_elements[objective.id]
		entry.update_display()
