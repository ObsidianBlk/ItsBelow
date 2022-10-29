extends Camera2D
class_name ShakeyCamera


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal player_fell()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var target_node_group : String = "Player"

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _last_vp_rect : Rect2 = Rect2(0,0,0,0)
var _shake_frequency : float = 0.0
var _shake_amplitude : float = 0.0
var _shake_priority : float = 0.0

var _target : WeakRef = weakref(null)


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var _timer : Timer = $Duration
onready var _tween : Tween = $Tween

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_target_node_group(tng : String) -> void:
	target_node_group = tng

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_timer.connect("timeout", self, "_on_duration_timeout")
	_UpdateTarget()
	_CheckViewport()

func _physics_process(_delta : float) -> void:
	_CheckViewport()
	var target = _target.get_ref()
	if target:
		if target.global_position.y < global_position.y:
			global_position.y = target.global_position.y
	else:
		_UpdateTarget()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateTarget() -> void:
	var nodes = get_tree().get_nodes_in_group(target_node_group)
	if nodes.size() > 0:
		_target = weakref(nodes[0])


func _CheckViewport() -> void:
	var vpr : Rect2 = get_viewport_rect()
	if not vpr.size.is_equal_approx(_last_vp_rect.size):
		_last_vp_rect = vpr
		global_position.x = vpr.size.x * 0.5

func _Shake(amplitude : float, duration : float) -> void:
	var vec : Vector2 = Vector2(
		rand_range(-amplitude, amplitude),
		rand_range(-amplitude, amplitude)
	)
	if not _tween.is_connected("tween_all_completed", self, "_on_shake_finished"):
		_tween.connect("tween_all_completed", self, "_on_shake_finished")
	_tween.interpolate_property(self, "offset", self.offset, vec, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_tween.start()

func _ResetFromShake(duration : float) -> void:
	# NOTE: Not using the Tween node in the camera!!
	var tween : SceneTreeTween = get_tree().create_tween()
	tween.tween_property(self, "offset", Vector2.ZERO, duration)
	_shake_priority = 0.0

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func shake(amplitude : float, frequency : float, duration : float, priority : float = 0.1) -> void:
	if _shake_priority < priority and frequency > 0.0:
		_shake_priority = priority
		_timer.start(duration)
		_shake_frequency = 1/frequency
		_shake_amplitude = amplitude
		_Shake(_shake_amplitude, _shake_frequency)

func reset_to_start() -> void:
	if _last_vp_rect.size.y > 0.0:
		global_position.y = _last_vp_rect.size.y * 0.5

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_shake_finished() -> void:
	_shake_amplitude *= 0.9
	if _tween.is_connected("tween_all_completed", self, "_on_shake_finished"):
		_tween.disconnect("tween_all_completed", self, "_on_shake_finished")
		if not _timer.is_stopped() and _shake_frequency > 0.0:
			_Shake(_shake_amplitude, _shake_frequency)

func _on_duration_timeout() -> void:
	if _shake_frequency > 0.0:
		_ResetFromShake(_shake_frequency)
	else:
		offset = Vector2.ZERO


func _on_PlayerWatch_body_entered(body : Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("die"):
			body.die()
		emit_signal("player_fell")
	if body.is_in_group("Cacoon"):
		if body.has_method("die"):
			body.die()
