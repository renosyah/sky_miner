extends BaseGameplayMp

var ai_bots :Array = []
var islands :Array
onready var enemy_airship_patrol = $enemy_airship_patrol

# test
func on_map_ready():
	.on_map_ready()
	
	islands = _map.get_islands()
	
	spawn_bot_airship()
	spawn_defence_bot()
	spawn_player_airship()
	
	enemy_airship_patrol.start()
	
func spawn_player_airship():
	var datas :Array = []
	var index :int = 0
	for p in NetworkLobbyManager.get_players():
		var player :NetworkPlayer = p
		var airship :AirshipData = preload("res://data/airship/list/cruiser.tres").duplicate()
		airship.entity_name = player.player_name
		airship.node_name = "player_%s" % player.player_network_unique_id
		airship.network_id = player.player_network_unique_id
		airship.position = islands[index].translation + Vector3(-10, 0, -10)
		airship.level = int(rand_range(50, 100))
		airship.team = 0
		airship.color_coat = Color.green
		airship.enable_bot = false
		
		airship.turrets = []
		for turret_index in airship.turrets_count:
			var t :TurretData = preload("res://data/turret/list/mg.tres").duplicate()
			t.node_name = "%s_turret_%s" % [airship.node_name, turret_index]
			t.level = airship.level
			airship.turrets.append(t)
			
		datas.append(airship)
		index += 1
		
	.spawn_airships(datas)
	
func spawn_bot_airship():
	var datas :Array = []
	for i in 4:
		var airship :AirshipData = preload("res://data/airship/list/cruiser.tres").duplicate()
		airship.entity_name = "%s (Bot)" % RandomNameGenerator.generate()
		airship.node_name = "airship_%s" % i
		airship.network_id = Network.PLAYER_HOST_ID
		airship.level = int(rand_range(1, 25))
		airship.position = islands[i].translation + Vector3(10, 0, 10)
		airship.team = i + 10
		airship.color_coat = Color.red
		airship.enable_bot = true
		
		airship.turrets = []
		for index in airship.turrets_count:
			var t :TurretData = preload("res://data/turret/list/mg.tres").duplicate()
			t.node_name = "%s_turret_%s" % [airship.node_name, index]
			t.level = airship.level
			airship.turrets.append(t)
			
		datas.append(airship)
		
	.spawn_airships(datas)
	
func spawn_defence_bot():
	var datas :Array = []
	for i in 4:
		var defence :EmplacementData = preload("res://data/emplacement/list/turret_platform.tres").duplicate()
		defence.entity_name = "Defence (Bot)"
		defence.node_name = "defence_%s" % i
		defence.network_id = Network.PLAYER_HOST_ID
		defence.position = islands[i].translation
		defence.level = int(rand_range(1, 25))
		defence.team = i + 20
		defence.color_coat = Color.orange
		defence.enable_bot = true
		
		defence.turrets = []
		for index in defence.turrets_count:
			var t :TurretData = preload("res://data/turret/list/mg.tres").duplicate()
			t.node_name = "%s_turret_%s" % [defence.node_name, index]
			t.level = defence.level
			defence.turrets.append(t)
			
		datas.append(defence)
		
	.spawn_emplacements(datas)
	
func _process(_delta):
	# test mob
	for bot in ai_bots:
		var unit = bot.get_unit()
		if unit is AirShip or unit is Emplacement:
			unit.assign_turret_target(bot.get_node_path_targets())
		
# assign AI to patrol
func _test_on_enemy_airship_patrol_timeout():
	for ai_bot in ai_bots:
		var unit = get_node_or_null(ai_bot.unit)
		if unit is AirShip:
			ai_bot.move_to(_map.get_random_island().translation)
		
	enemy_airship_patrol.start()
	
func on_airship_spawned(data :AirshipData, airship :AirShip, bot :Bot):
	.on_airship_spawned(data, airship, bot)
	
	if airship != player_airship:
		ai_bots.append(bot)
	
func on_emplacement_spawned(data :EmplacementData, emplacement :Emplacement, bot :Bot):
	.on_emplacement_spawned(data, emplacement, bot)
	ai_bots.append(bot)
	
func on_airship_dead(_unit :AirShip, _hp_bar :HpBar3D):
	.on_airship_dead(_unit, _hp_bar)
	
	yield(get_tree().create_timer(15), "timeout")
	
	var pos :Vector3 = _map.get_random_island().translation
	pos.y = _unit.altitude
	
	.respawn(_unit,pos)
	
func on_emplacement_dead(_unit :Emplacement, _hp_bar :HpBar3D):
	.on_emplacement_dead(_unit, _hp_bar)
	
	yield(get_tree().create_timer(15), "timeout")
	
	.respawn(_unit, _unit.translation)
	
	
	
	
	
