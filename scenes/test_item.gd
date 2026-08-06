extends Node3D

@onready var sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var sprite: Sprite3D = $Sprite3D
@onready var ding: AudioStreamPlayer = $AudioStreamPlayer2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if sprite.visible == true:
			set_deferred("monitoring", false)
			
			sprite.visible = false
			sound.play()
			ding.play()
			Global.score += 1
		else:
			return


func _on_audio_stream_player_finished() -> void:
	queue_free()
