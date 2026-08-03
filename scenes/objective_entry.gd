extends RichTextLabel

# These export variables will appear in the Inspector for you to modify graphically
@export var main_color: Color = Color(1.0, 0.84, 0.0) # Default Gold
@export var side_color: Color = Color(0.6, 0.8, 1.0)  # Default Light Blue
@export var completed_color: Color = Color(0.5, 0.5, 0.5) # Default Gray
@export var failed_color: Color = Color(0.9, 0.2, 0.2) # Default Red

var current_objective: Objective

## Called by the main UI when this entry is spawned
func setup(objective: Objective) -> void:
	current_objective = objective
	update_display()

## Updates the BBCode text and applies the correct inspector color
func update_display() -> void:
	var active_color: Color
	var prefix: String = "- "
	
	# Determine which color to use based on status and type
	if current_objective.status == Objective.Status.COMPLETED:
		active_color = completed_color
	elif current_objective.status == Objective.Status.FAILED:
		active_color = failed_color
	elif current_objective.type == Objective.Type.MAIN:
		active_color = main_color
	else:
		active_color = side_color
		
	# Convert the Godot Color to a hex code (e.g., #ffcc00) for BBCode
	var hex_color = active_color.to_html(false)
	
	# Apply BBCode to the RichTextLabel
	text = "[color=#%s]%s%s[/color]" % [hex_color, prefix, current_objective.objective_name]
