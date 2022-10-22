extends KinematicBody2D


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var climb_speed : float = 10.0
export var step_rate : float = 2.0


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _last_step_time : float = 0.0
var _cur_l_leg : int = 0
var _cur_r_leg : int = 0
var _use_left : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var left_legs : Array = $LeftLegs.get_children()
onready var right_legs : Array = $RightLegs.get_children()

onready var right_target : Position2D = $RightTarget
onready var left_target : Position2D = $LeftTarget


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_NextStep()
	_NextStep()
	_NextStep(Vector2(0.0, 140.0))
	_NextStep(Vector2(0.0, 140.0))
	_NextStep(Vector2(0.0, 280.0))
	_NextStep(Vector2(0.0, 280.0))
	_NextStep(Vector2(0.0, 400.0))
	_NextStep(Vector2(0.0, 400.0))

func _physics_process(delta : float) -> void:
	var move_vec : Vector2 = Vector2(0.0, -climb_speed)
	move_and_collide(move_vec * delta)

func _process(delta : float) -> void:
	_last_step_time += delta
	if _last_step_time >= step_rate:
		_NextStep()
		_last_step_time = 0.0

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _NextStep(offset : Vector2 = Vector2.ZERO) -> void:
	var leg = null
	var pos : Position2D = null
	if _use_left:
		leg = left_legs[_cur_l_leg]
		pos = left_target
		_cur_l_leg += 1
		if _cur_l_leg >= left_legs.size():
			_cur_l_leg = 0
	else:
		leg = right_legs[_cur_r_leg]
		pos = right_target
		_cur_r_leg += 1
		if _cur_r_leg >= right_legs.size():
			_cur_r_leg = 0
	_use_left = not _use_left
	leg.step_to(pos.global_position + offset)

