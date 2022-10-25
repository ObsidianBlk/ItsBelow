extends Node2D


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const CLASS_NAME : String = "Chunk"

const TILES : Dictionary = {
	"base": [4],
	"dl":[2],
	"dr":[3],
	"ul":[0],
	"ur":[1]
}

const TILE_JUMP_DIST : int = 2
const TILE_JUMP_HEIGHT : int = 2
const MIN_PLATFORM_SIZE : int = 3

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
var _max_platform_size : int = 0

var _platforms : Array = []

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
	_max_platform_size = max(MIN_PLATFORM_SIZE + 1, int(_cols * 0.5))


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
	var max_thickness : int = _cols * 0.25
	for i in range(_rows):
		var thickness : int = _rng.randi_range(1, max_thickness)
		for col in range(thickness):
			_tilemap.set_cell(col, i, _GetBase())
		thickness = _rng.randi_range(1, max_thickness)
		for col in range(thickness):
			_tilemap.set_cell(_cols - col, i, _GetBase())

func _GenFloor(row : int) -> void:
	for col in _cols:
		_tilemap.set_cell(col, row, _GetBase())

func _GenPlatform() -> Array:
	var size = _rng.randi_range(MIN_PLATFORM_SIZE, _max_platform_size)
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

func _GetAvailableColumns(row : int) -> Array:
	var columns : Array = []
	# Get all empty tiles in the row
	for c in range(_cols):
		if _tilemap.get_cell(c, row) == TileMap.INVALID_CELL:
			columns.append(c)
	return columns

func _GetColumnsAroundRect(plat_rect : Rect2, dist : int = 1) -> Array:
	var columns : Array = []
	if _tilemap.get_cell(int(plat_rect.position.x - dist), int(plat_rect.position.y)) == TileMap.INVALID_CELL:
		columns.append(int(plat_rect.position.x - dist))
		
	if _tilemap.get_cell(int(plat_rect.end.x + dist), int(plat_rect.position.y)) == TileMap.INVALID_CELL:
		columns.append(int(plat_rect.end.x + dist))
	
	for col in range(plat_rect.position.x - dist, plat_rect.end.x + dist):
		if _tilemap.get_cell(int(col), int(plat_rect.position.y - 1)) == TileMap.INVALID_CELL:
			columns.append(int(col))
	return columns

func _ValidPlatformPosition(plat_rect : Rect2) -> bool:
	for platinfo in _platforms:
		if platinfo.buffer_rect.intersects(plat_rect):
			return false
	return true

func _RecordPlatform(plat_rect : Rect2, solution : bool = false) -> void:
	_platforms.append({
		"rect": plat_rect,
		"buffer_rect": Rect2(
			plat_rect.position - Vector2(-1, -1),
			plat_rect.size + Vector2(2, 2)),
		"solution": solution
	})

func _PlacePlatform(plat_rect : Rect2, check_overlap : bool = false) -> Rect2:
	if check_overlap and not _ValidPlatformPosition(plat_rect):
		return Rect2(-1,-1,0,0)
	
	var row : int = plat_rect.position.y
	var length : int = 0
	for col in range(plat_rect.position.x, plat_rect.end.x + 1):
		if _tilemap.get_cell(col, row) != TileMap.INVALID_CELL:
			break
		length += 1
	
	if length <= 0:
		return Rect2(-1,-1,0,0)
	return Rect2(plat_rect.position, Vector2(length, 1))



# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_class() -> String:
	return "Chunk"

func get_width() -> float:
	return float(_cols * tile_size)

func get_height() -> float:
	return float(_rows * tile_size)

func get_solution_end_platform() -> Rect2:
	var pr : Rect2 = Rect2()
	for platinfo in _platforms:
		if platinfo.solution and (platinfo.rect.position.y < pr.position.y or pr.size.y <= 0):
			pr = platinfo.rect
	return pr

func generate_new(prev_chunk : Node2D) -> void:
	_CalcRowsCols()
	_rng.seed = chunk_seed
	_tilemap.clear()
	_GenWalls()
	
	var cur_row = _rows - 1
	var last_plat : Rect2 = Rect2(-1,-1, 0,0)
	if prev_chunk != null and prev_chunk.get_class() == CLASS_NAME:
		# If there is a previous chunk, then just reposition THIS chunk above the last one.
		position.y = prev_chunk.position.y - get_height()
		last_plat = prev_chunk.get_solution_end_platform()
		last_plat.position.y = _rows # Force this "platform" to the very bottom of the chunk!
	else:
		# If we don't need to change position, we must be a "Base" chunk, and, therefore
		# must define the floor and the player start position
		cur_row = int(_rows * 0.75)
		_GenFloor(cur_row)
		var ps : Position2D = Position2D.new()
		ps.position = Vector2(
			float(_cols * tile_size) * 0.5,
			float((cur_row - 1) * tile_size) - float(tile_size)
		)
		ps.add_to_group("PlayerStart")
		add_child(ps)
		last_plat = Rect2(0, cur_row, _cols, 1)

	# Figure out a solution set of platforms...
	while last_plat.position.y > 0:
		pass
#		var columns : Array = _GetAvailableColumns(cur_row)
#		if columns.size() < 5:
#			# Row is too full. Skip
#			continue
#
#		if last_plat.position.x < 0:
#			if prev_chunk != null:
#				var pcrect : Rect2 = prev_chunk.get_solution_end_platform()
#				var check_left : bool = _rng.randf() < 0.5
#				var length : int = _PlacePlatformRelative(pcrect, cur_row, columns, check_left)
#				if length <= 0:
#					printerr("Failed to generate a solution platform")
#				else:
#					pass
#			else:
#				var col : int = columns[_rng.randi_range(0, columns.size() - 1)]
#				var length : int = _PlacePlatform(col, cur_row)
#				if length <= 0:
#					printerr("Failed to generate a solution platform!")
#				else:
#					_RecordPlatform(col, cur_row, length, true)
#					last_plat = Rect2(col, cur_row, length, 1)
#
#		cur_row -= 1




# NOTE: Soon to be removed once the method above works!
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





