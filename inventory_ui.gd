extends Control

@export var slot_scene: PackedScene

@onready var slot_container: GridContainer = $GridContainer
@onready var name_label: Label = $NameLabel # Create a Label node at the bottom of this scene

func _ready() -> void:
	InventoryManager.inventory_updated.connect(refresh_inventory)
	name_label.text = "" # Start empty
	refresh_inventory()

func refresh_inventory() -> void:
	# Clear old slots
	for child in slot_container.get_children():
		child.queue_free()
	
	for item in InventoryManager.get_items():
		if slot_scene:
			var slot_instance = slot_scene.instantiate() as InventorySlot
			slot_container.add_child(slot_instance)
			slot_instance.set_item(item)
			
			# When the player's cursor moves onto this slot, update the label with this item's name
			slot_instance.focus_entered.connect(_on_slot_focused.bind(item.name))

func _on_slot_focused(item_name: String) -> void:
	name_label.text = item_name

## Called by the player script when opening
func open_menu() -> void:
	name_label.text = ""
	if slot_container.get_child_count() > 0:
		# call_deferred waits until the engine is finished drawing the frame
		# before executing grab_focus, guaranteeing it won't fail.
		slot_container.get_child(0).call_deferred("grab_focus")

## Called by the player script when closing
func close_menu() -> void:
	name_label.text = ""
	# Remove the cursor focus so it doesn't invisibly stay selected
	var focused_node = get_viewport().gui_get_focus_owner()
	if focused_node:
		focused_node.release_focus()
