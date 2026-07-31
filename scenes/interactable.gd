extends Area3D

## Assign the item's .tres resource here in the Inspector
@export var item: ItemData

## Drag your ItemGet scene (.tscn) here in the Inspector
@export var item_get_scene: PackedScene

var player_in_range: bool = false

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("use"):
		interact()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"): # Ensure your Player node is in the "player" group
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

	# 1. Create a CanvasLayer to force the UI on top of everything
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 100 
	get_tree().current_scene.add_child(ui_layer)
	
	# 2. Instantiate and add the popup to the CanvasLayer (NOT the scene tree directly)
	var item_get_instance = item_get_scene.instantiate()
	ui_layer.add_child(item_get_instance)
	
	# 3. Tell the CanvasLayer to destroy itself whenever the popup finishes and calls queue_free()
	item_get_instance.tree_exited.connect(ui_layer.queue_free)
	
	# 4. Initialize the reveal
	item_get_instance.setup_reveal(item)
	
	# 5. Destroy the physical item in the world
	queue_free()
