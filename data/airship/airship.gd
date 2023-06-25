extends BaseData
class_name AirshipData

export var player_name :String

export var node_name :String
export var network_id :int
export var scene_path :String
export var position :Vector3

export var level :int
export var team :int
export var color_coat:Color

export var turrets :Array
export var turrets_count :int

export var enable_bot :bool

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	player_name = data["player_name"]
	
	node_name = data["node_name"]
	network_id = data["network_id"]
	scene_path = data["scene_path"]
	position = data["position"]
	
	level = data["level"]
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
	
	data["player_name"] = player_name
	
	data["node_name"] = node_name
	data["network_id"] = network_id
	data["scene_path"] = scene_path
	data["position"] = position
	
	data["level"] = level
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
	airship.max_hp = LevelSystem.get_value(level, airship.max_hp)
	airship.hp = airship.max_hp
	airship.team = team
	airship.color_coat = color_coat
	airship.altitude = 20
	parent.add_child(airship)
	airship.translation = position
	airship.translation.y = 20
	
	var index = 0
	for data in turrets:
		var turret :TurretData = data
		turret.position = airship.turret_positions[index]
		index += 1
		
	for data in turrets:
		var turret_data :TurretData = data
		var turret :Turret = load(turret_data.scene_path).instance()
		turret.name = turret_data.node_name
		turret.ignore_body = airship.get_path()
		turret.attack_damage = LevelSystem.get_value(turret_data.level, turret.attack_damage)
		turret.max_ammo = LevelSystem.get_value(turret_data.level, turret.max_ammo)
		turret.ammo = turret.max_ammo
		airship.assign_turret_position(turret, turret_data.position)
	
	var bot :Bot = preload("res://assets/bot/bot.tscn").instance()
	bot.enable = enable_bot
	bot.team = team
	bot.unit = airship.get_path()
	airship.add_child(bot)
	
	return [airship, bot]
	







