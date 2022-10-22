extends KinematicBody2D


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var accel : float = 500						setget set_accel
export var dampening : float = 0.1					setget set_dampening
export var max_speed : float = 512					setget set_max_speed
export var max_jump_height : float = 128.0			setget set_max_jump_height
export var half_jump_dist : float = 150				setget set_half_jump_dist
export var fall_multiplier : float = 1.25			setget set_fall_multiplier

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var velocity : Vector2 = Vector2.ZERO
var direction_x : Array = [0.0, 0.0]
var jump_strength : float = 0
var gravity : float = 1

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_accel(a : float) -> void:
	if a > 0:
		accel = a

func set_dampening(d : float) -> void:
	if d >= 0.0 and d <= 1.0:
		dampening = d

func set_max_speed (s : float) -> void:
	if s > 0:
		max_speed = s
		_CalculateJumpVariables()

func set_max_jump_height(h : float) -> void:
	if h >= 0:
		max_jump_height = h
		_CalculateJumpVariables()

func set_half_jump_dist(d : float) -> void:
	if d > 0:
		half_jump_dist = d
		_CalculateJumpVariables()

func set_fall_multiplier(m : float) -> void:
	if m > 0.0:
		fall_multiplier = m

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_CalculateJumpVariables()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CalculateJumpVariables() -> void:
	# NOTE: The idea for this came from...
	# https://youtu.be/hG9SzQxaCm8
	jump_strength = (2 * max_jump_height * max_speed) / half_jump_dist
	gravity = (2 * max_jump_height * pow(accel, 2)) / pow(half_jump_dist, 2)

func _ProcessVelocity_H(change : float = 0.0) -> void:
	if change != 0.0:
		if sign(change) != sign(velocity.x):
			velocity.x = 0.0
		velocity.x += max(-max_speed, min(change, max_speed))
	else:
		velocity.x = lerp(velocity.x, 0.0, dampening)
		if abs(velocity.x) < 0.05:
			velocity.x = 0.0 

func _ProcessVelocity_V(change : float = 0.0, instant : bool = false) -> void:
	if instant:
		velocity.y = change
	else:
		velocity.y += change

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------

