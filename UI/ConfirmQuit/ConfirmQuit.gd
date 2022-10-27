extends Control


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal request(req_name, msg)


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

func _on_Yes_pressed():
	emit_signal("request", "quit", {"immediate": true})

func _on_No_pressed():
	emit_signal("request", "quit_cancel")
