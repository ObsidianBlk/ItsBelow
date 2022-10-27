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

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if level.is_playing():
			if ui.is_menu_visible("GamePauseMenu"):
				_ResumeGame()
			else:
				get_tree().paused = true
				ui.show_menu("GamePauseMenu")
		else:
			ui.show_menu("ConfirmQuit")


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ResumeGame() -> void:
	if get_tree().paused:
		get_tree().paused = false
	ui.close_menus()

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
		"quit_game":
			if get_tree().paused:
				get_tree().paused = false
			if level.is_playing():
				level.close_level()
			ui.show_menu("MainMenu")
		"resume_game":
			_ResumeGame()
		"quit":
			if "immediate" in msg and msg["immediate"] == true:
				get_tree().quit()
			else:
				ui.show_menu("ConfirmQuit")
		"quit_cancel":
			if ui.is_menu_visible("ConfirmQuit"):
				if get_tree().paused:
					if level.is_playing():
						ui.show_menu("GamePauseMenu")
				else:
					ui.show_menu("MainMenu")

func _on_height_changed(meters : float) -> void:
	print("Player Max Height: ", meters)
