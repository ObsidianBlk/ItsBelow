extends "res://Objects/Player/PlayerState.gd"


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------

func handle_input(event : InputEvent) -> void:
	for ename in ["player_left", "player_right"]:
		if event.is_action_pressed(ename):
			_sm.change_to_state("Move")
	if event.is_action_pressed("player_jump"):
		_sm.change_to_state("Jump")

func physics_update(delta : float) -> void:
	if not player.is_on_floor():
		_sm.change_to_state("Fall")