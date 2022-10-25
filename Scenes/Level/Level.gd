extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const BASE_CHUNK : PackedScene = preload("res://Scenes/BaseChunk/BaseChunk.tscn")
const CHUNK : PackedScene = preload("res://Scenes/Chunk/Chunk.tscn")

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


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var _chunk_container : Node2D = $ChunkContainer
onready var _player : Player = $Player
onready var _camera : ShakeyCamera = $ShakeyCamera


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_CheckViewport()

func _physics_process(_delta : float) -> void:
	if _viewport_rect.size.x <= 0 or _viewport_rect.size.y <= 0:
		_CheckViewport()
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

func _GenerateChunk() -> void:
	if _viewport_rect.size.x <= 0 or _viewport_rect.size.y <= 0:
		return
	
	var chunk : Node2D = CHUNK.instance()
	chunk.chunk_seed = _rng.randi()
	chunk.position = _TopChunkPosition()
	add_child(chunk)
	chunk.generate()

func _ChunkDropAndAdd() -> void:
	if _chunks.size() <= 0:
		return
	
	_chunk_container.remove_child(_chunks[0])
	_chunks.pop_front()
	_GenerateChunk()

func _SetPlayerStart() -> void:
	var ps = get_tree().get_nodes_in_group("PlayerStart")
	if ps.size() > 0:
		_player.global_position = ps[0].global_position
		_camera.reset_to_start()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func start_level() -> void:
	_rng.seed = level_seed

	for chunk in _chunks:
		_chunk_container.remove_child(chunk)
	_chunks.clear()
	
	var chunk : Node2D = BASE_CHUNK.instance()
	_chunk_container.add_child(chunk)
	_chunks.append(chunk)
	_GenerateChunk()
	_GenerateChunk()
	call_deferred("_SetPlayerStart")

