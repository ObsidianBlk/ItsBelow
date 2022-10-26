extends Node2D


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var ui : CanvasLayer = $UI
onready var level : Node2D = $Level


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	level.connect("height_changed", self, "_on_height_changed")
	level.connect("game_over", self, "_on_game_over")
	ui.connect("request", self, "_on_request")


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_game_over(message : String) -> void:
	level.close_level()
	ui.show_menu("MainMenu")

func _on_request(req_name : String, msg : Dictionary = {}) -> void:
	match req_name:
		"start_game":
			ui.close_menus()
			level.start_level()
		"quit":
			get_tree().quit()

func _on_height_changed(meters : float) -> void:
	print("Player Max Height: ", meters)
