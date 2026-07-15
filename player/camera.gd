extends Camera3D

@export var target: Node3D
var offset: Vector3 = Vector3(0,1.5,4) # position of camera
var lerp_speed: float = 0.1 # change to make floatier

@onready var parallax: Parallax2D = $"../../../Background/Parallax2D"

func _physics_process(delta: float) -> void:
	if not target:
		return
	
	# lags a little behind, but goes to target position as offset reaches 0
	var target_position = target.global_position + offset 
	
	# ranging target position
	global_position = global_position.lerp(target_position, lerp_speed)
	
	if parallax:
		parallax.screen_offset = Vector2(-global_position.x, global_position.z) * 2.0
