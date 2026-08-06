extends Node3D

@export var cutout_shader: Shader
@onready var player: CharacterBody3D = $Entities/Player/CharacterBody3D
@onready var player_ui: CanvasLayer = $Entities/Player/UI
@onready var block: CollisionShape3D = $Misc/block/CollisionShape3D
@onready var world: FuncGodotMap = $World/FuncGodotMap
@onready var world_1_1: FuncGodotMap = $level_1_1/World/FuncGodotMap
@onready var lvl1_spawn: Marker3D = $Interactions/transition/Marker3D
@onready var lvl1_1_spawn: Marker3D = $level_1_1/Interactions/transition/Marker3D
@onready var shop_spawn: Marker3D = $level_1_1/Interactions/Interactable2/Marker3D
@onready var blackbg: Sprite2D = $Background/Parallax2D/Sprite2D/Sprite2D2

# textures to ignore in shader
@export var ignore_textures: Array[String] = []

var _is_transitioning: bool = false

func _ready() -> void:
	set_process(true)
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
			new_mat.set_shader_parameter("uv_scale", Vector2(old_mat.uv1_scale.x, old_mat.uv1_scale.y))

			if old_mat.albedo_texture:
				new_mat.set_shader_parameter("albedo_texture", old_mat.albedo_texture)
				
			mesh_instance.set_surface_override_material(i, new_mat)

func _on_transition_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		await _run_transition(lvl1_1_spawn, false)


func _on_transition_1_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		await _run_transition(lvl1_spawn, true)

func _run_transition(target_spawn: Marker3D, show_level_1: bool) -> void:
	if _is_transitioning:
		return

	_is_transitioning = true
	player_ui.flash.visible = true
	player_ui.flash.color.a = 0.0

	var fade_in: Tween = create_tween()
	fade_in.tween_property(player_ui.flash, "color:a", 1.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await fade_in.finished

	player.global_position = target_spawn.global_position

	world.visible = show_level_1
	world_1_1.visible = not show_level_1

	var fade_out: Tween = create_tween()
	fade_out.tween_property(player_ui.flash, "color:a", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await fade_out.finished

	player_ui.flash.visible = false
	_is_transitioning = false


func _on_shop_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		await _run_transition(shop_spawn, false)
		blackbg.visible = false
