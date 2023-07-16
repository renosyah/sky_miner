extends ShowCaseGameplayMP

func all_player_ready():
	.all_player_ready()
	
	var index :int = 0
	var heroes :Array = []
	
	for p in NetworkLobbyManager.get_players():
		var player :NetworkPlayer = p
		var hero :HeroData = preload("res://data/hero/list/crewman.tres").duplicate()
		hero.entity_name = "man"
		hero.node_name = "player_%s" % player.player_network_unique_id
		hero.network_id = player.player_network_unique_id
		hero.position = Vector3(index, 20, index)
		hero.level = 1
		hero.team = 1 
		hero.color_coat = Color.green
		hero.inventories = []
		heroes.append(hero)
		index += 10
		
	.spawn_heroes(heroes)
	
	var items :Array = []
	index = 0
	
	var resources = [
		preload("res://data/inventory_item/list/coin.tres"),
		preload("res://data/inventory_item/list/wood.tres"),
		preload("res://data/inventory_item/list/iron.tres"),
		preload("res://data/inventory_item/list/coal.tres")
	]
	var tools = [
		preload("res://data/inventory_item/list/axe.tres"),
		preload("res://data/inventory_item/list/pickaxe.tres"),
	]
	var weapons = [
		preload("res://data/inventory_item/list/assault_rifle.tres")
	]
	
	for i in resources :
		var item :InventoryItemData = i.duplicate()
		item.node_name = "world_resource_%s" % 1
		item.position = $resource.global_transform.origin + Vector3(index, 2, 0)
		item.enable_pickup = true
		item.stack_total = 10
		items.append(item)
		index += 2
		
	index = 0
	
	for i in tools:
		var tool_data :InventoryItemData = i.duplicate()
		tool_data.node_name = "world_tool_%s" % i
		tool_data.position = $tool.global_transform.origin + Vector3(index, 2, 0)
		tool_data.stack_total = 1
		tool_data.enable_pickup = true
		items.append(tool_data)
		index += 2
		
	index = 0
	
	for i in weapons:
		var weapon :InventoryItemData = i.duplicate()
		weapon.node_name = "world_weapon_%s" % i
		weapon.position = $weapon.global_transform.origin + Vector3(index, 2, 0)
		weapon.stack_total = 1
		weapon.enable_pickup = true
		items.append(weapon)
		index += 2
		
	.spawn_items(items)
	
func _on_resource_dead(_resource : BaseResources):
	var item :InventoryItemData
	
	match (_resource.type_resource):
		BaseResources.type_resource_enum.wood:
			item = preload("res://data/inventory_item/list/wood.tres").duplicate()
			item.stack_total = int(rand_range(10,20))
			
		BaseResources.type_resource_enum.iron:
			item = preload("res://data/inventory_item/list/iron.tres").duplicate()
			item.stack_total = int(rand_range(4,12))
			
		BaseResources.type_resource_enum.coal:
			item = preload("res://data/inventory_item/list/coal.tres").duplicate()
			item.stack_total = int(rand_range(6,16))
			
		BaseResources.type_resource_enum.food:
			return
			
	item.node_name = "world_droped_item_%s" % _resource.name
	item.position = _resource.translation + Vector3.BACK * 5
	item.enable_pickup = true
	
	.spawn_item(item)
	
	yield(get_tree().create_timer(5),"timeout")
	_resource.reset()
	
func _on_target_take_damage(_unit, _damage):
	pass

func _on_target_dead(_unit):
	$target/Tween.interpolate_property(_unit, "rotation_degrees:x", 0, 90, 0.5)
	$target/Tween.start()
	
	yield(get_tree().create_timer(5),"timeout")
	_unit.reset()
	
func _on_target_reset(_unit):
	$target/Tween.interpolate_property(_unit, "rotation_degrees:x", 90, 0, 0.5)
	$target/Tween.start()






















