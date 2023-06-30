extends Node
class_name BaseGameplayMp

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	init_connection_watcher()
	
	setup_map()
	setup_camera()
	setup_ui()
	setup_parents()
	
	NetworkLobbyManager.set_ready()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func on_back_pressed():
	on_exit_game_session()
	
################################################################
# cameras
var _camera :FixCamera

func setup_camera():
	_camera = preload("res://assets/utils/fix_camera/fix_camera.tscn").instance()
	add_child(_camera)
	
################################################################
# map
var _map :Map

func setup_map():
	_map = preload("res://map/map.tscn").instance()
	_map.connect("on_map_ready", self, "on_map_ready")
	_map.connect("resource_take_damage", self, "_resource_take_damage")
	_map.connect("resource_dead", self, "_resource_dead")
	_map.connect("resource_reset", self, "_resource_reset")
	add_child(_map)
	
	if is_server():
		_map.generate_islands()
		NetworkLobbyManager.argument["map_data"] = _map.map_data
		NetworkLobbyManager.set_host_ready()
	
func on_map_ready():
	_ui.make_ready()
	
func _generate_island():
	_map.map_data = NetworkLobbyManager.argument["map_data"]
	_map.spawn_islands()
	
func _resource_take_damage(_resource :BaseResources, _damage :int):
	pass
	
func _resource_dead(_resource :BaseResources):
	_resource.queue_free()
	
func _resource_reset(_resource :BaseResources):
	pass
	
################################################################
# ui
var _ui :UiMp

func setup_ui():
	_ui = preload("res://gameplay/mp/ui/ui.tscn").instance()
	_ui.connect("exit_airship", self, "on_exit_airship")
	_ui.connect("enter_airship", self, "on_enter_airship")
	add_child(_ui)
	
func on_exit_airship():
	if not is_instance_valid(landing_zone_validator):
		return
		
	landing_zone_validator.enable = false
	enable_airship_bot(player_airship_bot, true)
	
	if is_instance_valid(player_hero):
		last_landing_spot = landing_zone_validator.position + Vector3(0,8,0)
		enable_hero(player_hero, true, last_landing_spot)
	
func on_enter_airship():
	if not is_instance_valid(landing_zone_validator):
		return
		
	landing_zone_validator.enable = true
	enable_airship_bot(player_airship_bot, false)
	
	if is_instance_valid(player_hero):
		enable_hero(player_hero, false, player_hero_spawn_pos)
	
################################################################
# network connection watcher
# for both client and host
func init_connection_watcher():
	NetworkLobbyManager.connect("on_host_disconnected", self, "on_host_disconnected")
	NetworkLobbyManager.connect("connection_closed", self, "connection_closed")
	NetworkLobbyManager.connect("all_player_ready", self, "all_player_ready")
	NetworkLobbyManager.connect("on_player_disconnected", self, "on_player_disconnected")
	
func on_player_disconnected(_player_network :NetworkPlayer):
	pass
	
func connection_closed():
	to_main_menu()
	
func on_host_disconnected():
	to_main_menu()
	
func all_player_ready():
	_generate_island()
	
################################################################
# holders
var _hero_parent :Node
var _airship_parent :Node
var _defence_parent :Node

func setup_parents():
	_hero_parent = Node.new()
	_hero_parent.name = "hero_parent"
	add_child(_hero_parent)
	
	_airship_parent = Node.new()
	_airship_parent.name = "airship_parent"
	add_child(_airship_parent)
	
	_defence_parent = Node.new()
	_defence_parent.name = "defence_parent"
	add_child(_defence_parent)
	
################################################################
# respawner
func respawn(_unit :BaseUnit, _position :Vector3):
	if not is_server():
		return
		
	rpc("_respawn", _unit.get_path(), _position)
	
remotesync func _respawn(_node_path :NodePath, _position :Vector3):
	var _unit :BaseUnit = get_node_or_null(_node_path)
	if not is_instance_valid(_unit):
		return
		
	_unit.reset(false)
	_unit.translation = _position
	
################################################################
# player variables
var player_team :int

var player_airship :AirShip
var player_airship_bot :Bot

var player_hero :Hero
var player_hero_spawn_pos :Vector3

var landing_zone_validator :LandingZoneValidator
var last_landing_spot :Vector3

################################################################
# hero spawner
func spawn_heroes(_datas :Array, _parent :Node = _hero_parent):
	var _datas_dicts :Array = []
	for i in _datas:
		_datas_dicts.append(i.to_dictionary())
		
	rpc("_spawn_heroes", _datas_dicts, _parent.get_path())
	
