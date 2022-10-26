extends Node2D



# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal game_over(exit_reason)
signal height_changed(height)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
#const BASE_CHUNK : PackedScene = preload("res://Scenes/BaseChunk/BaseChunk.tscn")
const CHUNK : PackedScene = preload("res://Scenes/Chunk/Chunk.tscn")

const BASE_CHUNKS : Array = [
	{"src" : "res://Scenes/Level/BaseChunk/BaseChunk.tscn", "scene" : null}
]

const CHUNKS : Array = [
	{"src" : "res://Scenes/Level/Chunks/Chunk_001.tscn", "scene" : null},
	{"src" : "res://Scenes/Level/Chunks/Chunk_002.tscn", "scene" : null}
]

const PIXELS_PER_METER : float = 48.0

const TILES_ACROSS : int = 30
const TILES_DOWN : int = 16
const TILE_SIZE : int = 64


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var level_seed : int = 0


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _chunks : Array = []
var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
var _viewport_rect : Rect2 = Rect2(0,0,0,0)
var _spider_start : Vector2 = Vector2.ZERO

var _initial_height : float = 0.0
var _cur_height : float = 0.0
var _meters_traveled : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var _chunk_container : Node2D = $ChunkContainer
onready var _player : Player = $Player
onready var _camera : ShakeyCamera = $ShakeyCamera
onready var _spider : Spider = $Spider

onready var _message : Control = $GameEndScreens/Message
onready var _height_meter : Control = $GameEndScreens/HeightMeter


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_height_meter.visible = false
	_player.die() # I don't want the player processing at the moment
	_spider_start = _spider.global_position
	_CheckViewport()

func _physics_process(_delta : float) -> void:
	if _viewport_rect.size.x <= 0 or _viewport_rect.size.y <= 0:
		_CheckViewport()
	if _player.global_position.y < _cur_height:
		_cur_height = _player.global_position.y
		var meters = abs(_cur_height - _initial_height)/PIXELS_PER_METER
		if floor(meters) > floor(_meters_traveled):
			_meters_traveled = meters
			emit_signal("height_changed", meters)
	elif _chunks.size() > 1:
		var vhh : float = _viewport_rect.size.y * 0.5
		var tcpos : Vector2 = _TopChunkPosition()
		if _camera.global_position.y - vhh < tcpos.y + _viewport_rect.size.y:
			call_deferred("_ChunkDropAndAdd")


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CheckViewport() -> void:
	var vpr : Rect2 = get_viewport_rect()
	if not vpr.size.is_equal_approx(_viewport_rect.size):
		_viewport_rect = vpr

func _TopChunkPosition() -> Vector2:
	if _chunks.size() > 0:
		return _chunks[_chunks.size() - 1].position
	return Vector2.ZERO

func _GetNextChunkPosition() -> Vector2:
	if _chunks.size() > 0:
		var pos : Vector2 = _TopChunkPosition()
		pos.y -= float(TILES_DOWN * TILE_SIZE)
		return pos
	return Vector2.ZERO

func _GetBaseChunk() -> Node2D:
	var idx = _rng.randi_range(0, BASE_CHUNKS.size() - 1)
	if BASE_CHUNKS[idx]["scene"] == null:
		var scene = load(BASE_CHUNKS[idx]["src"])
		if not (scene is PackedScene):
			return null
		BASE_CHUNKS[idx]["scene"] = scene
	
	var chunk = BASE_CHUNKS[idx]["scene"].instance()
	if chunk is Node2D:
		return chunk
	
	return null

func _AddChunk() -> void:
	var pos : Vector2 = _GetNextChunkPosition()
	var idx : int = _rng.randi_range(0, CHUNKS.size() - 1)
	if CHUNKS[idx]["scene"] == null:
		var scene = load(CHUNKS[idx]["src"])
		if not (scene is PackedScene):
			printerr("ERROR: Failed to load chunk scene ", CHUNKS[idx]["src"])
			return
		CHUNKS[idx]["scene"] = scene
	
	var chunk = CHUNKS[idx]["scene"].instance()
	if chunk is Node2D:
		_chunks.append(chunk)
		chunk.position = pos
		_chunk_container.add_child(chunk)

#func _GenerateChunk(prev_chunk : Node2D = null) -> Node2D:
#	if _viewport_rect.size.x <= 0 or _viewport_rect.size.y <= 0:
#		return null
#
#	var chunk : Node2D = CHUNK.instance()
#	chunk.chunk_seed = _rng.randi()
#	chunk.position = _TopChunkPosition()
#	add_child(chunk)
#	chunk.generate(prev_chunk)
#	_chunks.append(chunk)
#	return chunk

func _ChunkDropAndAdd() -> void:
	if _chunks.size() <= 0:
		return
	
	_chunk_container.remove_child(_chunks[0])
	_chunks.pop_front()
	_AddChunk()
#	if _chunks.size() > 0:
#		_GenerateChunk(_chunks[_chunks.size() - 1])
#	else:
#		print("WARNING: Generating a base chunk where one should not be generated!")
#		_GenerateChunk()

func _SetPlayerStart() -> void:
	var ps = get_tree().get_nodes_in_group("PlayerStart")
	if ps.size() > 0:
		_player.global_position = ps[0].global_position
		_initial_height = _player.global_position.y
		_cur_height = _initial_height
		_meters_traveled = 0.0
		_player.revive()
		_spider.global_position = _spider_start
		_spider.start()
		_camera.reset_to_start()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func start_level() -> void:
	_rng.seed = level_seed

	for chunk in _chunks:
		_chunk_container.remove_child(chunk)
	_chunks.clear()
	
#	var chunk : Node2D = _GenerateChunk()
#	#_chunk_container.add_child(chunk)
#	#_chunks.append(chunk)
#	chunk = _GenerateChunk(chunk)
#	chunk = _GenerateChunk(chunk)

	var chunk : Node2D = _GetBaseChunk()
	if chunk != null:
		_chunks.append(chunk)
		_chunk_container.add_child(chunk)
	_AddChunk()
	_AddChunk()
	_height_meter.visible = true
	emit_signal("height_changed", 0.0)
	call_deferred("_SetPlayerStart")

func close_level() -> void:
	for chunk in _chunks:
		_chunk_container.remove_child(chunk)
	_chunks.clear()
	_player.die()
	_spider.global_position = _spider_start
	_spider.stop()
	_height_meter.visible = false


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_Spider_player_eaten():
	print("Player has been eaten!")
	if not _message.is_connected("message_hidden", self, "_on_message_hidden"):
		_message.connect("message_hidden", self, "_on_message_hidden", ["Spider has nibbled your bits!"])
		_message.show_message("Your bits are slowly be crushed in the spider's mandables")

func _on_ShakeyCamera_player_fell():
	print("Player has falled to their doom!")
	if not _message.is_connected("message_hidden", self, "_on_message_hidden"):
		_message.connect("message_hidden", self, "_on_message_hidden", ["You have fallen down the pit of doom!"])
		_message.show_message("Your bits are slowly be crushed in the spider's mandables")

func _on_message_hidden(msg : String = "") -> void:
	print("Message is Hidden")
	_message.disconnect("message_hidden", self, "_on_message_hidden")
	emit_signal("game_over", msg)

