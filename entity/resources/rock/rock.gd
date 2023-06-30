extends BaseResources

var rocks = [
	preload("res://entity/resources/rock/Rock1.obj"), 
	preload("res://entity/resources/rock/Rock2.obj"), 
	preload("res://entity/resources/rock/Rock3.obj")
]

onready var _mesh_instance = $MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	var mesh :Mesh = rocks[_rng.randi_range(0, rocks.size() - 1)]
	if mesh == preload("res://entity/resources/rock/Rock2.obj"):
		type_resource = type_resource_enum.iron
	else:
		type_resource = type_resource_enum.coal
		
	_mesh_instance.mesh = mesh
	_mesh_instance.rotation_degrees.y = _rng.randf_range(0, 180)
	_mesh_instance.software_skinning_transform_normals = false
	
	._create_collision_shape(_mesh_instance)
