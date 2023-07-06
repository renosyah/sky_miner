extends BaseData
class_name InventoryItemData

export var entity_name :String
export var entity_icon :String
export var description :String

export var node_name :String
export var network_id :int
export var scene_path :String
export var position :Vector3

export var enable_pickup :bool

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	entity_name = data["entity_name"]
	entity_icon = data["entity_icon"]
	description = data["description"]
	
	node_name = data["node_name"]
	network_id = data["network_id"]
	scene_path = data["scene_path"]
	position = data["position"]
	
	enable_pickup = data["enable_pickup"]

func to_dictionary() -> Dictionary :
	var data = .to_dictionary()
	
	data["entity_name"] = entity_name
	data["entity_icon"] = entity_icon
	data["description"] = description
	
	data["node_name"] = node_name
	data["network_id"] = network_id
	data["scene_path"] = scene_path
	data["position"] = position
	
	data["enable_pickup"] = enable_pickup
	
	return data
	
func spawn_item(parent :Node) -> InventoryItem:
	var item :InventoryItem = load(scene_path).instance()
	item.name = node_name
	item.item_name = entity_name
	item.enable_pickup = enable_pickup
	item.set_network_master(network_id)
	parent.add_child(item)
	item.translation = position
	item.visible = enable_pickup
	return item
	







