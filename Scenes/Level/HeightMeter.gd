extends Control


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var meter_label : Label = $Stack/Current/Meters
onready var highest_lable : Label = $Stack/Highest/Meters

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_Level_height_changed(height : float) -> void:
	meter_label.text = String(floor(height))
	IBSys.set_highest_score(int(height))
	highest_lable.text = String(IBSys.get_highest_score())
