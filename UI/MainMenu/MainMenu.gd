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
onready var start_btn : Button = $Menu/Center/Options/Start

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
	if visible == true:
		start_btn.grab_focus()

func _on_Start_pressed():
	emit_signal("request", "show_menu", {"menu_name":"LevelSeed"})

func _on_Options_pressed() -> void:
	emit_signal("request", "show_menu", {"menu_name":"Options"})

func _on_Quit_pressed():
	emit_signal("request", "quit")


func _on_Jamoween_pressed():
	OS.shell_open("https://itch.io/jam/jamoween3")


func _on_Obsidian_pressed():
	OS.shell_open("https://obsidianblk.itch.io/")
