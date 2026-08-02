extends Control

@onready var container: TextureRect = $TextureRect2
@onready var texturerect: TextureRect = $TextureRect2/TextureRect
@onready var animation: AnimationPlayer = $TextureRect2/AnimationPlayer
@onready var timer: Timer = $Timer
@onready var sound: AudioStreamPlayer = $TextureRect2/AudioStreamPlayer
@onready var welldonetimer: Timer = $TextureRect2/Timer
@onready var welldone: AudioStreamPlayer = $TextureRect2/welldone

func _ready() -> void:
	pass

# called by parent interactable
func setup_reveal(item: ItemData) -> void:
	if item:
		texturerect.texture = item.texture
		InventoryManager.add_item(item)

	if animation.has_animation("labelfall"):
		sound.play()
		welldonetimer.start()
		container.modulate.a = 1.0
		animation.play("labelfall")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "labelfall":
		timer.start()

func fade_and_destroy() -> void:
	var tween = create_tween()
	tween.tween_property(container, "modulate:a", 0.0, 1)
	if container.modulate.a == 0.0:
		queue_free()

func _on_timer_timeout():
	fade_and_destroy()


func _on_welldonetimer_timeout() -> void:
	welldone.play()
