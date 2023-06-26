extends BaseData
class_name TurretData

export var entity_name :String
export var entity_icon :String

export var node_name :String
export var scene_path :String
export var position :Vector3

export var level :int = 1

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	entity_name = data["entity_name"]
	entity_icon = data["entity_icon"]
	
	node_name = data["node_name"]
	scene_path = data["scene_path"]
	position = data["position"]
	
	level = data["level"]

func to_dictionary() -> Dictionary :
	var data = .to_dictionary()
	
	data["entity_name"] = entity_name
	data["entity_icon"] = entity_icon
	
	data["node_name"] = node_name
	data["scene_path"] = scene_path
	data["position"] = position
	
	data["level"] = level
	return data
	
