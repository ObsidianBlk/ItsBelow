extends "res://Objects/Player/PlayerState.gd"


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func handle_input(event : InputEvent) -> void:
	if event.is_action_pressed("player_left"):
		player.direction_x[0] = -event.get_action_strength("player_left")
	elif event.is_action_released("player_left"):
		player.direction_x[0] = 0.0
	elif event.is_action_pressed("player_right"):
		player.direction_x[1] = event.get_action_strength("player_right")
	elif event.is_action_released("player_right"):
		player.direction_x[1] = 0.0

func physics_update(delta : float) -> void:
	if player.is_on_floor():
		if abs(player.velocity.x) > 0.05:
			_sm.change_to_state("Move")
		else:
			_sm.change_to_state("Idle")
	else:
		var direction : float = player.direction_x[0] + player.direction_x[1]
		if abs(direction) > 0.1:
			player._ProcessVelocity_H(direction * player.accel * delta)
		else:
			player._ProcessVelocity_H()
		player._ProcessVelocity_V(player.gravity * player.fall_multiplier * delta)
		player.velocity = player.move_and_slide_with_snap(
			player.velocity, Vector2.DOWN, Vector2.UP, false
		)
	
	
	
