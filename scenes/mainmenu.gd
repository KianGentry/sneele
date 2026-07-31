extends Node3D

# Configuration
@export var rotation_speed: float = -0.03

# Reference your two road mesh nodes
@onready var camera: Camera3D = $Camera3D
@onready var light: DirectionalLight3D = $DirectionalLight3D
@onready var animation: AnimationPlayer = $Camera3D/AnimationPlayer

func _process(delta: float) -> void:
	camera.rotation.y += deg_to_rad(rotation_speed)
	light.rotation.y += deg_to_rad(rotation_speed)
