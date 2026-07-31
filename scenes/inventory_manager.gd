extends Node

#when an item is added or removed or changed
signal inventory_updated

## Stores your collected ItemData resources
var inventory: Array[ItemData] = []

## Adds an item resource to the inventory list and notifies UI
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
