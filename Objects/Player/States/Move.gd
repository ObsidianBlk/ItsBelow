extends "res://Objects/Player/PlayerState.gd"


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------

func enter(msg : Dictionary = {}) -> void:
	player.direction_x[0] = -Input.get_action_strength("player_left")
	player.direction_x[1] = Input.get_action_strength("player_right")
	player.play_animation("Run")

func handle_input(event : InputEvent) -> void:
	if event.is_action_pressed("player_left"):
		player.direction_x[0] = -event.get_action_strength("player_left")
	elif event.is_action_released("player_left"):
		player.direction_x[0] = 0.0
	elif event.is_action_pressed("player_right"):
		player.direction_x[1] = event.get_action_strength("player_right")
	elif event.is_action_released("player_right"):
		player.direction_x[1] = 0.0
	elif event.is_action_pressed("player_jump"):
		_sm.change_to_state("Jump")

func physics_update(delta : float) -> void:
	if player.is_on_floor():
		var direction : float = player.direction_x[0] + player.direction_x[1]
		if abs(direction) > 0.1:
			player.face_left(direction < 0.0)
			player._ProcessVelocity_H(direction * player.accel * delta)
		else:
			player._ProcessVelocity_H()
			#if abs(player.velocity.x) < 0.5:
			#	_sm.change_to_state("Idle")
		player.velocity = player.move_and_slide_with_snap(
			player.velocity, Vector2.DOWN, Vector2.UP, false, 2, deg2rad(55), false
		)
		if abs(player.velocity.x) < 8.0:
			player.velocity.x = 0.0
			_sm.change_to_state("Idle")
	else:
		_sm.change_to_state("Fall")

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------

