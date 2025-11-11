extends SpringArm3D

@export var mouse_sensitivity: float = 0.005
@export var rotation_speed: float = 5.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-40), deg_to_rad(60)) # prevent flipping

func _process(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, get_parent().rotation.y, delta * rotation_speed)
