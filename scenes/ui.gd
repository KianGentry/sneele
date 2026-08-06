extends CanvasLayer

@onready var score_label: Label = $score
@onready var score_timer: Timer = $scoreTimer
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var inventory_ui: Control = $inventory
@onready var obj_animation: AnimationPlayer = $AnimationPlayer2
@onready var score_animation: AnimationPlayer = $AnimationPlayer3
@onready var flash: ColorRect = $ColorRect
@onready var tween: Tween = create_tween()
@onready var close: AudioStreamPlayer = $close
@onready var open: AudioStreamPlayer = $open

var is_playing = false
var is_obj_playing = false
var is_score_playing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flash.visible = true
	tween.tween_property(flash, "color:a", 0.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	flash.visible = false
	animation.play("RESET")
	
	Global.score_changed.connect(_on_score_changed)
	score_label.text = str(Global.score)
	
func _on_score_changed(new_score: int) -> void:
	if is_score_playing == true:
		is_score_playing = true
		score_timer.start()
		score_label.text = str(new_score)
	else:
		if score_timer.time_left:
			score_timer.start()
			score_label.text = str(new_score)
		else:
			score_animation.play("pop_up")
			score_timer.start()
			score_label.text = str(new_score)

func _on_score_timer_timeout() -> void:
	is_score_playing = true
	score_animation.play("pop_down")

func _on_animation_finished(anim_name: StringName) -> void:
	is_playing = false

func _on_obj_animation_finished(anim_name: StringName) -> void:
	is_obj_playing = false

func _on_score_animation_finished(anim_name: StringName) -> void:
	is_score_playing = false
	if anim_name == "pop_down":
		score_animation.play("RESET")