remotesync func _spawn_heroes(_datas :Array, _parent_path :NodePath):
	for data in _datas:
		_spawn_hero(data, _parent_path)
	
func spawn_hero(_data :HeroData, _parent :Node = _hero_parent):
	rpc("_spawn_hero", _data, _parent.get_path())
	
remotesync func _spawn_hero(_data :Dictionary, _parent_path :NodePath):
	var _hero_data :HeroData = HeroData.new()
	_hero_data.from_dictionary(_data)
	
	var _parent = get_node_or_null(_parent_path)
	if not is_instance_valid(_parent):
		return
		
	var hero :Hero = _hero_data.spawn_hero(_parent)
	on_hero_spawned(_hero_data, hero)
	
func on_hero_spawned(_data :HeroData, hero :Hero):
	var is_player = (_data.node_name == "player_%s" % NetworkLobbyManager.get_id())
	var is_same_team = (hero.team == player_team)
	
	var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
	hp_bar.tag_name = _data.entity_name
	hp_bar.level = _data.level
	hp_bar.enable_label = true
	hp_bar.color = Color.green if is_player else (Color.blue if is_same_team else Color.red)
	hp_bar.attach_to = hero.get_path()
	hp_bar.pos_offset = Vector3(0,3,0)
	add_child(hp_bar)
	hp_bar.update_bar(hero.hp, hero.max_hp)
	
	hero.connect("take_damage", self, "on_unit_take_damage",[hp_bar])
	hero.connect("dead", self, "on_hero_dead",[hp_bar])
	hero.connect("reset", self, "on_hero_reset",[hp_bar])
	
	if is_player:
		player_hero = hero
		player_hero_spawn_pos = hero.translation

################################################################
# airship spawner
func spawn_airships(_datas :Array, _parent :Node = _airship_parent):
	var _datas_dicts :Array = []
	for i in _datas:
		_datas_dicts.append(i.to_dictionary())
		
	rpc("_spawn_airships", _datas_dicts, _parent.get_path())

remotesync func _spawn_airships(_datas :Array, _parent_path :NodePath):
	for data in _datas:
		_spawn_airship(data, _parent_path)

func spawn_airship(_data :AirshipData, _parent :Node = self):
	rpc("_spawn_airship", _data.to_dictionary(), _parent.get_path())

remotesync func _spawn_airship(_data :Dictionary, _parent_path :NodePath):
	var _airship_data :AirshipData = AirshipData.new()
	_airship_data.from_dictionary(_data)
	
	var _parent = get_node_or_null(_parent_path)
	if not is_instance_valid(_parent):
		return
		
	var airship :AirShip = _airship_data.spawn_airship(_parent)
	on_airship_spawned(_airship_data, airship)
	
func on_airship_spawned(data :AirshipData, airship :AirShip):
	var is_player = (data.node_name == "player_%s" % NetworkLobbyManager.get_id())
	var is_same_team = (airship.team == player_team)
	var is_master = (NetworkLobbyManager.get_id() == data.network_id)
	
	var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
	hp_bar.tag_name = data.entity_name
	hp_bar.level = data.level
	hp_bar.enable_label = true
	hp_bar.color = Color.green if is_player else (Color.blue if is_same_team else Color.red)
	hp_bar.attach_to = airship.get_path()
	hp_bar.pos_offset = Vector3(0,3,0)
	add_child(hp_bar)
	hp_bar.update_bar(airship.hp, airship.max_hp)
	
	var marker :ScreenMarker = preload("res://addons/3d-marker/3d_marker.tscn").instance()
	marker.camera = _camera.get_camera().get_path()
	marker.icon = preload("res://assets/ui/icons/airship.png")
	marker.color = Color.blue if is_same_team else Color.red
	airship.add_child(marker)
	
	airship.connect("take_damage", self, "on_unit_take_damage",[hp_bar])
	airship.connect("dead", self, "on_airship_dead",[hp_bar, marker])
	airship.connect("reset", self, "on_unit_reset",[hp_bar, marker])
	
	if is_master:
		var bot :Bot = preload("res://assets/bot/bot.tscn").instance()
		bot.team = data.team
		bot.unit = airship.get_path()
		airship.add_child(bot)
		
		if is_player:
			player_airship_bot = bot
			player_airship_bot.autochase = false
			
		else:
			airship.is_bot = true
			on_bot_spawned(bot)
		
		
	if is_player:
		player_airship = airship
		
		player_airship.connect("take_damage", self, "on_player_airship_take_damage")
		player_airship.connect("dead", self, "on_player_airship_dead")
		player_airship.connect("reset", self, "on_player_airship_reset")
		
		_ui.airship_info.display_info(data.entity_name, data.entity_icon, data.color_coat)
		_ui.airship_info.display_turrets(data, airship, data.color_coat)
		
		landing_zone_validator = preload("res://assets/utils/landing_zone_validator/landing_zone_validator.tscn").instance()
		landing_zone_validator.enable = true
		landing_zone_validator.follow_body = player_airship.get_path()
		add_child(landing_zone_validator)

