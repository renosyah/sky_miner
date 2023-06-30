extends BaseResources

onready var _mesh_instance = $MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	var mesh :Mesh = load(resource_mesh_path)
	if resource_mesh_path == "res://entity/resources/rock/Rock2.obj":
		type_resource = type_resource_enum.iron
	else:
		type_resource = type_resource_enum.coal
		
	_mesh_instance.mesh = mesh
	_mesh_instance.rotation_degrees.y = rotate_value
	_mesh_instance.software_skinning_transform_normals = false
	
	._create_collision_shape(_mesh_instance)
