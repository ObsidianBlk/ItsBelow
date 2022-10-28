extends Control


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal request(req_name, msg)

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var volume_master : HSlider = $VBC/Sections/LeftColumn/VolumeMaster/Value
onready var volume_music : HSlider = $VBC/Sections/LeftColumn/VolumeMusic/Value
onready var volume_sfx : HSlider = $VBC/Sections/LeftColumn/VolumeSFX/Value
onready var fullscreen : CheckButton = $VBC/Sections/RightColumn/Fullscreen
onready var highest_score : Label = $VBC/Sections/RightColumn/HighScore/Info/Value
onready var score_clear : Button = $VBC/Sections/RightColumn/HighScore/Clear

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	visible = false

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateInfoValues() -> void:
	volume_master.value = IBSys.get_audio_volume(IBSys.AUDIO_BUS.Master) * 100
	volume_music.value = IBSys.get_audio_volume(IBSys.AUDIO_BUS.Music) * 100
	volume_sfx.value = IBSys.get_audio_volume(IBSys.AUDIO_BUS.SFX) * 100
	fullscreen.pressed = IBSys.is_fullscreen()
	highest_score.text = String(IBSys.get_highest_score())

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_close_menu() -> void:
	visible = false

func _on_menu_requested(menu_name : String) -> void:
	visible = menu_name == name
	if visible == true:
		_UpdateInfoValues()
		volume_master.grab_focus()

func _on_VolumeMaster_value_changed(value : float) -> void:
	IBSys.set_audio_volume(IBSys.AUDIO_BUS.Master, value / 100.0, true)

func _on_VolumeMusic_value_changed(value : float) -> void:
	IBSys.set_audio_volume(IBSys.AUDIO_BUS.Music, value / 100.0, true)

func _on_VolumeSFX_value_changed(value : float) -> void:
	IBSys.set_audio_volume(IBSys.AUDIO_BUS.SFX, value / 100.0, true)

func _on_Fullscreen_toggled(button_pressed : bool) -> void:
	IBSys.set_fullscreen(button_pressed)

func _on_ClearHighScore_pressed() -> void:
	IBSys.set_highest_score(0, true)
	highest_score.text = String(IBSys.get_highest_score())

func _on_Back_pressed() -> void:
	IBSys.save_settings()
	emit_signal("request", "close_menu")
