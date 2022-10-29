extends CenterContainer

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal request(req_name, msg)


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var start_btn : Button = $Main/Options/Start
onready var line_edit : LineEdit = $Main/Seed/LineEdit

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
		line_edit.text = String(int(rand_range(0, 999999)))
		start_btn.grab_focus()

func _on_Random_pressed():
	line_edit.text = String(int(rand_range(0, 999999)))


func _on_Start_pressed():
	var level_seed = 0
	if line_edit.text.strip_edges() == "":
		level_seed = int(rand_range(0, 999999))
	elif line_edit.text.is_valid_integer():
		level_seed = line_edit.text.to_int()
	else:
		level_seed = line_edit.text.hash()
	emit_signal("request", "start_game", {"seed":level_seed})


func _on_Cancel_pressed():
	emit_signal("request", "close_menu")


