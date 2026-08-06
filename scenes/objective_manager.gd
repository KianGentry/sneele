extends Node

# Signals allow your UI to update automatically when objectives change
signal objective_added(objective: Objective)
signal objective_updated(objective: Objective)
signal objective_renamed(objective: Objective)
signal objective_removed(id: String)

# A dictionary mapping the objective 'id' to the Objective object
var active_objectives: Dictionary = {}

## Adds a new objective to the manager
func add_objective(p_name: String, p_desc: String, p_is_main: bool = true) -> void:
	var new_objective = Objective.new(p_name, p_desc, p_is_main)
	
	# Prevent adding duplicate objectives
	if active_objectives.has(new_objective.id):
		push_warning("Objective Manager: Objective '%s' already exists!" % new_objective.id)
		return
		
	active_objectives[new_objective.id] = new_objective
	objective_added.emit(new_objective)
	
	var objective_type_label = "Main" if p_is_main else "Side"
	print("New %s Objective: %s" % [objective_type_label, p_name])

## Marks an existing objective as complete
func complete_objective(id: String) -> void:
	if active_objectives.has(id):
		var obj: Objective = active_objectives[id]
		obj.complete()
		objective_updated.emit(obj)
		print("Objective Completed: ", obj.objective_name)
	else:
		push_error("Objective Manager: Cannot complete, ID '%s' not found." % id)

## Renames an existing objective (ID stays the same)
func rename_objective(id: String, new_name: String) -> void:
	if not active_objectives.has(id):
		push_error("Objective Manager: Cannot rename, ID '%s' not found." % id)
		return

	var obj: Objective = active_objectives[id]
	obj.rename_to(new_name)
	objective_renamed.emit(obj)

## Removes an objective from the manager
func remove_objective(id: String) -> void:
	if not active_objectives.has(id):
		push_error("Objective Manager: Cannot remove, ID '%s' not found." % id)
		return

	active_objectives.erase(id)
	objective_removed.emit(id)
	print("Objective Removed: ", id)
