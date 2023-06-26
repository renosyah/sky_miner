extends BaseData
class_name EmplacementData

export var entity_name :String
export var entity_icon :String

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
	
	entity_name = data["entity_name"]
	entity_icon = data["entity_icon"]
	
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
	
	data["entity_name"] = entity_name
	data["entity_icon"] = entity_icon
	
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
	
func spawn_emplacement(parent :Node) -> Array:
	var defence :Emplacement = load(scene_path).instance()
	defence.name = node_name
	defence.set_network_master(network_id)
	defence.max_hp = LevelSystem.get_value(level, defence.max_hp)
	defence.hp = defence.max_hp
	defence.team = team
	defence.color_coat = color_coat
	parent.add_child(defence)
	defence.translation = position
	
	var index = 0
	for data in turrets:
		var turret :TurretData = data
		turret.position = defence.turret_positions[index]
		index += 1
		
	for data in turrets:
		var turret_data :TurretData = data
		var turret :Turret = load(turret_data.scene_path).instance()
		turret.name = turret_data.node_name
		turret.ignore_body = defence.get_path()
		turret.attack_damage = LevelSystem.get_value(turret_data.level, turret.attack_damage)
		turret.max_ammo = LevelSystem.get_value(turret_data.level, turret.max_ammo)
		turret.ammo = turret.max_ammo
		defence.assign_turret_position(turret, turret_data.position)
	
	var bot :Bot = preload("res://assets/bot/bot.tscn").instance()
	bot.enable = enable_bot
	bot.team = team
	bot.unit = defence.get_path()
	defence.add_child(bot)
	
	return [defence, bot]
	



