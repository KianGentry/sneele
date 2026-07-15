extends Node3D

# Configuration
@export var scroll_speed: float = 20.0  # Speed of the road moving toward the camera
@export var tile_length: float = 1024.0  # The EXACT length of your road mesh in TrenchBroom units

# Reference your two road mesh nodes
@onready var road_1: MeshInstance3D = $Road1
@onready var road_2: MeshInstance3D = $Road2

func _process(delta: float) -> void:
	# Move the entire parent node backward along the Z-axis (towards the camera)
	position.z += scroll_speed * delta
	
	# Check if Road 1 has scrolled past the camera's "reset point"
	# Once it has moved backward by its full length, we move it BACK to the front of the line
	if position.z > 0.0:
		# Reset the parent's Z position
		# By snapping the whole parent back, both tiles move seamlessly.
		position.z -= tile_length
		
