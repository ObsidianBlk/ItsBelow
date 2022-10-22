extends Node
class_name FSMState


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _sm : Node = null

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func enter(msg : Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func handle_input(event : InputEvent) -> void:
	pass

func update(_delta : float) -> void:
	pass

func physics_update(_delta : float) -> void:
	pass

