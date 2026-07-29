extends Control

@export_category("Textures")
@export var image_list: Array[Texture2D] = []

@export_category("Timing & Speed")
## Time in seconds for the sequence to reach maximum intensity
@export var intensity_duration: float = 10.0 
## Seconds between image flashes at the start
@export var min_flash_interval: float = 0.8  
## Seconds between image flashes at peak speed
@export var max_flash_interval: float = 0.05 

@onready var image_display: TextureRect = $ImageDisplay
@onready var vignette_overlay: ColorRect = $VignetteOverlay

var current_intensity: float = 0.0
var flash_timer: float = 0.0
var vignette_material: ShaderMaterial

func _ready() -> void:
	if vignette_overlay.material is ShaderMaterial:
		vignette_material = vignette_overlay.material
	
	# Start with the first image
	_show_next_image()

func _process(delta: float) -> void:
	# 1. Ramp intensity over time (0.0 to 1.0)
	if current_intensity < 1.0:
		current_intensity += delta / intensity_duration
		current_intensity = clamp(current_intensity, 0.0, 1.0)

	# 2. Update Vignette Tightness
	if vignette_material:
		# Optionally apply an exponential curve so it gets tighter faster near the end
		var eased_tightness = pow(current_intensity, 2.0)
		vignette_material.set_shader_parameter("tightness", eased_tightness)

	# 3. Handle Flashing Timing
	flash_timer -= delta
	if flash_timer <= 0.0:
		_show_next_image()
		
		# Calculate delay based on current intensity
		var current_interval = lerp(min_flash_interval, max_flash_interval, current_intensity)
		flash_timer = current_interval

var current_image_index: int = 0

func _show_next_image() -> void:
	if image_list.is_empty():
		return
	
	image_display.texture = image_list[current_image_index]
	
	# Increment index and loop back to 0 at the end
	current_image_index = (current_image_index + 1) % image_list.size()
