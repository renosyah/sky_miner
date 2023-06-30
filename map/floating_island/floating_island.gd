extends StaticBody
class_name FloatingIsland

export var island :Resource = preload("res://map/floating_island/island_1/island.obj")

export var size :float = 1
export var rotate :float = 0
export var curve :Curve3D

var _collision :CollisionShape
var _spawn_path :Path
var _path_follow :PathFollow

onready var _mesh_instance = $MeshInstance

func _ready():
	_mesh_instance.mesh = island
	_mesh_instance.create_trimesh_collision()
	
	_collision = _mesh_instance.get_child(0).get_child(0)
	_mesh_instance.get_child(0).remove_child(_collision)
	add_child(_collision)
	_mesh_instance.get_child(0).queue_free()
	
	_spawn_path = Path.new()
	_spawn_path.curve = curve
	add_child(_spawn_path)
	
	_path_follow = PathFollow.new()
	_spawn_path.add_child(_path_follow)
	
	scale = Vector3.ONE * size
	rotate_y(deg2rad(rotate))


func get_random_position() -> Vector3:
	randomize()
	_path_follow.unit_offset = randf()
	var _p = _path_follow.global_transform.origin
	var _at = global_transform.origin
	var _rand_distance = rand_range(1, _p.distance_to(_at) * 0.7)
	_p += _p.direction_to(_at) * _rand_distance
	return _p










