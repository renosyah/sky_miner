extends Spatial
class_name GatherIndicator

onready var indicator = $indicator
onready var viewport = $indicator/Viewport
onready var ui_indicator = $indicator/Viewport/ui_indicator

# Called when the node enters the scene tree for the first time.
func _ready():
	indicator.texture = viewport.get_texture()
	
func set_icon(icon :Resource):
	ui_indicator.set_icon(icon)
	
func update_indicator(value, max_value : int):
	ui_indicator.update_indicator(value, max_value)
