extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MUSIC_MENU : AudioStream = preload("res://Assets/Audio/Music/Horror Game Menu.ogg")
const MUSIC_GAME : AudioStream = preload("res://Assets/Audio/Music/Iwan Gabovitch - Dark Ambience Loop.ogg")


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var ui : CanvasLayer = $UI
onready var level : Node2D = $Level
onready var music : AudioStreamPlayer = $Music


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	level.connect("height_changed", self, "_on_height_changed")
	level.connect("game_over", self, "_on_game_over")
	ui.connect("request", self, "_on_request")
	music.stream = MUSIC_MENU
	IBSys.fade_audio_in(IBSys.AUDIO_BUS.Music, 0.5, true)
	music.play()

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

func _QuitGame() -> void:
	if get_tree().paused:
		get_tree().paused = false
	if level.is_playing():
		level.close_level()
		IBSys.fade_audio_out(IBSys.AUDIO_BUS.Music, 0.25)
		yield(IBSys, "audio_fade_finished")
	if music.stream != MUSIC_MENU:
		music.stop()
		music.stream = MUSIC_MENU
		IBSys.fade_audio_in(IBSys.AUDIO_BUS.Music, 0.25)
		music.play()
	ui.show_menu("MainMenu")

func _StopMusic(fade : bool = false) -> void:
	if fade:
		var tween : SceneTreeTween = get_tree().create_tween()
	else:
		music.stop()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_game_over(message : String) -> void:
	_QuitGame()

func _on_request(req_name : String, msg : Dictionary = {}) -> void:
	match req_name:
		"start_game":
			ui.close_menus()
			IBSys.fade_audio_out(IBSys.AUDIO_BUS.Music, 0.25)
			yield(IBSys, "audio_fade_finished")
			if "seed" in msg:
				if typeof(msg["seed"]) == TYPE_INT:
					level.level_seed = msg["seed"]
				elif typeof(msg["seed"]) == TYPE_STRING:
					if msg["seed"].is_valid_integer():
						level.level_seed = msg["seed"].to_int()
					elif msg["seed"].strip_edges() != "":
						level.level_seed = msg["seed"].hash()
			level.start_level()
			music.stop()
			music.stream = MUSIC_GAME
			IBSys.fade_audio_in(IBSys.AUDIO_BUS.Music, 0.25)
			music.play()
		"quit_game":
			_QuitGame()
		"resume_game":
			_ResumeGame()
		"quit":
			if "immediate" in msg and msg["immediate"] == true:
				# NOTE: Don't fade and yield without making sure system is ~~NOT~~ paused!!
				if get_tree().paused == true:
					get_tree().paused = false
				IBSys.fade_audio_out(IBSys.AUDIO_BUS.Music, 0.25)
				yield(IBSys, "audio_fade_finished")
				IBSys.save_settings()
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
		"close_menu":
			if level.is_playing():
				if get_tree().paused:
					get_tree().paused = false
				ui.close_menus()
			else:
				ui.show_menu("MainMenu") # Return to default menu

func _on_height_changed(meters : float) -> void:
	pass
