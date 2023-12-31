extends Node
class_name Map

signal on_map_ready
signal on_map_data_created(_data)
signal resource_take_damage(_resource, _damage)
signal resource_dead(_resource)
signal resource_reset(_resource)

var island_templates = [
	"res://map/floating_island/island_1"
]

var island_scene = preload("res://map/floating_island/floating_island.tscn")
var tree_scene = preload("res://entity/resources/trees/trees.tscn")
var ore_scene = preload("res://entity/resources/rock/rock.tscn")

onready var _wall = $wall
onready var _islands = $islands
onready var _trees = $trees
onready var _ores = $ores
onready var _spawn_position = $spawn_position

var _spawn_path :Path
var _path_follow :PathFollow

export var map_seed :int
var _map_data :Dictionary

onready var _h_points :Array = [
	$wall/west,
	$wall/east,
]
onready var _v_points :Array = [
	$wall/north,
	$wall/south
]

var _rng = RandomNumberGenerator.new()

func _ready():
	_spawn_path = Path.new()
	_spawn_position.add_child(_spawn_path)
	
	_path_follow = PathFollow.new()
	_spawn_path.add_child(_path_follow)
	
func get_islands() -> Array:
	return _islands.get_children()
	
func get_random_island() -> FloatingIsland:
	var islands :Array = get_islands()
	return islands[rand_range(0, islands.size())]
	
func get_entry_points(offset :float = 0) -> Array:
	var points :Array = []
	var center_point :Vector3 = _wall.global_transform.origin
	
	for i in _h_points:
		var pos :Vector3 = i.global_transform.origin
		var dir_to_center :Vector3 = pos.direction_to(center_point)
		points.append(pos + (dir_to_center * 20) + Vector3(0, 0, offset))
		
	for i in _v_points:
		var pos :Vector3 = i.global_transform.origin
		var dir_to_center :Vector3 = pos.direction_to(center_point)
		points.append(pos + (dir_to_center * 20) + Vector3(offset, 0, 0))
		
	return points
	
func get_random_entry_point(offset :float = 0) -> Vector3:
	randomize()
	var points :Array = get_entry_points(offset)
	return points[rand_range(0, points.size())]
	
func set_map_data(_data :Dictionary):
	_map_data = _data
	
func generate_map():
	if _map_data.empty():
		_generate_map_contents()
		
	for i in _map_data["islands"]:
		var island = island_scene.instance()
		island.island = load(i["mesh"])
		island.name = i["name"]
		island.rotate = i["rotate"]
		island.curve = load(i["curve"])
		_islands.add_child(island)
		island.translation = i["position"]
		island.scale = i["scale"]
		
	for tree in _map_data["trees"]:
		var resource :BaseResources = tree_scene.instance()
		resource.name = tree["name"]
		resource.set_network_master(Network.PLAYER_HOST_ID)
		resource.resource_mesh_path = tree["mesh_path"]
		resource.rotate_value = tree["rotate"]
		resource.hp = 100
		resource.max_hp = 100
		resource.connect("take_damage", self, "_resource_take_damage")
		resource.connect("dead", self, "_resource_dead")
		resource.connect("reset", self, "_resource_reset")
		_trees.add_child(resource)
		resource.translation = tree["position"]
		
	for ore in _map_data["ores"]:
		var resource :BaseResources = ore_scene.instance()
		resource.name = ore["name"]
		resource.set_network_master(Network.PLAYER_HOST_ID)
		resource.resource_mesh_path = ore["mesh_path"]
		resource.rotate_value = ore["rotate"]
		resource.hp = 100
		resource.max_hp = 100
		resource.connect("take_damage", self, "_resource_take_damage")
		resource.connect("dead", self, "_resource_dead")
		resource.connect("reset", self, "_resource_reset")
		_ores.add_child(resource)
		resource.translation = ore["position"]
		
	yield(get_tree(),"idle_frame")
	yield(get_tree().create_timer(2),"timeout")
	
	emit_signal("on_map_ready")
	
func _resource_take_damage(_resource :BaseResources, _damage :int):
	emit_signal("resource_take_damage", _resource, _damage)
	
func _resource_dead(_resource :BaseResources):
	emit_signal("resource_dead", _resource)
	