################################################################
# emplacement spawner
func spawn_emplacements(_datas :Array, _parent :Node = _defence_parent):
	var _datas_dicts :Array = []
	for i in _datas:
		_datas_dicts.append(i.to_dictionary())
		
	rpc("_spawn_emplacements", _datas_dicts, _parent.get_path())

remotesync func _spawn_emplacements(_datas :Array, _parent_path :NodePath):
	for data in _datas:
		_spawn_emplacement(data, _parent_path)

func spawn_emplacement(_data :EmplacementData, _parent :Node = self):
	rpc("_spawn_emplacement", _data.to_dictionary(), _parent.get_path())

remotesync func _spawn_emplacement(_data :Dictionary, _parent_path :NodePath):
	var _emplacement_data :EmplacementData = EmplacementData.new()
	_emplacement_data.from_dictionary(_data)
	
	var _parent = get_node_or_null(_parent_path)
	if not is_instance_valid(_parent):
		return
		
	var emplacement :Emplacement = _emplacement_data.spawn_emplacement(_parent)
	on_emplacement_spawned(_emplacement_data, emplacement)
	
func on_emplacement_spawned(data :EmplacementData, emplacement :Emplacement):
	var is_same_team = (emplacement.team == player_team)
	var is_master = (NetworkLobbyManager.get_id() == data.network_id)
	
	var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
	hp_bar.tag_name = data.entity_name
	hp_bar.level = data.level
	hp_bar.enable_label = true
	hp_bar.color = Color.blue if is_same_team else Color.red
	hp_bar.attach_to = emplacement.get_path()
	hp_bar.pos_offset = Vector3(0,3,0)
	add_child(hp_bar)
	hp_bar.update_bar(emplacement.hp, emplacement.max_hp)

	var marker :ScreenMarker = preload("res://addons/3d-marker/3d_marker.tscn").instance()
	marker.camera = _camera.get_camera().get_path()
	marker.icon = preload("res://assets/ui/icons/castle.png")
	marker.color = Color.blue if is_same_team else Color.red
	emplacement.add_child(marker)
	
	emplacement.connect("take_damage", self, "on_unit_take_damage",[hp_bar])
	emplacement.connect("dead", self, "on_emplacement_dead",[hp_bar, marker])
	emplacement.connect("reset", self, "on_unit_reset",[hp_bar, marker])
	
	if is_master:
		var bot :Bot = preload("res://assets/bot/bot.tscn").instance()
		bot.team = data.team
		bot.unit = emplacement.get_path()
		emplacement.add_child(bot)
		on_bot_spawned(bot)
		
func on_bot_spawned(_bot :Bot):
	pass
	
################################################################
# unit signals handler
func on_unit_take_damage(_unit :BaseUnit, _damage :int, hp_bar :HpBar3D):
	hp_bar.update_bar(_unit.hp, _unit.max_hp)
	
func on_hero_dead(_unit :Hero, hp_bar :HpBar3D):
	hp_bar.update_bar(0, _unit.max_hp)
	hp_bar.visible = false
	
func on_hero_reset(unit :Hero, hp_bar :HpBar3D):
	hp_bar.update_bar(unit.hp, unit.max_hp)
	hp_bar.visible = true
	unit.move_direction = Vector3.FORWARD
	
func on_airship_dead(_unit :AirShip, hp_bar :HpBar3D, marker :ScreenMarker):
	hp_bar.update_bar(0, _unit.max_hp)
	hp_bar.visible = false
	marker.visible = false
	
func on_emplacement_dead(_unit :Emplacement, hp_bar :HpBar3D, marker :ScreenMarker):
	hp_bar.update_bar(0, _unit.max_hp)
	hp_bar.visible = false
	marker.visible = false
	
func on_unit_reset(_unit :BaseUnit, hp_bar :HpBar3D, marker :ScreenMarker):
	hp_bar.update_bar(_unit.hp, _unit.max_hp)
	hp_bar.visible = true
	marker.visible = true
	
