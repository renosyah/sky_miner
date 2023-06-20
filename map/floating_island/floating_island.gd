extends StaticBody
class_name FloatingIsland

export var island :Resource = preload("res://map/floating_island/island_1/island.obj")
export var size :float = 1
export var rotate :float = 0

var _collision :CollisionShape
onready var _mesh_instance = $MeshInstance

func _ready():
	_mesh_instance.mesh = island
	_mesh_instance.create_trimesh_collision()
	
	_collision = _mesh_instance.get_child(0).get_child(0)
	_mesh_instance.get_child(0).remove_child(_collision)
	add_child(_collision)
	_mesh_instance.get_child(0).queue_free()
	
	scale = Vector3.ONE * size
	rotate_y(deg2rad(rotate))
