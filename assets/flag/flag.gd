extends MeshInstance

export var color :Color

onready var flag_material :ShaderMaterial = get_surface_material(0).duplicate()

func _ready():
	apply()

func apply():
	var gt :GradientTexture = GradientTexture.new()
	gt.gradient = Gradient.new()
	gt.gradient.colors = [color]
	flag_material.set_shader_param("tex", gt)
	set_surface_material(0, flag_material)
