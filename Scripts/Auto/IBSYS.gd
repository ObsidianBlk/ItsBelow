extends Node


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal audio_fade_finished(bus_id, direction)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const CONFIG_PATH : String = "user://IBConfig.cfg"
const SEC_SETTINGS : String = "Settings"

enum AUDIO_BUS {Master=0, Music=1, SFX=2}
const AUDIO_BUS_NAMES : Array = [
	"Master",
	"Music",
	"SFX"
]

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _config : ConfigFile = ConfigFile.new()
var _highest_score : int = 0

var _fading_active : Array = [false,false,false]


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	var err : int = _config.load(CONFIG_PATH)
	if _config:
		for idx in range(AUDIO_BUS_NAMES.size()):
			var key : String = "audio_%s"%[AUDIO_BUS_NAMES[idx]]
			if _config.has_section_key(SEC_SETTINGS, key):
				set_audio_volume(idx, _config.get_value(SEC_SETTINGS, key, 1.0))
			else:
				_config.set_value(SEC_SETTINGS, key, get_audio_volume(idx))
		if _config.has_section_key(SEC_SETTINGS, "highest_score"):
			_highest_score = _config.get_value(SEC_SETTINGS, "highest_score", 0)
		if _config.has_section_key(SEC_SETTINGS, "fullscreen"):
			var fs : bool = _config.get_value(SEC_SETTINGS, "fullscreen", false)
			if fs != OS.window_fullscreen:
				OS.window_fullscreen = fs


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _FaderVolume(vol : float, bus_id : int) -> void:
	set_audio_volume(bus_id, vol, false)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func save_settings() -> void:
	var err : int = _config.save(CONFIG_PATH)
	if err != OK:
		printerr("ERROR: Failed to save config file!")

func is_fullscreen() -> bool:
	return OS.window_fullscreen

func set_fullscreen(enable : bool) -> void:
	if OS.window_fullscreen != enable:
		OS.window_fullscreen = enable
		_config.set_value(SEC_SETTINGS, "fullscreen", enable)

func set_audio_volume(bus_id : int, vol : float, save_config : bool = false) -> void:
	var bus_idx : int = -1
	if bus_id >= 0 and bus_id < AUDIO_BUS_NAMES.size():
		bus_idx = AudioServer.get_bus_index(AUDIO_BUS_NAMES[bus_id])
	
	if bus_idx >= 0:
		vol = max(0.0, min(1.0, vol))
		AudioServer.set_bus_volume_db(bus_idx, linear2db(vol))
		if save_config and _config:
			_config.set_value(SEC_SETTINGS, "audio_%s"%[AUDIO_BUS_NAMES[bus_id]], vol)

func get_audio_volume(bus_id : int) -> float:
	var bus_idx : int = -1
	if bus_id >= 0 and bus_id < AUDIO_BUS_NAMES.size():
		bus_idx = AudioServer.get_bus_index(AUDIO_BUS_NAMES[bus_id])
	
	if bus_idx >= 0:
		return db2linear(AudioServer.get_bus_volume_db(bus_idx))
	return 0.0

func fade_audio_out(bus_id : int, duration : float, force_full : bool = false) -> void:
	if not (bus_id >= 0 and bus_id < AUDIO_BUS_NAMES.size()):
		return
	if _fading_active[bus_id]:
		return
	_fading_active[bus_id] = true
	if force_full:
		var target : float = _config.get_value(SEC_SETTINGS, "audio_%s"%[AUDIO_BUS_NAMES[bus_id]], 1.0)
		set_audio_volume(bus_id, target, false)
	var tween : SceneTreeTween = get_tree().create_tween()
	var cur : float = get_audio_volume(bus_id)
	tween.connect("finished", self, "_on_fader_finished", [bus_id, "out"])
	tween.tween_method(self, "_FaderVolume", cur, 0.0, duration, [bus_id])

func fade_audio_in(bus_id : int, duration : float, force_dead : bool = false) -> void:
	if not (bus_id >= 0 and bus_id < AUDIO_BUS_NAMES.size()):
		return
	if _fading_active[bus_id]:
		return
	_fading_active[bus_id] = true
	if force_dead:
		set_audio_volume(bus_id, 0.0)
	var target : float = _config.get_value(SEC_SETTINGS, "audio_%s"%[AUDIO_BUS_NAMES[bus_id]], 1.0)
	var tween : SceneTreeTween = get_tree().create_tween()
	tween.connect("finished", self, "_on_fader_finished", [bus_id, "in"])
	tween.tween_method(self, "_FaderVolume", get_audio_volume(bus_id), target, duration, [bus_id])

func is_audio_fading(bus_id : int) -> bool:
	if bus_id >= 0 and bus_id < AUDIO_BUS_NAMES.size():
		return _fading_active[bus_id]
	return false

func set_highest_score(score : int, reset : bool = false) -> void:
	if reset or score > _highest_score:
		_highest_score = score
		_config.set_value(SEC_SETTINGS, "highest_score", _highest_score)

func get_highest_score() -> int:
	return _highest_score


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_fader_finished(bus_id, direction : String) -> void:
	_fading_active[bus_id] = false
	emit_signal("audio_fade_finished", bus_id, direction)
