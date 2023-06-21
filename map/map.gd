extends Node
class_name Map

var island_templates = [
	"res://map/floating_island/island_1"
]

var island_scene = preload("res://map/floating_island/floating_island.tscn")
var tree_scene = preload("res://entity/resources/trees/trees.tscn")
var ore_scene = preload("res://entity/resources/rock/rock.tscn")

onready var _islands = $islands
onready var _trees = $trees
onready var _ores = $ores
onready var _spawn_position = $spawn_position

var _spawn_path :Path
var _path_follow :PathFollow

export var map_data :Dictionary

func _ready():
	_spawn_path = Path.new()
	_spawn_position.add_child(_spawn_path)
	
	_path_follow = PathFollow.new()
	_spawn_path.add_child(_path_follow)

func spawn_islands():
	var map_seed = map_data["map_seed"]
	var rng = RandomNumberGenerator.new()
	rng.seed = map_seed
		
	for i in map_data["islands"]:
		var island = island_scene.instance()
		island.island = load(i["mesh"])
		island.name = i["name"]
		island.size = i["size"]
		island.rotate = i["rotate"]
		_islands.add_child(island)
		island.translation = i["position"]
		
	for tree in map_data["trees"]:
		var resource :BaseResources = tree_scene.instance()
		resource.name = tree["name"]
		resource.set_network_master(Network.PLAYER_HOST_ID)
		resource.rng = rng
		_trees.add_child(resource)
		resource.translation = tree["position"]
		
	for ore in map_data["ores"]:
		var resource :BaseResources = ore_scene.instance()
		resource.name = ore["name"]
		resource.set_network_master(Network.PLAYER_HOST_ID)
		resource.rng = rng
		_ores.add_child(resource)
		resource.translation = ore["position"]
		
		
func generate_islands():
	map_data["map_seed"] = rand_range(-100, 100)
	map_data["islands"] = []
	map_data["trees"] = []
	map_data["ores"] = []
	
	for x in range(-1, 3, 1):
		for y in range(-2, 3, 1):
			randomize()
			
			var template = island_templates[rand_range(0, island_templates.size())]
			var island_name = "island_%s_%s" % [x,y]
			var pos = Vector3(x * 40, 10, y * 30)
			var size = rand_range(1, 2)
			var rotate = rand_range(0, 360)
			
			_spawn_position.translation = pos
			_spawn_position.scale = Vector3.ONE * size
			_spawn_position.rotation_degrees = Vector3.ZERO
			_spawn_position.rotate_y(deg2rad(rotate))
			
			_spawn_path.curve = load(template + "/curve.tres")
			
			map_data["islands"].append({
				"name" : island_name,
				"mesh" : template + "/island.obj",
				"size" : size,
				"rotate" : rotate,
				"position" :pos,
			})
			
			var _trees_pos :Array = generate_random_spawn_positions(pos, 6)
			var index = 0
			for i in _trees_pos:
				map_data["trees"].append({
					"name" : "%s_tree_%s" % [island_name, index],
					"position" : i,
				})
				index += 1
				
			index = 0
			var _ores_pos :Array = generate_random_spawn_positions(pos, 4)
			for i in _ores_pos:
				map_data["ores"].append({
					"name" : "%s_ores_%s" % [island_name, index],
					"position" : i,
				})
				index += 1
		
		
		
func generate_random_spawn_positions(_at :Vector3, count :int) -> Array:
	var _pos :Array = []
	var _rand_offset = rand_range(1, 4)
	
	for i in count:
		_path_follow.unit_offset = randf()
		var p = _path_follow.global_transform.origin
		p += p.direction_to(_at) * _rand_offset
		_pos.append(p)
	
	return _pos
