extends BaseGameplayMp

var airships_to_spawn :Array = []
var defences_to_spawn :Array = []

var ai_bots :Array = []
var islands :Array = []

const turrets = [
	preload("res://data/turret/list/cannon.tres"),
	preload("res://data/turret/list/flak.tres"),
	preload("res://data/turret/list/mg.tres"),
	preload("res://data/turret/list/missile.tres"),
	preload("res://data/turret/list/ciwis.tres"),
	preload("res://data/turret/list/guided_missile.tres")
]

onready var enemy_airship_patrol = $enemy_airship_patrol

func _ready():
	player_team = 1

# test
func on_map_ready():
	.on_map_ready()
	
	islands = _map.get_islands()
	
	spawn_player_heroes()
	spawn_player_airship()
	spawn_bot_airship()
	spawn_defence_bot()
	spawn_coins()
	
	.spawn_airships(airships_to_spawn)
	.spawn_emplacements(defences_to_spawn)
	
	enemy_airship_patrol.start()
	
func spawn_player_heroes():
	var heroes :Array = []
	var index :int = 10
	for p in NetworkLobbyManager.get_players():
		var player :NetworkPlayer = p
		var hero :HeroData = preload("res://data/hero/list/airman.tres").duplicate()
		hero.entity_name = player.player_name
		hero.node_name = "player_%s" % player.player_network_unique_id
		hero.network_id = player.player_network_unique_id
		hero.position = Vector3(index, 150, index)
		hero.level = 100
		hero.team = player_team 
		hero.color_coat = Color.green
		hero.inventories = []
		
#		for i in 5:
#			var coin :InventoryItemData =  preload("res://data/inventory_item/list/coin.tres").duplicate()
#			coin.node_name = "%s_coin_%s" % [hero.node_name, i]
#			coin.network_id = Network.PLAYER_HOST_ID
#			coin.position = Vector3.ZERO
#			coin.enable_pickup = false
#			hero.inventories.append(coin)
			
#		var axe :InventoryItemData = preload("res://data/inventory_item/list/axe.tres").duplicate()
#		axe.node_name = "%s_axe_%s" % [hero.node_name, 1]
#		axe.network_id = Network.PLAYER_HOST_ID
#		axe.position = Vector3.ZERO
#		axe.enable_pickup = false
#		hero.inventories.append(axe)
#
#		var pickaxe :InventoryItemData = preload("res://data/inventory_item/list/pickaxe.tres").duplicate()
#		pickaxe.node_name = "%s_pickaxe_%s" % [hero.node_name, 1]
#		pickaxe.network_id = Network.PLAYER_HOST_ID
#		pickaxe.position = Vector3.ZERO
#		pickaxe.enable_pickup = false
#		hero.inventories.append(pickaxe)
		
		heroes.append(hero)
		index += 10
		
	.spawn_heroes(heroes)
	
func spawn_player_airship():
	var player_index :int = 10
	for p in NetworkLobbyManager.get_players():
		var player :NetworkPlayer = p
		var airship :AirshipData = preload("res://data/airship/list/cruiser.tres").duplicate()
		airship.entity_name = player.player_name
		airship.node_name = "player_%s" % player.player_network_unique_id
		airship.network_id = player.player_network_unique_id
		airship.position = _map.get_entry_points(player_index)[1] + Vector3(10,0,0)
		airship.level = 100
		airship.team = player_team 
		airship.color_coat = Color.green
		
		airship.turrets = []
		for index in airship.turrets_count:
			var t :TurretData = turrets[rand_range(0, turrets.size())].duplicate()
			t.node_name = "%s_turret_%s" % [airship.node_name, index]
			t.level = airship.level
			airship.turrets.append(t)

		airships_to_spawn.append(airship)
		player_index += 10
		
