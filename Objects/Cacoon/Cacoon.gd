extends StaticBody2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MIN_TIME_TO_BREAK : float = 0.75
const MAX_TIME_TO_BREAK : float = 1.25

enum GENDER {Random=0, Male=1, Female=2}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export (GENDER) var gender : int = GENDER.Random
export (float, 0.0, 45.0) var angle : float = 8.0			setget set_angle
export var time_to_max_angle : float = 0.1
export var gravity : float = 300.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _interacting : bool = false
var _time_to_break : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var sprite : Sprite = $Sprite
onready var tween : Tween = $Tween
onready var sfx : Node = $SFX

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_angle(a : float) -> void:
	angle = max(0.0, min(45.0, a))


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if gender == GENDER.Random:
		gender = GENDER.Male if randf() < 0.5 else GENDER.Female
	sfx.connect("finished", self, "_on_audio_finished")
	tween.connect("tween_all_completed", self, "_on_wiggle_complete")
	_time_to_break = rand_range(MIN_TIME_TO_BREAK, MAX_TIME_TO_BREAK)
	set_physics_process(false)

func _physics_process(delta : float) -> void:
	global_position.y += gravity * delta

func _process(delta : float) -> void:
	if _interacting:
		_time_to_break -= delta
		if _time_to_break <= 0.0:
			_interacting = false
			set_physics_process(true)
			sfx.play_from_group("f_scream" if gender == GENDER.Female else "m_scream", true)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Wiggle() -> void:
	if not tween.is_active():
		tween.reset_all()
	
	var dir : int = -sign(rotation)
	if rotation == 0.0:
		dir = -1 if randf() < 0.5 else 1
	var rads : float = deg2rad(rand_range(-angle, angle))
	
	var duration : float = (abs(rotation - rads) / deg2rad(angle * 2)) * (time_to_max_angle * 2)
	tween.interpolate_property(self, "rotation", rotation, rads, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func die() -> void:
	var parent = get_parent()
	if parent != null:
		parent.remove_child(self)
		queue_free()

func eatible() -> bool:
	if _time_to_break <= 0.0:
		return true
	return false

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_wiggle_complete() -> void:
	if _interacting:
		_Wiggle()

func _on_audio_finished() -> void:
	if _interacting:
		sfx.play_from_group("f_cry" if gender == GENDER.Female else "m_cry")

func _on_interact(active : bool) -> void:
	if _time_to_break > 0.0:
		_interacting = active
		if _interacting and not tween.is_active():
			_Wiggle()
			sfx.play_from_group("f_cry" if gender == GENDER.Female else "m_cry")

func _on_InteractZone_body_entered(body : Node2D) -> void:
	if body.has_signal("interact"):
		if not body.is_connected("interact", self, "_on_interact"):
			body.connect("interact", self, "_on_interact")

func _on_InteractZone_body_exited(body : Node2D) -> void:
	if body.has_signal("interact"):
		if body.is_connected("interact", self, "_on_interact"):
			body.disconnect("interact", self, "_on_interact")
