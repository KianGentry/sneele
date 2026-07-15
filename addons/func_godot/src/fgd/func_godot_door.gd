extends AnimatableBody3D

@export var properties: Dictionary = {}

var local_closed_position: Vector3
var local_opened_position: Vector3
var is_open: bool = false
var speed: float = 4.0

func _func_godot_apply_properties(props: Dictionary) -> void:
	properties = props
	# Read properties from TrenchBroom (default to moving UP 4 units if not set)
	var move_vector = properties.get("move_vector", Vector3(0, 4, 0))
	speed = properties.get("speed", 4.0)
	
	local_closed_position = position
	local_opened_position = position + move_vector

func _ready() -> void:
	# Add to a group so triggers or players can find it
	add_to_group("doors")

func interact() -> void:
	var target = local_opened_position if not is_open else local_closed_position
	is_open = !is_open
	
	# Tween the door smoothly to its new position
	var tween = create_tween()
	tween.tween_property(self, "position", target, 1.0 / speed)