# player signals handler
func on_player_airship_take_damage(unit :BaseUnit, _damage :int):
	if unit.hp < unit.max_hp * 0.15:
		_ui.show_hurting()
		return
		
	_ui.show_hurt()
	
func on_player_airship_dead(_unit :AirShip):
	_ui.hide_hurt()
	
func on_player_airship_reset(_unit :AirShip):
	_ui.hide_hurt()
	
################################################################
# airships bot
func enable_airship_bot(_bot :Bot, _val :bool):
	if not is_instance_valid(_bot):
		return
		
	_bot.get_unit().is_bot = _val
	airship_bot_updated(_bot)
	
func airship_bot_updated(_bot :Bot):
	pass
	
################################################################
# heroes
func enable_hero(_hero :Hero, _val :bool, _position :Vector3):
	rpc("_enable_hero", _hero.get_path(), _val, _position)
	
remotesync func _enable_hero(_hero_path :NodePath, _val :bool, _position :Vector3):
	var _unit :Hero = get_node_or_null(_hero_path)
	if not is_instance_valid(_unit):
		return
		
	_unit.enable_network = _val
	_unit.visible = _val
	
	var _is_master = _unit.is_master()
	
	if _val and _is_master:
		_unit.move_direction = Vector3.FORWARD
		
	if not _is_master:
		yield(get_tree().create_timer(1),"timeout")
		
	_unit.translation = _position
	
	hero_updated(_unit)
	
func hero_updated(_hero :Hero):
	pass
	
################################################################
# proccess
func _process(_delta):
	check_valid_landing_zone()
	player_input_airship_control()
	player_input_hero_control()
	
func player_input_airship_control():
	if not is_instance_valid(player_airship_bot):
		return
		
	if not is_instance_valid(player_airship):
		return
		
	player_airship.assign_turret_target(player_airship_bot.get_node_path_targets())
	
	# player control
	# airship
	if not player_airship.is_bot:
		player_airship.move_direction = _ui.get_joystick_direction()
		_camera.translation = player_airship.translation
		_camera.set_distance(player_airship.throttle * player_airship.speed)
	
func player_input_hero_control():
	if not is_instance_valid(player_airship_bot):
		return
		
	if not is_instance_valid(player_hero):
		return
		
	# player control
	# hero
	if player_airship.is_bot:
		player_hero.move_direction = _ui.get_joystick_direction()
		var post_to_follow :Vector3 = player_hero.translation * Vector3(1, 0, 1)
		post_to_follow += Vector3(0, player_airship.translation.y, 0)
		
		player_airship_bot.move_to(post_to_follow, 10, true)
		
		if player_airship.translation.distance_to(post_to_follow) > 15:
			_camera.translation = player_hero.translation
			_camera.set_distance(10)
			
		else:
			_camera.translation = get_avg_position([player_hero.translation, player_airship.translation], 15)
			_camera.set_distance(12)
		
func check_valid_landing_zone():
	if not is_instance_valid(landing_zone_validator):
		return
		
	if not is_instance_valid(player_airship):
		return
		
	if not is_instance_valid(player_hero):
		return
		
	_ui.show_exit_button(
		landing_zone_validator.is_valid and not player_airship.is_dead and not player_hero.is_dead
	)
	
################################################################
# exit
func on_exit_game_session():
	Network.disconnect_from_server()
	
func to_main_menu():
	get_tree().change_scene("res://menu/main_menu/main_menu.tscn")
	
################################################################
# utils code
func get_players_positions(players :Array) -> Array:
	var pos :Array = []
	for player in players:
		if player is BaseUnit:
			pos.append(player.global_transform.origin)
			
	return pos
	
func get_avg_position(list_pos :Array, y :float = 0) -> Vector3:
	var pos :Vector3 = Vector3.ZERO
	var pos_len = list_pos.size()
	for i in list_pos:
		pos += i
		
	pos = pos / pos_len
	pos.y = y
	return pos
	
func get_closes(bodies :Array, from :Vector3) -> BaseUnit:
	if bodies.empty():
		return null
		
	var default :BaseUnit = bodies[0]
	for i in bodies:
		var dis_1 = from.distance_squared_to(default.global_transform.origin)
		var dis_2 = from.distance_squared_to(i.global_transform.origin)
		
		if dis_2 < dis_1:
			default = i
		
	return default
	
################################################################
# network utils code
func is_server():
	if not is_network_on():
		return false
		
	if not get_tree().is_network_server():
		return false
		
	return true
	
func is_network_on() -> bool:
	if not get_tree().network_peer:
		return false
		
	if get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
		
	return true
	
################################################################

