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
	_camera = preload("res://assets/fix_camera/fix_camera.tscn").instance()
	add_child(_camera)
	
################################################################
# map
var _map :Map

func setup_map():
	_map = preload("res://map/map.tscn").instance()
	_map.connect("on_map_ready", self, "on_map_ready")
	add_child(_map)
	
	if is_server():
		_map.generate_islands()
		NetworkLobbyManager.argument["map_data"] = _map.map_data
		NetworkLobbyManager.set_host_ready()
	
func on_map_ready():
	pass
	
func _generate_island():
	_map.map_data = NetworkLobbyManager.argument["map_data"]
	_map.spawn_islands()
	
################################################################
# ui
var _ui :UiMp

func setup_ui():
	_ui = preload("res://gameplay/mp/ui/ui.tscn").instance()
	add_child(_ui)
	
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
var _airship_parent :Node
var _defence_parent :Node

func setup_parents():
	_airship_parent = Node.new()
	_airship_parent.name = "airship_parent"
	add_child(_airship_parent)
	
	_defence_parent = Node.new()
	_defence_parent.name = "defence_parent"
	add_child(_defence_parent)
	
################################################################
# spawner
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
var player_airship :AirShip
var player_airship_bot :Bot

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
		
	var spawns :Array = _airship_data.spawn_airship(_parent)
	on_airship_spawned(_airship_data, spawns[0], spawns[1])
	
func on_airship_spawned(data :AirshipData, airship :AirShip, bot :Bot):
	var is_player = (data.node_name == "player_%s" % NetworkLobbyManager.get_id())
	
	var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
	hp_bar.tag_name = data.entity_name
	hp_bar.level = data.level
	hp_bar.enable_label = true
	hp_bar.color = Color.green if is_player else Color.red
	airship.add_child(hp_bar)
	hp_bar.update_bar(airship.hp, airship.max_hp)
	
	airship.connect("take_damage", self, "on_unit_take_damage",[hp_bar])
	airship.connect("dead", self, "on_airship_dead",[hp_bar])
	airship.connect("reset", self, "on_unit_reset",[hp_bar])
		
	if is_player:
		player_airship = airship
		player_airship_bot = bot
	
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
		
	var spawns :Array = _emplacement_data.spawn_emplacement(_parent)
	on_emplacement_spawned(_emplacement_data, spawns[0], spawns[1])
	
func on_emplacement_spawned(data :EmplacementData, emplacement :Emplacement, _bot :Bot):
	var hp_bar = preload("res://assets/bar-3d/hp_bar_3d.tscn").instance()
	hp_bar.tag_name = data.entity_name
	hp_bar.level = data.level
	hp_bar.enable_label = true
	hp_bar.color = Color.orange
	emplacement.add_child(hp_bar)
	hp_bar.update_bar(emplacement.hp, emplacement.max_hp)
	
	emplacement.connect("take_damage", self, "on_unit_take_damage",[hp_bar])
	emplacement.connect("dead", self, "on_emplacement_dead",[hp_bar])
	emplacement.connect("reset", self, "on_unit_reset",[hp_bar])
	
################################################################
# unit signals handler
func on_unit_take_damage(_unit :BaseUnit, _damage :int, _hp_bar :HpBar3D):
	if _unit == player_airship:
		_ui.show_hurt()
		
	_hp_bar.update_bar(_unit.hp, _unit.max_hp)
	
func on_airship_dead(_unit :AirShip, _hp_bar :HpBar3D):
	_hp_bar.update_bar(0, _unit.max_hp)
	
func on_emplacement_dead(_unit :Emplacement, _hp_bar :HpBar3D):
	_hp_bar.update_bar(0, _unit.max_hp)
	
func on_unit_reset(_unit :BaseUnit, _hp_bar :HpBar3D):
	_hp_bar.update_bar(_unit.hp, _unit.max_hp)
	
################################################################
# proccess
func _process(_delta):
	player_input_airship_control()
	player_input_squad_control()
	
func player_input_airship_control():
	if not is_instance_valid(player_airship_bot):
		return
		
	if player_airship_bot.enable:
		return
		
	if not is_instance_valid(player_airship):
		return
		
	player_airship.move_direction = _ui.get_joystick_direction()
	player_airship.assign_turret_target(player_airship_bot.get_node_path_targets())
	_camera.translation = player_airship.translation
	_camera.set_distance(player_airship.throttle * player_airship.speed)
	
func player_input_squad_control():
	pass
	
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
	
func get_move_direction_with_basis_camera() -> Vector3:
	var move_direction = _ui.get_move_direction()
	var camera_basis = _camera.transform.basis
	return camera_basis.z * move_direction.z + camera_basis.x * move_direction.x
	
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

