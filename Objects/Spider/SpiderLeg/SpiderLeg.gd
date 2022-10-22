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

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var len_lower : float = 0.0
var len_mid : float = 0.0
var len_end : float = 0.0

var goal_pos : Vector2 = Vector2.ZERO
var int_pos : Vector2 = Vector2.ZERO
var start_pos: Vector2 = Vector2.ZERO
var step_height : float = 300
var step_rate : float = 0.5
var step_time : float = 0.0

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
	step_time += delta
	var target_pos : Vector2 = Vector2.ZERO
	var t = step_time / step_rate
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
	if verbos:
		print(base_angles, " | ", next_angles)
	
	global_rotation = (base_rot + base_angles.b + next_angles.b)
	lower_joint.rotation = next_angles.c
	mid_joint.rotation = (base_angles.c + next_angles.a)
	if verbos:
		print("Global: ", rad2deg(global_rotation), " | Lower: ", rad2deg(lower_joint.rotation), " | Mid: ", rad2deg(mid_joint.rotation))


func _SSSCalc(side_a : float, side_b : float, side_c : float) -> Dictionary:
	var res : Dictionary = {"a":0, "b":0, "c":0}
	if side_c < side_a + side_b:
		var sng : float = -1.0 if flipped else 1.0
		#var sng : float = 1.0
		res.a = sng * _LawOfCOS(side_b, side_c, side_a)
		res.b = sng * _LawOfCOS(side_c, side_a, side_b) + PI
		res.c = sng * (PI - res.a - res.b)
	return res

func _LawOfCOS(a : float, b : float, c : float) -> float:
	var ab2 : float = a * b * 2.0
	if ab2 == 0.0:
		return 0.0
	return acos((a * a + b * b - c * c)/ab2)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func step_to(pos : Vector2) -> void:
	if pos == goal_pos:
		return
	goal_pos = pos
	var end_pos : Vector2 = end_joint.global_position
	var highest = pos.y
	if end_pos.y < highest:
		highest = end_pos.y
	
	var mid = (pos.x + end_pos.x) * 0.5
	start_pos = end_pos
	int_pos = Vector2(mid, highest - step_height)
	step_time = 0.0

