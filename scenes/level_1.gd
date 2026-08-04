extends Node3D

@export var cutout_shader: Shader
@onready var player: Node3D = $Entities/Player
@onready var player_ui: CanvasLayer = $Entities/Player/UI
@onready var block: CollisionShape3D = $Misc/block/CollisionShape3D

# textures to ignore in shader
@export var ignore_textures: Array[String] = []

func _ready() -> void:
	ObjectiveManager.objective_updated.connect(_on_objective_updated)
	ObjectiveManager.add_objective(
		"Speak to Mum",
		"Go to your mum's room and speak to her.",
		true
	)
	_apply_shader_to_children(self)

func _on_objective_updated(objective: Objective) -> void:
	if objective.id == "speak_to_mum" and objective.status == Objective.Status.COMPLETED:
		block.disabled = true

func _apply_shader_to_children(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh:
			_convert_mesh_materials(child)

		if child.get_child_count() > 0:
			_apply_shader_to_children(child)

func _convert_mesh_materials(mesh_instance: MeshInstance3D) -> void:
	var mesh = mesh_instance.mesh

	for i in range(mesh.get_surface_count()):
		var old_mat = mesh_instance.get_surface_override_material(i)
		if not old_mat:
			old_mat = mesh.surface_get_material(i)

		# only convert StandardMaterial3D surfaces
		if old_mat and old_mat is StandardMaterial3D:
			var tex_name = ""
			if old_mat.albedo_texture:
				# filename (+ .png)
				tex_name = old_mat.albedo_texture.resource_path.get_file().get_basename()

			var skip_cutout = false
			for ignore_name in ignore_textures:
				# if the ignore string is anywhere in the texture name, disable cutout only
				if ignore_name.nocasecmp_to(tex_name) == 0 or ignore_name in tex_name:
					skip_cutout = true
					break
			
			var new_mat = ShaderMaterial.new()
			new_mat.shader = cutout_shader
			new_mat.set_shader_parameter("enable_cutout", not skip_cutout)

			if old_mat.albedo_texture:
				new_mat.set_shader_parameter("albedo_texture", old_mat.albedo_texture)
				
			mesh_instance.set_surface_override_material(i, new_mat)

func _on_transition_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_ui.flash.visible = true
		player_ui.flash.color.a = 0.0
		var tween = create_tween()
		tween.tween_property(player_ui.flash, "color:a", 1.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tween.finished
		get_tree().change_scene_to_file("res://scenes/level_1_1.tscn")
