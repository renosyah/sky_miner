extends HBoxContainer
class_name HeroInfo

const inventory_info_scene = preload("res://assets/ui/hero_info/inventory_info/inventory_info.tscn")

onready var _icon = $airship_potrait/icon
onready var _name = $VBoxContainer/name

onready var _border = $airship_potrait/border
onready var _inventories_holder = $VBoxContainer/HBoxContainer

onready var repawn_indicator = $airship_potrait/repawn

func display_info(_nm :String, _ic :String, _val :Color):
	_icon.texture = load(_ic)
	_name.text = _nm
	_border.modulate = _val
	
func display_inventory(inventories :Array, _val :Color):
	for i in _inventories_holder.get_children():
		_inventories_holder.remove_child(i)
		i.queue_free()
		
	var inventory_dict :Dictionary = {}
	
	for i in inventories:
		var item :InventoryItem = i
		if not inventory_dict.has(item.item_id):
			inventory_dict[item.item_id] = {
				"icon": item.icon,
				"total":1
			}
			continue
			
		inventory_dict[item.item_id]["total"] += 1
		
	for key in inventory_dict.keys():
		var inventory :InventoryInfo = inventory_info_scene.instance()
		inventory.icon = inventory_dict[key]["icon"]
		inventory.total = inventory_dict[key]["total"]
		inventory.color = _val
		_inventories_holder.add_child(inventory)













