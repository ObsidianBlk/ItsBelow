extends Position2D

# Lot of this code is adapted from code by https://www.youtube.com/c/Miziziziz
# From video : https://www.youtube.com/watch?v=qYwYgEGMdLA
# https://pastebin.com/ZxP8G3N5
#
# Adapted by: Bryan Miller

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MIN_DIST = 100

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var flipped : bool = false
export var verbos : bool = false
export var step_time : float = 0.5
export var step_height : float = 100.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var len_lower : float = 0.0
var len_mid : float = 0.0
var len_end : float = 0.0

var goal_pos : Vector2 = Vector2.ZERO
var int_pos : Vector2 = Vector2.ZERO
var start_pos: Vector2 = Vector2.ZERO
var step_time_elapsed : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var lower_joint : Position2D = $Lower
onready var mid_joint : Position2D = $Lower/Mid
onready var end_joint : Position2D = $Lower/Mid/End

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	len_lower = lower_joint.position.x
	len_mid = mid_joint.position.x
	len_end = end_joint.position.x

func _process(delta : float) -> void:
	step_time_elapsed += delta
	var target_pos : Vector2 = Vector2.ZERO
	var t = step_time_elapsed / step_time
	if t < 0.5:
		target_pos = start_pos.linear_interpolate(int_pos, t / 0.5)
	elif t <= 1.0:
		target_pos = int_pos.linear_interpolate(goal_pos, (t - 0.5) / 0.5)
	else:
		target_pos = goal_pos
	_UpdateIK(target_pos)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateIK(target_pos : Vector2) -> void:
	var offset : Vector2 = target_pos - global_position
	var dist_to_target : float = offset.length()
	if dist_to_target < MIN_DIST:
		offset = offset.normalized() * MIN_DIST
		dist_to_target = MIN_DIST
	
	var base_rot : float = offset.angle()
	var total_length = len_lower + len_mid + len_end
	var dummy_side_length = (len_lower + len_mid) * clamp(dist_to_target / total_length, 0, 1.0)
	
	var base_angles : Dictionary = _SSSCalc(dummy_side_length, len_end, dist_to_target)
	var next_angles : Dictionary = _SSSCalc(len_lower, len_mid, dummy_side_length)
	
	global_rotation = (base_rot + base_angles.b + next_angles.b)
	lower_joint.rotation = next_angles.c
	mid_joint.rotation = (base_angles.c + next_angles.a)


func _SSSCalc(side_a : float, side_b : float, side_c : float) -> Dictionary:
	var res : Dictionary = {"a":0, "b":0, "c":0}
	if side_c < side_a + side_b:
		var _pi : float = 0 if flipped else PI
		res.a = _LawOfCOS(side_b, side_c, side_a)
		res.b = _LawOfCOS(side_c, side_a, side_b) + _pi
		res.c = _pi - res.a - res.b
		if flipped:
			res.a = -res.a
			res.b = -res.b
			res.c = -res.c
	return res

func _LawOfCOS(a : float, b : float, c : float) -> float:
	var ab2 : float = a * b * 2.0
	if ab2 != 0.0:
		var val : float = acos((a * a + b * b - c * c)/ab2)
		if not is_nan(val):
			return val
	return 0.0

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func step_to(pos : Vector2, instant : bool = false) -> void:
	if pos == goal_pos:
		return
	goal_pos = pos
	var end_pos : Vector2 = end_joint.global_position
	var highest = pos.y
	if end_pos.y < highest:
		highest = end_pos.y
	
	var mid_body : float = (global_position.x - end_pos.x) * 0.5
	var mid = (pos.x + end_pos.x) * 0.5
	start_pos = end_pos
	int_pos = Vector2(mid + mid_body, highest - step_height)
	step_time_elapsed = 0.0
	
	if instant:
		_UpdateIK(goal_pos)

