extends CharacterBody3D

var SPEED: float = 2.7
const JUMP_VELOCITY: float = 2.5
var acceleration: float = 0.1
var deceleration: float = 0.05
var STEP_DELAY: float = 0.35
var step_timer: float = 0.0
var pull_speed_multiplier: float = 0.6
var pull_distance: float = 1.1
var pull_search_radius: float = 0.95
var pull_follow_strength: float = 10.0

var pulled_body: RigidBody3D = null
var pull_facing: Vector3 = Vector3(0, 0, 1)
var pulled_body_prev_lock_x: bool = false
var pulled_body_prev_lock_y: bool = false
var pulled_body_prev_lock_z: bool = false

@export var camera: Camera3D
@onready var sound = $AudioStreamPlayer3D
@onready var sprite = $AnimatedSprite3D
@onready var player = self
@onready var inv_open = false
@onready var obj_open = true
@onready var score_open = false
@onready var ui: CanvasLayer = $"../UI"

func _cardinalize_direction(dir: Vector3) -> Vector3:
	var flat := Vector2(dir.x, dir.z)
	if flat.length() <= 0.001:
		return pull_facing
	if abs(flat.x) > abs(flat.y):
		return Vector3(sign(flat.x), 0, 0)
	return Vector3(0, 0, sign(flat.y))

