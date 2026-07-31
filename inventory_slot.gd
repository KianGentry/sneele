class_name InventorySlot
extends Control

@onready var icon_rect: TextureRect = $TextureRect 
@onready var focus_border: ReferenceRect = $TextureRect/FocusBorder

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL 
	
	focus_border.visible = false

func set_item(item: ItemData) -> void:
	if item:
		icon_rect.texture = item.texture

func _on_focus_entered() -> void:
	focus_border.visible = true

func _on_focus_exited() -> void:
	focus_border.visible = false
