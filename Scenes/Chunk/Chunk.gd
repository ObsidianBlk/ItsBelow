extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const TILES : Dictionary = {
	"base": [4],
	"dl":[2],
	"dr":[3],
	"ul":[0],
	"ur":[1]
}

const TILE_JUMP_HEIGHT : int = 2
const MIN_PLATFORM_SIZE : int = 3
const MAX_PLATFORM_SIZE : int = 8

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var chunk_seed : int = 0
export var tile_size : int = 64

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
var _rows : int = 0
var _cols : int = 0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var _tilemap : TileMap = $TileMap

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_chunk_seed(s : int) -> void:
	chunk_seed = s
	_rng.seed = chunk_seed

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	pass

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CalcRowsCols() -> void:
	var vpr : Rect2 = get_viewport_rect()
	_cols = int(floor(vpr.size.x / float(tile_size)))
	_rows = int(floor(vpr.size.y / float(tile_size)))


func _GetTile(set_name : String) -> int:
	if set_name in TILES:
		if TILES[set_name].size() > 1:
			return TILES[set_name][_rng.randi_range(0, TILES[set_name].size() - 1)]
		return TILES[set_name][0]
	return -1

func _GetBase() -> int:
	return _GetTile("base")

func _GetPlatLeftEdge() -> int:
	return _GetTile("dl")

func _GetPlatRightEdge() -> int:
	return _GetTile("dr")

func _GenWalls() -> void:
	for i in range(_rows):
		_tilemap.set_cell(0, i, _GetBase())
		_tilemap.set_cell(_cols - 1, i, _GetBase())

func _GenPlatform() -> Array:
	var size = _rng.randi_range(MIN_PLATFORM_SIZE, MAX_PLATFORM_SIZE)
	var plat : Array = []
	if size > 0:
		if size == 1:
			plat.append(_GetBase())
		else:
			for i in range(size):
				if i == 0:
					plat.append(_GetPlatLeftEdge())
				elif i == size - 1:
					plat.append(_GetPlatRightEdge())
				else:
					plat.append(_GetBase())
	return plat


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_width() -> float:
	return float(_cols * tile_size)

func get_height() -> float:
	return float(_rows * tile_size)


func generate() -> void:
	_CalcRowsCols()
	_rng.seed = chunk_seed
	_tilemap.clear()
	_GenWalls()
	
	position.y -= get_height()
	
	var skip_row : int = 0
	for row in range(_rows):
		if skip_row == 0:
			var platform : Array = []
			var use_platform : bool = true
			var plat_i : int = 0
			for col in range(1, _cols - 1):
				if platform.size() <= 0:
					platform = _GenPlatform()
					use_platform = _rng.randf() < 0.25
					plat_i = 0
				if use_platform:
					_tilemap.set_cell(col, row, platform[plat_i])
				plat_i += 1
				if plat_i == platform.size():
					platform.clear()
		else:
			skip_row += 1
			if skip_row == TILE_JUMP_HEIGHT:
				skip_row = 0





