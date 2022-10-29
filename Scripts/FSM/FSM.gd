tool
extends Node
class_name FSM


# ------------------------------------------------------------------------------
# "Export" Variables
# ------------------------------------------------------------------------------
var _initial_state : NodePath = ""


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _states : Dictionary = {}
var _active_state : FSMState = null

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if Engine.editor_hint:
		freeze()
		return
	
	for child in get_children():
		if child is FSMState:
			child._sm = self
	call_deferred("change_to_state", _initial_state)

func _unhandled_input(event : InputEvent) -> void:
	if _active_state != null:
		_active_state.handle_input(event)

func _process(delta : float) -> void:
	if _active_state != null:
		_active_state.update(delta)

func _physics_process(delta : float) -> void:
	if _active_state != null:
		_active_state.physics_update(delta)

func _get(property : String):
	match property:
		"initial_state":
			return _initial_state
	return null

func _set(property : String, value) -> bool:
	var success : bool = true
	
	match property:
		"initial_state":
			if typeof(value) == TYPE_NODE_PATH:
				_initial_state = value
			else : success = false
		_:
			success = false
	
	if success:
		property_list_changed_notify()
	return success

func _get_property_list() -> Array:
	return [
		{
			name = get_class(),
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY
		},
		{
			name = "initial_state",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_class() -> String:
	return "FSM"

func change_to_state(state_name : NodePath, msg : Dictionary = {}) -> void:
	if has_node(state_name):
		var next_state = get_node_or_null(state_name)
		if next_state is FSMState:
			if _active_state != null:
				_active_state.exit()
			_active_state = next_state
			_active_state.enter(msg)

func change_to_initial_state() -> void:
	if _initial_state != "":
		change_to_state(_initial_state)


func freeze(enable : bool = true) -> void:
	set_process(not enable)
	set_physics_process(not enable)
	set_process_unhandled_input(not enable)

func is_frozen() -> bool:
	return not is_physics_processing()


