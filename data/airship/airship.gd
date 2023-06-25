extends BaseData
class_name AirshipData

export var node_name :String
export var network_id :int
export var scene_path :String
export var position :Vector3

export var team :int
export var color_coat:Color

export var turrets :Array
export var turrets_count :int

export var enable_bot :bool

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	node_name = data["node_name"]
	network_id = data["network_id"]
	scene_path = data["scene_path"]
	position = data["position"]

	team = data["team"]
	color_coat = data["color_coat"]
	
	turrets = []
	for turret in data["turrets"]:
		var t :TurretData = TurretData.new()
		t.from_dictionary(turret)
		turrets.append(t)
		
	turrets_count = data["turrets_count"]
	
	enable_bot = data["enable_bot"]
	
func to_dictionary() -> Dictionary :
	var data = .to_dictionary()
	
	data["node_name"] = node_name
	data["network_id"] = network_id
	data["scene_path"] = scene_path
	data["position"] = position

	data["team"] = team
	data["color_coat"] = color_coat

	data["turrets"] = []
	for turret in turrets:
		var t :TurretData = turret
		data["turrets"].append(t.to_dictionary())
		
	data["turrets_count"] = turrets_count
	
	data["enable_bot"] = enable_bot
	return data
	
func spawn_airship(parent :Node) -> Array:
	var airship :AirShip = load(scene_path).instance()
	airship.name = node_name
	airship.set_network_master(network_id)
	airship.team = team
	airship.color_coat = color_coat
	airship.altitude = 20
	parent.add_child(airship)
	airship.translation = position
	airship.translation.y = 20
	
	var _turret_datas :Array = []
	var index = 0
	for turret in turrets:
		var t :TurretData = turret
		t.position = airship.turret_positions[index]
		_turret_datas.append(t)
		index += 1
		
	for _data in _turret_datas:
		var turret_data :TurretData = _data
		var turret :Turret = load(turret_data.scene_path).instance()
		turret.name = turret_data.node_name
		turret.ignore_body = airship.get_path()
		airship.assign_turret_position(turret, turret_data.position)
	
	var bot :Bot = preload("res://assets/bot/bot.tscn").instance()
	bot.enable = enable_bot
	bot.team = team
	bot.unit = airship.get_path()
	airship.add_child(bot)
	
	return [airship, bot]
	







