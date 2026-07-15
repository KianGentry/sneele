extends CanvasLayer

@onready var score_label: Label = $score
@onready var score_timer: Timer = $scoreTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.score_changed.connect(_on_score_changed)
	score_label.text = str(Global.score)
	
func _on_score_changed(new_score: int) -> void:
	score_label.visible = true
	score_timer.start()
	score_label.text = str(new_score)

func _on_score_timer_timeout() -> void:
	score_label.visible = false
