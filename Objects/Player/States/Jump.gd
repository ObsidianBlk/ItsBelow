extends "res://Objects/Player/PlayerState.gd"

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _initial_jump : bool = true

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func enter(msg : Dictionary = {}) -> void:
	if player.is_on_floor():
		_initial_jump = true
	else:
		_sm.change_to_state("Fall")


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
	var direction : float = player.direction_x[0] + player.direction_x[1]
	if abs(direction) > 0.1:
		player._ProcessVelocity_H(direction * player.accel * delta)
	else:
		player._ProcessVelocity_H()
	if _initial_jump:
		player._ProcessVelocity_V(-player.jump_strength, true)
		_initial_jump = false
	else:
		player._ProcessVelocity_V(player.gravity * player.fall_multiplier * delta)
		if player.velocity.y > 0.0:
			_sm.change_to_state("Fall")
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP, false)

