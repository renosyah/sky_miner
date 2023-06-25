extends BaseGameplayMp

var island_defences :Array
var airships :Array
var bots :Array

var player_airship :AirShip
var player_airship_bot :Bot

func _ready():
	pass
	
# test
func on_map_ready():
	.on_map_ready()
	spawn()
	spawn_island_defence()
	
func spawn():
	for i in 4:
		var spawn_pos = _map.get_islands()[i].translation
		var node_name :String = "airship_%s" % i
		var is_player = (node_name == "airship_1")
		
		var airship :AirshipData = AirshipData.new()
		airship.node_name = node_name
		airship.network_id = Network.PLAYER_HOST_ID
		airship.scene_path = "res://entity/unit/airship/cruiser/cruiser.tscn"
		airship.position = spawn_pos
		airship.turrets_count = 3
		airship.team = i
		airship.color_coat = Color.green if is_player else Color.red
		airship.enable_bot = not is_player
		airship.turrets = []
		for index in airship.turrets_count:
			var t :TurretData = TurretData.new()
			t.node_name = "airship_%s_turret_%s" % [i, index]
			t.scene_path = "res://entity/turret/mg/mg.tscn"
			t.position = Vector3.ZERO
			airship.turrets.append(t)
			
		.spawn_airship(airship)
		
func on_airship_spawned(airship :AirShip, bot :Bot):
	.on_airship_spawned(airship, bot)
	
	var is_player = (airship.name == "airship_1")
	
	var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
	hp_bar.tag_name = airship.name
	hp_bar.enable_label = true
	hp_bar.color = Color.green if is_player else Color.red
	airship.add_child(hp_bar)
	hp_bar.update_bar(airship.hp, airship.max_hp)
	airship.connect("take_damage", self, "_test_on_unit_take_damage",[hp_bar])
	airship.connect("dead", self, "_test_on_cruiser_dead",[hp_bar])
		
	if is_player:
		player_airship = airship
		player_airship_bot = bot
	
	if not is_player:
		airships.append(airship)
		bots.append(bot)
	
func spawn_island_defence():
	for i in 4:
		var node_name :String = "defence_%s" % i
		var spawn_pos = _map.get_islands()[i].translation
		var is_player = (node_name == "defence_1")
		
		var defence :EmplacementData = EmplacementData.new()
		defence.node_name = node_name
		defence.network_id = Network.PLAYER_HOST_ID
		defence.scene_path = "res://entity/unit/emplacement/turret_platform/turret_platform.tscn"
		defence.position = spawn_pos
		defence.turrets_count = 3
		defence.team = i
		defence.color_coat = Color.green if is_player else Color.orange
		defence.enable_bot = true
		defence.turrets = []
		for index in defence.turrets_count:
			var t :TurretData = TurretData.new()
			t.node_name = "airship_%s_turret_%s" % [i, index]
			t.scene_path = "res://entity/turret/mg/mg.tscn"
			t.position = Vector3.ZERO
			defence.turrets.append(t)
		
		.spawn_emplacement(defence)
	
func on_emplacement_spawned(emplacement :Emplacement, bot :Bot):
	.on_emplacement_spawned(emplacement, bot)
	
	var is_player = (emplacement.name == "defence_1")
		
	var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
	hp_bar.tag_name = emplacement.name
	hp_bar.enable_label = true
	hp_bar.color = Color.green if is_player else Color.orange
	emplacement.add_child(hp_bar)
	hp_bar.update_bar(emplacement.hp, emplacement.max_hp)
	emplacement.connect("take_damage", self, "_test_on_unit_take_damage",[hp_bar])
	emplacement.connect("dead", self, "_test_on_defence_dead",[hp_bar])
		
	island_defences.append(emplacement)
	bots.append(bot)
	
func _process(_delta):
	# test player
	if is_instance_valid(player_airship):
		player_airship.move_direction = _ui.get_joystick_direction()
		player_airship.assign_turret_target(player_airship_bot.get_node_path_targets())
		_camera.translation = player_airship.translation
		_camera.set_distance(player_airship.throttle * player_airship.speed)
	
	# test mob
	for bot in bots:
		var unit = get_node_or_null(bot.unit)
		if is_instance_valid(unit):
			if unit is AirShip:
				unit.assign_turret_target(bot.get_node_path_targets())
			elif unit is Emplacement:
				unit.assign_turret_target(bot.get_node_path_targets())
# test
func _test_on_enemy_airship_patrol_timeout():
	for i in bots:
		i.move_to(_map.get_random_island().translation)
		
# test
func _test_on_unit_take_damage(_unit, _damage, _hp_bar):
	if _unit == player_airship:
		_ui.show_hurt()
		
	_hp_bar.update_bar(_unit.hp, _unit.max_hp)
	
# test
func _test_on_cruiser_dead(_unit, _hp_bar):
	yield(get_tree().create_timer(15), "timeout")
	_unit.reset()
	_unit.translation = _map.get_random_island().translation
	_unit.translation.y = 20
	_hp_bar.update_bar(_unit.hp, _unit.max_hp)
	
# test
func _test_on_defence_dead(_unit, _hp_bar):
	yield(get_tree().create_timer(15), "timeout")
	_unit.reset()
	_hp_bar.update_bar(_unit.hp, _unit.max_hp)


