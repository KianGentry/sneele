extends Area3D

@export var item: ItemData

@export var item_get_scene: PackedScene

var player_in_range: bool = false

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("use"):
		interact()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func interact() -> void:
	if item == null:
		push_warning("No ItemData assigned to interactable %s!" % name)
		return
		
	if item_get_scene == null:
		push_warning("No ItemGet scene assigned to interactable %s!" % name)
		return

	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 100 
	get_tree().current_scene.add_child(ui_layer)
	
	var item_get_instance = item_get_scene.instantiate()
	ui_layer.add_child(item_get_instance)
	
	item_get_instance.tree_exited.connect(ui_layer.queue_free)
	
	item_get_instance.setup_reveal(item)
	
	queue_free()
