extends CharacterBody3D

const SPEED = 10
const JUMP_VELOCITY = 5.5
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var parallax_factor : float = 5
@export var climb_speed : float = 3.0
@onready var animated_sprite = $Ara
@onready var ground = get_node("ground")
@onready var player_node : CharacterBody3D = get_node(".")

var initial_background_pos : Vector2
var facing_direction_x = 1
var facing_direction_z = 1
var was_on_floor = true
var last_dir = Vector2.ZERO

#---Climbing state ---
var is_climbing : bool = false
var climb_area : Area3D = null

# Called by ClimbableArea.gd
func set_climbable(state: bool, area: Area3D) -> void:
	is_climbing = state
	climb_area = area
	if state:
		velocity = Vector3.ZERO # reset movement when starting to climb

func _physics_process(delta: float) -> void:
	var player_pos = player_node.global_transform.origin
	ground.position.x = initial_background_pos.x - player_pos.x * parallax_factor

	# --- Choose which movement mode to use ---
	if is_climbing:
		_handle_climbing(delta)
	else:
		_handle_normal_movement(delta)
	
	# --- Handle Normal Ground Movement ---
func _handle_normal_movement(delta: float) -> void:
	# Apply gravity if not on the ground
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Handle jump input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_play_jump_animation()

	# Movement input
	var input_dir := Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Detect state change: landing / airborne
	var just_landed = is_on_floor() and not was_on_floor
	var just_left_ground = not is_on_floor() and was_on_floor

	# Handle animations
	if not is_on_floor():
		if just_left_ground:
			_play_jump_animation()
	elif just_landed:
		_play_ground_animation(input_dir)
	else:
		_play_ground_animation(input_dir)

	was_on_floor = is_on_floor()
	
	move_and_slide()
	
	# --- Handle Climbing Movement ---
func _handle_climbing(delta: float) -> void:
	# Stop gravity
	velocity = Vector3.ZERO

	# Get input
	var move_y = 0.0
	var move_x = 0.0

	if Input.is_action_pressed("move_up"):
		move_y = climb_speed
	elif Input.is_action_pressed("move_down"):
		move_y = -climb_speed

	if Input.is_action_pressed("move_left"):
		move_x = -climb_speed
	elif Input.is_action_pressed("move_right"):
		move_x = climb_speed

	velocity.y = move_y
	velocity.x = move_x

	move_and_slide()


# --- Animation helpers ---
func _play_jump_animation():
	var move_dir = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	)

	if abs(move_dir.x) > abs(move_dir.z):
		animated_sprite.play("jump side")
		animated_sprite.flip_h = move_dir.x < 0
	elif move_dir.z > 0:
		animated_sprite.play("jump forward")
	else:
		if move_dir.z < 0:
			animated_sprite.play("jump back")


func _play_ground_animation(input_dir: Vector2):
	if input_dir != Vector2.ZERO:
		last_dir = input_dir
		if abs(input_dir.x) > abs(input_dir.y):
			animated_sprite.play("walk (side)")
			animated_sprite.flip_h = input_dir.x < 0
		elif input_dir.y < 0:
			animated_sprite.play("walk (back)")
		else:
			animated_sprite.play("walk (front)")
	else:
		# Idle animation
		if abs(last_dir.x) > abs(last_dir.y):
			animated_sprite.play("idle_side")
			animated_sprite.flip_h = last_dir.x < 0
		elif last_dir.y < 0:
			animated_sprite.play("idle_back")
		else:
			animated_sprite.play("idle_front")
