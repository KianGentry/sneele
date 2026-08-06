extends Area3D

@export var max_distance: float = 6.0 
@export var min_distance: float = 1.5 

@export var min_scale: Vector3 = Vector3(0.2, 0.2, 0.2)
@export var max_scale: Vector3 = Vector3(1.2, 1.2, 1.2)

@onready var triangle: Sprite3D = $Sprite3D

var player: Node3D = null

func _ready() -> void:
	triangle.visible = false

func _process(_delta: float) -> void:
	if not player or not triangle.visible:
		return

	var distance: float = global_position.distance_to(player.global_position)
	
	var progress: float = remap(distance, max_distance, min_distance, 0.0, 1.0)
	progress = clamp(progress, 0.0, 1.0)
	
	triangle.scale = min_scale.lerp(max_scale, progress)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body
		triangle.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
		triangle.visible = false
