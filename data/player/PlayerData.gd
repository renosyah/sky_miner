extends BaseData
class_name PlayerData

export var player_id :String = ""
export var player_name : String = ""

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	player_id = data["player_id"]
	player_name = data["player_name"]
	
func to_dictionary() -> Dictionary:
	var data : Dictionary = {}
	data["player_id"] = player_id
	data["player_name"] = player_name
	return data
	
