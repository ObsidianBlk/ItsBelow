extends KinematicBody2D
class_name Player


# ------------------------------------------------------------------------------
# Interacting
# ------------------------------------------------------------------------------
signal interact(active)


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var dampening : float = 0.1					setget set_dampening
export var max_speed : float = 512					setget set_max_speed
export var max_speed_time : float = 0.1				setget set_max_speed_time
export var max_jump_height : float = 128.0			setget set_max_jump_height
export var max_jump_time : float = 0.25				setget set_max_jump_time
export var jump_multiplier : float = 0.8			setget set_jump_multiplier
export var fall_multiplier : float = 1.25			setget set_fall_multiplier
export var coyote_time : float = 0.15				setget set_coyote_time
export var preland_grace_time : float = 0.1			setget set_preland_grace_time

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var accel : float = 0.0
var velocity : Vector2 = Vector2.ZERO
var direction_x : Array = [0.0, 0.0]
var facing_left : bool = false
var jump_strength : float = 0
var gravity : float = 1

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var sprite : Sprite = $Sprite
onready var anim : AnimationPlayer = $AnimationPlayer
onready var fsm : FSM = $FSM

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------

func set_dampening(d : float) -> void:
	if d >= 0.0 and d <= 1.0:
		dampening = d

func set_max_speed (s : float) -> void:
	if s > 0:
		max_speed = s
		_CalculateJumpVariables()

func set_max_speed_time(t : float) -> void:
	if t > 0.0:
		max_speed_time = t
		_CalculateJumpVariables()

func set_max_jump_height(h : float) -> void:
	if h >= 0:
		max_jump_height = h
		_CalculateJumpVariables()

func set_max_jump_time(t : float) -> void:
	if t > 0.0:
		max_jump_time = t
		_CalculateJumpVariables()

func set_fall_multiplier(m : float) -> void:
	if m > 0.0:
		fall_multiplier = m

func set_jump_multiplier(m : float) -> void:
	if m > 0.0 and m <= 1.0:
		jump_multiplier = m
		_CalculateJumpVariables()

func set_coyote_time(t : float) -> void:
	if t >= 0.0 and t <= 1.0:
		coyote_time = t

func set_preland_grace_time(t : float) -> void:
	if t >= 0.0:
		preland_grace_time = t

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_CalculateJumpVariables()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CalculateJumpVariables() -> void:
	# Calculations based on information found...
	# https://error454.com/2013/10/23/platformer-physics-101-and-the-3-fundamental-equations-of-platformers/
	accel = (max_speed * 2) / pow(max_speed_time, 2)
	gravity = (2 * max_jump_height) / pow(max_jump_time, 2)
	jump_strength = sqrt(2 * gravity * max_jump_height)

func _ProcessVelocity_H(change : float = 0.0) -> void:
	if change != 0.0:
		if sign(change) != sign(velocity.x):
			velocity.x = 0.0
		velocity.x = max(-max_speed, min(velocity.x + change, max_speed))
	else:
		velocity.x = lerp(velocity.x, 0.0, dampening)
		if abs(velocity.x) < 0.25 * max_speed:
			velocity.x = 0.0 

func _ProcessVelocity_V(change : float = 0.0, instant : bool = false) -> void:
	if instant:
		velocity.y = change
	else:
		velocity.y += change

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_class() -> String:
	return "Player"

func interact(active : bool = true) -> void:
	emit_signal("interact", active)

func face_left(left : bool = true) -> void:
	facing_left = left
	sprite.flip_h = facing_left

func play_animation(anim_name : String) -> void:
	if anim.has_animation(anim_name):
		anim.play(anim_name)

func revive() -> void:
	if fsm.is_frozen():
		self.visible = true
		fsm.freeze(false)

func die() -> void:
	fsm.freeze()
	self.visible = false
