extends HBoxContainer
class_name HeroInfo

const inventory_info_scene = preload("res://assets/ui/hero_info/inventory_info/inventory_info.tscn")

onready var _icon = $hero_potrait/VBoxContainer/icon

onready var _border = $hero_potrait/border
onready var _inventories_holder = $inventories

onready var respawn_indicator = $hero_potrait/respawn_indicator
onready var respawn_timer = $hero_potrait/respawn_timer

func display_respawn_cooldown(time :float):
	respawn_indicator.value = time
	respawn_indicator.max_value = time
	respawn_timer.wait_time = time
	respawn_timer.start()
	set_process(true)
	
func _process(_delta):
	respawn_indicator.value = respawn_timer.time_left
	
func display_info(_ic :String, _val :Color):
	_icon.texture = load(_ic)
	_border.modulate = _val
	
func display_inventory(inventories :Array, _val :Color):
	for i in _inventories_holder.get_children():
		_inventories_holder.remove_child(i)
		i.queue_free()
		
	for i in inventories:
		var item :InventoryItem = i
		var inventory :InventoryInfo = inventory_info_scene.instance()
		inventory.icon = item.icon
		inventory.total = item.stack_total
		inventory.color = _val
		_inventories_holder.add_child(inventory)













