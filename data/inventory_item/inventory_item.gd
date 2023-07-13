extends BaseData
class_name InventoryItemData

export var entity_name :String
export var entity_icon :String
export var description :String

export var node_name :String
export var scene_path :String
export var position :Vector3

export var item_id :String
export var enable_pickup :bool
export var color_highlight :Color
export var stack_total :int = 1

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	entity_name = data["entity_name"]
	entity_icon = data["entity_icon"]
	description = data["description"]
	
	node_name = data["node_name"]
	scene_path = data["scene_path"]
	position = data["position"]
	
	item_id = data["item_id"]
	enable_pickup = data["enable_pickup"]
	color_highlight = data["color_highlight"]
	stack_total = data["stack_total"]

func to_dictionary() -> Dictionary :
	var data = .to_dictionary()
	
	data["entity_name"] = entity_name
	data["entity_icon"] = entity_icon
	data["description"] = description
	
	data["node_name"] = node_name
	data["scene_path"] = scene_path
	data["position"] = position
	
	data["item_id"] = item_id
	data["enable_pickup"] = enable_pickup
	data["color_highlight"] = color_highlight
	data["stack_total"] = stack_total
	
	return data
	
func spawn_item(parent :Node) -> InventoryItem:
	var item :InventoryItem = load(scene_path).instance()
	item.name = node_name
	item.item_id = item_id
	item.item_name = entity_name
	item.icon = entity_icon
	item.enable_pickup = enable_pickup
	item.color_highlight = color_highlight
	item.stack_total = stack_total
	parent.add_child(item)
	item.translation = position
	item.visible = enable_pickup
	return item
	







