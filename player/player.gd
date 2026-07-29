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

	# animation
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

	if camera:
		var dist_to_cam = global_position.distance_to(camera.global_position)
		RenderingServer.global_shader_parameter_set("player_depth", dist_to_cam)
		RenderingServer.global_shader_parameter_set("player_y", global_position.y)
