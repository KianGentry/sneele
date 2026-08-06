class_name Objective
extends RefCounted

# Using enums keeps our types and statuses strictly categorized
enum Type { MAIN, SIDE }
enum Status { ACTIVE, COMPLETED, FAILED }

var id: String
var objective_name: String
var description: String
var type: Type
var status: Status

# The _init function acts as our constructor
func _init(p_name: String, p_description: String, p_is_main: bool = true):
	objective_name = p_name
	description = p_description
	type = Type.MAIN if p_is_main else Type.SIDE
	status = Status.ACTIVE
	
	# Generate a simple unique ID based on the name (e.g., "Find Key" -> "find_key")
	id = objective_name.to_lower().replace(" ", "_")

# Optional helper methods for encapsulation
func complete() -> void:
	status = Status.COMPLETED

func fail() -> void:
	status = Status.FAILED

func rename_to(new_name: String) -> void:
	objective_name = new_name
