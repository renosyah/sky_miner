extends BaseData
class_name HeroData

export var entity_name :String
export var entity_icon :String
export var description :String

export var node_name :String
export var network_id :int
export var scene_path :String
export var position :Vector3

export var level :int = 1
export var team :int
export var color_coat:Color

export var attack_damage :int
export var attack_delay :float
export var attack_range :float

export var inventories :Array

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	entity_name = data["entity_name"]
	entity_icon = data["entity_icon"]
	description = data["description"]
	
	node_name = data["node_name"]
	network_id = data["network_id"]
	scene_path = data["scene_path"]
	position = data["position"]
	
	level = data["level"]
	team = data["team"]
	color_coat = data["color_coat"]
	
	attack_damage = data["attack_damage"]
	attack_delay = data["attack_delay"]
	attack_range = data["attack_range"]
	
	inventories = []
	for turret in data["inventories"]:
		var item :InventoryItemData = InventoryItemData.new()
		item.from_dictionary(turret)
		inventories.append(item)
		
func to_dictionary() -> Dictionary :
	var data = .to_dictionary()
	
	data["entity_name"] = entity_name
	data["entity_icon"] = entity_icon
	data["description"] = description
	
	data["node_name"] = node_name
	data["network_id"] = network_id
	data["scene_path"] = scene_path
	data["position"] = position
	
	data["level"] = level
	data["team"] = team
	data["color_coat"] = color_coat
	
	data["attack_damage"] = attack_damage
	data["attack_delay"] = attack_delay
	data["attack_range"] = attack_range
	
	data["inventories"] = []
	for inventory in inventories:
		var item :InventoryItemData = inventory
		data["inventories"].append(item.to_dictionary())
	
	return data
	
func spawn_hero(parent :Node) -> Hero:
	var hero :Hero = load(scene_path).instance()
	hero.name = node_name
	hero.set_network_master(network_id)
	hero.max_hp = LevelSystem.get_value(level, hero.max_hp)
	hero.hp = hero.max_hp
	hero.team = team
	hero.color_coat = color_coat
	hero.attack_damage = LevelSystem.get_value(level, attack_damage)
	hero.attack_delay = attack_delay
	hero.attack_range = attack_range
	hero.enable_network = false
	parent.add_child(hero)
	hero.translation = position
	hero.visible = false
	
	for inventory in inventories:
		var item :InventoryItemData = inventory
		var item_spawn :InventoryItem = item.spawn_item(hero)
		hero.inventories.append(item_spawn)
		
	return hero
	







