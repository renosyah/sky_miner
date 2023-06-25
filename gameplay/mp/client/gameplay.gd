extends BaseGameplayMp

var islands :Array

# test
func on_map_ready():
	.on_map_ready()
	
	islands = _map.get_islands()
	
	spawn_player_airship()
	
func spawn_player_airship():
	var spawn_pos = _map.get_random_island().translation
	var airship :AirshipData = AirshipData.new()
	airship.player_name = RandomNameGenerator.generate()
	airship.node_name = unique_player_node_name
	airship.network_id = NetworkLobbyManager.get_id()
	airship.scene_path = "res://entity/unit/airship/cruiser/cruiser.tscn"
	airship.position = islands[7].translation
	airship.turrets_count = 3
	airship.level = int(rand_range(1, 100))
	airship.team = 1
	airship.color_coat = Color.green
	airship.enable_bot = false
	
	airship.turrets = []
	for index in airship.turrets_count:
		var t :TurretData = TurretData.new()
		t.node_name = "%s_turret_%s" % [unique_player_node_name, index]
		t.scene_path = "res://entity/turret/mg/mg.tscn"
		t.level = airship.level
		t.position = Vector3.ZERO
		airship.turrets.append(t)
		
	.spawn_airship(airship)
	
func _process(_delta):
	if is_instance_valid(player_airship):
		player_airship.move_direction = _ui.get_joystick_direction()
		player_airship.assign_turret_target(player_airship_bot.get_node_path_targets())
		_camera.translation = player_airship.translation
		_camera.set_distance(player_airship.throttle * player_airship.speed)
	
func on_unit_take_damage(_unit :BaseUnit, _damage :int, _hp_bar :HpBar3D):
	.on_unit_take_damage(_unit, _damage , _hp_bar)
	if _unit == player_airship:
		_ui.show_hurt()
