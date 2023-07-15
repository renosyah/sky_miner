extends ShowCaseGameplayMP

func all_player_ready():
	.all_player_ready()
	
	var index :int = 0
	var heroes :Array = []
	
	for p in NetworkLobbyManager.get_players():
		var player :NetworkPlayer = p
		var hero :HeroData = preload("res://data/hero/list/airman.tres").duplicate()
		hero.entity_name = "Airman"
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
	_resource.reset(false)
	
func _on_target_take_damage(_unit, _damage):
	$hpBar.update_bar(_unit.hp, _unit.max_hp)
	$hpBar.translation = _unit.global_transform.origin + Vector3(0, 3, 0)

func _on_target_dead(_unit):
	_unit.reset(false)




















