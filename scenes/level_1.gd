extends Node3D

@export var cutout_shader: Shader

# textures to ignore in shader
@export var ignore_textures: Array[String] = []

func _ready() -> void:
	ObjectiveManager.add_objective(
		"Speak to Mum",
		"Go to your mum's room and speak to her.",
		true
	)
	_apply_shader_to_children(self)

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

		# opt out selected textures
		if old_mat and old_mat is StandardMaterial3D:
			var tex_name = ""
			if old_mat.albedo_texture:
				# filename (+ .png)
				tex_name = old_mat.albedo_texture.resource_path.get_file().get_basename()

			var skip = false
			for ignore_name in ignore_textures:
				# ff the ignore string is anywhere in the texture name, skip
				if ignore_name.nocasecmp_to(tex_name) == 0 or ignore_name in tex_name:
					skip = true
					break

			if skip:
				continue # skip to the next material without converting
			
			var new_mat = ShaderMaterial.new()
			new_mat.shader = cutout_shader

			if old_mat.albedo_texture:
				new_mat.set_shader_parameter("albedo_texture", old_mat.albedo_texture)
				
			mesh_instance.set_surface_override_material(i, new_mat)