func _find_nearby_rigidbody() -> RigidBody3D:
	var space_state := get_world_3d().direct_space_state
	var sphere := SphereShape3D.new()
	sphere.radius = pull_search_radius

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(Basis(), global_position)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [self]

	var hits := space_state.intersect_shape(query, 16)
	var nearest: RigidBody3D = null
	var nearest_dist := INF
	for hit in hits:
		var collider = hit.get("collider")
		if collider is RigidBody3D:
			var dist := global_position.distance_to(collider.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = collider
	return nearest

func _start_pull(input_dir: Vector2) -> void:
	pulled_body = _find_nearby_rigidbody()
	if pulled_body == null:
		return

	var current_facing := pull_facing
	if Input.is_action_pressed("up"):
		current_facing = Vector3(0, 0, -1)
	elif Input.is_action_pressed("down"):
		current_facing = Vector3(0, 0, 1)
	elif Input.is_action_pressed("left"):
		current_facing = Vector3(-1, 0, 0)
	elif Input.is_action_pressed("right"):
		current_facing = Vector3(1, 0, 0)

	var to_body := (pulled_body.global_position - global_position)
	to_body.y = 0.0
	if to_body.length() <= 0.001:
		pulled_body = null
		return

	var to_body_dir := to_body.normalized()
	if current_facing.dot(to_body_dir) < 0.35:
		pulled_body = null
		return

	var facing_from_input := Vector3(input_dir.x, 0, input_dir.y)
	if facing_from_input.length() <= 0.001:
		facing_from_input = current_facing
	pull_facing = _cardinalize_direction(facing_from_input)

	pulled_body.sleeping = false
	pulled_body_prev_lock_x = pulled_body.axis_lock_angular_x
	pulled_body_prev_lock_y = pulled_body.axis_lock_angular_y
	pulled_body_prev_lock_z = pulled_body.axis_lock_angular_z
	pulled_body.axis_lock_angular_x = true
	pulled_body.axis_lock_angular_y = true
	pulled_body.axis_lock_angular_z = true
	pulled_body.angular_velocity = Vector3.ZERO

func _stop_pull() -> void:
	if pulled_body != null and is_instance_valid(pulled_body):
		pulled_body.axis_lock_angular_x = pulled_body_prev_lock_x
		pulled_body.axis_lock_angular_y = pulled_body_prev_lock_y
		pulled_body.axis_lock_angular_z = pulled_body_prev_lock_z
		pulled_body.angular_velocity = Vector3.ZERO
	pulled_body = null

func _ready() -> void:
	ObjectiveManager.objective_added.connect(_on_objective_added)
	ObjectiveManager.objective_updated.connect(_on_objective_updated)
	
func _on_objective_added(_objective: Objective) -> void:
	if ui.is_obj_playing == false:
		if obj_open == false:
			ui.obj_animation.play("slide")
			ui.is_obj_playing = true
			obj_open = true

func _on_objective_updated(objective: Objective) -> void:
	if objective.status == objective.Status.COMPLETED:
		if ui.is_obj_playing == false:
			if obj_open == false:
				ui.obj_animation.play("slide")
				ui.is_obj_playing = true
				obj_open = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	if pulled_body != null and not is_instance_valid(pulled_body):
		_stop_pull()

	if Input.is_action_pressed("use"):
		if pulled_body == null:
			_start_pull(input_dir)
	else:
		if pulled_body != null:
			_stop_pull()

	var is_pulling := pulled_body != null
	var move_speed := SPEED
	if is_pulling:
		move_speed *= pull_speed_multiplier

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# slidey movement
	if direction:
		velocity.x = lerp(velocity.x, direction.x * move_speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * move_speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, deceleration)
		velocity.z = lerp(velocity.z, 0.0, deceleration)

	# footstep sounds
	if is_on_floor() and direction.length() > 0.1:
		step_timer += delta
		if step_timer >= STEP_DELAY:
			sound.play()
			step_timer = 0.0
	else:
		step_timer = STEP_DELAY

	# player animation
	if is_pulling:
		var moving := direction.length() > 0.1
		if pull_facing.z < 0:
			if moving:
				sprite.play("walk_back")
			else:
				sprite.play("stand_back")
		elif pull_facing.z > 0:
			if moving:
				sprite.play("walk")
			else:
				sprite.play("stand")
		elif pull_facing.x < 0:
			if moving:
				sprite.play("walk_left")
			else:
				sprite.play("stand_left")
		else:
			if moving:
				sprite.play("walk_right")
			else:
				sprite.play("stand_right")
	else:
		if Input.is_action_pressed("up"): 
			sprite.play("walk_back")
		elif Input.is_action_just_released("up"): 
			if randi_range(1,1000) == 1:
				sprite.play("bald")
			else:
				sprite.play("stand_back")
		
		elif Input.is_action_pressed("down"): 
			sprite.play("walk")
		elif Input.is_action_just_released("down"):
			if randi_range(1,1000) == 1:
				sprite.play("faceless")
			else:
				sprite.play("stand")
		
		elif Input.is_action_pressed("left"): 
			sprite.play("walk_left")
		elif Input.is_action_just_released("left"): 
			sprite.play("stand_left")
		
		elif Input.is_action_pressed("right"): 
			sprite.play("walk_right")
		elif Input.is_action_just_released("right"): 
			sprite.play("stand_right")

	move_and_slide()
	
	# inventory input
	if Input.is_action_just_pressed("inv"):
		if InventoryManager.is_empty() == false:
			if ui.is_playing == false:
				if inv_open == false:
					ui.animation.play("slide")
					ui.open.play()
					ui.is_playing = true
					inv_open = true
					
					ui.inventory_ui.open_menu() 
				else:
					ui.is_playing = true
					ui.animation.play("slide_back")
					ui.close.play()
					inv_open = false
					ui.inventory_ui.close_menu()
		
	if Input.is_action_just_pressed("obj"):
		if ui.is_obj_playing == false:
			if obj_open == false:
				ui.obj_animation.play("slide")
				ui.open.play()
				ui.is_obj_playing = true
				obj_open = true
			else:
				ui.is_obj_playing = true
				ui.close.play()
				ui.obj_animation.play("slide_out")
				obj_open = false
	
	if Input.is_action_just_pressed("score"):
		if ui.is_score_playing == false:
			if score_open == false:
				ui.score_animation.play("pop_up")
				ui.open.play()
				ui.is_score_playing = true
				score_open = true
			else:
				ui.is_score_playing = true
				ui.close.play()
				ui.score_animation.play("pop_down")
				score_open = false
	
	# keep pulled body in front while holding use
	if is_pulling and is_instance_valid(pulled_body):
		var target_pos := global_position + (pull_facing * pull_distance)
		var to_target := target_pos - pulled_body.global_position
		pulled_body.linear_velocity = Vector3(to_target.x, 0.0, to_target.z) * pull_follow_strength
		pulled_body.angular_velocity = Vector3.ZERO

	var screen_pos = camera.unproject_position(player.global_position)
	var viewport_size = get_viewport().get_visible_rect().size
	# Calculate offset from center normalized to -0.5 to 0.5
	var offset = (screen_pos / viewport_size) - Vector2(0.5, 0.5)
	RenderingServer.global_shader_parameter_set("player_screen_offset", offset)

	if camera:
		var dist_to_cam = global_position.distance_to(camera.global_position)
		RenderingServer.global_shader_parameter_set("player_depth", dist_to_cam)
		RenderingServer.global_shader_parameter_set("player_y", global_position.y)
