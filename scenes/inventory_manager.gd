extends Node

signal inventory_updated

var inventory: Array[ItemData] = []

func add_item(item: ItemData) -> void:
	if item:
		inventory.append(item)
		inventory_updated.emit()
		print("Added %s to inventory!" % item.name)

## Returns the current array of items
func get_items() -> Array[ItemData]:
	return inventory

func is_empty() -> bool:
	return inventory.is_empty()
