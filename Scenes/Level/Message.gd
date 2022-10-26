extends CenterContainer

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal message_visible()
signal message_hidden()

# ------------------------------------------------------------------------------
# Export variables
# ------------------------------------------------------------------------------
export var time_to_visible : float = 0.25
export var time_to_hidden : float = 0.5
export var time_on_screen : float = 10.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _tweening : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var label : Label = $Label

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _gui_input(event : InputEvent) -> void:
	if modulate == Color(1,1,1,1):
		if event.is_action_pressed("ui_cancel"):
			_Hide()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------

func _Hide() -> void:
	var tween : SceneTreeTween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), time_to_hidden)
	tween.connect("finished", self, "_on_tween_finished", ["hide"])

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_hidden() -> bool:
	return modulate == Color(1,1,1,0)

func show_message(msg : String) -> void:
	if modulate != Color(1,1,1,1):
		label.text = msg
		var tween : SceneTreeTween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(1,1,1,1), time_to_visible)
		tween.connect("finished", self, "_on_tween_finished", ["show"])


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_tween_finished(tween_type : String) -> void:
	match tween_type:
		"show":
			emit_signal("message_visible")
			var timer : SceneTreeTimer = get_tree().create_timer(time_on_screen)
			yield(timer, "timeout")
			if modulate == Color(1,1,1,1):
				_Hide()
		"hide":
			emit_signal("message_hidden")

