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
	spawn_airship()
	spawn_island_defence()
	
func spawn_airship():
	for i in 4:
		var spawn_pos = _map.get_islands()[i].translation
		var is_player_airship = (i == 0)
		
		var airship :AirShip = preload("res://entity/unit/airship/cruiser/cruiser.tscn").instance()
		airship.name = "airship_%s" % i
		airship.set_network_master(Network.PLAYER_HOST_ID)
		airship.team = i
		airship.color_coat = Color(randf(),randf(),randf(),1)
		add_child(airship)
		airship.translation = spawn_pos
		airship.translation.y = 20
	
		var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
		hp_bar.tag_name = airship.name
		hp_bar.enable_label = true
		hp_bar.color = Color.green if is_player_airship else Color.red
		airship.add_child(hp_bar)
		hp_bar.update_bar(airship.hp, airship.max_hp)
		airship.connect("take_damage", self, "_test_on_unit_take_damage",[hp_bar])
		airship.connect("dead", self, "_test_on_cruiser_dead",[hp_bar])
	
		var turret_index = 0
		for turret_pos in airship.turret_positions:
			var turret :Turret = preload("res://entity/turret/mg/mg.tscn").instance()
			turret.name = "airship_%s_turret_%s" % [i, turret_index]
			turret.ignore_body = airship.get_path()
			airship.assign_turret_position(turret, turret_pos)
			turret_index += 1
		
		var bot :Bot = preload("res://assets/bot/bot.tscn").instance()
		bot.enable = not is_player_airship
		bot.team = airship.team
		bot.unit = airship.get_path()
		airship.add_child(bot)
		
		if is_player_airship:
			player_airship = airship
			player_airship_bot = bot
			
		if not is_player_airship:
			airships.append(airship)
			bots.append(bot)
		
	
func spawn_island_defence():
	for i in 3:
		var spawn_pos = _map.get_islands()[i].translation
		var defence :Emplacement = preload("res://entity/unit/emplacement/turret_platform/turret_platform.tscn").instance()
		defence.name = "defence_%s" % i
		defence.set_network_master(Network.PLAYER_HOST_ID)
		defence.team = i
		defence.color_coat = Color(randf(),randf(),randf(),1)
		add_child(defence)
		defence.translation = spawn_pos
		
		var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
		hp_bar.tag_name = defence.name
		hp_bar.enable_label = true
		hp_bar.color = Color.green if (i == 0) else Color.orange
		defence.add_child(hp_bar)
		hp_bar.update_bar(defence.hp, defence.max_hp)
		defence.connect("take_damage", self, "_test_on_unit_take_damage",[hp_bar])
		defence.connect("dead", self, "_test_on_defence_dead",[hp_bar])
		
		var turret_index = 0
		for turret_pos in defence.turret_positions:
			var turret :Turret = preload("res://entity/turret/mg/mg.tscn").instance()
			turret.name = "defence_%s_turret_%s" % [i, turret_index]
			turret.ignore_body = defence.get_path()
			defence.assign_turret_position(turret, turret_pos)
			turret_index += 1
			
		var bot :Bot = preload("res://assets/bot/bot.tscn").instance()
		bot.enable = true
		bot.team = defence.team
		bot.unit = defence.get_path()
		defence.add_child(bot)
		
		island_defences.append(defence)
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


