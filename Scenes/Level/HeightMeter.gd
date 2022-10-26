extends HBoxContainer


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var meter_label : Label = $Values/Meters

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_Level_height_changed(height : float) -> void:
	meter_label.text = String(floor(height))