func _resource_reset(_resource :BaseResources):
	emit_signal("resource_reset", _resource)
	
func _generate_map_contents():
	_rng.seed = map_seed
	
	_map_data["islands"] = []
	_map_data["trees"] = []
	_map_data["ores"] = []
	
	var generated_positions = []
	for x in range(-2, 3, 1):
		for z in range(-2, 3, 1):
			generated_positions.append(Vector3(x, 0, z))
			
	var max_island = clamp(_rng.randi_range(2, generated_positions.size() - 1), 2, 10)
	generated_positions.shuffle()
	
	for i in max_island:
		generated_positions.pop_back()
	
	for pos in generated_positions:
		var template = island_templates[_rng.randi_range(0, island_templates.size() - 1)]
		var island = _generate_island(pos.x, pos.z, template)
		_map_data["islands"].append(island)
		
		_spawn_position.translation = island["position"]
		_spawn_position.scale = island["scale"]
		_spawn_position.rotation_degrees = Vector3.ZERO
		_spawn_position.rotate_y(deg2rad(island["rotate"]))
		
		_spawn_path.curve = load(island["curve"])
		
		_map_data["trees"].append_array(
			_generate_resource(
				island["position"],
				island["name"],
				"tree",
				_rng.randi_range(2, 3) * island["size"]
			)
		)
		
		_map_data["ores"].append_array(
			_generate_resource(
				island["position"],
				island["name"],
				"ore",
				_rng.randi_range(2, 3) * island["size"]
			)
		)
		
	_map_data["islands"].shuffle()
	_map_data["trees"].shuffle()
	_map_data["ores"].shuffle()
	
	yield(get_tree(),"idle_frame")
	yield(get_tree().create_timer(2),"timeout")
	
	emit_signal("on_map_data_created", _map_data)
	
	
func _generate_island(x, y :float, template :String) -> Dictionary:
	var island_name :String = "island_%s_%s" % [x,y]
	var pos :Vector3 = Vector3(x * 30, 10, y * 30)
	var size_x :float = _rng.randf_range(1, 3)
	var size_z :float = _rng.randf_range(1, 3)
	var rotate :float = _rng.randf_range(0, 360)
	
	return {
		"name" : island_name,
		"mesh" : template + "/island.obj",
		"curve" : template + "/curve.tres",
		"size" : max(size_x, size_z),
		"scale" : Vector3(size_x, 1, size_z),
		"rotate" : rotate,
		"position" :pos,
	}
	
func _generate_resource(_at :Vector3, _island_name :String, _resource_name :String, count :int) -> Array:
	var resources :Array = []
	var index = 0
	var resource_pos :Array = _generate_random_spawn_positions(_at, count)
	var mesh_path :String
	
	var rocks = [
		 "res://entity/resources/rock/Rock1.obj", 
		 "res://entity/resources/rock/Rock2.obj", 
		 "res://entity/resources/rock/Rock3.obj" 
	]
	var trees = [
		"res://entity/resources/trees/Tree1.obj",
		"res://entity/resources/trees/Tree2.obj",
		"res://entity/resources/trees/Tree3.obj",
		"res://entity/resources/trees/Tree4.obj"
	]
	
	if _resource_name == "ore":
		mesh_path = rocks[_rng.randi_range(0, rocks.size() - 1)]
		
	elif _resource_name == "tree":
		mesh_path = trees[_rng.randi_range(0, trees.size() - 1)]
		
	for i in resource_pos:
		resources.append({
			"name" : "%s_%s_%s" % [_island_name, _resource_name, index],
			"position" : i,
			"mesh_path" : mesh_path,
			"rotate" : _rng.randf_range(0, 360)
		})
		index += 1
		
	return resources
		
func _generate_random_spawn_positions(_at :Vector3, count :int) -> Array:
	var _pos :Array = []
	
	for i in count:
		_path_follow.unit_offset = _rng.randf()
		var p = _path_follow.global_transform.origin
		var _rand_distance = _rng.randf_range(1, p.distance_to(_at) * 0.7)
		p += p.direction_to(_at) * _rand_distance
		_pos.append(p)
	
	return _pos
