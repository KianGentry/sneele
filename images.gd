extends Control

@export var image_list: Array[Texture2D] = []

@export var intensity_duration: float = 10.0 
@export var min_flash_interval: float = 0.8  
@export var max_flash_interval: float = 0.05 

@onready var image_display: TextureRect = $ImageDisplay
@onready var vignette_overlay: ColorRect = $VignetteOverlay

var current_intensity: float = 0.0
var flash_timer: float = 0.0
var vignette_material: ShaderMaterial

func _ready() -> void:
	if vignette_overlay.material is ShaderMaterial:
		vignette_material = vignette_overlay.material
	
	_show_next_image()

func _process(delta: float) -> void:
	if current_intensity < 1.0:
		current_intensity += delta / intensity_duration
		current_intensity = clamp(current_intensity, 0.0, 1.0)

	if vignette_material:
		var eased_tightness = pow(current_intensity, 2.0)
		vignette_material.set_shader_parameter("tightness", eased_tightness)

	flash_timer -= delta
	if flash_timer <= 0.0:
		_show_next_image()

		var current_interval = lerp(min_flash_interval, max_flash_interval, current_intensity)
		flash_timer = current_interval

var current_image_index: int = 0

func _show_next_image() -> void:
	if image_list.is_empty():
		return
	
	image_display.texture = image_list[current_image_index]

	current_image_index = (current_image_index + 1) % image_list.size()
