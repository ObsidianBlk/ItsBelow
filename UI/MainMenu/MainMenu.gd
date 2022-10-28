extends Control



# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal request(req_name, msg)



# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var vp : Viewport = $Viewport
onready var texrec : TextureRect = $TextureRect

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	visible = false
	if texrec.texture == null:
		texrec.texture = vp.get_texture()

func _enter_tree() -> void:
	if texrec:
		texrec.texture = vp.get_texture()

func _exit_tree() -> void:
	if texrec:
		texrec.texture = null

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_close_menu() -> void:
	visible = false

func _on_menu_requested(menu_name : String) -> void:
	visible = menu_name == name

func _on_Start_pressed():
	emit_signal("request", "start_game")

func _on_Quit_pressed():
	emit_signal("request", "quit")


