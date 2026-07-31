extends Node

@export var items: Array[ItemData] = []

# map items to ItemData
var _items_by_name: Dictionary = {}

func _ready() -> void:
	for item in items:
		if item:
			_items_by_name[item.name.to_lower()] = item

# item lookup
func get_item_by_name(item_name: String) -> ItemData:
	var key = item_name.to_lower()
	if _items_by_name.has(key):
		return _items_by_name[key]
	
	push_warning("item database: item '%s' not found" % item_name)
	return null
