class_name InventorySlot
extends Control

@onready var icon_rect: TextureRect = $TextureRect 
@onready var focus_border: ReferenceRect = $TextureRect/FocusBorder

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL 
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	focus_border.visible = false

func set_item(item: ItemData) -> void:
	if item:
		icon_rect.texture = item.texture

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		grab_focus()
		accept_event()

func _on_focus_entered() -> void:
	focus_border.visible = true

func _on_focus_exited() -> void:
	focus_border.visible = false
