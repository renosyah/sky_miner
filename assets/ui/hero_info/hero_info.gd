extends HBoxContainer
class_name HeroInfo

const inventory_info_scene = preload("res://assets/ui/hero_info/inventory_info/inventory_info.tscn")

onready var _icon = $hero_potrait/VBoxContainer/icon
onready var _name = $VBoxContainer/name

onready var _border = $hero_potrait/border
onready var _inventories_holder = $VBoxContainer/HBoxContainer

onready var respawn_indicator = $hero_potrait/respawn_indicator
onready var respawn_timer = $hero_potrait/respawn_timer

func display_respawn_cooldown(time :float):
	respawn_indicator.value = time
	respawn_indicator.max_value = time
	respawn_timer.wait_time = time
	respawn_timer.start()
	set_process(true)
	
func _process(delta):
	respawn_indicator.value = respawn_timer.time_left
	
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













