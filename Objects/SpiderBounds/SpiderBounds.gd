extends Node2D



# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var bound_width : float = 64.0
export var target_node_path : NodePath = ""


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _target_ref : WeakRef = weakref(null)

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var _left_bound_node : StaticBody2D = $LeftEdgeBound
onready var _left_colshape_node : CollisionShape2D = $LeftEdgeBound/ColShape

onready var _right_bound_node : StaticBody2D = $RightEdgeBound
onready var _right_colshape_node : CollisionShape2D = $RightEdgeBound/ColShape

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	var target : Node2D = get_node_or_null(target_node_path)
	if target:
		_target_ref = weakref(target)
	_AdjustBounds()

func _enter_tree() -> void:
	var vp : Viewport = get_viewport()
	var _res : int = vp.connect("size_changed", self, "_AdjustBounds")

func _exit_tree() -> void:
	var vp : Viewport = get_viewport()
	if vp.is_connected("size_changed", self, "_AdjustBounds"):
		vp.disconnect("size_changed", self, "_AdjustBounds")

func _physics_process(_delta : float) -> void:
	var target : Node2D = _target_ref.get_ref()
	if target:
		global_position.y = target.global_position.y

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _AdjustBounds() -> void:
	if not is_inside_tree():
		return
	
	var vprect : Rect2 = get_viewport_rect()
	var hbw : float = bound_width * 0.5
	var hvh : float = vprect.size.y * 0.5
	
	_left_bound_node.position = Vector2(hbw, hvh)
	_right_bound_node.position = Vector2(vprect.size.x - hbw, hvh)
	
	_left_colshape_node.shape.extents = Vector2(hbw, vprect.size.y*2)
	_right_colshape_node.shape.extents = Vector2(hbw, vprect.size.y*2)

