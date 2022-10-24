extends KinematicBody2D


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var target_node_path : NodePath = ""			setget set_target_node_path
export var climb_speed : float = 10.0				setget set_climb_speed
export var horizontal_speed : float = 200.0			setget set_horizontal_speed
export var horizontal_speed_time : float = 0.1		setget set_horizontal_speed_time
export var distance_per_step : float = 40.0			setget set_distance_per_step
export var step_time : float = 0.6					setget set_step_time


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _accel : float = 0.0
var _last_step_time : float = 0.0
var _cur_l_leg : int = 0
var _cur_r_leg : int = 0
var _use_left : bool = false

var _step_rate : float = 2.0
var _speed_x : float = 0.0

var target_node_ref : WeakRef = weakref(null)

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var left_legs : Array = $LeftLegs.get_children()
onready var right_legs : Array = $RightLegs.get_children()

onready var right_sensor : RayCast2D = $RightLegSensor
onready var left_sensor : RayCast2D = $LeftLegSensor



# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_target_node_path(np : NodePath) -> void:
	target_node_path = np
	if target_node_path == "":
		target_node_ref = weakref(null)
	else:
		var targ : Node2D = get_node_or_null(target_node_path)
		if targ:
			target_node_ref = weakref(targ)


func set_climb_speed (s : float) -> void:
	climb_speed = s
	_CalcStepRate()

func set_distance_per_step(d : float) -> void:
	if d > 0.0:
		distance_per_step = d
		_CalcStepRate()

func set_horizontal_speed(s : float) -> void:
	if s > 0.0:
		horizontal_speed = s
		_CalcAccel()

func set_horizontal_speed_time(t : float) -> void:
	if t > 0.0:
		horizontal_speed_time = t
		_CalcAccel()

func set_step_time(t : float) -> void:
	if t > 0.0:
		step_time = t

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	right_sensor.force_raycast_update()
	left_sensor.force_raycast_update()
	_CalcStepRate()
	set_target_node_path(target_node_path)

	_CalcAccel()
	
	for leg in left_legs:
		leg.step_time = step_time
	for leg in right_legs:
		leg.step_time = step_time
	call_deferred("_InitLegSteps")


func _physics_process(delta : float) -> void:
	var move_vec : Vector2 = Vector2(0.0, -climb_speed) + _GetHorzSpeed(delta)
	var res : KinematicCollision2D = move_and_collide(move_vec * delta)
	if res != null:
		_speed_x = 0.0

func _process(delta : float) -> void:
	_last_step_time += delta
	if _last_step_time >= _step_rate:
		_NextStep()
		_last_step_time = 0.0

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _InitLegSteps() -> void:
	_NextStep()
	_NextStep()
	_NextStep(Vector2(0.0, 140.0))
	_NextStep(Vector2(0.0, 140.0))
	_NextStep(Vector2(0.0, 280.0))
	_NextStep(Vector2(0.0, 280.0))
	_NextStep(Vector2(0.0, 400.0))
	_NextStep(Vector2(0.0, 400.0))

func _GetClosestViewportEdge() -> float:
	var resolution : Rect2 = get_viewport_rect()
	var d2l : float = global_position.x
	var d2r : float = abs(resolution.size.x - global_position.x)
	return min(d2l, d2r)

func _GetHorzSpeed(delta : float) -> Vector2:
	var target : Node2D = target_node_ref.get_ref()
	if target:
		var dist_to_target : float = target.global_position.x - global_position.x
		var hspeed : float = horizontal_speed * delta
		if abs(dist_to_target) > hspeed:
			_speed_x = max(-horizontal_speed, min(_speed_x + sign(dist_to_target) * _accel * delta, horizontal_speed))
		else:
			_speed_x = lerp(_speed_x, 0.0, 0.8)
		return Vector2(_speed_x, 0.0)
	return Vector2.ZERO

func _NextStep(offset : Vector2 = Vector2.ZERO) -> void:
	var leg = null
	var sensor : RayCast2D = null
	if _use_left:
		leg = left_legs[_cur_l_leg]
		sensor = left_sensor
		_cur_l_leg += 1
		if _cur_l_leg >= left_legs.size():
			_cur_l_leg = 0
	else:
		leg = right_legs[_cur_r_leg]
		sensor = right_sensor
		_cur_r_leg += 1
		if _cur_r_leg >= right_legs.size():
			_cur_r_leg = 0
	_use_left = not _use_left
	
	if sensor.is_colliding():
		var pos : Vector2 = sensor.get_collision_point()
		print("Leg Pos: ", pos)
		leg.step_to(pos + offset)
	else:
		print("No Leg Collision")

func _CalcAccel() -> void:
	_accel = (2 * horizontal_speed) / pow(horizontal_speed_time, 2)

func _CalcStepRate() -> void:
	if climb_speed != 0.0:
		_step_rate = distance_per_step / climb_speed
	else:
		_step_rate = 0.0
