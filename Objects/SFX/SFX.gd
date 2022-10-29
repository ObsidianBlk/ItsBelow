extends Node2D


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal finished()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export (Array, String) var sample_names : Array = []
export (Array, AudioStream) var sample_streams : Array = []
export (Array, String) var sample_groups : Array = []			setget set_sample_groups


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _groups : Dictionary = {}

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var audio1 : AudioStreamPlayer2D = $Audio_1
onready var audio2 : AudioStreamPlayer2D = $Audio_2


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_sample_groups(groups : Array) -> void:
	sample_groups = groups
	var group_names : Array = []
	for group in sample_groups:
		var group_name : String = _AddSampleGroup(group)
		if group_name != "":
			group_names.append(group_name)
	_ClearMissingSampleGroup(group_names)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_sample_groups(sample_groups)
	audio1.connect("finished", self, "_on_finished", [audio1])
	audio2.connect("finished", self, "_on_finished", [audio2])

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ClearMissingSampleGroup(groups : Array) -> void:
	var keys : Array = _groups.keys()
	for key in keys:
		if groups.find(key) < 0:
			_groups.erase(key)

func _AddSampleGroup(group_def : String) -> String:
	var ginfo : Array = group_def.split(",")
	for i in range(ginfo.size()):
		ginfo[i] = ginfo[i].strip_edges(true, true)
	if ginfo.size() > 2 and ginfo[0] != "":
		_groups[ginfo[0]] = ginfo.slice(1, ginfo.size() - 1)
	else : return ""
	return ginfo[0]


func _GetAvailableStream() -> AudioStreamPlayer2D:
	for stream in [audio1, audio2]:
		if not stream.playing:
			return stream
	return null

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func play(stream_name : String, force : bool = false) -> void:
	var idx : int = sample_names.find(stream_name)
	if not (idx >= 0 and idx < sample_streams.size()):
		return
	
	var audio : AudioStreamPlayer2D = _GetAvailableStream()
	if audio == null and force:
		audio = audio1
	if audio != null:
		audio.stop()
		audio.stream = sample_streams[idx]
		audio.play()

func play_from_group(group_name : String, force : bool = false) -> void:
	if group_name in _groups:
		var idx : int = int(rand_range(0, _groups[group_name].size() - 1))
		play(_groups[group_name][idx], force)
	
# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_finished(audio_stream : AudioStreamPlayer2D) -> void:
	emit_signal("finished")
