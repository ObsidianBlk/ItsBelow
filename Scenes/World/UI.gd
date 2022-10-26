extends CanvasLayer


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal menu_requested(menu_name)
signal close_menu()
signal request(req_name, msg)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var initial_menu : String = ""


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	for child in get_children():
		if child.has_method("_on_menu_requested"):
			connect("menu_requested", child, "_on_menu_requested")
		if child.has_method("_on_close_menu"):
			connect("close_menu", child, "_on_close_menu")
		if child.has_signal("request"):
			child.connect("request", self, "_on_request")
	emit_signal("menu_requested", initial_menu)


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func show_menu(menu_name : String) -> void:
	emit_signal("menu_requested", menu_name)

func close_menus() -> void:
	emit_signal("close_menu")

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_request(req_name : String, msg : Dictionary = {}) -> void:
	emit_signal("request", req_name, msg)
