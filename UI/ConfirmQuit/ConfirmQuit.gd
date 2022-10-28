extends Control


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal request(req_name, msg)


# ------------------------------------------------------------------------------
# Onready Methods
# ------------------------------------------------------------------------------
onready var no_btn : Button = $Center/VBC/Options/No

# ------------------------------------------------------------------------------
# Override Method
# ------------------------------------------------------------------------------
func _ready() -> void:
	visible = false

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_close_menu() -> void:
	visible = false

func _on_menu_requested(menu_name : String) -> void:
	visible = menu_name == name
	if visible == true:
		no_btn.grab_focus()

func _on_Yes_pressed():
	emit_signal("request", "quit", {"immediate": true})

func _on_No_pressed():
	emit_signal("request", "quit_cancel")
