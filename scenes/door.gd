extends Area3D

# This is the parent "hinge" node we will rotate
@onready var door_parent: Node3D = $".." 
@onready var solid_collision: CollisionShape3D = $"../CollisionShape3D"
@onready var audio: AudioStreamPlayer3D = $"../AudioStreamPlayer3D"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if "CharacterBody3D" in body.name or "CharacterBody" in body.name:
		# Disable monitoring immediately so this trigger only fires once
		set_deferred("monitoring", false)
		
		# 1. Smoothly rotate the door over 1 second
		if door_parent:
			# Calculate our target rotation in radians (90 degrees clockwise)
			audio.play()
			var target_rotation_y = door_parent.rotation.y + deg_to_rad(-90)
			
			# Create a Tween to animate the rotation smoothly
			var tween = create_tween()
			
			# Animate the 'rotation:y' property to our target over 1.0 second
			# Use TRANS_QUAD and EASE_OUT for a smooth slowdown effect at the end
			tween.tween_property(door_parent, "rotation:y", target_rotation_y, 1.0)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT)
		
		# 2. Disable the physical collision so the player can pass through
		if solid_collision:
			solid_collision.set_deferred("disabled", true)
