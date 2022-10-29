extends Node2D
tool


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const TIME_SCALE : float = 30.0
const SPARK_SPAWN_TIME : float = 0.1

const SPARK : PackedScene = preload("res://Objects/LightPot/FireSpark/FireSpark.tscn")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var verbose : bool = false
export var broken : bool = false
export var light_seed : int = 0
export (float, 0.1, 10.0) var intact_light_energy : float = 3.0
export var intact_light_scale : float = 3.0
export (float, 0.1, 10.0) var broken_light_energy : float = 2.0
export var broken_light_scale : float = 2.0
export var spark_count : int = 6
export var spark_min_life : float = 2.0
export var spark_max_life : float = 4.0
export var spark_min_death : float = 0.5
export var spark_max_death : float = 1.0


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _noise : OpenSimplexNoise = OpenSimplexNoise.new()
var _time : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var light : Light2D = $Light2D
onready var sprite : Sprite = $Sprite
onready var anim : AnimationPlayer = $AnimationPlayer
onready var sfx : Node = $SFX
onready var spark_spawn_pos : Position2D = $SparkSpawn


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_broken(b : bool) -> void:
	broken = b
	if anim:
		anim.play("Broke" if broken else "Lit")

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if Engine.editor_hint:
		set_process(false)
	if light_seed == 0:
		light_seed = randi()
	_noise.octaves = 3.0
	_noise.period = 120.0
	_noise.persistence = 0.2
	_noise.lacunarity = 2.0
	_noise.seed = light_seed
	if broken:
		anim.play("Broke")
	else:
		anim.play("Lit")

func _process(delta : float) -> void:
	_time += TIME_SCALE * delta
	var n : float = _noise.get_noise_1d(_time)
	light.energy = (broken_light_energy if broken else intact_light_energy) + n
	var s = (broken_light_scale if broken else intact_light_scale) + n
	light.scale = Vector2(s,s)


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _SpawnSpark() -> void:
	if not is_inside_tree():
		return
	var parent = get_parent()
	if not parent:
		return
	var spark = SPARK.instance()
	if spark is RigidBody2D:
		spark.lifetime = rand_range(spark_min_life, spark_max_life)
		spark.deathtime = rand_range(spark_min_death, spark_max_death)
		parent.add_child(spark)
		spark.global_position = spark_spawn_pos.global_position
		var impulse : Vector2 = Vector2.UP.rotated(deg2rad(rand_range(-60, 60))) * 200.0
		spark.apply_central_impulse(impulse)
		
		spark_count -= 1
		if spark_count > 0:
			var timer : SceneTreeTimer = get_tree().create_timer(SPARK_SPAWN_TIME)
			timer.connect("timeout", self, "_SpawnSpark")


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_interact(active : bool) -> void:
	if not broken:
		set_broken(true)
		sfx.play_from_group("break")
		_SpawnSpark()


func _on_InteractArea_body_entered(body):
	if body.has_signal("interact"):
		if not body.is_connected("interact", self, "_on_interact"):
			body.connect("interact", self, "_on_interact")


func _on_InteractArea_body_exited(body):
	if body.has_signal("interact"):
		if body.is_connected("interact", self, "_on_interact"):
			body.disconnect("interact", self, "_on_interact")
