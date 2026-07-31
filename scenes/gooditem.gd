extends Node3D

@onready var sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var sprite: Sprite3D = $Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if sprite.visible == true:
			# Disable monitoring immediately so this trigger only fires once
			set_deferred("monitoring", false)
			
			sprite.visible = false
			sound.play()
			Global.score += 3
		else:
			return


func _on_audio_stream_player_finished() -> void:
	queue_free()
