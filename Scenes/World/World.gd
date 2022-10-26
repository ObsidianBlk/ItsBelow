extends Node2D


func _ready() -> void:
	$Level.connect("height_changed", self, "_on_height_changed")
	$Level.start_level()


func _on_height_changed(meters : float) -> void:
	print("Player Max Height: ", meters)
