extends Control

@export var slot_scene: PackedScene
@export var grid_columns: int = 4
@export var slot_size: Vector2 = Vector2(54, 54)

@onready var slot_container: GridContainer = $GridContainer
@onready var name_label: Label = $NameLabel

func _ready() -> void:
	slot_container.columns = grid_columns
	InventoryManager.inventory_updated.connect(refresh_inventory)
	name_label.text = ""
	name_label.visible = false
	refresh_inventory()

func refresh_inventory() -> void:

	for child in slot_container.get_children():
		child.queue_free()
	
	for item in InventoryManager.get_items():
		if slot_scene:
			var slot_instance = slot_scene.instantiate() as InventorySlot
			slot_instance.custom_minimum_size = slot_size
			slot_container.add_child(slot_instance)
			slot_instance.set_item(item)

			slot_instance.focus_entered.connect(_on_slot_focused.bind(_get_item_display_name(item)))

func _on_slot_focused(item_name: String) -> void:
	name_label.text = item_name
	name_label.visible = true

func _get_item_display_name(item: ItemData) -> String:
	if not item:
		return ""

	if not item.name.is_empty():
		return item.name

	if item.texture and not item.texture.resource_path.is_empty():
		return item.texture.resource_path.get_file().get_basename().replace("_", " ")

	return "Item"

## Called by the player script when opening
func open_menu() -> void:
	name_label.text = ""
	name_label.visible = true
	if slot_container.get_child_count() > 0:
		slot_container.get_child(0).call_deferred("grab_focus")

## Called by the player script when closing
func close_menu() -> void:
	name_label.text = ""
	name_label.visible = false
	var focused_node = get_viewport().gui_get_focus_owner()
	if focused_node:
		focused_node.release_focus()
