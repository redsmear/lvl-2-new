extends Area3D

@export var climbable_type: String = "ladder" # "vine", "boulder", etc.
@export var show_debug: bool = false # set true to see console logs when testing

func _ready() -> void:
	# Add this node to a group so RayCast or other scripts can find climbables
	add_to_group("climbable")

	# Connect signals for when a body enters or exits this area
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	# Only react to player characters
	if body.is_in_group("player"):
		if body.has_method("set_climbable"):
			body.set_climbable(true, self)

			if show_debug:
				print("Entered climbable area:", climbable_type)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("set_climbable"):
			body.set_climbable(false, null)

			if show_debug:
				print("Exited climbable area:", climbable_type)
