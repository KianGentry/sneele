extends Node

var level: int = 0

signal score_changed(new_score)
var score: int = 0:
	set(value):
		if score != value:
			score = value
			score_changed.emit(score)
