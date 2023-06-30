extends MarginContainer

onready var progress = $progress
onready var texture_rect = $TextureRect

func set_icon(icon :Resource):
	texture_rect.texture = icon
	
func update_indicator(value, max_value : int):
	progress.value = value
	progress.max_value = max_value
