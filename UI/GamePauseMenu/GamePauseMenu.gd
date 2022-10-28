extends Control

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal request(req_name, msg)


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var resume_btn : Button = $Center/Options/Resume

# ------------------------------------------------------------------------------
# Override Method
# ------------------------------------------------------------------------------
func _ready() -> void:
	visible = false

func _gui_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		emit_signal("request", "resume_game")

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_close_menu() -> void:
	visible = false

func _on_menu_requested(menu_name : String) -> void:
	visible = menu_name == name
	if visible == true:
		resume_btn.grab_focus()

func _on_Resume_pressed():
	emit_signal("request", "resume_game")

func _on_QuitToMainMenu_pressed():
	emit_signal("request", "quit_game")

func _on_QuitToDesktop_pressed():
	emit_signal("request", "quit")
