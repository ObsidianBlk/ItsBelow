extends "res://Objects/Player/PlayerState.gd"



# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func enter(msg : Dictionary = {}) -> void:
	player.interact(true)

func handle_input(event : InputEvent) -> void:
	if event.is_action_released("player_interact"):
		player.interact(false)
		_sm.change_to_state("Idle")
