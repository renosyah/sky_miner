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
	var airship :AirshipData = AirshipData.new()
	airship.entity_name = RandomNameGenerator.generate()
	airship.entity_icon = ""
	airship.node_name = unique_player_node_name
	airship.network_id = NetworkLobbyManager.get_id()
	airship.scene_path = "res://entity/unit/airship/cruiser/cruiser.tscn"
	airship.position = islands[6].translation
	airship.turrets_count = 3
	airship.level = int(rand_range(1, 100))
	airship.team = 0
	airship.color_coat = Color.green
	airship.enable_bot = false
	
	airship.turrets = []
	for index in airship.turrets_count:
		var t :TurretData = TurretData.new()
		t.entity_name = "mg turret"
		t.entity_icon = ""
		t.node_name = "%s_turret_%s" % [unique_player_node_name, index]
		t.scene_path = "res://entity/turret/mg/mg.tscn"
		t.level = airship.level
		t.position = Vector3.ZERO
		airship.turrets.append(t)
		
	.spawn_airship(airship)
	
func spawn_bot_airship():
	var datas :Array = []
	for i in 4:
		var airship :AirshipData = AirshipData.new()
		airship.entity_name = "%s (Bot)" % RandomNameGenerator.generate()
		airship.entity_icon = ""
		airship.node_name = "airship_%s" % i
		airship.network_id = Network.PLAYER_HOST_ID
		airship.scene_path = "res://entity/unit/airship/cruiser/cruiser.tscn"
		airship.position = islands[i].translation + Vector3(10, 0, -10)
		airship.turrets_count = 3
		airship.level = int(rand_range(1, 100))
		airship.team = i + 10
		airship.color_coat = Color.red
		airship.enable_bot = true
		
		airship.turrets = []
		for index in airship.turrets_count:
			var t :TurretData = TurretData.new()
			t.entity_name = "mg turret"
			t.entity_icon = ""
			t.node_name = "%s_turret_%s" % [airship.node_name, index]
			t.scene_path = "res://entity/turret/mg/mg.tscn"
			t.level = airship.level
			t.position = Vector3.ZERO
			airship.turrets.append(t)
			
		datas.append(airship)
		
	.spawn_airships(datas)
	
func spawn_defence_bot():
	var datas :Array = []
	for i in 4:
		var defence :EmplacementData = EmplacementData.new()
		defence.entity_name = "Defence (Bot)"
		defence.entity_icon = ""
		defence.node_name = "defence_%s" % i
		defence.network_id = Network.PLAYER_HOST_ID
		defence.scene_path = "res://entity/unit/emplacement/turret_platform/turret_platform.tscn"
		defence.position = islands[i].translation
		defence.turrets_count = 3
		defence.level = int(rand_range(1, 100))
		defence.team = i + 20
		defence.color_coat = Color.orange
		defence.enable_bot = true
		
		defence.turrets = []
		for index in defence.turrets_count:
			var t :TurretData = TurretData.new()
			t.entity_name = "mg turret"
			t.entity_icon = ""
			t.node_name = "%s_turret_%s" % [defence.node_name, index]
			t.scene_path = "res://entity/turret/mg/mg.tscn"
			t.position = Vector3.ZERO
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
	
func on_unit_take_damage(_unit :BaseUnit, _damage :int, _hp_bar :HpBar3D):
	.on_unit_take_damage(_unit, _damage , _hp_bar)
	if _unit == player_airship:
		_ui.show_hurt()
		
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
	
	
	
	
	
