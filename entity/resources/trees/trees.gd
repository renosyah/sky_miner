extends BaseResources

onready var _mesh_instance = $MeshInstance
var _material

# Called when the node enters the scene tree for the first time.
func _ready():
	_mesh_instance.mesh = load(resource_mesh_path)
	_mesh_instance.rotation_degrees.y = rotate_value
	_mesh_instance.software_skinning_transform_normals = false
	
	._create_collision_shape(_mesh_instance)
