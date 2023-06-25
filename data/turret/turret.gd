extends BaseData
class_name TurretData

export var node_name :String
export var scene_path :String
export var position :Vector3

export var level :int

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	node_name = data["node_name"]
	scene_path = data["scene_path"]
	position = data["position"]
	
	level = data["level"]

func to_dictionary() -> Dictionary :
	var data = .to_dictionary()
	
	data["node_name"] = node_name
	data["scene_path"] = scene_path
	data["position"] = position
	
	data["level"] = level
	return data
	
