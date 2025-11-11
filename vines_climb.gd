extends Area2D


@export var climbable_type: String = "vines_climb" # or "vine", "boulder" (for reference if needed)

# Optional visual feedback or sound when entering/leaving the climb area
@export var show_debug: bool = false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"): # ensure the player has the "player" group set
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
