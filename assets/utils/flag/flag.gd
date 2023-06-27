extends MeshInstance

const double_sided_flag = preload("res://assets/utils/flag/double_sided_flag.gdshader")
const one_sided_flag = preload("res://assets/utils/flag/flag.gdshader")

export var color :Color
export var double_side :bool

func _ready():
	apply()

func apply():
	var flag_material :ShaderMaterial = ShaderMaterial.new()
	flag_material.shader = double_sided_flag.duplicate() if double_side else one_sided_flag.duplicate()
	
	var gt :GradientTexture = GradientTexture.new()
	gt.gradient = Gradient.new()
	gt.gradient.colors = [color]
	flag_material.set_shader_param("tex", gt)
	
	set_surface_material(0, flag_material)
