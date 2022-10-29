extends RigidBody2D



# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var lifetime : float = 3.0
export var deathtime : float = 1.0


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var _light : Light2D = $Light2D

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	var timer : SceneTreeTimer = get_tree().create_timer(lifetime)
	timer.connect("timeout", self, "_on_lifetime_timeout")


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_SpiderZone_body_entered(body : Node2D) -> void:
	print("Body Entered: ", body)
	if body.is_in_group("Spider") and body.has_method("freeze"):
		body.freeze()


func _on_SpiderZone_body_exited(body : Node2D) -> void:
	pass # Replace with function body.

func _on_lifetime_timeout() -> void:
	var st : SceneTree = get_tree()
	if st: # This is a precaution in case the fire spark is removed before actually getting here.
		var tween : SceneTreeTween = get_tree().create_tween()
		tween.tween_property(_light, "energy", 0.0, deathtime)
		tween.connect("finished", self, "_on_death")

func _on_death() -> void:
	queue_free()

