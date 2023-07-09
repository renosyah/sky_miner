extends MeshInstance

export var color_highlight :Color

var _material :SpatialMaterial = get_surface_material(0).duplicate()

# Called when the node enters the scene tree for the first time.
func _ready():
	_material.albedo_color = color_highlight
	_material.albedo_color.a = 0.35
	
	set_surface_material(0, _material)
