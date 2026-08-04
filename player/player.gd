extends CharacterBody3D

var SPEED: float = 2.7
const JUMP_VELOCITY: float = 2.5
var push_force: float = 0.03
var acceleration: float = 0.1
var deceleration: float = 0.05
var STEP_DELAY: float = 0.35
var step_timer: float = 0.0

@export var camera: Camera3D
@onready var sound = $AudioStreamPlayer3D
@onready var sprite = $AnimatedSprite3D
@onready var player = self
@onready var inv_open = false
@onready var obj_open = true
@onready var ui: CanvasLayer = $"../UI"

func ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# slidey movement
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, acceleration)
		velocity.z = lerp(velocity.z, direction.z * SPEED, acceleration)
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
					ui.is_playing = true
					inv_open = true
					
					ui.inventory_ui.open_menu() 
				else:
					ui.is_playing = true
					ui.animation.play("slide_back")
					inv_open = false
					ui.inventory_ui.close_menu()
		
	if Input.is_action_just_pressed("obj"):
		if ui.is_obj_playing == false:
			if obj_open == false:
				ui.obj_animation.play("slide")
				ui.is_obj_playing = true
				obj_open = true
			else:
				ui.is_obj_playing = true
				ui.obj_animation.play("slide_out")
				obj_open = false
	
	# pushing stuff logic
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			var push_dir = -collision.get_normal()
			push_dir.y = 0.0
			push_dir = push_dir.normalized()
			var force = push_dir * SPEED * push_force
			collider.apply_central_impulse(force)

	var screen_pos = camera.unproject_position(player.global_position)
	var viewport_size = get_viewport().get_visible_rect().size
	# Calculate offset from center normalized to -0.5 to 0.5
	var offset = (screen_pos / viewport_size) - Vector2(0.5, 0.5)
	RenderingServer.global_shader_parameter_set("player_screen_offset", offset)

	if camera:
		var dist_to_cam = global_position.distance_to(camera.global_position)
		RenderingServer.global_shader_parameter_set("player_depth", dist_to_cam)
		RenderingServer.global_shader_parameter_set("player_y", global_position.y)
