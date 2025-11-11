extends Camera3D

@export var player: Node3D
@export var follow_offset: Vector3 = Vector3(0, 5, 10)
@export var follow_speed: float = 0.1
@export var rotation_speed: float = 2.0  # how fast the camera rotates

var _rotation_input: Vector2 = Vector2.ZERO
var _is_rotating: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	# Mouse capture/release toggle
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Detect when holding or releasing the left button
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_is_rotating = event.pressed

	# Rotate only while holding left click
	if _is_rotating and event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_rotation_input.x -= event.relative.x * rotation_speed * 0.01
		_rotation_input.y -= event.relative.y * rotation_speed * 0.01
		_rotation_input.y = clamp(_rotation_input.y, deg_to_rad(-30), deg_to_rad(45))


func _process(_delta: float) -> void:
	if not player:
		return

	# Smoothly follow the player
	global_position = global_position.lerp(
		player.global_position + follow_offset.rotated(Vector3.UP, _rotation_input.x),
		follow_speed
	)

	# Always look at the player
	look_at(player.global_position, Vector3.UP)

	# Apply up/down tilt
	rotation.x = _rotation_input.y