func spawn_bot_airship():
	var teams = {1 : 2, 2: 2}
	for key in teams.keys():
		var player_index :int = 10
		var team :int = key
		var count :int = teams[key]
		for i in range(count):
			var airship :AirshipData = preload("res://data/airship/list/cruiser.tres").duplicate()
			airship.entity_name = "%s (Bot)" % RandomNameGenerator.generate()
			airship.node_name = "airship_%s_%s" % [team, i]
			airship.network_id = Network.PLAYER_HOST_ID
			airship.level = 1
			airship.position = _map.get_entry_points(player_index)[team]
			airship.team = team
			airship.color_coat = Color.red if team == 2 else Color.green
			
			airship.turrets = []
			for index in airship.turrets_count:
				var t :TurretData = turrets[rand_range(0, turrets.size())].duplicate()
				t.node_name = "%s_turret_%s" % [airship.node_name, index]
				t.level = airship.level
				airship.turrets.append(t)
				
			airships_to_spawn.append(airship)
			player_index += 10
			
func spawn_defence_bot():
	for i in 2:
		var defence :EmplacementData = preload("res://data/emplacement/list/turret_platform.tres").duplicate()
		defence.entity_name = "Defence (Bot)"
		defence.node_name = "defence_%s" % i
		defence.network_id = Network.PLAYER_HOST_ID
		defence.position = islands[i].get_random_position()
		defence.level = 1
		defence.team = 2
		defence.color_coat = Color.orange
		
		defence.turrets = []
		for index in defence.turrets_count:
			var t :TurretData = turrets[rand_range(0, turrets.size())].duplicate()
			t.node_name = "%s_turret_%s" % [defence.node_name, index]
			t.level = defence.level
			defence.turrets.append(t)
			
		defences_to_spawn.append(defence)
	
func spawn_coins():
	var coins :Array = []
	for i in 25:
		var pos :Vector3 = _map.get_random_island().get_random_position()
		var coin :InventoryItemData =  preload("res://data/inventory_item/list/coin.tres").duplicate()
		coin.node_name = "world_coin_%s" % i
		coin.network_id = Network.PLAYER_HOST_ID
		coin.position = pos + Vector3(0, 0.60, 0)
		coin.enable_pickup = true
		coins.append(coin)
		
	var axe :InventoryItemData = preload("res://data/inventory_item/list/axe.tres").duplicate()
	axe.node_name = "world_axe_%s" % 1
	axe.network_id = Network.PLAYER_HOST_ID
	axe.position = Vector3(0, 0.60, 0) + islands[0].get_random_position()
	axe.enable_pickup = true
	
	var pickaxe :InventoryItemData = preload("res://data/inventory_item/list/pickaxe.tres").duplicate()
	pickaxe.node_name = "world_pickaxe_%s" % 1
	pickaxe.network_id = Network.PLAYER_HOST_ID
	pickaxe.position = Vector3(0, 0.60, 0) + islands[0].get_random_position()
	pickaxe.enable_pickup = true
	
	.spawn_items(coins + [axe, pickaxe])
	
	
func _process(_delta):
	# assign target bot to unit
	for bot in ai_bots:
		var unit = bot.get_unit()
		if unit is AirShip or unit is Emplacement:
			unit.assign_turret_target(bot.get_node_path_targets())
		
# assign autofight to bot
func _test_on_enemy_airship_patrol_timeout():
	for ai_bot in ai_bots:
		if ai_bot.get_unit() is AirShip:
			ai_bot.move_to(_map.get_random_island().get_random_position())
		
	enemy_airship_patrol.start()
	
func on_bot_spawned(bot :Bot):
	.on_bot_spawned(bot)
	ai_bots.append(bot)
	
func on_airship_dead(_unit :AirShip, _hp_bar :HpBar3D, marker :ScreenMarker):
	.on_airship_dead(_unit, _hp_bar, marker)
	
	yield(get_tree().create_timer(15), "timeout")
	
	var pos :Vector3 = _map.get_random_entry_point()
	pos.y = _unit.altitude
	
	.respawn(_unit, pos)
	
func on_emplacement_dead(_unit :Emplacement, _hp_bar :HpBar3D, marker :ScreenMarker):
	.on_emplacement_dead(_unit, _hp_bar, marker)
	
	yield(get_tree().create_timer(25), "timeout")
	
	.respawn(_unit, _unit.translation)
	
func on_hero_dead(_unit :Hero, hp_bar :HpBar3D):
	.on_hero_dead(_unit, hp_bar)
	
	for i in _unit.inventories:
		if i is InventoryItem:
			i.drop(self)
	
	yield(get_tree().create_timer(5), "timeout")
	
	_unit.reset()

