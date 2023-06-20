extends Node
class_name Map

var island_scene = preload("res://map/floating_island/floating_island.tscn")

export var islands :Array

func spawn_islands():
	for i in islands:
		var island = island_scene.instance()
		island.name = i["name"]
		island.size = i["size"]
		island.rotate = i["rotate"]
		add_child(island)
		island.translation = i["position"]
		
		var rng = RandomNumberGenerator.new()
		rng.seed = int(i["seed"])
		
		for tree_data in i["trees"]:
			var tree :BaseResources = preload("res://entity/resources/trees/trees.tscn").instance()
			tree.rng = rng
			add_child(tree)
			tree.translation = tree_data["position"]
			
		for ore_data in i["ores"]:
			var ore :BaseResources = preload("res://entity/resources/rock/rock.tscn").instance()
			ore.rng = rng
			add_child(ore)
			ore.translation = ore_data["position"]
			
func generate_islands():
	for x in range(-1, 3, 1):
		for y in range(-2, 4, 1):
			randomize()
			
			var size = rand_range(1, 2)
			var island_pos = Vector3(x * 40, 10, y * 30)
			var random_pos :Array = _get_random_positions(island_pos, 6, size)
			random_pos.shuffle()
			
			var trees = []
			var trees_pos = random_pos.slice(0, 2)
			for pos in trees_pos:
				trees.append({
					"position" : pos
				})
			
			var ores = []
			var ores_pos = random_pos.slice(3, 5)
			for pos in ores_pos:
				ores.append({
					"position" : pos
				})
				
			islands.append({
				"name" : "island_%s_%s" % [x,y],
				"size" : size,
				"rotate" : rand_range(0, 360),
				"position" : island_pos,
				"trees" : trees,
				"ores" :ores,
				"seed" : rand_range(-100, 100)
			})
	
func _get_random_positions(at :Vector3, count :int, size :float) -> Array:
	var _positions :Array = []
	var _radius = Vector3(3, 0, 0) * size
	var _step = 2 * PI / count
	
	for i in range(count):
		var pos = at + _radius.rotated(Vector3.UP, _step * i)
		_positions.append(pos)
		
	return _positions
